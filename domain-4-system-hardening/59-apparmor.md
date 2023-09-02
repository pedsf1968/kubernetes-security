# Configure
## Check status of apparmor:
```sh
systemctl status apparmor
```
## Create sample Script:
```sh
mkdir /root/apparmor
cd /root/apparmor
```
```sh
nano myscript.sh
```
```sh
#!/bin/bash
touch /tmp/file.txt
echo "New File created"

rm -f /tmp/file.txt
echo "New file removed"
```
```sh
chmod +x myscript.sh
```
## Install Apparmor Utils:
```sh
apt install apparmor-utils -y
```

# Create apparmor profile
## Start to generate a new profile:
```sh
root@controlplane:~/apparmor# aa-genprof ./myscript.sh
Updating AppArmor profiles in /etc/apparmor.d.
Writing updated profile for /root/apparmor/myscript.sh.
Setting /root/apparmor/myscript.sh to complain mode.

Before you begin, you may wish to check if a
profile already exists for the application you
wish to confine. See the following wiki page for
more information:
https://gitlab.com/apparmor/apparmor/wikis/Profiles

Profiling: /root/apparmor/myscript.sh

Please start the application to be profiled in
another window and exercise its functionality now.

Once completed, select the "Scan" option below in
order to scan the system logs for AppArmor events.

For each AppArmor event, you will be given the
opportunity to choose whether the access should be
allowed or denied.

[(S)can system log for AppArmor events] / (F)inish
```

## Launch the script in other console

## Configure profile
- chose S
```sh
Reading log entries from /var/log/syslog.

Profile:  /root/apparmor/myscript.sh
Execute:  /usr/bin/touch
Severity: 3

(I)nherit / (C)hild / (N)amed / (X) ix On / (D)eny / Abo(r)t / (F)inish
```
- chose I
```sh
Profile:  /root/apparmor/myscript.sh
Execute:  /usr/bin/rm
Severity: unknown

(I)nherit / (C)hild / (N)amed / (X) ix On / (D)eny / Abo(r)t / (F)inish
```
- chose I
```sh
Complain-mode changes:

Profile:  /root/apparmor/myscript.sh
Path:     /dev/tty
New Mode: owner rw
Severity: 9

 [1 - include <abstractions/consoles>]
  2 - owner /dev/tty rw,
(A)llow / [(D)eny] / (I)gnore / (G)lob / Glob with (E)xtension / (N)ew / Audi(t) / (O)wner permissions off / Abo(r)t / (F)inish
```
- chose A
```sh
Adding include <abstractions/consoles> to profile.

Profile:  /root/apparmor/myscript.sh
Path:     /etc/ld.so.cache
New Mode: owner r
Severity: 1

 [1 - owner /etc/ld.so.cache r,]
(A)llow / [(D)eny] / (I)gnore / (G)lob / Glob with (E)xtension / (N)ew / Audi(t) / (O)wner permissions off / Abo(r)t / (F)inish
```
- chose A
```sh
Adding owner /etc/ld.so.cache r, to profile.

Profile:  /root/apparmor/myscript.sh
Path:     /etc/locale.alias
New Mode: owner r
Severity: unknown

 [1 - owner /etc/locale.alias r,]
(A)llow / [(D)eny] / (I)gnore / (G)lob / Glob with (E)xtension / (N)ew / Audi(t) / (O)wner permissions off / Abo(r)t / (F)inish
```
- chose A
```sh
Adding owner /etc/locale.alias r, to profile.

Profile:  /root/apparmor/myscript.sh
Path:     /tmp/file.txt
New Mode: owner w
Severity: unknown

 [1 - include <abstractions/user-tmp>]
  2 - owner /tmp/file.txt w,
(A)llow / [(D)eny] / (I)gnore / (G)lob / Glob with (E)xtension / (N)ew / Audi(t) / (O)wner permissions off / Abo(r)t / (F)inish
```
- chose A
```sh
Adding include <abstractions/user-tmp> to profile.

= Changed Local Profiles =

The following local profiles were changed. Would you like to save them?

 [1 - /root/apparmor/myscript.sh]
(S)ave Changes / Save Selec(t)ed Profile / [(V)iew Changes] / View Changes b/w (C)lean profiles / Abo(r)t
```
- chose S
```sh
Writing updated profile for /root/apparmor/myscript.sh.

Profiling: /root/apparmor/myscript.sh

Please start the application to be profiled in
another window and exercise its functionality now.

Once completed, select the "Scan" option below in
order to scan the system logs for AppArmor events.

For each AppArmor event, you will be given the
opportunity to choose whether the access should be
allowed or denied.

[(S)can system log for AppArmor events] / (F)inish
```
- chose F
```sh
Setting /root/apparmor/myscript.sh to enforce mode.

Reloaded AppArmor profiles in enforce mode.

Please consider contributing your new profile!
See the following wiki page for more information:
https://gitlab.com/apparmor/apparmor/wikis/Profiles

Finished generating profile for /root/apparmor/myscript.sh.
```
## Verify the new profile:
- see new profile in list
```sh
aa-status
```
- view configuration
```sh
cat /etc/apparmor.d/root.tt.script.sh
```
## Modify script add curl
```sh
#!/bin/bash
touch /tmp/file.txt
echo "New File created"

rm -f /tmp/file.txt
echo "New file removed"

curl -I google.com
```
- Execute the new script
```sh
 ./myscript.sh
New File created
New file removed
./myscript.sh: line 8: /usr/bin/curl: Permission denied
```
- disable apparmor
```sh
systemctl stop apparmor
./myscript.sh
New File created
New file removed
./myscript.sh: line 8: /usr/bin/curl: Permission denied
```




#### Disable a profile:
```sh
ln -s /etc/apparmor.d/root.apparmor.myscript.sh /etc/apparmor.d/disable/
apparmor_parser -R /etc/apparmor.d/root.apparmor.myscript.sh
```
