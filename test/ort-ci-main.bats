# SPDX-FileCopyrightText: 2022 Josef Andersson
#
# SPDX-License-Identifier: MIT

#Bats tests for the ort-main-ci scripts.
# https://github.com/bats-core/bats-core
# A few tests uses mock for eternal script calls
# One can argue this tests some implementation details (did value X get set and exported),
# but as most of the purpose of the script is setting up vars
# this is relevant.

# shellcheck disable=SC2148
setup() {
  TEST_LIB_PREFIX="${PWD}/test/lib/"
  load "${TEST_LIB_PREFIX}bats-support/load.bash"
  load "${TEST_LIB_PREFIX}bats-assert/load.bash"
  load "${TEST_LIB_PREFIX}bats-file/load.bash"
  # get the containing directory of this file
  # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
  # as those will point to the bats executable's location or the preprocessed file respectively
  DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" >/dev/null 2>&1 && pwd)"
  # make executables in src/ visible to PATH
  PATH="$DIR/../src:$PATH"

  TEST_TEMP_DIR="$(temp_make --prefix 'ort-ci-main-')"

}

function is_tool_available_exits_if_not_available { #@test

  # shellcheck source=/dev/null
  source ort-ci-main.sh

  run is_tool_available "cut"
  assert_success

  run is_tool_available "non_available_tool"
  assert_failure
  assert_output --partial 'non_available_tool could not be found, but is needed for the script'
}

function github_ci_adapter_sets_expected_vars { #@test

  # shellcheck source=/dev/null
  source ort-ci-main.sh

  # assert default GITHUB CI values set
  # shellcheck disable=SC2034
  local -r GITHUB_SHA='76543210'
  # shellcheck disable=SC2034
  local -r GITHUB_REPOSITORY='namespace/repo'
  # shellcheck disable=SC2034
  local -r GITHUB_WORKSPACE='github/worksp'
  # shellcheck disable=SC2034
  local -r GITHUB_SERVER_URL='gh_server_url'

  #Assert setters with export sets defaults vars
  github_ci_adapter
  assert_success

  assert_equal "$UPSTREAM_COMMIT_SHA" '76543210'
  assert_equal "$UPSTREAM_PROJECT_TITLE" 'repo'
  assert_equal "$UPSTREAM_PROJECT_PATH" 'namespace/repo'
  assert_equal "$PROJECT_DIR" 'github/worksp/project'
  assert_equal "$CI_PROJECT_DIR" 'github/worksp/project'

  assert_equal "$ORT_CONFIG_DIR" 'github/worksp/ort-configuration'

  assert_equal "$SW_VERSION" "7654321"
  assert_equal "$SW_NAME" 'repo'
  assert_equal "$VCS_REVISION" '76543210'
  assert_equal "$VCS_URL" 'ssh://git@gh_server_url/namespace/repo'

  #Assert values that have defaults use the set given value instead
  local SW_VERSION='12101112'
  local SW_NAME='gh_sw_name'
  local VCS_REVISION='gh_vcs_rev'
  local VCS_URL='gh_vcs_url'
  local ORT_OPTS='-xmx'

  github_ci_adapter
  assert_success

  assert_equal $SW_VERSION '1210111'
  assert_equal $SW_NAME 'gh_sw_name'
  assert_equal $VCS_REVISION 'gh_vcs_rev'
  assert_equal $VCS_URL 'gh_vcs_url'

}

