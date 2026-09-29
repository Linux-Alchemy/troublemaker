# Fault catalogue

Shapes, not scripts. Vary the specifics. Windows/AD first: it's the support-role gap.
Anything that cuts the trainee's network access to the guest is **medium or hard only**.

| Area | Fault shapes |
|---|---|
| **AD / accounts** | Locked account · expired password · user removed from a group · disabled account · user or computer in the wrong OU, so a GPO doesn't apply |
| **GPO / client** | GPO link disabled · security filtering excludes the user · drive map pointing at a renamed share |
| **Windows services** | Service disabled · wrong logon account · share permissions vs NTFS permissions mismatch |
| **Name resolution** | Client DNS pointed away from the DC · stale DNS record · hosts-file override |
| **Domain trust** | Clock skew breaking Kerberos · machine account password out of sync ("trust relationship failed") |
| **Linux services** | Config typo · masked or disabled unit · disk or inodes full · missing fstab mount · port already taken |
| **Linux access** | Missing group · sudoers typo · SSH key permissions · locked account · wrong ownership after a "restore" |
| **Host networking** | Wrong resolver · host firewall blocking a port · service bound to localhost only |

**Hard pairings:** fix one and the other shows (disk full + config typo; wrong OU + disabled GPO link; clock skew + stale DNS).

The access and service items (sudoers, permissions, service accounts) double as privilege-escalation findings for CJCA-style practice later.
