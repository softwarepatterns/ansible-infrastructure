# sshd stale-config — the failure mode this role exists to kill

Load-bearing facts, researched 2026-11. Do not re-derive; link here.

## The failure mode

OpenSSH reads its configuration when the **listener** process (re)starts.
Writing files under `/etc/ssh/sshd_config.d/` afterwards changes nothing
until SIGHUP (`systemctl reload ssh`) makes the listener re-exec. Nothing
in sshd watches files.

Observed on a live estate box:

1. Cloud-init wrote `50-cloud-init.conf` with `PasswordAuthentication yes`
   at first boot; sshd started with it.
2. Configuration management wrote a hardening drop-in 21 minutes later.
3. The deploy's change-notify did not fire — the file task reported
   "unchanged" on every later run because the file was already converged —
   and no later run ever re-triggered it.
4. The daemon served `PasswordAuthentication yes` for days while every
   check passed, because every check parsed config files fresh. They are
   structurally unable to see the running daemon.

Symptoms on the box: password auth offered on :22, constant
"Failed password" bot noise in the journal, and a client that mistakenly
connected to :22 received a password **prompt** instead of a clean
publickey-only refusal — the prompt itself was the staleness signal.

## The live probe

The only honest question is "what does the running listener offer right
now":

```
LC_ALL=C ssh -o BatchMode=yes -o PreferredAuthentications=none \
    -o StrictHostKeyChecking=accept-new -o ConnectTimeout=5 \
    <host> true
```

The role's probe sets `UserKnownHostsFile=/dev/null` and
`StrictHostKeyChecking=no` so it never writes `known_hosts` (the probe
never authenticates, so host-key checking is not load-bearing); this
hand-run debugging command may use `accept-new`. The role also sets
`check_mode: false` on that task so `ansible-playbook --check` still asks
the live listener. A skipped probe leaves the assert with an empty line,
and the assert then fails on a correct box.

`PreferredAuthentications=none` never authenticates; the server replies
with its method list. The answer appears on **stderr** and only with
**`-v`** (add `-v` when debugging by hand; the role passes it always):

```
debug1: Authentications that can continue: publickey
```

`LC_ALL=C` keeps the debug line's phrasing deterministic across locales
and client versions — the assertion extracts that one line and asserts on
it. The exact string is OpenSSH-client phrasing, not a stable protocol
message; the role documents the minimum client it is proven against in
`roles/sshd/README.md`.

## Gotchas carried into the role

- Without `-v` the client prints only `Permission denied (publickey).` —
  the offered-methods line is `debug1:` output on stderr. An assertion
  written without `-v` fails on a *correct* box.
- The `debug1:` line lands in the client's locale and version phrasing;
  probe with `LC_ALL=C` and assert on the extracted line, not the whole
  stderr.
- In `ansible.builtin.assert`, an UNQUOTED `that:` item containing
  `continue: publickey` parses as a YAML mapping (colon+space) and the
  module fails with "Conditional expressions must be strings". Quote items
  containing `: `.
- `PermitRootLogin` filters the method list per user — probe as a valid
  **non-root** user, or the answer for root is empty and the assertion
  fails on a correct box.
- `sshd -T` parses config files fresh and passes on a stale daemon. It is
  a diagnostic, never the enforcement.

## The reload ensure

The role reloads sshd when the daemon's last config load predates the
drop-in. The load time is systemd's `StateChangeTimestampMonotonic` — the
unit's state-change stamp, which restamps on every reload and start.
(`ExecMainStartTimestamp` does NOT restamp on reload: the listener
re-executes in place with the same main PID, so only the state-change
stamp advances. Verified empirically on Debian 12, not assumed.)

The comparison converts both events to ages — wall-clock age of the
drop-in (now − mtime) vs. monotonic age of the last state change
(uptime − stamp) — and reloads when the drop-in is younger. Comparing
ages rather than absolute times is what makes the check meaningful
across the two clocks; a guard (`mtime <= now`) means a future-dated
drop-in is not reloaded. There is no grace window — the live probe is the
backstop when wall-clock skew skips a reload.
