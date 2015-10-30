#!/bin/bash

SCRIPT_HOME=$(dirname $(readlink -f $0))
UICOV_BIN_PATH=$(readlink -f "${SCRIPT_HOME}/../bin")
echo $UICOV_BIN_PATH
export PATH=${UICOV_BIN_PATH}:${PATH}

FAILED_TESTS_COUNT=0
PASSED_TESTS_COUNT=0

function wrong_test(){
    echo "Usage:
runtest 'Test Name' 'executable with-or-without args' $optional-expected-exit-code"
    return 1
}

function test_passed(){
    echo "===--- Passed"
    PASSED_TESTS_COUNT=$((PASSED_TESTS_COUNT+1))
}

function test_failed(){
    echo "===--- Failed"
    FAILED_TESTS_COUNT=$((FAILED_TESTS_COUNT+1))
}

function runtest(){
    # $1 - Required. Test name.
    # $2 - Required. Command to execute.
    # $3 - Required. Expected output. Set '' if does not matter.
    # $4 - Optional. Expected exit code.
    echo "---=== Running test: ${test_name}"

    test_name=${1:-"wrong_test"}
    cmd=${2:-"wrong_test"}
    expected_output=${3:-""}
    expected_exit_code=${4:-0}

    actual_output=`set -x; ${cmd} 2>&1`
    exit_code=$?
    echo "Expected exit code: ${expected_exit_code}"
    echo "Actually exit code: ${exit_code}"
    echo "Expected output: '${expected_output}'"
    echo "Actually output: '${actual_output}'"
    $(test ${expected_exit_code} -eq ${exit_code}) && test_passed || test_failed
    echo
}

runtest "Test default behavior - should print help" \
  'uicov' \
  ''

runtest "Test coverage gathering from single log" \
  'uicov gather log1.log' \
  ''

runtest "Test multiple logs parsing" \
  'uicov gather log1.log log2.log log3.log' \
  ''

runtest 'Test generating template from single puml' \
  'uicov template model1.puml' \
  ''

runtest 'Test generating template from multiple pumls' \
  'uicov template model1.puml model2.puml model3.puml' \
  ''

runtest 'Test generating template from model folder' \
  'uicov template pumls' \
  ''

runtest "Test merging of two coverage data files" \
  'uicov merge out1.uicov out2.uicov' \
  ''

runtest "Test merging of several coverage data files" \
  'uicov merge out1.uicov out2.uicov out3.uicov' \
  ''

runtest "Test merging requires 2 params at least" \
  'uicov merge out1.uicov' \
  '' \
  2

runtest "Test standard html report" \
  'uicov report out1.uicov' \
  ''

runtest "Test puml reporting" \
  'uicov report --puml test.out.puml out1.uicov' \
  ''

### Keep it here - at the end ###
echo "
==============
Summary:
==============
 Total: $((PASSED_TESTS_COUNT+FAILED_TESTS_COUNT))
 Passed: ${PASSED_TESTS_COUNT}
 Failed: ${FAILED_TESTS_COUNT}
"

