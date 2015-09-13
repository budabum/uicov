#!/bin/bash

SCRIPT_HOME=$(dirname $(readlink -f $0))
UICOV_BIN_PATH=$(readlink -f "${SCRIPT_HOME}/../bin")
echo $UICOV_BIN_PATH
export PATH=${UICOV_BIN_PATH}:${PATH}

FAILED_TESTS_COUNT=0
PASSED_TESTS_COUNT=0

function wrong_test(){
    echo "Usage:
runtest 'Test Name' 'executale with-or-without args' $optional-expected-exit-code"
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
    expected_output=${3:-"wrong_test"}
    expected_exit_code=${4:-0}

    set -x
    eval ${cmd}
    exit_code=$?
    set +x
    echo "Exit code: ${exit_code}"
    $(test ${expected_exit_code} -eq ${exit_code}) && test_passed || test_failed
    echo
}

runtest "Test default behavior - should pringt help" \
    'uicov' \
    ''

runtest "Test single log parsing" \
    'uicov parse log1.log' \
    ''

runtest "Test multiple logs parsing" \
    'uicov parse log1.log log2.log log3.log' \
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
