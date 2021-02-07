---
layout: post
title: "Uploading to AWS S3 Bucket from Python file"
subtitle: "First step to saving results from webapp"
date: 2021-02-07 12:09:42PM EST
background: '/img/posts/joel-muniz-8xQJ5LUvBwA-unsplash.jpg'
markdown:           kramdown
category: tech
tags: tech, web app, bucket, s3, aws 
description: Upload to an AWS S3 bucket with a python function.
---

  <a class="top-link hide" href="" id="js-top">
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 12 6"><path d="M12 6H0l6-6z"/></svg>
      <span class="screen-reader-text">Back to top</span>
      </a>

\[ Photo by [Joel Muniz on Unsplash](https://unsplash.com/@jmuniz) \]
{: style="color:gray; font-size: 80%; text-align: center;"}

<!--
<script src="https://gist.github.com/franktcao/0683211eaf86f419dc8ea2f0eb85960c.js"></script>
-->

# Intro
# Create AWS account
To upload to an AWS S3 bucket, you'll need to sign up for an AWS account! Get one here:
https://aws.amazon.com/

# Setup
## Credentials
In order to know if an upload is coming from a legitimate source, credentials need 
to be set up. Let's start by creating, getting, and setting your AWS credentials.

### Create and Get Access Keys
Sign into your AWS and go to your account's `Security Credentials` (in the top right 
taskbar, `My Acccount` -> `Security Credentials`).

Click `Access keys (access key ID and secret access key)` to expand that section.

Click the blue `Create New Access Key` button. Your key ID and secret have been 
generated. Download it and save it to somewhere secure; keep for your records.

### Set Access Keys
There are several ways `boto3` but the most secure ways to do so are to store your 
credentials as environment variables or to add them to your config file (you can 
read all of it in the 
[docs](https://boto3.amazonaws.com/v1/documentation/api/latest/guide/credentials.html). 
I find the most straightforward way is to store thm in a config file.

#### Add credentials to config file
If it doesn't exist already, create a config file named `~/.aws/config` and add your 
credentials there:
```bash
[default]
aws_access_key_id=YOUR_ACCESS_KEY_ID
aws_secret_access_key=YOUR_SECRET_ACCESS_KEY
```
These credentials will be used by default for any `boto3` and/or AWS CLI calls. If 
you have different credentials for different profiles, you can add them to the same 
config file but just a different section names (e.g. `[default]` -> `[profile dev]`. 
Note, `profile` is required in there. Consult the docs for more information).

## Requirements
First, you'll need to add these to your `requirements.txt` (As always, I suggest 
working in a 
[virtual environment](https://franktcao.github.io/tech/2020/07/27/setting_up.html)):
```
awscli==1.19.3
boto3==1.17.3
botocore==1.20.3
```
Note, the pinned versions, likely to be outdated by the time you read this, are just 
to show a current working combination of requirements (of course, you can leave 
these unpinned if you so choose).

# Python Function
The function is pretty straightforward and documented well. The following snippet 
is from the [`Boto3` docs](https://boto3.amazonaws.com/v1/documentation/api/latest/guide/s3-uploading-files.html)
and renamed to distinguish from possibly uploading to other services:

```python
import boto3
import logging
from botocore.exceptions import ClientError
from typing import Optional


def upload_to_s3(
    file_name: str,
    bucket: str,
    object_name: Optional[str] = None
) -> bool:
    """Upload a file to an S3 bucket.

    :param file_name: File to upload
    :param bucket: Bucket to upload to
    :param object_name: S3 object name. If not specified then file_name is used
    :return: True if file was uploaded, else False
    """

    # If S3 object_name was not specified, use file_name
    if object_name is None:
        object_name = file_name

    # Upload the file
    s3_client = boto3.client("s3")
    try:
        s3_client.upload_file(file_name, bucket, object_name)
    except ClientError as e:
        logging.error(e)
        return False
    return True
```