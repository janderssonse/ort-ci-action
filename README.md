<!--
SPDX-FileCopyrightText: 2022 Josef Andersson

SPDX-License-Identifier: CC0-1.0
-->

# ORT CI Action

A GitHub Action for using the powerful [ORT (OSS Review Toolkit)](https://github.com/oss-review-toolkit/ort) to Analyse, Scan, Evaluate and Advise your code with ORT, with quite a lot of configuration options.

NOTE: TESTING THINGS; GIT HISTORY WILL BE RESET WHEN PROJECT IS "good enough" for an initial commit and pass the experimental phase, so if you clone it, don't expect to much, and don't use it "for real" yet, things will break

Related siblings projects are:

- [ORT CI Base](https://github.com/janderssonse/ort-ci-base) - Base Scripts etc. for running ORT in CI
- [ORT CI GitLab](https://github.com/janderssonse/ort-ci-gitlab) - A GitLab CI template for running ORT in CI

## Table of Contents

- [Usage](#usage)
- [Contributing](#contributing)
- [Maintainers](#maintainers)
- [License](#license)

## Usage

In the given example we are using a few other actions:

* [`checkout`](https://github.com/actions/checkout) - will checkout the current repo and put in under '$GITHUB_WORKSPACE/project' (the default expected repo location if nothing else configured).


* [`upload-artifact`](https://github.com/actions/upload-artifact) - to make the analysed results become available after the CI pipeline has finished.

### Analyse

```yaml
name: ORT CI Action
on: [push]

jobs:
  ort_report_job:
    runs-on: ubuntu-latest
    name: Analyse with ORT

    steps:

      - name: Checkout
        uses: actions/checkout@v3
        with:
          path: project

      - name: ORT CI Action run
        id: ort-ci-action
        uses: janderssonse/ort-ci-action@84fb404388a78fa8a2059470c6c38bec98c648f4
        with:
          ort_disable_scanner: true
          ort_disable_downloader: true
          ort_disable_evaluator: true
          ort_disable_advisor: false
          ort_cli_config_tmpl: "ort.conf.tmpl"
          ort_config_file: ''
          ort_log_level: info
          ort_opts: -Xmx5120m
        
       
      - name: ort-action-artifacts
        uses: actions/upload-artifact@v3
        with:
            name: analysis
            path: ./project/ort-results
```

For further configuration options, see [the variables configuration doc](https://github.com/janderssonse/ort-ci-base/blob/main/docs/variables.adoc) or, the [action.yml](action.yml) itself.

### Where can the results be found?

At the bottom of the workflow summary page, there is a dedicated section for artifacts. Here's a screenshot of something you might see:

<img src="https://user-images.githubusercontent.com/37870813/164996952-e1a6c353-fe52-4a43-a578-e9a9c3b1f861.png" width="700" height="300">

## Development

TO-DO

### Project linters

The project is using a few hygiene linters:

- [MegaLinter](https://megalinter.github.io/latest/) - for shell, markdown etc check.
- [Repolinter](https://github.com/todogroup/repolinter) - for overall repostructre.
- [commitlint](https://github.com/conventional-changelog/commitlint) - for conventional commit check.
- [REUSE Compliance Check](https://github.com/fsfe/reuse-action) - for reuse specification compliance.

Before commiting a PR, please have run with this linters to avoid red checks. If forking on GitHub, you can adjust them to work for fork in the .github/workflow-files.

## Contributing

ORT CI Action follows the [Contributor Covenant](http://contributor-covenant.org/version/1/3/0/) Code of Conduct.  
Please also see the [Contributor Guide](docs/CONTRIBUTING.adoc)

## Maintainers

[Josef Andersson](https://github.com/janderssonse).

## License

The Action is using ORT to run it's actions which is Apache Licensed and:

Copyright (C) 2020-2022 HERE Europe B.V.

ORT CI Action itself is is under

[MIT](LICENSE)

See .reuse/dep5 and file headers for further information.
Most "scrap" files, textfiles etc are under CC0-1.0, essentially Public Domain.

## Credits

Thanks to the [ORT (OSS Review Toolkit) Project](https://github.com/oss-review-toolkit/ort), for developing such a powerful tool. It fills a void in SCA-toolspace.

## F.A.Q

* TO-DO