function gitlab_ci_adapter_sets_expected_vars { #@test

  # shellcheck source=/dev/null
  source ort-ci-main.sh

  # assert default values set

  # shellcheck disable=SC2034
  local -r CI_COMMIT_SHA='12345678'
  # shellcheck disable=SC2034
  local -r CI_PROJECT_TITLE='ci_project_title'
  # shellcheck disable=SC2034
  local -r CI_PROJECT_PATH='ci_project_path'
  # shellcheck disable=SC2034
  local -r CI_BUILDS_DIR='ci_builds_dir'
  # shellcheck disable=SC2034
  local -r CI_COMMIT_SHORT_SHA='01234567'
  # shellcheck disable=SC2034
  local -r CI_SERVER_HOST='ci_server_host'

  gitlab_ci_adapter
  assert_success

  assert_equal "$UPSTREAM_COMMIT_SHA" '12345678'
  assert_equal "$UPSTREAM_PROJECT_TITLE" 'ci_project_title'
  assert_equal "$UPSTREAM_PROJECT_PATH" 'ci_project_path'

  assert_equal "$ORT_CONFIG_DIR" 'ci_builds_dir/ort-configuration'

  assert_equal "$SW_VERSION" "0123456"
  assert_equal "$SW_NAME" 'ci_project_title'
  assert_equal "$VCS_REVISION" '12345678'
  assert_equal "$VCS_URL" 'ssh://git@ci_server_host/ci_project_path'
  #assert_equal "$ORT_CLI_CONFIG_FILE" "$ORT_CONFIG_DIR/ort.conf"

  # Assert vars  with defaults use their set values

  local SW_VERSION='89101112'
  local SW_NAME='sw_name'
  local VCS_REVISION='vcs_rev'
  local VCS_URL='vcs_url'

  gitlab_ci_adapter
  assert_success

  assert_equal $SW_VERSION '8910111'
  assert_equal $SW_NAME 'sw_name'
  assert_equal $VCS_REVISION 'vcs_rev'
  assert_equal $VCS_URL 'vcs_url'

}

function ort_conf_sets_expected_values { #@test

  # shellcheck source=/dev/null
  source ort-ci-main.sh

  local ORT_OPTS='-xmx'

  #local ORT_BASE_SCRIPTS_DIR='path'

  ort_conf
  assert_success

  assert_equal "$PROJECT_DIR" 'project'
  #assert_equal "$ORT_SCRIPTS_DIR" 'path/scripts'

  assert_equal "$ORT_CLI" '/opt/ort/bin/ort'
  assert_equal "$ORT_ADVISOR_PROVIDERS" 'OssIndex'
  assert_equal "$ORT_DATA_DIR" '.ort'
  assert_equal "$ORT_RESULTS_DIR" 'ort-results'

  assert_equal "$ORT_ENABLE_REPOSITORY_PACKAGE_CONFIGURATIONS" 'false'
  assert_equal "$ORT_ENABLE_REPOSITORY_PACKAGE_CURATIONS" 'false'
  assert_equal "$ORT_REPORT_FORMATS" 'CycloneDx,EvaluatedModel,GitLabLicenseModel,NoticeTemplate,SpdxDocument,StaticHtml,WebApp'

  assert_equal "$ORT_SEVERE_ISSUE_THRESHOLD" 'ERROR'
  assert_equal "$ORT_SEVERE_RULE_VIOLATION_THRESHOLD" 'ERROR'

  assert_equal "$ORT_OPTS" '"-xmx"'

  #Test vars with non default opts
  local PROJECT_DIR='custom_dir'

  ort_conf
  assert_success

  assert_equal "$PROJECT_DIR" 'custom_dir'
}

