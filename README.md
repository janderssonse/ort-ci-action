<!--
SPDX-FileCopyrightText: 2022 Josef Andersson

SPDX-License-Identifier: MIT
-->


NOTE: GIT HISTORY WILL BE RESET WHEN PROJECT IS "good enough" for an initial commit and pass the experimental phase, so if you clone it, dont expect anything.

== Nothing to see here yet, scratchpad and will be rewritten using scripts at ort-gitlab-ci.




Should I Enable the ORT DOWNLOADER?


However, there are a few scenarios where you would not prefer that


GitLab CI:
If you are including the template in a CI-flow/Pipeline organisation wide and don't want it to run on the default branch latest, and don't want to add ssh keys for every repo, i.e you want to use the default GIT_STRATEGY.

If using the ORT Downloader, including the template in CI flow, set the GIT_STRATEGY to none, because you do want to handle the clone/fetch through ORT, not through the default CI pipe.

Should I change the PROJECT_DIR?

GitLab CI: The default value is 'project', and if you are allowed to configure GIT_CLONE_PATH on your runners to a specific dir, set that to the project path.
If this is not enabled, set the PROJECT_DIR to "./"
Ideally, the project you want to run ort on should be in the CI.../.../<default build dir>../project.

