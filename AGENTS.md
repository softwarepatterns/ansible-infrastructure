# AGENTS.md

Short-form for agents working on `softwarepatterns/ansible-infrastructure`.

## Inviolable

1. **No greenfield rewrite of production.** Roles extract existing, proven
   converge behavior. Byte-identical or proven no-op on a quiet box. Never
   “improve while moving,” never redesign a live traffic-serving host in
   place.
2. **One role = one resource (a noun).** Not a lifecycle phase, not a
   playbook section name, not a grab bag.
3. **One change at a time.** A subagent task moves or adds a single
   capability. No drive-by cleanups.
4. **Public, generic, self-contained.** No secrets, private keys, or
   unexposed hostnames/IPs in shipped `roles/` / `plugins/`.
5. **The running daemon is the resource** where that applies. Config files
   alone cannot prove a live listener (see
   `.agents/references/sshd-stale-config.md`).
6. **A role without proof does not ship.** When roles exist: README,
   defaults, tasks, meta, and a Molecule scenario (converge → idempotence →
   live verify). Gate enforces completeness per role directory.
7. **Enforcement is `scripts/gate.sh`.** Commit hook ≡ push hook.

## Empty collection

`0.0.0` ships no roles. Adding the first role is a deliberate product
decision: extract from a known-good consumer with zero behavior change,
then release above `0.0.0`.

## Do not

- Restore prior rewrite-era role trees from backup branches into `main`
  without human review of every task
- Pin or document `0.0.0` as production-ready
- Invent frameworks, phase roles, or custom modules without justification
