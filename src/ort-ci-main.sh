#!/usr/bin/env sh

# SPDX-FileCopyrightText: 2022 Josef Andersson
# SPDX-FileCopyrightText: 2020-2022 HERE Europe B.V.
#
# SPDX-License-Identifier: Apache-2.0

# shellcheck disable=SC3043

# abort on nonzero exitstatus
set -o errexit

#DESCRIPTION:
# This script is a handler for calling various ORT-CI-SCRIPTS.
# It's purpose is to ease the handling of ORT in CI-pipelines.

#bashism might still exist but a small effort was made to keep the script is quite sh posix compliant and would work in different shells.

is_tool_available() {

  local tool="$1"

  if ! command -v "$tool"; then
    echo "$tool could not be found, but is needed for the script"
    exit 1
  fi

}

#Adapter for GitHub Usage
github_ci_adapter() {

  local REPONAME
  REPONAME="$(echo "$GITHUB_REPOSITORY" | cut -d / -f 2)"
  export UPSTREAM_COMMIT_SHA="$GITHUB_SHA"
  export UPSTREAM_PROJECT_TITLE="$REPONAME"
  export UPSTREAM_PROJECT_PATH="$GITHUB_REPOSITORY"

  export PROJECT_DIR="${GITHUB_WORKSPACE}/project"
  export CI_PROJECT_DIR="$PROJECT_DIR"

  export ORT_CONFIG_DIR="${GITHUB_WORKSPACE}/ort-configuration"

  # ---The ORT DOWNLOADER PRE REQ
  local SHORT_SHA="${SW_VERSION:-$GITHUB_SHA}"
  SW_VERSION="$(echo "${SHORT_SHA}" | cut -c1-7)"
  export SW_VERSION
  export SW_NAME="${SW_NAME:-$REPONAME}"
  export VCS_REVISION="${VCS_REVISION:-$GITHUB_SHA}"
  export VCS_URL="${VCS_URL:-"ssh://git@${GITHUB_SERVER_URL}/${UPSTREAM_PROJECT_PATH}"}"
  #-----------------------------

}

#Adapter for GitLab Usage
gitlab_ci_adapter() {

  export UPSTREAM_COMMIT_SHA="$CI_COMMIT_SHA"
  export UPSTREAM_PROJECT_TITLE="$CI_PROJECT_TITLE"
  export UPSTREAM_PROJECT_PATH="$CI_PROJECT_PATH"

  export ORT_CONFIG_DIR="${CI_BUILDS_DIR}/ort-configuration"

  # ---The ORT DOWNLOADER PRE REQ
  local SHORT_SHA="${SW_VERSION:-$CI_COMMIT_SHORT_SHA}"
  SW_VERSION="$(echo "${SHORT_SHA}" | cut -c1-7)"
  export SW_VERSION
  export SW_NAME="${SW_NAME:-$CI_PROJECT_TITLE}"
  export VCS_REVISION="${VCS_REVISION:-$CI_COMMIT_SHA}"
  export VCS_URL="${VCS_URL:-"ssh://git@${CI_SERVER_HOST}/${UPSTREAM_PROJECT_PATH}"}"
  #-----------------------------

}

set_default_vars() {

  # shellcheck source=/dev/null
  . "${ORT_SCRIPTS_DIR}"/set-defaults.sh
}

ort_conf() {

  export PROJECT_DIR="${PROJECT_DIR:-"project"}"

  export ORT_CLI="/opt/ort/bin/ort"
  export ORT_CLI_CONFIG_FILE="${ORT_CONFIG_DIR}/ort.conf"
  export ORT_ADVISOR_PROVIDERS="OssIndex"
  export ORT_DATA_DIR=".ort"
  export ORT_RESULTS_DIR="ort-results"

  export ORT_ENABLE_REPOSITORY_PACKAGE_CONFIGURATIONS="false"
  export ORT_ENABLE_REPOSITORY_PACKAGE_CURATIONS="false"
  export ORT_REPORT_FORMATS="CycloneDx,EvaluatedModel,GitLabLicenseModel,NoticeTemplate,SpdxDocument,StaticHtml,WebApp"

  export ORT_SEVERE_ISSUE_THRESHOLD="ERROR"
  export ORT_SEVERE_RULE_VIOLATION_THRESHOLD="ERROR"

  export ORT_OPTS=\""${ORT_OPTS}"\"
}

