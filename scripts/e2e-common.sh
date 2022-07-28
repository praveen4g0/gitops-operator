#!/usr/bin/env bash

# Copyright 2020 The Tekton Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This script runs the presubmit tests; it is started by prow for each PR.
# For convenience, it can also be executed manually.
# Running the script without parameters, or with the --all-tests
# flag, causes all tests to be executed, in the right order.
# Use the flags --build-tests, --unit-tests and --integration-tests
# to run a specific set of tests.

# Helper functions for E2E tests.

function make_banner() {
    local msg="$1$1$1$1 $2 $1$1$1$1"
    local border="${msg//[-0-9A-Za-z _.,\/()]/$1}"
    echo -e "${border}\n${msg}\n${border}"
}

# Simple header for logging purposes.
function header() {
  local upper="$(echo $1 | tr a-z A-Z)"
  make_banner "=" "${upper}"
}

function wait_until_pods_running() {
  echo -n "Waiting until all pods in namespace $1 are up"
  for i in {1..150}; do  # timeout after 5 minutes
    local pods="$(oc get pods --no-headers -n $1 2>/dev/null)"
    # All pods must be running
    local not_running=$(echo "${pods}" | grep -v Running | grep -v Completed | wc -l)
    if [[ -n "${pods}" && ${not_running} -eq 0 ]]; then
      local all_ready=1
      while read pod ; do
        local status=(`echo -n ${pod} | cut -f2 -d' ' | tr '/' ' '`)
        # All containers must be ready
        [[ -z ${status[0]} ]] && all_ready=0 && break
        [[ -z ${status[1]} ]] && all_ready=0 && break
        [[ ${status[0]} -lt 1 ]] && all_ready=0 && break
        [[ ${status[1]} -lt 1 ]] && all_ready=0 && break
        [[ ${status[0]} -ne ${status[1]} ]] && all_ready=0 && break
      done <<< $(echo "${pods}" | grep -v Completed)
      if (( all_ready )); then
        echo -e "\nAll pods are up:\n${pods}"
        return 0
      fi
    fi
    echo -n "."
    sleep 2
  done
  echo -e "\n\nERROR: timeout waiting for pods to come up\n${pods}"
  return 1
}

function wait_until_object_exist() {
  local oc_ARGS="get $1 $2"
  local DESCRIPTION="$1 $2"

  if [[ -n $3 ]]; then
    oc_ARGS="get -n $3 $1 $2"
    DESCRIPTION="$1 $3/$2"
  fi
  echo -n "Waiting until ${DESCRIPTION} exist"
  for i in {1..150}; do  # timeout after 5 minutes
    if oc ${oc_ARGS} > /dev/null 2>&1; then
      echo -e "\n${DESCRIPTION} exist"
      return 0
    fi
    echo -n "."
    sleep 2
  done
  echo -e "\n\nERROR: timeout waiting for ${DESCRIPTION} to exist"
  oc ${oc_ARGS}
  return 1
}


function fail_test() {
  set_test_return_code 1
  [[ -n $1 ]] && echo "ERROR: $1"
  exit 1
}


function set_test_return_code() {
  echo -n "$1"
}

function success() {
  set_test_return_code 0
  echo "**************************************"
  echo "***        E2E TESTS PASSED        ***"
  echo "**************************************"
  exit 0
}

function install_operator_resources() {
  echo '------------------------------'

  echo ">> Deploying Gitops Operator Resources"

  make install && make deploy || fail_test "Gitops Operator installation failed"
  #  make install && make run || fail_test "Gitops Operator installation failed"
  # # Wait for pods to be running in the namespaces we are deploying to
  wait_until_pods_running "gitops-operator-system" || fail_test "Gitops Operator controller did not come up"
  local operator_namespace=$(get_operator_namespace)
  wait_until_pods_running ${operator_namespace} || fail_test "Gitops components did not come up"
}

function uninstall_operator_resources() {
  echo '------------------------------'
  echo ">> Destroying Gitops Operator Resources"
  oc patch argocd.argoproj.io/$(get_operator_namespace) -n $(get_operator_namespace) --type json --patch='[ { "op": "remove", "path": "/metadata/finalizers" } ]'

  echo -e ">> Delete arogo resources accross all namespaces"
  for res in applications applicationsets appprojects argocds; do
      oc delete --ignore-not-found=true ${res}.argoproj.io --all 
  done

  make uninstall undeploy
  
  echo -e ">> Cleanup existing crds"
  for res in applications applicationsets appprojects argocds; do
      oc delete --ignore-not-found=true crds ${res}.argoproj.io 
  done

  echo -e ">> Delete \"$(get_operator_namespace)\" project"
  oc delete --ignore-not-found=true project $(get_operator_namespace)
}


function get_operator_namespace() {
  # TODO: parameterize namespace, operator can run in a namespace different from the namespace where tektonpipelines is installed
  local operator_namespace="argocd-operator"
  [[ "${TARGET}" == "openshift" ]] && operator_namespace="openshift-gitops"
  echo ${operator_namespace}
}
