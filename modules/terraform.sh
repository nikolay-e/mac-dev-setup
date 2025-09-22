#!/bin/bash
# shellcheck shell=bash
# --------------------------------------------------------------------
## Terraform Infrastructure as Code
# --------------------------------------------------------------------

# Basic Terraform commands
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'
alias tfv='terraform validate'
alias tff='terraform fmt -recursive'
alias tfs='terraform show'
tfr() { terraform plan -refresh-only "$@"; }
alias tfo='terraform output'
alias tfws='terraform workspace'

# Enhanced Terraform workflows
tfapply() {
    terraform plan -out=tfplan && terraform apply tfplan
}

tfplan() {
    terraform plan -out=tfplan "$@"
}

tfdestroy-safe() {
    terraform plan -destroy -out=destroy.plan &&
        read -p "Execute destroy plan? (y/N) " -n 1 -r &&
        echo &&
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            terraform apply "destroy.plan"
        fi
}

tfwswitch() {
    terraform workspace select "$1" && terraform plan -var-file="workspaces/$1.tfvars"
}

tfdocs() {
    local output_file="${1:-terraform-docs.md}"
    terraform-docs markdown table . >"$output_file"
    echo "Documentation generated in $output_file"
}

# Version management with tenv
alias tfuse='tenv use terraform'
alias tflist='tenv list terraform'
alias tfinstall='tenv install terraform'

# Terragrunt aliases
alias tg='terragrunt'
alias tgi='terragrunt init'
alias tgp='terragrunt plan'
alias tga='terragrunt apply'
alias tgd='terragrunt destroy'
alias tgv='terragrunt validate'
alias tgf='terragrunt hclfmt'
alias tgr='terragrunt refresh'
alias tgo='terragrunt output'
alias tgaa='terragrunt run-all apply'
alias tgap='terragrunt run-all plan'
alias tgad='terragrunt run-all destroy'

# Terragrunt workflows
tgapply() {
    terragrunt plan -out=tgplan && terragrunt apply tgplan
}

tgplan() {
    terragrunt plan -out=tgplan "$@"
}

# Terragrunt version management
alias tguse='tenv use terragrunt'
alias tglist='tenv list terragrunt'
alias tginstall='tenv install terragrunt'