ort_conf_files_conf() {

  export ORT_CONFIG_DIR="${ORT_CONFIG_DIR:-"ort-configuration"}"

  export ORT_CONFIG_COPYRIGHT_GARBAGE_FILE="${ORT_CONFIG_DIR}/copyright-garbage.yml"
  export ORT_CONFIG_CURATIONS_DIR="${ORT_CONFIG_DIR}/curations"
  export ORT_CONFIG_CURATIONS_FILE="${ORT_CONFIG_DIR}/curations.yml"
  export ORT_CONFIG_CUSTOM_LICENSE_TEXTS_DIR="${ORT_CONFIG_DIR}/custom-license-ids"
  export ORT_CONFIG_LICENSE_CLASSIFICATIONS_FILE="${ORT_CONFIG_DIR}/license-classifications.yml"
  export ORT_CONFIG_NOTICE_TEMPLATE_PATHS="${ORT_CONFIG_DIR}/notice/summary.ftl,${ORT_CONFIG_DIR}/notice/by-package.ftl"
  export ORT_CONFIG_PACKAGE_CONFIGURATION_DIR="${ORT_CONFIG_DIR}/package-configurations"
  export ORT_CONFIG_PACKAGE_CONFIGURATION_FILE="${ORT_CONFIG_DIR}/packages.yml"
  export ORT_CONFIG_RESOLUTIONS_FILE="${ORT_CONFIG_DIR}/resolutions.yml"
  export ORT_CONFIG_RULES_FILE="${ORT_CONFIG_DIR}/evaluator.rules.kts"
  export ORT_HOW_TO_FIX_TEXT_PROVIDER_FILE="${ORT_CONFIG_DIR}/how-to-fix-text-provider.kts"
}

ort_result_files_conf() {

  export ORT_RESULTS_ADVISOR_FILE="${ORT_RESULTS_DIR}/advisor-result.json"
  export ORT_RESULTS_ANALYZER_FILE="${ORT_RESULTS_DIR}/analyzer-result.json"
  export ORT_RESULTS_CYCLONE_DX_FILE="${ORT_RESULTS_DIR}/cyclone-dx-report.xml"
  export ORT_RESULTS_EVALUATED_MODEL_FILE="${ORT_RESULTS_DIR}/evaluated-model.json"
  export ORT_RESULTS_EVALUATOR_FILE="${ORT_RESULTS_DIR}/evaluation-result.json"
  export ORT_RESULTS_GITLAB_LICENSE_MODEL_FILE="${ORT_RESULTS_DIR}/gl-license-scanning-report.json"
  export ORT_RESULTS_HTML_REPORT_FILE="${ORT_RESULTS_DIR}/ort-results/scan-report.html"
  export ORT_RESULTS_NOTICE_SUMMARY_FILE="${ORT_RESULTS_DIR}/NOTICE_summary"
  export ORT_RESULTS_SCANNER_FILE="${ORT_RESULTS_DIR}/analyzer-result.json"
  export ORT_RESULTS_WEB_APP_FILE="${ORT_RESULTS_DIR}/scan-report-web-app.html"
}

scancode_conf() {

  export ORT_SCANCODE_CLI_PARAMS='--copyright --license --info --strip-root --timeout 90'
  export ORT_SCANCODE_MAX_VERSION='30.2.0'
  export ORT_SCANCODE_MIN_VERSION='3.2.1-rc2'
  export ORT_SCANCODE_PARSE_LICENSE_EXPRESSIONS='true'
}

package_managers_conf() {

  export GO_CACHE_LOCAL="${CI_PROJECT_DIR}/cache/.go/pkg/mod"
  export GRADLE_USER_HOME="${CI_PROJECT_DIR}/cache/.gradle"
  export MAVEN_REPO_LOCAL="${CI_PROJECT_DIR}/cache/.m2/repository"
  export NODE_PATH="${CI_PROJECT_DIR}/cache/node_modules"
  export PIP_CACHE_DIR="${CI_PROJECT_DIR}/cache/pip"
  export SBT_OPTS="-Dsbt.global.base=${CI_PROJECT_DIR}/cache/sbt -Dsbt.ivy.home=${CI_PROJECT_DIR}/cache/ivy2 -Divy.home=${CI_PROJECT_DIR}/cache/ivy2"
  export YARN_CACHE_FOLDER="${CI_PROJECT_DIR}/cache/yarn"
}

# Create ~/.ssh dir with SSH keys if SSH_KEY_1_HOST is set.
setup_ssh() {

  if [ -n "${SSH_KEY_1_HOST}" ]; then
    "${ORT_SCRIPTS_DIR}"/setup-ssh.sh
  fi

}

# Set up configuration repository which holds ORT configuration files
# such as curations.yml, rules.kts, etc.
setup_ort_config_dir() {
  mkdir -p "$ORT_CONFIG_DIR" && cd "$ORT_CONFIG_DIR"
  git init -q
  git remote add origin "$ORT_CONFIG_REPO_URL"
  ORT_CONFIG_REVISION=${ORT_CONFIG_REVISION:-$(git remote show origin | sed -n '/HEAD branch/s/.*: //p')}
  git fetch --depth 1 origin "$ORT_CONFIG_REVISION"
  git checkout FETCH_HEAD
  ORT_CONFIG_REVISION="$(git rev-parse HEAD)"
  cd "$CI_PROJECT_DIR"
}

setup_ort_cli() {

  "${ORT_SCRIPTS_DIR}"/setup-ort-cli-config.sh
}