function ort_conf_files_sets_expected_values { #@test

  # shellcheck source=/dev/null
  source ort-ci-main.sh

  local TESTCONFDIR=''

  local ORT_CONFIG_DIR="$TESTCONFDIR"

  #ORT_CONFIG_DIR NOT SET
  ort_conf_files_conf
  assert_success

  assert_equal "$ORT_CONFIG_DIR" 'ort-configuration'

  assert_equal "$ORT_CONFIG_COPYRIGHT_GARBAGE_FILE" "$ORT_CONFIG_DIR/copyright-garbage.yml"
  assert_equal "$ORT_CONFIG_CURATIONS_DIR" "$ORT_CONFIG_DIR/curations"
  assert_equal "$ORT_CONFIG_CURATIONS_FILE" "$ORT_CONFIG_DIR/curations.yml"
  assert_equal "$ORT_CONFIG_CUSTOM_LICENSE_TEXTS_DIR" "$ORT_CONFIG_DIR/custom-license-ids"
  assert_equal "$ORT_CONFIG_LICENSE_CLASSIFICATIONS_FILE" "$ORT_CONFIG_DIR/license-classifications.yml"
  assert_equal "$ORT_CONFIG_NOTICE_TEMPLATE_PATHS" "$ORT_CONFIG_DIR/notice/summary.ftl,ort-configuration/notice/by-package.ftl"
  assert_equal "$ORT_CONFIG_PACKAGE_CONFIGURATION_DIR" "$ORT_CONFIG_DIR/package-configurations"
  assert_equal "$ORT_CONFIG_PACKAGE_CONFIGURATION_FILE" "$ORT_CONFIG_DIR/packages.yml"
  assert_equal "$ORT_CONFIG_RESOLUTIONS_FILE" "$ORT_CONFIG_DIR/resolutions.yml"
  assert_equal "$ORT_CONFIG_RULES_FILE" "$ORT_CONFIG_DIR/evaluator.rules.kts"
  assert_equal "$ORT_HOW_TO_FIX_TEXT_PROVIDER_FILE" "$ORT_CONFIG_DIR/how-to-fix-text-provider.kts"

  #ORT_CONFIG_DIR SET

  local TESTCONFDIR='c'

  local ORT_CONFIG_DIR="$TESTCONFDIR"

  ort_conf_files_conf
  assert_success

  assert_equal $ORT_CONFIG_DIR 'c'

  #assert_equal "$ORT_CLI_CONFIG_FILE" "$TESTCONFDIR/ort.conf"
  assert_equal "$ORT_CONFIG_COPYRIGHT_GARBAGE_FILE" "$TESTCONFDIR/copyright-garbage.yml"
  assert_equal "$ORT_CONFIG_CURATIONS_DIR" "$TESTCONFDIR/curations"
  assert_equal "$ORT_CONFIG_CURATIONS_FILE" "$TESTCONFDIR/curations.yml"
  assert_equal "$ORT_CONFIG_CUSTOM_LICENSE_TEXTS_DIR" "$TESTCONFDIR/custom-license-ids"
  assert_equal "$ORT_CONFIG_LICENSE_CLASSIFICATIONS_FILE" "$TESTCONFDIR/license-classifications.yml"
  assert_equal "$ORT_CONFIG_NOTICE_TEMPLATE_PATHS" "$TESTCONFDIR/notice/summary.ftl,$TESTCONFDIR/notice/by-package.ftl"
  assert_equal "$ORT_CONFIG_PACKAGE_CONFIGURATION_DIR" "$TESTCONFDIR/package-configurations"
  assert_equal "$ORT_CONFIG_PACKAGE_CONFIGURATION_FILE" "$TESTCONFDIR/packages.yml"
  assert_equal "$ORT_CONFIG_RESOLUTIONS_FILE" "$TESTCONFDIR/resolutions.yml"
  assert_equal "$ORT_CONFIG_RULES_FILE" "$TESTCONFDIR/evaluator.rules.kts"
  assert_equal "$ORT_HOW_TO_FIX_TEXT_PROVIDER_FILE" "$TESTCONFDIR/how-to-fix-text-provider.kts"
}

function ort_result_files_conf_sets_expected_vars { #@test

  # shellcheck source=/dev/null
  source ort-ci-main.sh

  local -r RESULTSDIR='resultsdir'
  local -r ORT_RESULTS_DIR="$RESULTSDIR"

  ort_result_files_conf
  assert_success

  assert_equal "$ORT_RESULTS_ADVISOR_FILE" "$RESULTSDIR/advisor-result.json"
  assert_equal "$ORT_RESULTS_ANALYZER_FILE" "$RESULTSDIR/analyzer-result.json"
  assert_equal "$ORT_RESULTS_CYCLONE_DX_FILE" "$RESULTSDIR/cyclone-dx-report.xml"
  assert_equal "$ORT_RESULTS_EVALUATED_MODEL_FILE" "$RESULTSDIR/evaluated-model.json"
  assert_equal "$ORT_RESULTS_EVALUATOR_FILE" "$RESULTSDIR/evaluation-result.json"
  assert_equal "$ORT_RESULTS_GITLAB_LICENSE_MODEL_FILE" "$RESULTSDIR/gl-license-scanning-report.json"
  assert_equal "$ORT_RESULTS_HTML_REPORT_FILE" "$RESULTSDIR/ort-results/scan-report.html"
  assert_equal "$ORT_RESULTS_NOTICE_SUMMARY_FILE" "$RESULTSDIR/NOTICE_summary"
  assert_equal "$ORT_RESULTS_SCANNER_FILE" "$RESULTSDIR/analyzer-result.json"
  assert_equal "$ORT_RESULTS_WEB_APP_FILE" "$RESULTSDIR/scan-report-web-app.html"
}

