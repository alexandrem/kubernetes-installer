TF_STATE_DIR=generated
TF_STATE=$(TF_STATE_DIR)/terraform.tfstate
WORKSPACE=examples/individual-os-nova
REQUIREMENTS=installer/requirements.txt

$(WORKSPACE)/.terraform:
	cd $(WORKSPACE) && \
	terraform init

venv/bin/activate:
	virtualenv venv -p python3 && \
	source venv/bin/activate && \
	pip3 install -r $(REQUIREMENTS)

.PHONY: init
init: venv/bin/activate $(WORKSPACE)/.terraform

.PHONY: apply
apply: init
	. venv/bin/activate && \
	cd $(WORKSPACE) && \
	terraform apply -auto-approve -state $(TF_STATE)

.PHONY: plan
plan: init
	. venv/bin/activate && \
	cd $(WORKSPACE) && \
	terraform plan -state $(TF_STATE)

.PHONY: show
show:
	cd $(WORKSPACE)/$(TF_STATE_DIR) && \
	terraform show

.PHONY: destroy
destroy: init
	. venv/bin/activate && \
	cd $(WORKSPACE) && \
	terraform destroy -state $(TF_STATE)

.PHONY: rke-up
rke-up:
	cd $(WORKSPACE)/$(TF_STATE_DIR) && \
	rke up

.PHONY: clean
clean:
	rm -fr venv
	rm -fr $(WORKSPACE)/.terraform