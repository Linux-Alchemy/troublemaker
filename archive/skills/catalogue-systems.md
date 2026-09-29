# Systems / services fault catalogue — starter bank

**Added 2026-09-24; expected to evolve.** The everyday support ticket that isn't networking or permissions: services, storage, packages, scheduling, time, logs. Same conventions as the networking bank. Anything here that stops SSH counts as a NIC-down-class fault (**difficulty 5+**).

| # | Shape | What a human did | Symptom the user reports | Depth | Undo shape |
|---|---|---|---|---|---|
| Y1 | Service won't start | Typo in a service's config file during "a quick change" | "The intranet page is down" / "the share's gone" | D1 | Fix the line, restart |
| Y2 | Disk full | A runaway log or a forgotten large file fills `/` or `/var` | "Nothing will save" / "the app throws errors" | D1 | Remove the file, restart what failed |
| Y3 | Inodes exhausted | Thousands of tiny temp files; `df -h` shows space free | "It says the disk is full but there's loads of space" | D3 | Remove the files |
| Y4 | Missing mount | An `/etc/fstab` entry commented out or its target renamed | "My shared folder is empty" | D2 | Restore the entry, `mount -a` |
| Y5 | Unit masked or disabled | Service disabled "while troubleshooting" and never re-enabled; comes back only after reboot | "It worked yesterday, not after the restart" | D1 | `systemctl unmask` / `enable --now` |
| Y6 | Cron job not running | A broken schedule line, or the script lost its execute bit | "The nightly backup report stopped arriving" | D2 | Fix the line / `chmod +x` |
| Y7 | Clock wrong | Time sync disabled and the clock set hours off | "Logins fail" / "certificate errors" / "timestamps are wrong" | D3 | Re-enable sync, correct the time |
| Y8 | Held or broken package | A package held, or a half-finished upgrade left dependencies broken | "Updates keep failing" | D2 | Release the hold, finish the upgrade |
| Y9 | Port already taken | A second program grabs the service's port first | "The service starts and immediately dies" | D2 | Stop/disable the squatter |
| Y10 | Resource limit | A tiny `LimitNOFILE`/`MemoryMax` drop-in on the service | "It works for a while, then falls over under load" | D3 | Remove the drop-in, `daemon-reload` |

**Good pairings for 7–8:** Y2 + Y1 (clear the disk, the config typo is still there); Y4 + Y5 (fix the mount, the service using it is still disabled); Y7 + Y6 (the job runs again, but at the wrong time).

**Red herrings that are safe:** a large but static old log in `/var/log`; a disabled unit nothing depends on; a stale `.rpmnew`/`.dpkg-old` file beside a config; an old failed-unit entry in the journal from last week.