function scancode_conf_sets_expected_var { #@test

  # shellcheck source=/dev/null
  source ort-ci-main.sh

  scancode_conf
  assert_success

  assert_equal "$ORT_SCANCODE_CLI_PARAMS" '--copyright --license --info --strip-root --timeout 90'
  assert_equal "$ORT_SCANCODE_MAX_VERSION" "30.2.0"
  assert_equal "$ORT_SCANCODE_MIN_VERSION" "3.2.1-rc2"
  assert_equal "$ORT_SCANCODE_PARSE_LICENSE_EXPRESSIONS" "true"
}

function package_managers_conf_sets_expected_vars { #@test

  local -r CI_PROJECT_DIR='dir'

  # shellcheck source=/dev/null
  source ort-ci-main.sh

  package_managers_conf
  assert_success

  assert_equal "$GO_CACHE_LOCAL" "${CI_PROJECT_DIR}/cache/.go/pkg/mod"
  assert_equal "$GRADLE_USER_HOME" "${CI_PROJECT_DIR}/cache/.gradle"
  assert_equal "$MAVEN_REPO_LOCAL" "${CI_PROJECT_DIR}/cache/.m2/repository"
  assert_equal "$NODE_PATH" "${CI_PROJECT_DIR}/cache/node_modules"
  assert_equal "$PIP_CACHE_DIR" "${CI_PROJECT_DIR}/cache/pip"

  # shellcheck disable=SC2153
  assert_equal "$SBT_OPTS" "-Dsbt.global.base=${CI_PROJECT_DIR}/cache/sbt -Dsbt.ivy.home=${CI_PROJECT_DIR}/cache/ivy2 -Divy.home=${CI_PROJECT_DIR}/cache/ivy2"
  assert_equal "$YARN_CACHE_FOLDER" "${CI_PROJECT_DIR}/cache/yarn"
}

function setup_ssh_calls_script_if_var_set { #@test

  # shellcheck source=/dev/null
  source ort-ci-main.sh

  local SSH_KEY_1_HOST=''
  ORT_SCRIPTS_DIR='prefix'

  #mock
  prefix/setup-ssh.sh() {
    echo 'setup-ssh.sh called'
  }

  run setup_ssh
  assert_success
  refute_output --partial 'setup-ssh.sh called'

  # shellcheck disable=SC2034
  SSH_KEY_1_HOST='sshhost'

  run setup_ssh

  assert_success
  assert_output --partial 'setup-ssh.sh called'

}

function setup_ort_config_dir_creates_dir_calls_git { #@test

  # shellcheck source=/dev/null
  source ort-ci-main.sh

  # shellcheck disable=SC2034
  local ORT_CONFIG_REVISION='rev'

  local -r ORT_CONFIG_DIR="${TEST_TEMP_DIR}/confdir"
  local -r CI_PROJECT_DIR="${TEST_TEMP_DIR}"
  # shellcheck disable=SC2034
  local -r ORT_CONFIG_REPO_URL='repourl'

  #mock
  git() {
    echo "$*"
  }

  assert_not_exist "${ORT_CONFIG_DIR}"

  run setup_ort_config_dir

  assert_line --index 0 'init -q'
  assert_line --index 1 'remote add origin repourl'
  assert_line --index 2 'fetch --depth 1 origin rev'
  assert_line --index 3 'checkout FETCH_HEAD'
  assert_exist "${ORT_CONFIG_DIR}"

}

function setup_ort_cli_calls_script { #@test

  # shellcheck source=/dev/null
  source ort-ci-main.sh

  local -r ORT_SCRIPTS_DIR='prefix'

  prefix/setup-ort-cli-config.sh() {

    echo 'prefix/setup-ort-cli-config.sh called'
  }

  run setup_ort_cli

  assert_success
  assert_output --partial 'prefix/setup-ort-cli-config.sh called'

}

