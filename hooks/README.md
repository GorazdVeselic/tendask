# Git hooks

Versioned git hooks for this repo. Activated via `core.hooksPath` (set once per
clone — it is local config, not carried in the repo):

```sh
git config core.hooksPath hooks
```

## `pre-push`

Runs `flutter analyze` (whole project) + `flutter test` before every push and
aborts the push if either fails. This is the safety net that keeps `main` (and
its CI) green — added after CI broke twice from pushing unverified code.

Emergency bypass (avoid making it a habit): `git push --no-verify`.
