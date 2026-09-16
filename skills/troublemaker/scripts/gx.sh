#!/usr/bin/env bash
# gx — run one shell command inside a libvirt guest through the QEMU guest agent.
#
#   gx <domain> '<shell command>'
#
# Prints the guest command's stdout, forwards its stderr, and exits with its exit code.
# No network involved: this is the out-of-band standard the troublemaker skills depend on.
# Needs: virsh with access to qemu:///system, jq, base64.
set -u
V="virsh -c qemu:///system"

usage() { echo "usage: gx <domain> '<shell command>'" >&2; exit 64; }
[ $# -eq 2 ] || usage
dom="$1" cmd="$2"

# guest-exec is asynchronous: start it, get a pid, poll for exit.
req=$(jq -cn --arg c "$cmd" '{execute:"guest-exec",arguments:{path:"/bin/sh",arg:["-c",$c],"capture-output":true}}')
pid=$($V qemu-agent-command "$dom" "$req" | jq -r '.return.pid') || exit 70
[ -n "$pid" ] && [ "$pid" != null ] || { echo "gx: guest-exec on $dom returned no pid" >&2; exit 70; }

# Cap the wait at 10s. A lab guest slower than that is a finding, not a reason to wait longer.
for _ in $(seq 1 50); do
  st=$($V qemu-agent-command "$dom" "$(jq -cn --argjson p "$pid" '{execute:"guest-exec-status",arguments:{pid:$p}}')")
  [ "$(printf '%s' "$st" | jq -r '.return.exited')" = true ] && break
  sleep 0.2
done
[ "$(printf '%s' "$st" | jq -r '.return.exited')" = true ] || { echo "gx: pid $pid on $dom did not exit within 10s" >&2; exit 75; }

printf '%s' "$st" | jq -r '.return."out-data" // empty' | base64 -d
printf '%s' "$st" | jq -r '.return."err-data" // empty' | base64 -d >&2
exit "$(printf '%s' "$st" | jq -r '.return.exitcode // 1')"