function setup_cache_workarounds_moves_caches_if_dir_exists { #@test

  # shellcheck source=/dev/null
  source ort-ci-main.sh

  #Dont move caches if dir exists

  local HOME="${TEST_TEMP_DIR}"/target
  local GOPATH="${TEST_TEMP_DIR}"/target
  mkdir "${TEST_TEMP_DIR}"/target

  run setup_cache_workarounds

  assert_success

  assert_not_exist "${TEST_TEMP_DIR}"/target/pkg/mod/bfile
  assert_not_exist "${TEST_TEMP_DIR}"/target/.m2/repository/afile

  #Move caches if dir exists
  local MAVEN_REPO_LOCAL="${TEST_TEMP_DIR}"/maven_repo_local
  local GO_CACHE_LOCAL="${TEST_TEMP_DIR}"/go_cache_local

  mkdir "${MAVEN_REPO_LOCAL}"
  mkdir "${GO_CACHE_LOCAL}"
  touch "${GO_CACHE_LOCAL}"/bfile
  touch "${MAVEN_REPO_LOCAL}"/afile

  run setup_cache_workarounds

  assert_success

  assert_exist "${TEST_TEMP_DIR}"/target/pkg/mod/bfile
  assert_exist "${TEST_TEMP_DIR}"/target/.m2/repository/afile

}

function ort_download_calls_scripts_if_false() { #@test

  # shellcheck source=/dev/null
  source ort-ci-main.sh

  local ORT_DISABLE_DOWNLOADER=''
  local ORT_SCRIPTS_DIR='prefix'

  prefix/ort-downloader.sh() {
    echo 'prefix/ort-downloader.sh called'
    echo "$@"
  }

  prefix/check-vars.sh() {
    echo 'prefix/check-vars.sh called'
  }

  # downloader was not called
  run ort_download
  assert_success

  refute_output --partial 'prefix/ort-check-vars.sh called'
  refute_output --partial 'prefix/ort-downloader.sh called'

  # shellcheck disable=SC2034
  ORT_DISABLE_DOWNLOADER='false'

  run ort_download

  assert_success

  assert_output --partial 'prefix/check-vars.sh called'
  assert_output --partial 'prefix/ort-downloader.sh called'

}

function ort_analyse_calls_script_if_var_false() { #@test

  # shellcheck source=/dev/null
  source ort-ci-main.sh

  local ORT_SCRIPTS_DIR='prefix'

  prefix/ort-step-wrapper.sh() {
    echo 'prefix/ort-step-wrapper.sh called'
    echo "$@"
  }

  run ort_analyse

  assert_success
  assert_line --index 0 'prefix/ort-step-wrapper.sh called'
  assert_line --index 1 'analyzer'

}

function ort_scan_calls_script_if_var_false() { #@test

  # shellcheck source=/dev/null
  source ort-ci-main.sh

  prefix/ort-step-wrapper.sh() {
    echo 'prefix/ort-step-wrapper.sh called'
    echo "$@"
  }

  local ORT_DISABLE_SCANNER=''
  run ort_scan
  assert_success
  refute_output --partial 'ort-step-wrapper.sh scanner'

  # shellcheck disable=SC2034
  ORT_DISABLE_SCANNER='false'
  local ORT_SCRIPTS_DIR='prefix'

  run ort_scan

  assert_success
  assert_line --index 0 'prefix/ort-step-wrapper.sh called'
  assert_line --index 1 'scanner'

}

function ort_advise_calls_script_if_var_false() { #@test

  # shellcheck source=/dev/null
  source ort-ci-main.sh

  prefix/ort-step-wrapper.sh() {
    echo 'prefix/ort-step-wrapper.sh called'
    echo "$@"
  }

  local ORT_DISABLE_ADVISOR=''

  run ort_advise
  assert_success
  refute_output --partial 'ort-step-wrapper.sh advisor'

  # shellcheck disable=SC2034
  ORT_DISABLE_ADVISOR='false'
  local ORT_SCRIPTS_DIR='prefix'

  run ort_advise

  assert_success
  assert_line --index 0 'prefix/ort-step-wrapper.sh called'
  assert_line --index 1 'advisor'

}

