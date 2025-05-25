#!/bin/bash
set -e

# Default values
LANG=C
TIMEOUT_SECONDS=45
OPERATOR="openshift-gitops-operator"
OPERATOR_NS="openshift-gitops-operator"
ARGO_NS="openshift-gitops"

# shellcheck source=/dev/null
source "$(dirname "$0")/functions.sh"
source "$(dirname "$0")/util.sh"
source "$(dirname "$0")/command_flags.sh" "$@"

remove_firmly(){
  oc delete gitopsservice cluster -n ${ARGO_NS}
  oc delete subs ${OPERATOR} -n ${OPERATOR_NS}
  oc delete csv ${CSV_NAME} -n ${OPERATOR_NS}
  oc delete project ${ARGO_NS}
  oc delete project ${OPERATOR_NS}
  echo ""
}


uninstall_gitops(){
  echo
  echo "Checking if GitOps Operator is already installed and running"
  
  if [[ $(oc get csv -n ${OPERATOR_NS} -l operators.coreos.com/openshift-gitops-operator.${OPERATOR_NS}='' -o jsonpath='{.items[0].status.phase}' 2>/dev/null) != "Succeeded" ]]; then
    echo
    echo "GitOps operator is not installed"
  else
    echo
    echo "GitOps operator is installed and running. Uninstalling GitOps Operator."

    # oc wait docs:
    # https://docs.openshift.com/container-platform/latest/cli_reference/openshift_cli/developer-cli-commands.html#oc-wait
    #
    # kubectl wait docs:
    # https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#wait

    echo "Retrieving the InstallPlan name"
    INSTALL_PLAN_NAME=$(oc get sub ${OPERATOR} -n ${OPERATOR_NS} -o jsonpath='{.status.installPlanRef.name}')

    echo "Retrieving the CSV name"
    CSV_NAME=$(oc get ip $INSTALL_PLAN_NAME -n ${OPERATOR_NS} -o jsonpath='{.spec.clusterServiceVersionNames[0]}')

    remove_firmly

    echo "OpenShift GitOps successfully uninstalled."
  fi
}

# Verify CLI tooling
setup_bin
check_bin oc
check_bin kustomize
check_oc_login

uninstall_gitops