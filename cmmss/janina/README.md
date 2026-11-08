# Janina

`cmmss/run` creates a locked, hidden `janina` account and starts current stable
T3 on port 3773 at boot. Janina uses Homebrew Bash.

The personal Android SDK is shared read-only. Its parent directories allow
search, so known paths remain accessible subject to normal permissions. Other
homes are blocked.

Device support is enabled. Pair a client, sign into providers, and provision
compatible iOS runtimes and Android AVDs. launchd writes stdout and stderr to
`/var/log/janina-t3.log`.

Reruns leave T3 running. Restart when idle to apply updates. FileVault still
needs unlock; the existing cmmss sleep policy stays unchanged.
