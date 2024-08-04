.PHONY: 
help:  ## Show this help message
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[$$()% a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
# help:	## Show this help.
# 	@grep -hE '^[A-Za-z0-9_ \-]*?:.*##.*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
# ##@ Utility
# help:  ## Display this help
# 	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Publishing
html:  ## Generate html from markdown files and put them in approproate `_site` path
	bundle exec jekyll serve

tags:  ## Collect all tags from posts and generate a page with all of them in tag/*
	python tag_generator.py

setup:  ## Install needed packages (need to `brew install ruby` and update PATH)
	gem install jekyll
	gem install kramdown
	gem install bundler
# test: ## plain

# $dollar: ## leading dollar

# ##@ Utility
# # PHONY: percent% ## hey
# percent%: ## percent included

# (paren): ## parenthesis

# $(both): ## both

# space : ## space before colon



