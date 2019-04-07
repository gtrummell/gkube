.PHONY: help
.DEFAULT_GOAL := help

# Self-documenting Makefile based on code written by [François Zaninotto](http://bit.ly/2PYuVj1)

help:
	@echo "Make targets for GKube Linuxserver.io HTPC microk8s Templates:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

lint: ## Lint all YAML files
	@echo "Lint-testing YAML files..."
	@export error_count=0 ; \
	for yaml_file in $(shell find $(pwd) -maxdepth 1 -type f -name "*yml") ; do \
		yamllint $$yaml_file ; \
		export error_count=$$(( $$error_count + $$? )) ; \
	done ; \
	if [ $$error_count -ne 0 ] ; then \
		echo "FAIL: Cumulative error count is $$error_count" ; \
		exit 1 ; \
	else \
		echo "SUCCESS: Cumulative error count is $$error_count" ; \
	fi

ci: lint ## Run all tests
