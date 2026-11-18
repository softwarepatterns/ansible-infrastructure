# sshd

Hardens the **running** host sshd: drop-in (outranks cloud-init), reload-ensure when the daemon predates the file, live probe that offered methods are publickey-only.

Does **not** own: authorized_keys, accounts, firewall, application SSH (e.g. forge git on another port).

See `.agents/references/sshd-stale-config.md`.

## Usage

```yaml
- ansible.builtin.include_role:
    name: softwarepatterns.infrastructure.sshd
    tasks_from: converge
# optional path override for an existing drop-in name on a box:
# vars:
#   sshd_dropin_path: /etc/ssh/sshd_config.d/00-builder-hardening.conf
```
