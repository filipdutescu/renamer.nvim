# Contributing to `renamer.nvim`

## Getting started

If you want to help but don't know where to start, here are some
low-risk/isolated tasks:

- Have a look at the [available issue templates][issue-templates] and checkout
  [examples of good first issues][good-first-issues].
- Look through the [issues that need help][help-wanted].
- Take a look at a [Pull Request template][pr-template] to get yourself started.

## Reporting problems

- [Search existing issues][github-issues] (including closed!)
- Update Neovim and `renamer.nvim` to the latest version to see if your problem
  persists.
- [Bisect (git)][git-bisect] `renamer.nvim`'s source code to find the cause of a
  regression, if you can. This is _extremely_ helpful.
- Check the Neovim logs (`:edit $NVIM_LOG_FILE`).

## Developer guidelines

### Pull requests (PRs)

- To avoid duplicate work, create a draft pull request.
- Your PR must include [test coverage][run-tests], in the sense that there are
  tests which cover its changes.
- Avoid cosmetic changes to unrelated files in the same commit.
- Use a [Gitflow branch][gitflow-workflow] instead of the master branch.
- Use a **rebase workflow** for all PRs.
    - Before submitting for review, ensure your branch is rebased with the base
      and passes all of the [required actions][github-actions].
    - After addressing review comments, you should rebase and force-push.

### Stages: Draft and Ready for review

Pull requests have two stages: Draft and Ready for review.

1. [Create a Draft PR][pr-draft] while you are *not* requesting feedback as
  you are still working on the PR.
    - You can skip this if your PR is ready for review.
2. [Change your PR to ready][pr-ready] when the PR is ready for review.
    - You can convert back to Draft at any time.

Do **not** add labels like `[RFC]` or `[WIP]` in the title to indicate the
state of your PR: this just adds noise. Non-Draft PRs are assumed to be open
for comments; if you want feedback from specific people, `@`-mention them in
a comment.

### Commit messages

Follow the [Conventional Commits guidelines][conventional-commits] to *make
reviews easier* and to make the VCS/git logs more valuable. The general structure
of a commit message is:

```
<type>([optional scope]): <description>

[optional body]

[optional, Related issue: GH-XX]
Signed-off-by: Name Surname <email-address>
```

- Prefix the commit subject with one of these [*types*](https://github.com/commitizen/conventional-commit-types/blob/master/index.json):
    - `build`, `ci`, `docs`, `feat`, `fix`, `perf`, `refactor`, `revert`, `test`, `vim-patch`, `chore`
    - You can **ignore this for "fixup" commits** or any commits you expect to be squashed.
- Append optional scope to *type* such as `(defaults)`, `(makefile)`, `(setup)`, …
- *Description* shouldn't start with a capital letter or end in a period.
- Use the *imperative voice*: "Fix bug" rather than "Fixed bug" or "Fixes bug."
- Try to keep the first line under 72 characters.
- A blank line must follow the subject.
- Breaking API changes must be indicated by
    1. `!` after the type/scope, and
    2. a `BREAKING CHANGE` footer describing the change.
       Example:
       ```
       refactor(provider)!: drop support for Python 2

       BREAKING CHANGE: refactor to use Python 3 features since Python 2 is no
       longer supported.
       ```
- If your pull request is related to an issue, add the `Related issue: GH-XX`
  footer, where `XX` is the number of that issue.
- ***Sign off your commits***. This can be done by either writing the footer as
  above, or by using the `-s` flag for the `git commit` command.

### Automated builds (CI)

Each pull request must pass the automated builds on [GitHub Actions][github-actions].

- If any tests fail, the build will fail.
  See [lua/tests/README.md#running-tests][run-tests] to run tests locally.
  Passing locally doesn't guarantee passing the CI build, because of the
  different compilers and platforms tested against.
- The [commit lint][github-actions] build checks modified lines *and their immediate
  neighbors*, to encourage incrementally updating the legacy style to meet the
  project's style.
- There is also a style check job, that needs to pass in order for a pull request to
  be accepted and merged.

[conventional-commits]: https://www.conventionalcommits.org
[git-bisect]: http://git-scm.com/book/en/v2/Git-Tools-Debugging-with-Git
[gitflow-workflow]: https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow
[github-actions]: https://github.com/filipdutescu/renamer.nvim/actions
[github-issues]: https://github.com/filipdutescu/renamer.nvim/issues
[good-first-issues]: https://github.com/filipdutescu/renamer.nvim/labels/good%20first%20issue
[help-wanted]: https://github.com/filipdutescu/renamer.nvim/labels/help%20wanted
[issue-templates]: https://github.com/filipdutescu/renamer.nvim/issues/new/choose
[pr-draft]: https://docs.github.com/en/github/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request
[pr-ready]: https://docs.github.com/en/github/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/changing-the-stage-of-a-pull-request
[pr-template]: https://github.com/filipdutescu/renamer.nvim/blob/develop/.github/pull_request_template.md
[run-tests]: https://github.com/filipdutescu/renamer.nvim/blob/develop/lua/tests/README.md#running-tests

