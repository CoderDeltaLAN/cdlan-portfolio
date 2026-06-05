# Repository Governance

This repository is the public professional portfolio for CDLAN / Yosvel Delta.

It must stay clean, auditable and commercially responsible from the first commit onward.

## Core rule

Nothing reaches main without evidence.

Evidence means:

- clean local status;
- real files read before editing;
- minimal scoped change;
- local checks passed;
- exact staging;
- staged diff reviewed;
- commit created only after checks;
- strong pre-push validation;
- pull request opened;
- CI green for the exact SHA;
- PR diff reviewed;
- pre-merge validation complete;
- post-merge main verified;
- branch cleaned after merge.

## Branch policy

After the initial bootstrap commit, all changes must use a branch.

Allowed branch prefixes:

- chore/
- docs/
- feat/
- fix/

One branch must contain one logical change.

Do not mix unrelated work.

## Main policy

Do not work directly on main after bootstrap.

Main must represent the best known stable public state of the portfolio.

Main must remain:

- clean;
- synchronized with origin/main;
- verifiable locally;
- backed by CI when applicable.

## Change policy

Before editing, read the current repository state.

For every phase:

1. checkpoint main;
2. create branch;
3. read relevant files;
4. apply minimal change;
5. run checks before stage;
6. stage exact files only;
7. review staged diff;
8. commit;
9. run strong pre-push checks;
10. push branch;
11. verify remote branch and CI;
12. open pull request;
13. verify PR state, checks and diff;
14. run pre-merge validation;
15. merge with exact head SHA;
16. verify main after merge;
17. verify CI for main SHA when applicable;
18. delete local and remote branch;
19. close the phase with clean status.

## Staging policy

Never use git add .

Stage only expected files.

If an unexpected file appears, stop and inspect before continuing.

## Security policy

This repository is public.

Never commit:

- credentials;
- tokens;
- API keys;
- private prompts;
- real N8N workflow exports;
- backend internals;
- SaaS internals;
- client material;
- private commercial strategy;
- logs with sensitive data;
- screenshots with private information.

## Content policy

Public claims must be modest, sober and defensible.

Do not publish:

- fake metrics;
- invented clients;
- exaggerated AI claims;
- unsupported performance numbers;
- unverified pricing;
- unverified tax claims;
- model/version claims that may become outdated.

Laboratory work must be labeled as laboratory work.

Private systems must stay private.

## Website policy

The public website can include:

- brand presentation;
- public services;
- non-sensitive portfolio items;
- public GitHub links;
- static HTML, CSS and JavaScript;
- contact information approved for publication.

The public website must not include:

- secrets;
- backend logic;
- private automations;
- private prompts;
- client data;
- unsupported claims;
- unfinished placeholders.

## Pages policy

GitHub Pages must not be activated without explicit approval.

Before publication:

- index.html reviewed;
- links reviewed;
- contact reviewed;
- accessibility basics reviewed;
- performance reviewed;
- no secrets;
- no placeholders;
- CI green;
- main clean.

## Definition of done

A phase is done only when:

- PR is merged;
- main is clean;
- main is synchronized with origin/main;
- local checks pass;
- CI for the relevant SHA is green when applicable;
- no open PR remains for the branch;
- local branch is deleted;
- remote branch is deleted;
- no staged or untracked accidental files remain.
