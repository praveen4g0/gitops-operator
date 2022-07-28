#!/bin/sh

# fail if some commands fails
set -e

# Do not show token in CI log
set +x

# show commands
set -x
export CI="prow"
go mod vendor
# make prepare-test-cluster

source $(dirname $0)/e2e-common.sh

# Script entry point.
TARGET=${TARGET:-openshift}
KUBECONFIG=${KUBECONFIG:-$HOME/.kubeconfig}

export PATH="$PATH:$(pwd)"

# INSTALL_OPERATOR_SDK="./scripts/install-operator-sdk.sh"
# sh $INSTALL_OPERATOR_SDK

# Copy kubeconfig to temporary kubeconfig file and grant
# read and Write permission to temporary kubeconfig file
TMP_DIR=$(mktemp -d)
cp $KUBECONFIG $TMP_DIR/kubeconfig
chmod 640 $TMP_DIR/kubeconfig
export KUBECONFIG=$TMP_DIR/kubeconfig
KUBECONFIG_PARAM=${KUBECONFIG:+"--kubeconfig $KUBECONFIG"}

# make sure you export IMAGE and version so it builds and pushes code to right registry. 

uninstall() {
    header "Uninstalling operator resources"
    uninstall_operator_resources
}
trap uninstall EXIT


echo "Running tests on ${TARGET}"

echo "Building and pushing controller images"
make docker-build
make docker-push

header "Setting up environment"
[[ -z ${E2E_SKIP_OPERATOR_INSTALLATION} ]] && install_operator_resources

header "Running kuttl e2e tests"
make kuttl-e2e || fail_test "Kuttl tests failed"

success