setup_cache_workarounds() {

  # Workaround for maven cache.
  if [ -d "${MAVEN_REPO_LOCAL}" ]; then
    mkdir -p "${HOME}"/.m2/repository/
    mv "${MAVEN_REPO_LOCAL}"/* "${HOME}"/.m2/repository/
  fi

  # Workaround for go cache.
  if [ -d "$GO_CACHE_LOCAL" ]; then
    mkdir -p "${GOPATH}"/pkg/mod
    mv "${GO_CACHE_LOCAL}"/* "${GOPATH}"/pkg/mod/
  fi

}

# Execute ORT's Downloader to fetch the source code for the project to be scanned.
ort_download() {

  if [ "${ORT_DISABLE_DOWNLOADER}" = "false" ]; then
    "${ORT_SCRIPTS_DIR}"/check-vars.sh
    "${ORT_SCRIPTS_DIR}"/ort-downloader.sh || { [ $? -eq 1 ] && exit 1; }
  fi

}

# Executes ORT's Analyzer to determines the dependencies of projects and their metadata,
# abstracting which package managers or build systems are actually being used.
ort_analyse() {
  "${ORT_SCRIPTS_DIR}"/ort-step-wrapper.sh analyzer
}

# Executes ORT's Scanner which uses configured source code scanners to detect license / copyright findings.
ort_scan() {

  if [ "$ORT_DISABLE_SCANNER" = "false" ]; then
    "${ORT_SCRIPTS_DIR}"/ort-step-wrapper.sh scanner
  fi

}

# Conditionally execute ORT's Advisor to retrieve security advisories
# for used dependencies from configured vulnerability data services.
ort_advise() {

  if [ "$ORT_DISABLE_ADVISOR" = "false" ]; then
    "${ORT_SCRIPTS_DIR}"/ort-step-wrapper.sh advisor
  fi

}

# Conditionally execute ORT's Evaluator to evaluate copyright, file, package and license findings
# against customizable policy rules.
ort_evaluate() {

  if [ "$ORT_DISABLE_EVALUATOR" = "false" ]; then
    "${ORT_SCRIPTS_DIR}"/ort-step-wrapper.sh evaluator
  fi

}

# Executes ORT's Reporter to presents scan results in various formats (defined by ORT_REPORT_FORMATS) such as visual reports,
# Open Source notices or Bill-Of-Materials (BOMs) to easily identify dependencies, licenses, copyrights or policy rule violations.
ort_report() {

  "${ORT_SCRIPTS_DIR}"/ort-step-wrapper.sh reporter
}

diff_notice() {
  # Set NOTICE_FILES_DIFFER boolean based on comparing existing open source notices file against on generated in the scan.
  if diff --brief "$PROJECT_DIR/$NOTICE_FILE" "$ORT_RESULTS_DIR/$NOTICE_FILE"; then
    export NOTICE_FILES_DIFFER='false'
  else
    export NOTICE_FILES_DIFFER='true'
  fi
}

set_job_result() {
  "${ORT_SCRIPTS_DIR}"/set-job-result.sh
}

move_caches() {

  # Workaround for maven cache.
  if [ -d "${HOME}"/.m2/repository/ ]; then
    mkdir -p "$MAVEN_REPO_LOCAL"
    mv -f "${HOME}"/.m2/repository/* "$MAVEN_REPO_LOCAL"
  fi

  # Workaround for go cache.
  if [ -d "${GOPATH}"/pkg/mod/ ]; then
    mkdir -p "${GO_CACHE_LOCAL}"
    mv "${GOPATH}"/pkg/mod/* "${GO_CACHE_LOCAL}"
  fi

}

setup() {

  is_tool_available "cut"
  is_tool_available "date"
  is_tool_available "git"
  is_tool_available "sed"

  if [ -n "${GITHUB_ACTION}" ]; then
    github_ci_adapter
  else
    gitlab_ci_adapter
  fi

  set_default_vars
  ort_conf
  ort_conf_files_conf
  ort_result_files_conf
  scancode_conf
  package_managers_conf
  setup_ssh

  setup_ort_config_dir
  setup_ort_cli
  setup_cache_workarounds
  echo "[DEBUG] env vars"
  env | sort
}

cleanup() {

  move_caches

  # Create metadata.json which can be used to reproduce the scan
  # or perform more easily audits over multiple scan runs.
  "${ORT_SCRIPTS_DIR}"/print-metadata.sh >metadata.json

  # Compress some of the ort-scan result files to save disk space and reduce file download times.
  "${ORT_SCRIPTS_DIR}"/archive-results.sh

  # If ort-scan is run as part of a merge request add comment with scan results to the merge request.
  "${ORT_SCRIPTS_DIR}"/post-mr-comment.sh

}

main() {

  JOB_STARTED_AT="$(date +"%Y-%m-%dT%H:%M:%S%z")"
  export JOB_STARTED_AT

  TRIGGERER=${UPSTREAM_PIPELINE_URL:-"${GITLAB_USER_NAME} manually"}
  export TRIGGERER
  echo "Started by $TRIGGERER"

  setup

  ort_download
  ort_analyse
  ort_scan
  ort_advise
  ort_evaluate
  ort_report
  diff_notice
  set_job_result
  cleanup

  JOB_FINISHED_AT="$(date +"%Y-%m-%dT%H:%M:%S%z")"
  export JOB_FINISHED_AT
}

#call script with arg main to start (if not sourced)
"$@"
