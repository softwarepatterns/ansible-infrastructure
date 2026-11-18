# softwarepatterns/ansible-infrastructure

Ansible collection `softwarepatterns.infrastructure`.

**Status: empty.** No roles ship. Version `0.0.0` is a clean skeleton only.
Do not consume this collection for production until a deliberate release
with real roles is published and pinned.

## Purpose

A versioned home for **resource-oriented** infrastructure roles (one noun
per coherent capability — e.g. a daemon, an engine, an account policy).
Estate boxes should include roles here instead of copying converge logic
between hosts.

## What this repo is not

- Not a place to rewrite live servers from scratch
- Not lifecycle phases (`bootstrap` / `deploy`) dressed as roles
- Not a dump of unproven “improvements” while moving code

## Structure

```
roles/                   # empty until a role is extracted with zero behavior change
plugins/                 # empty by design until a custom plugin is justified
meta/runtime.yml         # minimum ansible-core
.agents/references/      # load-bearing operational facts (not role code)
```

## Consuming (when roles exist)

```yaml
# requirements.yml — pin a real release tag, never 0.0.0
collections:
  - name: softwarepatterns.infrastructure
    type: git
    source: https://forgejo.softwarepatterns.com/softwarepatterns/ansible-infrastructure.git
    version: <release>
```

## Testing

`./scripts/gate.sh` — static gate on commit and push (`.githooks/`).

## License

Apache-2.0. See `LICENSE`.
