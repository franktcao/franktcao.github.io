---
layout: post
title: "Job Scraping"
subtitle: "Why scrape the bottom of the barrel for a job when you can scrape the web for one!"
date: 2019-08-29 12:44:41
background: '/img/emile-perron-xrVDYZRGdw4-unsplash.jpg'
markdown:           kramdown
tags: data-science machine-learning web-scraping tutorial
description: Using `BeautifulSoup` and `requests` to extract job postings from indeed.com
photo-cred: Émile Perron 
photo-cred-link: https://unsplash.com/@emilep
---

  <a class="top-link hide" href="" id="js-top">
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 12 6"><path d="M12 6H0l6-6z"/></svg>
      <span class="screen-reader-text">Back to top</span>
      </a>

<!--
<script src="https://gist.github.com/franktcao/0683211eaf86f419dc8ea2f0eb85960c.js"></script>
-->

This job search has been a bit more difficult than originally anticipated. There is a large overlap between what is done in physics and what is done in data science. Unfortunately,
the vocabulary is not quite compatible. So I decided that the best way to showcase my abilities (while keeping them in practice) 
is to scrape job postings to see what is desired in industry. 

In this tutorial, we will begin to scrape `indeed.com` to compile a list of sought-after keywords that the current market is looking for. The overarching goal of this is to -- other than finding a rewarding career that I absolutely love --  do statistical analysis on the vocabulary built out of what's done here. We will start by using  `BeautifulSoup` to parse the search results, load them into `pandas`dataframes and saving them to `.csv` or `.json` files to process in the next tutorial.

**Note:** Not all websites are so welcoming to having their data scraped. Sites like glassdoor, linkedin, facebook, and many others that have personal user information are particularly vigilant when it comes to crawlig/scraping. You can check to see which parts are dis/allowed by adding '/robots.txt' to the main URL (e.g. www.linkedin.com/robots.txt).

**Note:** The scraper depends on indeed's website structure which you can parse through by right-clicking anywhere on the website and selecting Inspect (on Chrome, at least). So full discretion, this will *not* be the most stable way to get job postings from indeed. There is likely a more stable indeed API but I think this is a good exercise in web-scraping which is another important way to gather data. More so, many places will not provide an API to work with.


Let's get started...

----

## Contents
{:.no_toc}

- TOC
{:toc}

----

