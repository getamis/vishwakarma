SHELL += -eu

export PKCS_KEY := "deploy/secrets/oidc-issuer.pub"
export POD_IDENTITY_SECRET_NAME := pod-identity-webhook
export POD_IDENTITY_SERVICE_NAMESPACE := kube-system

default: init

.PHONY: init
init:
	@rm -rf deploy
	@mkdir -p deploy/kubernetes
	@mkdir -p deploy/secrets
	@touch deploy/secrets/keys.json
	@terraform init
	@terraform apply -auto-approve
	@rm deploy/secrets/keys.json
	@go run ./main.go -key ${PKCS_KEY}  | jq '.keys += [.keys[0]] | .keys[1].kid = ""' > ./deploy/secrets/keys.json
	@terraform apply -auto-approve

.PHONY: deploy
deploy:
	@kubectl apply -f deploy/kubernetes/iam-auth.yaml
	@sleep 5
	@kubectl apply -f deploy/kubernetes/iam-admin.yaml
	@kubectl create secret generic ${POD_IDENTITY_SECRET_NAME} \
    --from-file=./deploy/secrets/tls.crt --from-file=./deploy/secrets/tls.key \
	--dry-run=client -o yaml | kubectl apply -f -
	@kubectl apply -f deploy/kubernetes/irsa.yaml
	@until kubectl get csr -o \
	jsonpath='{.items[?(@.spec.username=="system:serviceaccount:kube-system:pod-identity-webhook")].metadata.name}' | \
	grep -m 1 "csr-"; \
	do echo "Waiting for CSR to be created" && sleep 1 ; \
	done;
	@kubectl certificate approve $$(kubectl get csr -o jsonpath='{.items[?(@.spec.username=="system:serviceaccount:kube-system:pod-identity-webhook")].metadata.name}')

.PHONY: clean-k8s
clean-k8s:
	@kubectl get csr -o jsonpath='{.items[?(@.spec.username=="system:serviceaccount:kube-system:pod-identity-webhook")].metadata.name}' | xargs kubectl delete csr
	@kubectl delete -f deploy/kubernetes/irsa.yaml
	@kubectl delete secrets ${POD_IDENTITY_SECRET_NAME} --namespace ${POD_IDENTITY_SERVICE_NAMESPACE}
	@kubectl delete -f deploy/kubernetes/iam-admin.yaml
	@kubectl delete -f deploy/kubernetes/iam-auth.yaml

.PHONY: clean-terraform
clean-terraform:
	@terraform destroy -auto-approve
	@rm -rf deploy

.PHONY: clean
clean: clean-k8s clean-terraform
	@echo "Clean all auth related k8s resource"