---
layout: post
title: "Setting Up"
subtitle: "Want to start developing Python on your MacBook?"
date: 2020-07-27 4:34:58PM EST
background: '/img/posts/kevin-ku-w7ZyuGYNpRQ-unsplash.jpg'
markdown:           kramdown
category: tech
tags: tech  
description: Setting up a python dev environment for your MacBook
photo-cred: Kevin Ku
photo-cred-link: https://unsplash.com/@ikukevk
---

  <a class="top-link hide" href="" id="js-top">
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 12 6"><path d="M12 6H0l6-6z"/></svg>
      <span class="screen-reader-text">Back to top</span>
      </a>

<!--
<script src="https://gist.github.com/franktcao/0683211eaf86f419dc8ea2f0eb85960c.js"></script>
-->

# Intro
So you want to develop python projects on your McBook? You'll want:
* `homebrew` to easily install needed packages on your laptop
* a `python` version manager (`pyenv`) to work on different projects requiring
 different versions of `python`
* to set up a clean environment (`venv`), independent of how your system
 is set up, to develop on


# Homebrew

Homebrew is a package manager to
>> install stuff you need that Apple didn't.

Start by getting `homebrew` (see [homebrew website](https://brew.sh/)).

# `pyenv`

`pyenv` is a `python` version manager that allows you to easily switch between
different versions of `python` to develop different projects requiring different
 versions of `python`.
 
```bash
brew install pyenv
```

With Mac OSX, your shell is likely `zsh` so you'd need to also run (update: the correct 
use of `$PYENV_ROOT/shims` is used instead of the previously written `$PYENV_ROOT/bin`)

```bash
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo 'export PATH="$PYENV_ROOT/shims:$PATH"' >> ~/.zshrc
echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ~/.zshrc
```

For more details, see [pyenv's github](https://github.com/pyenv/pyenv#Installation).


## Check to see that it's working

Now that `pyenv` is installed, check to see which `python` your system is pointing to:

```bash
which python  # Default: /usr/local/bin/python
python --version  # Default: Python 2.7.3
```

To check which versions `python` your `python` version manager, `pyenv`,
has installed and which is active locally or globally:

```bash
pyenv versions
pyenv global
pyenv local
```

Install the latest version of `python` (at the moment: `python 3.8.5`) as a shim in
 `pyenv`. 
 
```bash
PYTHON_VERSION=3.8.5
# Install shim
pyenv install $PYTHON_VERSION
# Set default version on your system
pyenv global $PYTHON_VERSION
# Set the version for your project (current working directory)
pyenv local $PYTHON_VERSION
```

Check to make sure your system is pointing to the correct shims:

```zsh
which python  # /Users/YOURUSERNAME/.pyenv/shims/python
python --version  # Python 3.8.5
```

## Setting Up `venv` (Virtual Environment)
With python versions sorted out, you'll want to develop on a "clean" system that is
independent on how you've actually configured your laptop.

The two main options are:
* Virtual Environment
* Docker Image

Here, we'll use a python virtual environment, `venv`. In your project directory
, create and activate your virtual environment with `venv`:

```bash
VENV='.venv'
python -m venv $VENV
. $VENV/bin/activate
```

You'll know it's working if `(.venv)` is added to the beginning your `PS1` prompt.

Now you can add python packages to your project and not worry about different
versions that you've installed on your computer. Just `pip install` to update your
virtual environment since it's activated.

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

Now you're ready to start developing!
