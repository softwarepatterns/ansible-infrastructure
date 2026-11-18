# fly6pn

Installs a Fly **6PN WireGuard client** peer config and ensures `wg-quick@<iface>` is up. Verifies a live handshake.

Does **not** own: generating the peer (`fly wireguard create` stays on the controller), Tailscale, or application mail checks.

## Usage

```yaml
- ansible.builtin.include_role:
    name: softwarepatterns.infrastructure.fly6pn
  vars:
    fly6pn_config_src: "{{ playbook_dir }}/../fly6pn-{{ inventory_hostname }}.conf"
    fly6pn_interface: fly6pn
```
