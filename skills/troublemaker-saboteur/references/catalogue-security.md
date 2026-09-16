# Security / permissions fault catalogue — starter bank

**Reviewed 2026-09-16, all kept; expected to evolve.** Staged in after three networking engagements (see main skill). Same conventions as the networking bank.

| # | Shape | What a human did | Symptom the user reports | Depth | Undo shape |
|---|---|---|---|---|---|
| S1 | Missing group membership | User removed from `docker` / `wheel` / a share group | "I can't run X any more, it says permission denied" | D1 | `usermod -aG` |
| S2 | Nearly-right permission bits | A shared directory is `750` owned by the wrong group | "Dave can see the folder but Sarah can't" | D1 | `chgrp` / `chmod` |
| S3 | Broken sudoers line | A typo in a `/etc/sudoers.d/` drop-in | "sudo just says 'syntax error' and refuses everything" | D2 | Fix via `visudo -f` |
| S4 | SSH key perms | `~/.ssh` or `authorized_keys` too open | "My key stopped working, it asks for a password now" | D2 | `chmod 700` / `600` |
| S5 | Locked account | `passwd -l` / expired password (`chage`) | "I can't log in, it just bounces me" | D1 | `passwd -u` / `chage` |
| S6 | `sshd_config` lockdown | `PasswordAuthentication no` + `AllowUsers` missing the user | "I can't SSH in from the new laptop" | D2 | Fix config, reload |
| S7 | Wrong ownership after "a restore" | A service's data dir owned by root, service runs as its own user | "The app won't start after the backup was restored" | D2 | `chown -R` |
| S8 | Immutable attribute | `chattr +i` on a config file "so nobody changes it" | "I edit the file, save, and it just… doesn't change" | D3 | `chattr -i` |
| S9 | PAM / login.defs oddity | `pam_time` or a `login.defs` change restricting hours/logins | "I can log in in the morning but not after 6" | D3 | Revert the PAM line |
| S10 | ACL overriding mode | A setfacl entry denying a user despite permissive bits | "ls says I should be able to read it but I can't" | D3 | `setfacl -x` |
