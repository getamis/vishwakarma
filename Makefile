TF_FILES = $(shell find . -type f -name "*.tf" -exec dirname {} \;|sort -u)
TF_EXAMPLES = $(shell find ./examples -type f -name "*.tf" -exec dirname {} \;|sort -u)

export GO111MODULE := on

default: validate

.PHONY: validate
validate:
	@for m in $(TF_EXAMPLES); do terraform init "$$m" > /dev/null 2>&1; echo "$$m: "; terraform validate "$$m"; done

.PHONY: fmt
fmt:
	@for m in $(TF_FILES); do (terraform fmt -diff "$$m" && echo "√ $$m"); done

.PHONY: test-kubernetes-cluster
test-kubernetes-cluster:
	(cd test && go test -timeout 60m -v -run TestKubernetesCluster)