# AGENTS.md

Short-form for agents working on `softwarepatterns/ansible-infrastructure`.

## Inviolable

1. **No greenfield rewrite of production.** Roles extract proven converge
   behavior. Never redesign a live traffic-serving host in place.
2. **One role = one resource (a noun).** Not a lifecycle phase.
3. **One change at a time.** Narrow, verifiable scopes.
4. **Public, generic, self-contained.** No secrets or unexposed hostnames/IPs
   in shipped `roles/` / `plugins/`.
5. **The running daemon is the resource** where that applies (see
   `.agents/references/sshd-stale-config.md`).
6. **A role ships with** README, defaults, tasks, meta, and a Molecule
   scenario directory (gate enforces presence). Live proof is the consuming
   box until Molecule scenarios are fully wired.
7. **Enforcement is `scripts/gate.sh`.** Commit hook ≡ push hook.
8. **Version pins are bare semver** (`0.1.1`). Bump `galaxy.yml` + tag
   `N` and `vN` on release. Consumers pin the bare version.

## Shipped roles (desired state)

`docker`, `sshd`, `tailscale`, `fly6pn` — see root `README.md`.

## Do not

- Restore rewrite-era trees from backup branches without human review
- Invent frameworks, phase roles, or unjustified custom modules
- Break file compatibility with Docker CE vs Debian `docker.io` without
  removing conflict packages first (`docker` role)
