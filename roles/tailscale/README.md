# tailscale

Installs `tailscaled` and joins the tailnet when `tailscale_authkey` is non-empty (per-box secret from the consumer).

Does **not** own: ACL policy, laptop clients, or other VPN planes (e.g. Fly 6PN).

## Usage

```yaml
- ansible.builtin.include_role:
    name: softwarepatterns.infrastructure.tailscale
  vars:
    tailscale_authkey: "{{ vault_or_env_key }}"
    tailscale_advertise_tags: tag:builder   # optional
```
