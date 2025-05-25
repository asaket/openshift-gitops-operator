# openshift-gitops-operator

To install OpenShift GitOps operator to your cluster, follow below steps,
1. Install oc & kustomize binary tools. The install script will check and download if not installed already.
2. Login to ocp cluster using `oc login`
3. Run install.sh script - `$ ./install.sh`


To uninstall OpenShift GitOps operator from your cluster, follow below steps,
* Run uninstall.sh script - `$ ./uninstall.sh`

Other options
* `$ ./install.sh --help`