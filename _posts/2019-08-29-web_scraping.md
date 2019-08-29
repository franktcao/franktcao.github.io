---
layout: post
title: "Job Scraping"
subtitle: "Why scrape the bottom of the barrel for a job when you can scrape the web for a job!"
date: 2019-08-29 12:44:41
background: '/img/bg-index.jpg'
markdown:           kramdown
---

This job search has been a bit more difficult than originally anticipated. There is a large overlap between what is done in physics and what is done in data science. Unfortunately,
the vocabulary is not quite compatible. So I decided that the best way to showcase my abilities (while keeping them in practice) 
is to scrape job postings to see what is desired in industry. 

In this tutorial, we will begin to scrape `indeed.com` to compile a list of sought-after keywords that the current market is looking for. In the future tutorials, we will do a statistical
analysis of the vocabulary built out of what's done here. We will be using `BeautifulSoup` to parse the search results, loading them into `pandas` dataframes and saving them to `.csv` or `.json` files to process in the next tutorial.

Let's get started...
