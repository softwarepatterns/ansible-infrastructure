# docker

Converges the Docker **engine**: signing key, deb822 apt source, CE/CLI/plugins packages, `docker` service.

Does **not** own: group membership, sudoers, authorized_keys, images, or compose projects.

## Knobs

See `defaults/main.yml`. Override `docker_apt_key_sha256` when Docker rotates the key.

## Usage

```yaml
- ansible.builtin.include_role:
    name: softwarepatterns.infrastructure.docker
```
