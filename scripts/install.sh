#!/bin/bash
set -e

# Default values
LANG=C
TIMEOUT_SECONDS=45
OPERATOR_NS="openshift-gitops-operator"
ARGO_NS="openshift-gitops"
#GITOPS_OVERLAY=components/operators/openshift-gitops/operator/overlays/gitops-1.15/
GITOPS_OVERLAY=components/operators/openshift-gitops/operator/overlays/latest/

# shellcheck source=/dev/null
source "$(dirname "$0")/functions.sh"
source "$(dirname "$0")/util.sh"
source "$(dirname "$0")/command_flags.sh" "$@"

apply_firmly(){
  if [ ! -f "${1}/kustomization.yaml" ]; then
    print_error "Please provide a dir with \"kustomization.yaml\""
    return 1
  fi

  # kludge
  until oc kustomize "${1}" --enable-helm | oc apply -f- 2>/dev/null
  do
    echo "."
    sleep 10
  done
  echo ""
  # until_true oc apply -k "${1}" 2>/dev/null
}

install_gitops(){
  echo
  echo "Checking if GitOps Operator is already installed and running"
  
  if [[ $(oc get csv -n ${OPERATOR_NS} -l operators.coreos.com/openshift-gitops-operator.${OPERATOR_NS}='' -o jsonpath='{.items[0].status.phase}' 2>/dev/null) == "Succeeded" ]]; then
    echo
    echo "GitOps operator is already installed and running"
  else
    echo
    echo "Installing GitOps Operator."

    apply_firmly ${GITOPS_OVERLAY} 

    # oc wait docs:
    # https://docs.openshift.com/container-platform/latest/cli_reference/openshift_cli/developer-cli-commands.html#oc-wait
    #
    # kubectl wait docs:
    # https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#wait

    echo "Retrieving the InstallPlan name"
    INSTALL_PLAN_NAME=$(oc get sub openshift-gitops-operator -n ${OPERATOR_NS} -o jsonpath='{.status.installPlanRef.name}')

    echo "Retrieving the CSV name"
    CSV_NAME=$(oc get ip $INSTALL_PLAN_NAME -n ${OPERATOR_NS} -o jsonpath='{.spec.clusterServiceVersionNames[0]}')

    echo "Wait the Operator installation to be completed"
    oc wait --for jsonpath='{.status.phase}'=Succeeded csv/$CSV_NAME -n ${OPERATOR_NS}

    echo ""
    echo "OpenShift GitOps successfully installed."
  fi
}


# Verify CLI tooling
setup_bin
check_bin oc
check_bin kustomize
check_oc_login

# Execute bootstrap functions
install_gitops