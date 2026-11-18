# softwarepatterns/ansible-infrastructure

Ansible collection `softwarepatterns.infrastructure` — shared **capability
roles** for estate boxes (build-box, mail-box, …).

## Roles (0.1.1)

| Role | Resource |
|---|---|
| `docker` | Docker engine (apt source, packages, service) |
| `sshd` | Host sshd keys-only drop-in + live publickey probe |
| `tailscale` | tailscaled install + optional join via auth key |
| `fly6pn` | Fly 6PN WireGuard client install + handshake verify |

Product-specific roles (Forgejo, JuiceFS volume, Databasus, runners) stay
in the consuming repos.

## Consume

```yaml
# requirements.yml
collections:
  - name: softwarepatterns.infrastructure
    type: git
    source: https://forgejo.softwarepatterns.com/softwarepatterns/ansible-infrastructure.git
    version: 0.1.1
```

```bash
ansible-galaxy collection install -r requirements.yml
```

```yaml
- ansible.builtin.include_role:
    name: softwarepatterns.infrastructure.sshd
    tasks_from: converge
```

Pin a release. Bump deliberately. Do not use `0.0.0`.

## Law

- One role = one noun/resource
- No greenfield rewrite of production behavior
- Public, no secrets or unexposed hostnames in shipped roles
- Gate: `./scripts/gate.sh`

## License

Apache-2.0. See `LICENSE`.
