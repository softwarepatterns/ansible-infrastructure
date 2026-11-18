# plugins

Intentionally empty.

A collection skeleton includes `plugins/` (modules, filters, lookups, …).
This one ships none, and that emptiness is a lesson: custom modules are a
last resort. A module earns its place only when (1) no core/community
module owns the resource and (2) at least two consumers need the operation
programmatically. Until then, tasks and roles are the honest expression.

If a plugin appears here, it ships with tests — same law as roles.