function ort_evaluate_calls_script_if_var_false() { #@test

  # shellcheck source=/dev/null
  source ort-ci-main.sh

  prefix/ort-step-wrapper.sh() {
    echo 'prefix/ort-step-wrapper.sh called'
    echo "$@"
  }

  run ort_evaluate
  assert_success
  refute_output --partial 'ort-step-wrapper.sh evaluator'

  # shellcheck disable=SC2034
  ORT_DISABLE_EVALUATOR='false'
  local ORT_SCRIPTS_DIR='prefix'

  run ort_evaluate

  assert_success
  assert_line --index 0 'prefix/ort-step-wrapper.sh called'
  assert_line --index 1 'evaluator'

}

function ort_report_is_called() { #@test

  # shellcheck source=/dev/null
  source ort-ci-main.sh

  prefix/ort-step-wrapper.sh() {
    echo 'prefix/ort-step-wrapper.sh called'
    echo "$@"
  }

  local ORT_SCRIPTS_DIR='prefix'

  # shellcheck disable=SC2034
  run ort_report

  assert_success
  assert_line --index 0 'prefix/ort-step-wrapper.sh called'
  assert_line --index 1 'reporter'

}

function diff_and_set_job_result_test() { #@test

  local -r ORT_SCRIPTS_DIR='prefix'
  local -r PROJECT_DIR="${TEST_TEMP_DIR}"
  local -r NOTICE_FILE='notice'
  local -r ORT_RESULTS_DIR="${TEST_TEMP_DIR}"/noticeresult

  mkdir "$ORT_RESULTS_DIR"
  echo 'a' >"${TEST_TEMP_DIR}"/"${NOTICE_FILE}"
  echo 'b' >"${ORT_RESULTS_DIR}"/"${NOTICE_FILE}"

  # shellcheck source=/dev/null
  source ort-ci-main.sh

  prefix/set-job-result.sh() {
    echo 'prefix/set-job-result.sh called'
  }

  diff_notice

  assert_success
  assert_equal "$NOTICE_FILES_DIFFER" 'true'

  echo 'a' >"${ORT_RESULTS_DIR}"/"${NOTICE_FILE}"
  diff_notice

  assert_success
  assert_equal "$NOTICE_FILES_DIFFER" 'false'

}

function setjobresult_is_called() { #@test

  # shellcheck source=/dev/null
  source ort-ci-main.sh

  prefix/set-job-result.sh() {
    echo 'prefix/set-job-result.sh called'
    echo "$@"
  }

  # shellcheck disable=SC2034
  local ORT_SCRIPTS_DIR='prefix'

  # shellcheck disable=SC2034
  run set_job_result

  assert_success
  assert_line --index 0 'prefix/set-job-result.sh called'

}

function move_caches_moves_dirs_if_cache_dirs_exists() { #@test

  # shellcheck source=/dev/null
  source ort-ci-main.sh

  local MAVEN_REPO_LOCAL="${TEST_TEMP_DIR}"/a
  local GO_CACHE_LOCAL="${TEST_TEMP_DIR}"/b

  # shellcheck disable=SC2034
  local HOME="${TEST_TEMP_DIR}"
  # shellcheck disable=SC2034
  local GOPATH="${TEST_TEMP_DIR}"

  #Nothing happens if dir does not exist
  run move_caches

  assert_success

  assert_not_exist "${TEST_TEMP_DIR}"/a
  assert_not_exist "${TEST_TEMP_DIR}"/b

  #dir exists, move content
  mkdir -p "${TEST_TEMP_DIR}"/.m2/repository
  mkdir -p "${TEST_TEMP_DIR}"/pkg/mod

  touch "${TEST_TEMP_DIR}"/.m2/repository/afile
  touch "${TEST_TEMP_DIR}"/pkg/mod/bfile

  run move_caches

  assert_success

  assert_exist "${TEST_TEMP_DIR}"/a/afile
  assert_exist "${TEST_TEMP_DIR}"/b/bfile
}
