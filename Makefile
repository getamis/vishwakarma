modules = $(shell find . -type f -name "*.tf" -exec dirname {} \;|sort -u)
examples = $(shell find ./examples -type f -name "*.tf" -exec dirname {} \;|sort -u)

.PHONY: test

default: test

test:
	@for m in $(examples); do \
		terraform init "$$m" > /dev/null 2>&1; \
		echo "$$m: "; terraform validate "$$m"; \
	done

fmt:
	@for m in $(modules); do (terraform fmt "$$m" && echo "√ $$m"); done