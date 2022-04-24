<!--
SPDX-FileCopyrightText: 2022 Josef Andersson

SPDX-License-Identifier: CC0-1.0
-->



NOTE: STILL TESTING THINGS; GIT HISTORY WILL BE RESET WHEN PROJECT IS "good enough" for an initial commit and pass the experimental phase, so if you clone it, dont expect to much, and dont use it "for real" yet, things will break

# ORT CI Action

A GitHub Action for using the powerful [ORT (OSS Review Toolkit)](https://github.com/oss-review-toolkit/ort) to Analyze, Scan, Evaluate and Advise your code with ORT, with quite a lot of configuration options.

## Table of Contents

- [Usage](#usage)
- [Maintainers](#maintainers)
- [Contributing](#contributing)
- [License](#license)

## Usage

In the given example we are using a few other actions:

* [`checkout`](https://github.com/actions/checkout) - will checkout the current repo and put in under '$GITHUB_WORKSPACE/project' (the default expected repolocation if nothing else configured).


* [`upload-artifact`](https://github.com/actions/upload-artifact) - to make the analysed results becoma available after the CI pipeline has finished. 

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

For further configuration options, see [action.yml](action.yml).

### Where can the results be found?

At the bottom of the workflow summary page, there is a dedicated section for artifacts. Here's a screenshot of something you might see:

<img src="https://user-images.githubusercontent.com/37870813/164996952-e1a6c353-fe52-4a43-a578-e9a9c3b1f861.png" width="700" height="300">

## Maintainers

[Josef Andersson](https://github.com/janderssonse).

## Contributing

ORT CI Action follows the [Contributor Covenant](http://contributor-covenant.org/version/1/3/0/) Code of Conduct.


## License

[MIT](LICENSE)

== Nothing to see here yet, scratchpad and will be rewritten using scripts at ort-gitlab-ci.

## F.A.Q

* TO-DO


