modules = $(shell find . -type f -name "*.tf" -exec dirname {} \;|sort -u)
examples = $(shell find ./examples -type f -name "*.tf" -exec dirname {} \;|sort -u)

default: validate

.PHONY: validate
validate:
	@for m in $(examples); do terraform init "$$m" > /dev/null 2>&1; echo "$$m: "; terraform validate "$$m"; done

.PHONY: check-fmt
check-fmt:
	@for m in $(modules); do (terraform fmt -diff -check "$$m" && echo "√ $$m"); done