# 1. Setting Up
<!--/*
You can find the notebook to follow along with the [notebook](https://www.github.com/franktcao/job_scraping/scrape_indeed.ipynb) or you can just go directly to the [full repository](https://www.github.com/franktcao/job_scraping/). First you will need to make sure you have the required modules. 
*/ -->
You can follow along 
* with this [<u>interactive in-browser notebook</u>](https://colab.research.google.com/github/franktcao/job_scraping/blob/master/scrape_indeed.ipynb){:target="\_blank"} <sup>\*</sup>,
* by downloading the [<u>source</u>](https://github.com/franktcao/job_scraping/blob/master/scrape_indeed.ipynb){:target="\_blank"} to work on it locally, or 
* by going directly to the [<u>full repository</u>](https://www.github.com/franktcao/job_scraping/){:target="\_blank"}. 

<sup>\*</sup>The interactive notebook requires a google account to save a copy and run on their servers. 

## Setting Up for Success

```python
import sys
import time
import pandas as pd
import requests
from bs4 import BeautifulSoup
```

Below are the modules and why we use them:
* `sys`: Not really important, just a way to print out a progress bar.
* `time`: We use this to really get the date so that we have a time stamp on each file we create. This way, if things break in the future, we still have a working example to apply the next stages.
* `pandas`: If we're going to be working with a fairly large table of data (memory-limited so if things were much heavier, we'd be querying from a database or some data distribution center), `pandas` is currently my favorite way to work with it.  
* `requests`: This module pulls a webpage in a format to be used to feed ino `BeautifulSoup` (from a URL string with the `get()` method).
* `bs4`, `BeautifulSoup`: The meat and potatoes that takes the output `requests.get()` and allows you to parse through it with its built-in methods.

Alright, let's put the tools to work.


# 2. Utilizing `BeautifulSoup`
Now that we have our job query going, we want to pull job postings and fill out a table row-by-row with each posting.
So let's see how we can use `BeautifulSoup` to do that. First let's acknowledge what tools will be using i.e., import the required modules. 


## a. Understanding the URL
### 1. Inspecting Indeed's Website
Let's just go ahead and perform a search on [indeed](https://www.indeed.com) for a data scientist position with a minimum annual salary of, let's say, $20,000 in Boston.

[![Hey, look at you searching](/img/job_scraping/ss_indeed.png){:width="100%"}]( /img/job_scraping/ss_indeed.png)

Note the address bar after you submit the search. It should look something, if not exactly, like this:

` https://www.indeed.com/jobs?q=data+scientist+%2420%2C000&l=Boston%2C+MA `

Let's break down what and why it looks like this. Our request was to look up job postings for 'data scientist' with '$20,000' salary in Boston, MA. Everything after the `jobs?q=` reflects just that. 
* `data+scientist` is pretty straightforward. 
* The next piece, `%24`, is the URL escape code for the dollar sign ($). 
* Following that is `20` and then the escape URL code for the comma `%2C` (,). 
* Finally, we see `&l=` and `Boston, MA` afer it. This indicates an additional requirement for the query to look for job postings where the *location variable*, `&l=`, is Boston, Massachusetts.

Knowing this structure allows us to know how to navigate the page without having to be on it and clicking through a series of intermediate steps. Also, this will become important later in this tutorial!

Maybe it's overkill, but I like to break down each component of the URL in separate variables.

<!--URL_page_start = '&start=' + str(page_number)-->
<!--URL_base = 'https://www.indeed.com/jobs?q=data+scientist+%2420%2C000'-->

### 2. Setting Variables

```python
city = 'boston'
job = 'data+scientist'
min_sal = '%2420%2C000'

URL_base = 'https://www.indeed.com/jobs?q=' + job + '+' + min_sal
URL_location = '&l=' + city

URL = URL_base + URL_location 
```

With this URL, let's grab the results page and feed it into `BeautifulSoup`.

### 3. Packaging Webpage

First, we use `requests` to get the results page. Then we make a `BeautifulSoup` class out of the webpage request.

```python
page = requests.get(URL)
soup = BeautifulSoup(page.text, 'lxml')
```

The webpage is now in a nice class with useful methods that we can use to parse through and extract exactly what we want.

## b. Get Entries/Postings

But how does it work? First, we need to know what we want so we can pinpoint what we need from `BeautifulSoup`. 
We're going to want to eventually loop over the job postings so let's identify what that is and see how `BeautifulSoup` can help.
Again, let's inspect our results.

What will be really helpful is Chrome's cursor tool on the top left (highlighted in blue in the image, left of 'Elements' and the mobile view).

[![Wow, you've already found the Easter Egg. Was it too easy?](/img/job_scraping/ss_cursor.png){:width="50%"}]( /img/job_scraping/ss_cursor.png)
{: style="text-align: center"}

When you activate this tool, whatever element you hover over on the page, you'll see the corresponding HTML that produced it. 
Taking a look, we see that when hovering over a single posting (highlighted in green and blue below), the corresponding `div` is highlighted on the right hand side 
(Yes, it sure does look like an ad but it's not -- it's a screenshot. Dammit Google!):

[![Whroa](/img/job_scraping/ss_entry.png){:width="100%"}]( /img/job_scraping/ss_entry.png)
{: style="text-align: center"}

And there's a lot here. There're a lot of different terms under `class`, there's an `id`, there's different `data-` attributes, etc. 
As you go through the different postings, you'll see a couple different things common between all of them. 
The `class='row'` encompassed and best described the post.

So, using `BeautifulSoup`, we can get all of the entries on a single webpage via defining a method:

```python
def get_entries(soup):
    #     entries = soup.find_all(name='div', attrs={'class':'row'}) # This way we can have a certain criteria
    entries = soup.find_all(name='div', class_='row') # This looks cleaner
    return entries

entries = get_entries(soup)
```

The first line in `get_entries()` is commented out but it's another way to get the entries. It uses a dictionary of attributes to select exactly what you want, with multiple criteria. 
Instead, we use a -- what I personally prefer and find simpler/cleaner -- version where you explicitly state the common variables to extract what you want.

This returns a list of entries. At this current time, there are 18 job posting/results for a given page with pagination/links for next few pages of other postings.

## c. Reading Through a Single Posting

For a given posting, what do we want? 
What immediately comes to mind is the company name, location, salary range, and a description/summary.

Look through a single job posting. There are lot of different attributes. Some obvious, some not. To start off, within the job post, there is a `class` with value `"title"`. 
This is the official job title that the company is seeking. Here are the common ones:


|---
| Class           | Description       
|-                |-                 
| `title`         | Job Title       
| `sjcl`          | Company Info    
| `location`      | Office Location 
| `salarySnippet` | Salary Range    
| `summary`       | Job Summary     
{: align="center"}

Some things to note are that the data is not pristine: The format can change from one job posting to another (`sjcl`, `location`, ...) -- sometimes the values aren't even there (`salarySnippet`, `location`, ...)!


## d. Entry Example
### 1. Getting Job Location
Let's go through and see how we'd use `BeautifulSoup` to get one of these values. A more complicated one that comes to mind is the job location.
For one, it's embedded in the company info. Also, the formatting varies from posting to posting. 

The class enclosing the location is the `sjcl`. We can get this class from an entry by using the `BeautifulSoup` element's `find()` method. 
Within an entry, we look for the class `'sjcl'` to pull the company info. Within that, we look for the location by `find()`ing the class `'location'`.

```python
def get_location_info(entry):
    company_info = entry.find(class_='sjcl')
    location_info = company_info.find(class_='location')

    location = location_info.text.strip()
    ...
```

Loaded into the `location` variable is everything within the HTML tags with `class="sjcl"` and also within `class="location"`.
The last line above extracts the text, not including any of the HTML, CSS, etc from the `text` member. Then we additionally use python's `string` method `strip` to get rid of excess spaces.

Sometimes, the neighborhood is included. Within the `'location'`, the neighborhood, when there, is found within the `'span'` attribute.

```python
def get_neighborhood(location_info):
    neighborhood_info = location_info.find(name='span')
    neighborhood = ' '
    if neighborhood_info:
        neighborhood = neighborhood_info.text
    return neighborhood
```

Finishing our `get_location_info()` method, we can extract the location along with the neighborhood.
Let's look at an example where this is applicable.

[![What time is it?](/img/job_scraping/ss_neighborhood.png){:width="50%"}]( /img/job_scraping/ss_neighborhood.png)
{: style="text-align: center"}

We see on the third line of this screenshot is the location information with the neighborhood in parentheses. 
We'd like to keep the location and neighborhood as separate variables. So we redefine the location with the neighborhood stripped.

```python
def get_location_info(entry):
    ...
    # Extract neightborhood info if it's there
    neighborhood = get_neighborhood(location_info)
    location = location.rstrip(neighborhood)
    neighborhood = neighborhood.strip('()')
    return location, neighborhood

test_job_entry = entries[0]
location, neighborhood = get_location_info(test_job_entry)
```

### 2. Getting the Job Description 

The job summary is nice but it's often cut much too short: there is some word or character limit. Some descriptions don't get to the substantial part until 
a bit later so the summary is inadequate. Getting the full job description is much trickier.

Getting the summary is simply:

``` python
def get_job_summary(entry):
    return entry.find(class_='summary').text.strip()
```

But we can go beyond that!

To get the full job description, we have to click on the job posting to go to the page of the actual posting. 

Now, note the link. It may be a nasty thing.

`https://www.indeed.com/viewjob?jk=466c648cf7a22a50&tk=1dkuk8nat0gc8000&from=serp&vjs=3&advn=6613095622180756&adid=77005642&sjdu=teYnAu8OgCGxABCwWD3OBGSvNPsXXaEnWLrUq8268_Q7hC0YDHACZYjlfAZ2VvRY5EESrqlz1VwWF8YSqa7ebseSPxZCuEl0hMQipV1VPT6vIRhbN2jzOprwFHzzg5eqCVENzzZ9i-4GTmNHGSUnm5ZkpfgPbmXOGU2P7n50pq-C5LGpOJGmAL5Loqy_5pM1WIA2dUwXdF02ymLel9jAy22GfZafOde6nrdo-YH9JMgK4xylf_Z_R6MGkuLZCpCX`

How are we going to work with this beastly thing and do it so in an automated way? Well, from our experience earlier, we saw that there's a lot of information in the URL. 
Maybe we don't know what all of the tokens mean but we *do* know that the variables are separated by `&var=`, where `var` is some variable. What's more, if you've been observant
when looking through the individual job posting from our results page, you'll see that the value from the attribute name `data-jk` is a unique id that also appears in the URL! 
And where does it show up? It shows up after `viewjob?` and subsequently after the URL variable `jk=`.

Try getting rid of everything except that. What you're left with is this:

`https://www.indeed.com/viewjob?jk=466c648cf7a22a50`

and gets you to the same page. I assume the rest of the URL is for tracking and statistics purposes to understand what was the most effective way to bring you to the job posting.

Using this information along with knowing how to extract text from a webpage, we can add in functionality to go beyond the job summary and extract the job description.

First, we get the unique id or link.

```python
def get_link(entry):
    link = entry['data-jk']
    return link 

URL_job_desc = 'https://www.indeed.com/viewjob?jk=' + get_link(test_job_entry)
```

Now we can use what we've done before to navigate to that page and pull the data that we want. Again, navigate to the page and inspect it.

[![Here's another one](/img/job_scraping/ss_job-description.png){:width="100%"}]( /img/job_scraping/ss_job-description.png)

If we have the unique link, we can navigate straight to the page using `request.get()` again. This time, let's include a pause with `time.sleep()` so that we do not 
trigger any response due to "suspicious" web traffic. 

From my experience, the job description page is particularly messy. This is probably due to recruiters using
-- likely -- internal job postings with a certain format. Regardless, we can pull the text, touch it up now, and worry about the rest during the data cleaning stage. 
Just scanning a few examples, we see that many of the C escape sequences like `\n` and `\t` -- a clear sign of copying and pasting the posting from different sources.

```python
def get_job_description(job_page):
    page = requests.get(job_page)
    time.sleep(1)  # Ensuring at least 1 second between page grabs
    soup = BeautifulSoup(page.text, 'lxml')

    description = soup.find(name='div', class_='jobsearch-jobDescriptionText')

    description = description.text.strip()
    description = description.replace('\n',' ')
    description = description.replace('\t',' ')
    return description

description = get_job_description(URL_job_desc)
```

### 3. Defining All Methods Needed 

I won't go into each of these and feel free to leave a comment if you have any questions to clear anything up. 
I mix it up between using the dictionary way to gather (`attr=`) and using variables directly (`class_=`). 
There are also some methods with `try:` and `except:`. These are used to consider entries where the variable is subject
to change. If it's not there, returning a `None` or a `NaN` can break the entire program.

```python
def get_job_title(entry):
    job_title_container = entry.find(name='a', attrs={'data-tn-element':'jobTitle'})
    job_title = job_title_container.text
    return job_title.strip()

def get_company(entry):
    company_list = []
    try:
        test_entry = entry.find(class_='company')
        company_list.append(test_entry.text.strip()) 
        company = company_list.pop()
    except:
        try:
            test_entry = entry.find(class_='result-link-source')
            company_list.append(test_entry.text.strip()) 
            company = company_list.pop()
        except:
            company = ' '
    return company

def get_location_info(entry):
    company_info = entry.find(class_='sjcl')
    location_info = company_info.find(class_='location')

    location = location_info.text.strip()

    # Extract neightborhood info if it's there
    neighborhood = get_neighborhood(location_info)
    location = location.rstrip(neighborhood)
    neighborhood = neighborhood.strip('()')
    return location, neighborhood


def get_neighborhood(location_info):
    neighborhood_info = location_info.find(name='span')
    neighborhood = ' '
    if neighborhood_info:
        neighborhood = neighborhood_info.text
    return neighborhood

def get_salary(entry):
    salary_list = []
    salary = ''
    try:
        salary_list.append(entry.find('nobr').text.strip())
        salary = salary_list.pop()
    except:
        try:
            salary_container = entry.find(name='div', class_='salarySnippet')
            salary_temp = salary_container.find(name='span', class_='salary')
            salary_list.append(salary_temp.text.strip())
            salary = salary_list.pop()
        except:
            salary = ' '
    return salary

def get_job_summary(entry):
    return entry.find(class_='summary').text.strip()

def get_link(entry):
    link = entry['data-jk']
    return link 

def get_job_description(job_page):
    page = requests.get(job_page)
    time.sleep(1)  # Ensuring at least 1 second between page grabs
    soup = BeautifulSoup(page.text, 'lxml')

    description = soup.find(name='div', class_='jobsearch-jobDescriptionText')

    description = description.text.strip()
    description = description.replace('\n',' ')
    description = description.replace('\t',' ')
    return description
```

Now that we have all the methods we need to grab the relevant information, we can go ahead and make a list to loop through to extract several postings from several cities.





# 3. Putting it All Together (Full Example)
## a. Setting Up
Again, looking at the results page, we see 18 postings per page. Since this is a variable based off indeed, let's name the variable `POSTINGS_PER_PAGE`.
We're looking to loop over cities we're interested in and then loop over pages and loop over postings within the page. 
From there, we'll construct a `pandas` dataframe with the variables that we'll use in our machine learning and analysis stage.

```python
max_pages_per_city = 60
POSTINGS_PER_PAGE = 18 # Indeed's default 18 entries per page
postings_per_city = max_pages_per_city * POSTINGS_PER_PAGE 

columns = ['job_title', 'company_name', 'location', 'neighborhood', 'description', 'salary', 'link']
df = pd.DataFrame(columns = columns) 
```
## b. Looping Over Postings

I'm personally only interested with job postings in and around Boston so I'll only include that in my `city_set` but this can be extended for your own use.

```python
URL_base = 'https://www.indeed.com/jobs?q=data+scientist+%2420%2C000'
# Loop over cities
city_set = ['Boston']
for city_targ in city_set:
    URL_location = '&l=' + city_targ
    # Loop over pages
    for page_number in range(0, postings_per_city, POSTINGS_PER_PAGE):
        URL_page_start = '&start=' + str(page_number)
        URL = URL_base + URL_location + URL_page_start
        page = requests.get(URL)
        time.sleep(1)  # Ensuring at least 1 second between page grabs
        soup = BeautifulSoup(page.text, 'lxml')
                      
        # Loop over posts/entries
        entries = get_entries(soup)
        for i,entry in enumerate(entries): 
            sys.stdout.write('\r' + ' page: ' + str(page_number//POSTINGS_PER_PAGE) 
                                  + ' / ' + str(max_pages_per_city)  
                                  + ', job posting: ' + str(i) + ' / ' + str(len(entries))
            )        
            title = get_job_title(entry)
            company = get_company(entry)
            location, neighborhood = get_location_info(entry)
            salary = get_salary(entry)
            link = get_link(entry)
              
            job_page = 'https://www.indeed.com/viewjob?jk=' + link
            description = get_job_description(job_page)
              
            # Append the new row with data scraped
            i_next = len(df) + 1
            df.loc[i_next] = [title, company, location, neighborhood, description, salary, link]
              
import datetime
date = str(datetime.date.today())
  
# Saving dataframe as local csv file 
df.to_csv(date + '_indeed-ds-postings.csv', encoding='utf-8')
```

At the very end, we save the data in a comma-separated values (CSV) format with the date to be used in the next stages.
The date is important to not overwrite your data on different days but also if there are any changes to indeed's website formatting, 
we still have a working copy to work with for the next stages, with the present scripts.


# 4. Conclusion
There, you have it! To review, we've
  * Used `requests` to pull webpages from its URL
  * Seen how `BeautifulSoup` takes in the output from `requests.get()` and has built-in functions to extract elements of the page
  * Inspected pages to see how to extract the information, once we've figured out what we want
  * Inspected the URL to understand what parts are relevant and what's fluff
  * Got to see some data like the job description being very varied from posting to posting
  * Used `pandas` dataframe to load in data relevant and important to us
  * Saved the dataframe as a more universal CSV format for future stages

What we'll do in the next tutorial is clean and format the data in a more suitable format for our TFIDF, salary regression, and any other future analysis we come up with. 
Please leave a comment and provide from feedback. I know it might be a little too detailed in some areas and not enough in other areas. I can make updates to extend on them
or even answer them personally.

----


Comments!
=====
{: style="text-align: center;"}

<script src="https://kit.fontawesome.com/9d39d89011.js"></script>
<form method="POST" action="https://formspree.io/franktcao@gmail.com">
  <div class="control-group">
    <!--<div class="form-group floating-label-form-group controls">-->
    <div class="form-group">
      <span class="input-group-addon"><i class="fa fa-user fa-fw"></i></span>
      <label>Name*</label>
      <input type="text" name="Name" class="form-control" placeholder="Dave Chappelle" id="name" required data-validation-required-message="First and last name, please.">
      <p class="help-block text-danger"></p>
    </div>
  </div>
  <div class="control-group">
    <div class="form-group">
		<span class="input-group-addon"><i class="fa fa-envelope-o fa-fw"></i></span>
      <label>Email Address*</label>
      <input type="email" name="Email Address" class="form-control" placeholder="user@site.com" id="email" required data-validation-required-message="Please enter your email address.">
      <p class="help-block text-danger"></p>
    </div>
  </div>
  
  <div class="control-group">
    <div class="form-group">
      <label>Comment*</label>
      <textarea rows="5" name="Comment" class="form-control" placeholder="What I think about this post is..." id="message" required data-validation-required-message="Please write a comment."></textarea>
      <p class="help-block text-danger"></p>
    </div>
  </div>
  <br>
  <div id="success"></div>
  <div class="form-group">
    <center>
    <button type="submit" class="btn btn-primary" id="sendMessageButton">Send</button>
    </center>
  </div>
</form>




<!---
|-----------------+------------+-----------------+----------------|
| Default aligned |Left aligned| Center aligned  | Right aligned  |
|-----------------|:-----------|:---------------:|---------------:|
| First body part |Second cell | Third cell      | fourth cell    |
| Second line     |foo         | **strong**      | baz            |
| Third line      |quux        | baz             | bar            |
|-----------------+------------+-----------------+----------------|
| Second body     |            |                 |                |
| 2 line          |            |                 |                |
|=================+============+=================+================|
| Footer row      |            |                 |                |
|-----------------+------------+-----------------+----------------|

---->


$$
\begin{align*}
& \phi(x,y) = \phi \left(\sum_{i=1}^n x_ie_i, \sum_{j=1}^n y_je_j \right)
  = \sum_{i=1}^n \sum_{j=1}^n x_i y_j \phi(e_i, e_j) = \\
    & (x_1, \ldots, x_n) \left( \begin{array}{ccc}
        \phi(e_1, e_1) & \cdots & \phi(e_1, e_n) \\
        \vdots & \ddots & \vdots \\
        \phi(e_n, e_1) & \cdots & \phi(e_n, e_n)
        \end{array} \right)
    \left( \begin{array}{c}
        y_1 \\
        \vdots \\
        y_n
        \end{array} \right)
\end{align*}
$$

<!--
The following is a math block:

$$ 5 + 5 $$

But next comes a paragraph with an inline math statement:

\$$ 5 + 5 $$
| Meaning | 
|:-:            
| The job title 
| The job title 
| The job title 
| The job title 
| The job title 
#myBtn {
  display: none; /* Hidden by default */
  position: fixed; /* Fixed/sticky position */
  bottom: 20px; /* Place the button at the bottom of the page */
  right: 30px; /* Place the button 30px from the right */
  z-index: 99; /* Make sure it does not overlap */
  border: none; /* Remove borders */
  outline: none; /* Remove outline */
  background-color: red; /* Set a background color */
  color: white; /* Text color */
  cursor: pointer; /* Add a mouse pointer on hover */
  padding: 15px; /* Some padding */
  border-radius: 10px; /* Rounded corners */
  font-size: 18px; /* Increase font size */
}

#myBtn:hover {
  background-color: #555; /* Add a dark-grey background on hover */
}
//Get the button:
mybutton = document.getElementById("myBtn");

// When the user scrolls down 20px from the top of the document, show the button
window.onscroll = function() {scrollFunction()};

function scrollFunction() {
    if (document.body.scrollTop > 20 || document.documentElement.scrollTop > 20) {
          mybutton.style.display = "block";
            } else {
                  mybutton.style.display = "none";
                    }
}

// When the user clicks on the button, scroll to the top of the document
function topFunction() {
    document.body.scrollTop = 0; // For Safari
      document.documentElement.scrollTop = 0; // For Chrome, Firefox, IE and Opera
}
 -->
