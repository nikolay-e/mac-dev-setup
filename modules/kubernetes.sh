#!/bin/bash
# shellcheck shell=bash
# --------------------------------------------------------------------
## Kubernetes Container Orchestration
# --------------------------------------------------------------------

# Basic kubectl commands
alias k='kubectl'
alias kg='kubectl get'

# Get commands
alias kgp='kubectl get pods'
alias kgpo='kubectl get pods -o wide'
alias kgpw='kubectl get pods --watch'
alias kgs='kubectl get services'
alias kgso='kubectl get services -o wide'
alias kgd='kubectl get deployments'
alias kgdo='kubectl get deployments -o wide'
alias kgn='kubectl get nodes'
alias kgno='kubectl get nodes -o wide'
alias kgns='kubectl get namespaces'
alias kgcm='kubectl get configmaps'
alias kgsec='kubectl get secrets'
alias kgall='kubectl get all'

# Describe commands
alias kdp='kubectl describe pod'
alias kds='kubectl describe service'
alias kdd='kubectl describe deployment'
alias kdn='kubectl describe node'

# Logs and exec
alias kl='kubectl logs'
alias klf='kubectl logs -f'
alias klt='kubectl logs --tail=100'
alias klft='kubectl logs -f --tail=100'
alias kexec='kubectl exec -it'

# Apply and delete
alias kapp='kubectl apply -f'
alias kdel='kubectl delete'
alias kdelp='kubectl delete pod'
alias kdels='kubectl delete service'
alias kdeld='kubectl delete deployment'

# Port forwarding and proxy
alias kpf='kubectl port-forward'
alias kproxy='kubectl proxy'

# Context and namespace management
alias kctx='kubectx'
alias kns='kubens'
alias kgc='kubectl config get-contexts'
alias kcc='kubectl config current-context'

# Debugging utilities
kdebug() {
    kubectl run "debug-$(date +%s)" --rm -i --tty --image=nicolaka/netshoot -- sh
}

kdebug-simple() {
    kubectl run "debug-$(date +%s)" --rm -i --tty --image=busybox -- sh
}

kclean() {
    local pods
    pods="$(kubectl get pods --field-selector=status.phase=Succeeded -o name)"
    [ -n "$pods" ] && printf "%s\n" "$pods" | xargs kubectl delete
}

# Resource analysis
ktop-cpu() {
    kubectl top pod --all-namespaces --sort-by=cpu
}

ktop-mem() {
    kubectl top pod --all-namespaces --sort-by=memory
}

# Advanced debugging (requires kubectl plugins)
ktree() {
    command -v kubectl-tree >/dev/null 2>&1 || { echo "kubectl-tree plugin not installed (install: kubectl krew install tree)" >&2; return 1; }
    kubectl tree "${1:-deployment}" "${2}"
}

kneat() {
    command -v kubectl-neat >/dev/null 2>&1 || { echo "kubectl-neat plugin not installed (install: kubectl krew install neat)" >&2; return 1; }
    # canonical usage: pipe YAML through neat
    kubectl get "${1:?resource}" "${2:-}" -o yaml | kubectl neat
}

kaccess() {
    command -v kubectl-access-matrix >/dev/null 2>&1 || { echo "kubectl-access-matrix plugin not installed (install: kubectl krew install access-matrix)" >&2; return 1; }
    kubectl access-matrix --sa "${1:-default}"
}

# Helm package manager
alias h='helm'
alias hi='helm install'
alias hu='helm upgrade --install'
alias hl='helm list'
alias hd='helm delete'
alias hs='helm search repo'
alias hr='helm repo add'
alias hru='helm repo update'

helm-status() {
    if [ -z "$1" ]; then
        echo "Usage: helm-status <release_name>"
        return 1
    fi
    helm status "$1" --output table
}
