#!/usr/bin/env python

'''
tag_generator.py
Copyright 2017 Long Qian
Contact: lqian8@jhu.edu
This script creates tags for your Jekyll blog hosted by Github page.
No plugins required.


Altered by Frank Cao on 08/30/19.
  - Changed the front matter so that the title is more readable
'''

import glob
import os
import inspect

post_dir = '_posts/'
tag_dir = 'tag/'

filenames = glob.glob(post_dir + '*md')

total_tags = []
for filename in filenames:
    f = open(filename, 'r', encoding='utf8')
    crawl = False
    for line in f:
        if crawl:
            current_tags = line.strip().split()
            if current_tags[0] == 'tags:':
                total_tags.extend(current_tags[1:])
                crawl = False
                break
        if line.strip() == '---':
            if not crawl:
                crawl = True
            else:
                crawl = False
                break
    f.close()
total_tags = set(total_tags)

old_tags = glob.glob(tag_dir + '*.md')
for tag in old_tags:
    os.remove(tag)
    
if not os.path.exists(tag_dir):
    os.makedirs(tag_dir)

for tag in total_tags:
    tag_filename = tag_dir + tag + '.md'
    f = open(tag_filename, 'a')
    write_str = inspect.cleandoc(
        f"""
        ---
        layout: tagpage
        title: Relevant Posts
        subtitle: Tag = {tag}
        tag:  {tag} 
        robots: noindex
        background: '/img/louie-martinez-J8YmnoMG2hg-unsplash.jpg'
        photo-cred: Louie Martinez
        photo-cred-link: https://unsplash.com/@louie-martinez
        ---
        """
    )
    f.write(write_str)
    f.close()

