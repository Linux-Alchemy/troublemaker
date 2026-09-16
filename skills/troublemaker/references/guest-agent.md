# The out-of-band channel: QEMU guest agent

Everything the saboteur and tutor do on a guest goes through here. No SSH, ever.

## Prerequisites (checked by the lab agent, verified by us at Open)

- In the guest: `qemu-guest-agent` installed and enabled (`systemctl is-active qemu-guest-agent`).
- On the domain: a virtio-serial channel named `org.qemu.guest_agent.0`. virt-manager adds it by default; check with
  `virsh dumpxml <dom> | grep -A3 'org.qemu.guest_agent.0'`.

## Connection

Run on Shadowvault, always as `virsh -c qemu:///system` — the `reaper` user is in the `libvirt` group, so no sudo. Plain `virsh` connects to the per-user session, which is empty; that is the first thing to suspect when a domain "doesn't exist". From Legion, `tailscale ssh shadowvault` and work there; SV runs no `sshd`, so `qemu+ssh://` URIs fail. Below, `$V` is `virsh -c qemu:///system`.

## The three calls that matter

Ping — the guest agent is alive:
```bash
$V qemu-agent-command <dom> '{"execute":"guest-ping"}'
# {"return":{}}
```

Run a command — two steps, because exec is asynchronous:
```bash
$V qemu-agent-command <dom> \
  '{"execute":"guest-exec","arguments":{"path":"/bin/sh","arg":["-c","ip -br addr"],"capture-output":true}}'
# {"return":{"pid":1234}}

$V qemu-agent-command <dom> '{"execute":"guest-exec-status","arguments":{"pid":1234}}'
# {"return":{"exited":true,"exitcode":0,"out-data":"<base64>","err-data":"<base64>"}}
```
`out-data` and `err-data` are base64. Commands run as root inside the guest — no `sudo` needed, and no excuse for carelessness.

Write a file — for dropping a config in one go rather than escaping heredocs through JSON:
```bash
$V qemu-agent-command <dom> '{"execute":"guest-file-open","arguments":{"path":"/etc/foo.conf","mode":"w"}}'
# {"return":5}
$V qemu-agent-command <dom> '{"execute":"guest-file-write","arguments":{"handle":5,"buf-b64":"<base64 of content>"}}'
$V qemu-agent-command <dom> '{"execute":"guest-file-close","arguments":{"handle":5}}'
```

## The wrapper: `scripts/gx.sh`

Hand-rolling the two calls above for every command is the transport tax of the out-of-band standard, so the skill ships the wrapper:

```bash
skills/troublemaker/scripts/gx.sh <domain> '<shell command>'
# e.g.
gx tm-01 'ip -br addr'
gx tm-01 'systemctl is-active systemd-resolved' || echo "resolver is down"
```

Stdout is the guest command's stdout, stderr its stderr, exit code its exit code. Put it on `PATH` or alias it at the start of a session. Needs `jq`, which SV has.

This is the one deliberate exception to the repo's "no scripts until done by hand three times" rule: that rule is about workflow steps whose repeatable shape isn't known yet, and `gx` is the transport the standard depends on — its shape is the guest-agent protocol, which is fixed. A script the saboteur is *told to use* is also a stronger guarantee of "never SSH" than a function it is told to paste.

## Snapshots, for completeness

```bash
$V snapshot-create-as <dom> pre-<run> "before troublemaker run <run>"
$V snapshot-list <dom>
$V snapshot-revert <dom> pre-<run>      # Matt, by hand, at Close
```

## Things this channel will not do

- Interactive sessions. That's what `virsh console` is for, and it's the trainee's, not ours.
- Survive the guest agent being stopped, masked, or uninstalled. Hence the saboteur's first rule.
- Reach a guest that is powered off. Hence the second.
