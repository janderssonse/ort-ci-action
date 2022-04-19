#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2022 Josef Andersson
#
# SPDX-License-Identifier: MIT

#install bats libs in current folder /lib
#Bash Template based on https://gist.github.com/m-radzikowski/53e0b39e9a59a1518990e76c2bff8038

# abort on nonzero exitstatus
set -o errexit
# don't hide errors within pipes
set -o pipefail
# Allow error traps on function calls, subshell environment, and command substitutions
set -o errtrace

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

is_command_installed() {

  local -r sumprog=$1

  if ! [[ -x "$(command -v "${sumprog}")" ]]; then
    echo "${sumprog} could not be run, make sure it is installed and executable"
    return 1
  fi
}

download_and_extract_bats() {

  local -r name="${1}"
  local -r version="${2}"
  local -r url="${3}"

  local -r outputdir="${SCRIPT_DIR}/lib"
  mkdir -p "${outputdir}"
  (
    cd "${outputdir}"
    curl -L -O -J "${url}"
    tar -zxvf "${name}-${version}.tar.gz"
    mv "${name}-${version}" "${name}"
  )

}

main() {

  is_command_installed "curl"

  download_and_extract_bats 'bats-core' '1.6.0' 'https://github.com/bats-core/bats-core/archive/refs/tags/v1.6.0.tar.gz'
  download_and_extract_bats 'bats-support' '0.3.0' 'https://github.com/bats-core/bats-support/archive/v0.3.0.tar.gz'
  download_and_extract_bats 'bats-assert' '2.0.0' 'https://github.com/bats-core/bats-assert/archive/v2.0.0.tar.gz'
  download_and_extract_bats 'bats-file' '0.3.0' 'https://github.com/bats-core/bats-file/archive/refs/tags/v0.3.0.tar.gz'

}

main
