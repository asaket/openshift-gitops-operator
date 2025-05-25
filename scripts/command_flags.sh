# Help function
function show_help {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo "  --ocp_version=4.18    Target Openshift Version"
  echo "  --timeout=45          Timeout in seconds for waiting for each resource to be ready"
  echo "  --help                Show this help message"
}

for arg in "$@"
do
  case $arg in
    --ocp_version=*)
      export OCP_VERSION="${arg#*=}"
      echo "Using OCP Bianaires Version: ${OCP_VERSION}"
      shift
    ;;
    --timeout=*)
      export TIMEOUT_SECONDS="${arg#*=}"
      echo "Using Timeout Seconds: ${TIMEOUT_SECONDS}"
      shift
    ;;
    --help)
      show_help
      exit 0
    ;;

  esac
done
