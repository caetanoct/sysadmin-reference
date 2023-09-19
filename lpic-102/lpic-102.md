# Scheduling

## Cron

Cron is a daemon that wakes up every minute to check a set of tables (`crontabs`) if there is a task (`cronjob`) available to execute.

Any user has their personal crontab and root has the system crontabs.

### User Crontabs

Named after the user that created them, generally located on `/var/spool/cron`

Each line contains six fields separated by space:
* Minute of the hour (0-59)
* Hour of the day (0-23)
* Day of the month (1-31)
* Month of the year (1-12)
* Day of the week (0-7 with sunday=0 or sunday=7)
* The command to run

For month of the year and day of the week you can use the first three letters also.

The fields (except the command field) can contain one or more values, you can specify multiple values using:

- `*`
    to refer to any value
- `,`
    specify a list of possible values
- `-`
    specify a range of possible calues
- `/`
    specify stepped values

you can find a layout on `/etc/crontab` on most distros.

### System Crontabs

can only be edited by the root user. `/etc/crontab` and all files in `/etc/cron.d` are system crontabs.

you also have directories like `/etc/cron.daily` `/etc/cron.hourly/` `/etc/cron.weekly` `/etc/cron.monthly`.

The system crontab format is the same as the user except for and extra field before the command, that specified which user account will be used to run the command.

you can also use the following shortcuts instead of time specs:

- @reboot
    run the task after reboot
- @hourly
    once an hour at the beginning of the hour
- @daily (or @midnight)
    once a day at midnight
- @weekly
    once a week on sunday
- @monthly
    once a month at midnight of the first day
- @yearly (or @anually)
    once a year at midnight on the 1st of january

### Crontab Variables

These are variable assignments defined before the tasks are declared:

- HOME
    directory where cron invokes the command (default=user home directory)
- MAILTO
    name of the user or the address to which stoud and stderr is mailed. multiple comma-separated values are allowed and an empty value indicates no mail should be sent.
- PATH
    path where commands can be found
- SHELL 
    shell to use (default /bin/sh)

### Creating User Cronjobs

`crontab -e` uses VISUAL or EDITOR variables to start editing the crontab file.

`-l` is used to display current crontab to stdout
`-r` is used to remove the current crontab
`-u` is used to specify the name of the user whose crontab need to be modified.

### Creating System Cronjobs

Updated using an editor (`/etc/crontab` and `/etc/cron.d`). Remember to specify the user to run.

Unless output/stderr is redirected to a place, all output from a cronjob will be sent to the user via email. Common practice is to redirect stdout to /dev/null and to not redirect stderr. This way a user will be notified by email of any errors.

### Configuring Access to Job Scheduling

In linux the `/etc/cron.allow` and `/etc/cron.deny` files are used to set `crontab` restrictions.

if `/etc/cron.allow` exists, only users withing it can schedule cronjobs using crontab command
if `/etc/cron.deny` exists, only users listed in this file cannot schedule cronjobs using crontab command.

(root does not apply to cases above)

if neither of these files exists, user access to cronjob scheduling depends on the distribution

## Alternative to Cron (systemd)

In systemd, you can set *timers* as an alternative to cron. They are systemd unites suffixed by `.timer`. For each of these timers, you need a corresponding unit file which describes the unit to be activated. By default, a timer activates a service with the same name except for the suffix.

On `/etc/systed/system/`
```
[Unit]
Description=Run the foobar service on the first monday of the month at 5:30

[Timer]
OnCalendar=Mon *-*-1..7 05:30:00
Persistent=true

[Install]
WantedBy=timers.target
```

the OnCalendar syntax is: `DayOfWeek Year-Month-Day Hour:Minute:Second`

you can also use `*`, `/` and `,` operators, but the range operator is defined by `..`. you can also use the first three letters on day of week.

you can modify the OnCalendar value and then type `systemctl daemon-reload`.

you can view a list of active timers sorted by the time they elapse next by using `systemctl list-timers` and you can add `-all` option to see inactive timers.

you can specify particular frequencies for job execution (hourly, daily, weekly, mothly, yearly).

> remember, timer logs go to system journal (journalctl to read). full list of time and date specs: systemd.timer(5)

## `at` command

at is used for one-time task scheduling, for a specific job. example: `at now +5 minutes` will prompt you for command to be executend and then you press Ctrl+D to exit the prompt.
output is sent by email. `atd` daemon must be running in the system. at options:

`atq` is used to list a queue. `atrm` to remove scheduled jobs. you also have  `/etc/at.deny` and `/etc/at.allow`.

## `systemd-run` command

similar to at, can be used to schedule one-time tasks. for example: `systemd-run --on-calendar='2023-09-05 10:00' date` or to run after a 2 minutes for example: `systemd-run --on-active="2m" ./foo.sh`

# Desktop Environments

## X Window System (X11)

- X Windows System is a software stack used to display text and graphics on screen. It is multi-platform and can run on Linux, UNIX-like, solareis, BSD's, macOS and Windows.
- The overall interface look is dictated by the X client.
- The most used version used in modern linux distributions is X.org version 11 (X11).
- The X protocol is the communication mechanism between the X client and X server.

History: the predecessor was a window system called W and was a joint effort between IBM, DEC and MIT. Born out of project athena in 1984. Evolution is controlled by the MIT X Consortium.

1. The software provides mechanisms for drawing 2D shapes.
2. It is divided in client and server.
3. The client is an application (game, browser, terminal emulator).
4. The client informs the X server about its window location and size on a computer screen.
5. The client tells what goes into that window and the X server draws up on the screen.
6. X system also handles input from mice, keyboards, trackpads and more..

### Screens

- The X system is network-capable and different computers can make drawing requests to a single remote X server. With this, and administrator can have access to a graphical application on a remote system that may not be available on their local system.
- A *display manager* provides graphical login to a system (either remote or local). Example: GDM, SDDM, LightDM. Each instance has a display name in the format:
    ```
    hostname:displaynumber.screennumber
    ```
    - if hostname is blank, then it is localhost. it is where the system will display the application.
    - each running X server session is given a display number starting at 0.
    - default screennumber is 0. this can be the case if only one physical screen or multiple physical screens are configured to work as one screen.
    - when all screens are combined into one logical screen, applications can move freely between the screen. if is configured separated, then application can not be moved from one screen to another.
    - if there is only one logical sreen, then the dot and screen number are omitted.

The output of echo $DISPLAY == `:0` means:
1. X server is on local system.
2. Current X server session is the first.
3. One logical screen in use.

- To start an application on a specific screen, assign the screen number to the DISPLAY variable, example:
    ```bash
    DISPLAY=:0.1 firefox &
    ```

### X Server Configuration

Usually on `/etc/X11/xorg.conf`. On modern linux distributions, the X server will configure itself at runtime when the X server is started, so no xorg.conf file may exist.

Typical sections in configuration file are:

InputDevice is used to configure specific model of keyboard or mouse
InputClass is configure a class of hardware such as keyboard and mice rathen than a specific piece of hardware. a tabel of models and layouts can be found on `xkeyboard-config(7)`
    example:
        ```
        Section "InputClass"
            Identifier "system-keyboard"
            MatchIsKeyboard "on"
            Option "XkbLayout" "us"
            Option "XkbModel" "pc105"
        EndSection
        ```

Modern linux ditributions provied the `localectl` command via `systemd` to modify keyboard layout. example: `localectl --no-convert set-x11-keymap "gr(polytonic)" chromebook`

Monitor is used to configure monitors, which monitor is the primary.
Device described the physical video card that is used. also kernel module used as the driver and physical location on the motherboard.
Screen ties monitor and device together.
ServerLayour section groups all section such as mount keyboard and screens into one X window system interface.

configuration files in `/etc/X11/xorg.conf.d` take precedence to `/etc/X11/xorg.conf`

the `xdpyinfo` command is  used on a computer to display information about a running X server.

to generate a permanent `/etc/X11/xorg.conf` run `sudo Xorg -configure`

reference: xorg.conf(5), Xserver(1), X(1) and Xorg(1).

## Wayland

- Newer display protocol. Lighter on system resources, smaller installation footprint. begand in 2010 and is in active development.
- No server instance between the client and kernel.
- Client window works with own code or that of a toolkit (Qt or Gtk+, for example)
- To render, a request is made to the linux kernel using the wayland protocol.
    - Kernel then forwards to the wayland compositor, which handles device input, window management and composition.
- Modern toolkits like Gtk+ 3 and Qt 5 have been updated to allow rendering in either X11 or Wayland, however, there are still applications that don't support wayland.
- Xwayland can be used to render targeted X window systems. It is a X server that runs within a wayland client.
- variable `WAYLAND_DISPLAY` keep track of screens in use.


## Desktop Environments

- GNOME
- KDE (Qt)
- XFCE (low resource consumption)
- LXDE (even lower resource consumption)

## Remote Graphical Desktop Sessions

- xdmcp (X display manager control protocol), high bandwidth usage, and security issues.
- VNC (virtual network computing) uses RFB protocol. events produced by the local keyboard and mouse are transmitted to the remote desktop, which in turn sends back any screen updates. usually the TCP port 5900, 5901,.. for this protocol. Methods involving VPN and SSH tunnels are often used to secure VNC connections because they are unencrypted.
- RDP (remote desktop protocol), port 3389, mainly used to access windows machines but there are client implementation used in Linux Systems that are open-source.
- Spice (simple protocol for independent computing environments) comprises suite of tools aimed at accessing virtualised systems. can access local devices from the remote machine and file sharing.
- Rmmina remote desktop client provides integrated graphical interface that facilitates the connection. has plugins for the protocols above.

## Accessibility

It is possible, for example, to adjust desktop colors to better serve color-blin people. Alternate typing and pointing methods. The accessibility setting module is called *Universal Access* in Gnome, and in KDE they are under System Settings -> Personalization -> Accessiblity.

### Keyboard and Mouse Assist

Key combinations, Key auto repeat rate and unintended key presses can be obstacles for users with reduced hand mobility. They are addressed by: **Sticky Keys**, **Bounce Keys** and **Slow Keys**.

Sticky keys lets you to make key combinations without having to press all of them at the same time. In KDE for example, you can have locking keys, which make ctrl, alt and shift be pressed when you press them twice.

Bounce Keys tries to inhibit unintended key presses by placing a delay between them. 

Slow Keys also helps to avoid accidental key strokes. Slow keys require the user to hold down the key for a specified length of time.

Mouse Keys allows the user to control the mouse pointer itself with the numerical keypad.

If the Screen Keyboard switch in Gnome’s Universal Access settings is enabled, then an on-screen keyboard will appear every time the cursor is in a text field and new text is entered by clicking the keys with the mouse or touchscreen.

onboard package can be manually installed to provide a simple on-screen keyboard.

If the user is not able to click the mouse button quick enough to trigger a double-click event, for example, the time interval to press the mouse button a second time to double-click can be increased in the Mouse Preferences in the system configuration window.

If the user is not able to press one of the mouse buttons or none of the mouse buttons, then mouse clicks can be simulated using Click Assist.

### Visual Impairments

Gnome’s Seeing section of Universal Access settings provide options.

**High Contrast**

will make windows and buttons easier to see by drawing them in sharper colors.

**Large Text**

will enlarge the standard screen font size.

**Cursor Size**

allows to choose a bigger mouse cursor, making it easier to locate on the screen.

Screen Reader can be used to report screen events and reat text under mouse cursos.

# Administrative Tasks

## Adding User Accounts

- You can add a new user using `useradd $USERNAME`.
- After creation you can use the `passwrd $USERNAME` command to set the user password.
- You can review UID using `id $USERNAME`.
- You can review GID and groups through `groups $USERNAME` command.

If you just type `id` or `groups` without arguments it should also display useful information.

Options for useradd command:

- -c
    Creates new user with custom comments
- -d
    Creates new user with custom home directory
- -e
    Creates new user by setting a specific date on which it will be disabled
- -f
    Create a new user account by setting the number of days after a password expires the user should update.
- -g
    Create user with specific GID
- -G
    Creates new user adding it to multiple secondary groups
- -k
    Creates new user account by copying skeleton files from specific directory. if -m or --create-home options is specified
- -m
    Creates new user account with its home directory
- -M
    Create new user account without its home directory
- -s
    Creates new user account with specific login shell
- -u
    Creates user with specific UID.

## Modifying User Accounts

`usermod` flags:

- -c
    brief commend to the user account
- -d
    change home directory of the specified user account
- -e
    expiration date of user account
- -f
    set the number of days after a password expire which the user should update the password (or account will be disabled)
- -g
    Change primary group of the specified user account
- -G
    Add secondary groups. Comma separated. if used alone this option removes all groups to which the user belongs, while when used with -a it will append to existings
- -l
    change login name of the specified user account
- -L
    lock specified user account, puts exclamation mark in fron of /etc/shadow disabling access with password for that user
- -s
    change login shell of the user account
- -u
    change uid of the user account
- -U
    unlock specified used account. Removes exclamation mark in front of encrypted password with the /etc/shadow.

## Deleting User Accounts

`userdel -r $USERNAME` the -r flag removes user home directory and user mail spool

## Adding, Modifying and Deleting Groups

- groupadd, groupmod, groupdel.

`groupadd -g 1010 developer`

## Skeleton Directory

`/etc/skel`. newly home cretaed is populated with files and folders from this directory.

## The `/etc/login.defs` file

This file specified configuration parameters that control the creation of users and groups.

for example:

UID_MIN, UID_MAX, GID_MIN, GID_MAX
max and minimum uid, gid

CREATE_HOME

should create home directory for new users by default

USERGROUPS_ENAB

wheter the system should by default create a new group for each user account with the same name as the user.

MAIL_DIR

mail spool directory

PASS_MAX_DAYS

max number of days a password may be used

PASS_MIN_DAYS

minimum number of days allowed between password changes

PASS_MIN_LEN

minimum acceptable password length

PASS_WARN_AGE

nmber of warning days before password expires

## `passwd` command

any user can change its password but only root can change others passwords.

- -d
    to delete password (disabling user)
- -e
    force password change
- -i
    number of days of inactivity after password expires during which user should update the passwords.
- -l
    lock user account
- -n
    minimum password lifetime
- -S
    information about the password status
- -u
    unlock user accoiunt
- -x
    maximum password lifetime
- -w
    number of days of warning before passsword expires during which the user is warned that the password must be chagned

> Groups can also have a password, which can be set using the gpasswd command. Users, who are not members of a group but know its password, can join it temporarily using the newgrp command. Remember that gpasswd is also used to add and remove users from a group and to set the list of administrators and ordinary members of the group

## `chage` command

change password aging information. restricted to root (except for the -l option, used to list password aging information of own account)

- -d
    last password change for a user account
- -E
    expiration date for a user account
- -I
    numbber of days of inactivity after a password expires during which the user should update the password (or account will be disabled)
- -m
    set the minimum password lifetime for a user account
- -M
    set the maximum password lifetime for a user
- -W
    number of days of warning

## `/etc/passwd`

Seven (7) colon separated fields containing information about users.

username:password:uid:gid:gecos:homedir:shell

password is the encrypted password or x if shadow passwords are userd
gecos: optional comment field
gid: primary group id

## `/etc/group`

Four (4) colon separated fields containing information about groups.

grpname:grppasswd:gid:memberlist

memberlist: comma delimited list of users that belongs to group except those for whom this is the primary group.

## `/etc/shadow`

Nine (9) colon fields containing encrypted user passwords.

username:encryptedpasswd:dateoflastpasswordchange:minimumpasswordage:maximumpasswordage:passwordwarningperiod:passwordinactivityperiod:accountexprationdate:reservedfield

- date of last password change
    number of days since 01/01/1970 (value 0 means user should change password on the next login)
- minimum password age
    number of days, after a password change, till user can change password again
- maximum password age
    max number of days till a password change is required
- password warning period
    nuber of days, before password expiration, which the user is warned that the password must be changed
- password incativity period
    number of days after a password expires during which the user should update the password. After this period, if the user does not change the password, the account will be disabled.
- account expiration date
    date, expressed as the number of days since 01/01/1970 in which the user account will be disabled
- reserved field
    reserved for future use

> shells for users that execute administrive tasks, for example: mail, ftp, new, daemon usually have `/bin/false` or `/sbin/nologin` shells.
> system accounts range are usually less than 100 or between 500-100 ; ordinary users start at 1000 (although some systems start numbering at 500) the root UID is 0, on `/etc/login.defs` you can find the ranges for ornidary users.
> for LPIC-1 system accounts have UID less than 1000 and ordinary users greater than 1000.
> to know if a user account is blocked, just check for the ! before the encrypted password.

## `/etc/gshadow`

Fout (4) colon fields containing encrypted groups password.

groupname:encryptedpasswd:groupadmins:groupmembers

encryptedpasswd: used when a user who is not a member of a group wants to join the group using the newgrp command, if password starts with ! no one is allowed to acced using newgrp
groupadmins: comma separated list of administrators that can change the password of the group and add/remove members with the gpasswd command
groupmembers: comma separated list of members of the group

## Time Zones

Cloud Services, usually are configured to use UTC. `timedatectl` or  `date` can be used to display information about the time zone. The default time zone is located on `/etc/timezone`. to set the default timezone to GMT-3 set the value to `Etc/GMT-3`.

Command `tzselect` offers interactive method to choose a time zone.

The environment variable `TZ` defines the time zone for the shell session.

The `/etc/localtime` file contain the data used by the OS to adjust its clock. it will probably be a symbolic link to `/usr/share/zoneinfo/`.

## Language and Char Encoding

Linux can work with different locales (character encodings). The most basic local is the LANG environment variable which defines which language shell programs should use.

Language code follow the ISO-639 standard and region should follow ISO-3166 standard.

System wide local configs is on `/etc/locale.conf`. `localectl` command can also be used to query and change system locale: `localectl set-locale LANG=en_US.UTF-8`

`locale` command will show all variables in the current locale configuration.

LANC=C produces simple bytewise comparison when using sorting methods.

### Encoding Conversion
 
```
iconv -f ISO-8859-1 -t UTF-8 original.txt > converted.txt
```

//TRANSLIT can be appended to the target encondig, so characters not representat in the target character set will be transliterated by one of more similar looking characters.

## Maintaining System Time

Accurate timekeeping is crucial. When a linux computer boots up, it starts keeping time (system clock). In addition, modern computers also have a hardware or real time clock (on the motherboard) that keeps time running regardless if the computer is running or not.

On most linux systems, system time and hardware time are synchronized to *network time* (NTP).

### Local vs Universal Time

The system clock is set to Coordinated Universal Time (UTC) which is local time at greenwich.

### Date Formats and Setting Date

```bash
# ISO 8601 format
date -I
# RFC 5322
date -R
# RFC 3339
date --rfc-3339=ns
# specific field (unix time)
date +%s
# format a time that is not the current
date --date='@12398129421' 
```

To view the hardware clock type `hwclock` add `--verbose` for more information.

`timedatectl` can be used to check the status of time and see if network time has been synced

you can set time using timedatectl: `timedatectl set-time '2023-12-02 14:23:12'`
you can set timezone using timedatectl: `timedatectl list-timezones` and `timedatectl set-timezone America/Sao_Paulo`
disable ntp using timedatectl: `timedatectl set-ntp no`

to set the timezone manually without using a GUI you can do the following:

```bash
ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
```

after setting the time zone, it is recommended to run: `hwclock --systohc`

you can set date using date or hwclock, but is not recommended in systemd-based systems, instead use timedatectl.

to set date using `date`: `date --set="12 Nov 2021 12:12:10"`
to set date using `hwclock`: `hwclock --set --date "4/12/2019 11:15:19"`

to propagate to system, use: `hwclock --hctosys`

### NTP (Network Time Protocol)

The most accurate time is measured by reference clocks, which are typically atomic clocks. Computer Systems can be synchronised to these reference clocks using NTP.

NTP uses a server structure divided in stratums:

- Stratum 0 are devices like atomic clocks or GPS clocks
- Stratum 1 are connected to stratum 0 devices and are acessible by Stratum 2 servers, and so on.

Stratum 2 servers are accessible to punlic.

NTP Concepts

- Offset
    absolute difference between system and NTP server. for example, if system clock read 10:00:02 and NTP reads 10:00:00 then the offset is two seconds.
- Step
    if the offset is greater than 128ms, then NTP will perform a single significant change to system time, as opposed to slowing or speeding system time.
- Slew
    changes made to system time when the offset is less than 128ms.
- Insane Time
    if the offset is greater than 17 minutes, then the system is considered insane and NTP daemon will not introduce any changes to system time.
- Drift
    phenomenon where two clocks become out of sync over time.
- Jitter
    amount of drift since the last time a clock was queried.


`timedatectl` implements an SNTP client rather than a full NTP implementation. In this case, SNTP will not work unless the `timesyncd` service is running.

`systemctl status systemd-timesync`
`timedatectl show-timesync --all` to verify status of SNTP synchronization


#### NTP Daemon

It is responsible to compare network time to system time on a regular schedule. usually it is `ntpd`. `ntpd` will allow a machine to be a time consumer but also to **provide time to other machines**. This means that if you want a server to serve time, you can install ntpd.

to ensure ntpd is running use: `systemctl status ntpd`

NTP Queries happen on port 123, if NTP fails, ensure that this port is open and listening.

#### NTP Configuration

NTP can poll several sources and select the best candidates. The file `/etc/ntp.conf` contains configuration about how the system syncs with network time.

the syntax for adding NTP servers looks like this:

```
server (IP ADDRESS OR DOMAIN NAME)
```

You can also consider using a pool. in this case, load is balanced among other machines.

##### pool.ntp.org

NTP servers used by default are an open source project.

#### ntpdate

if ntpd is running, you need to stop it to make manual adjustments: `systemctl stop ntpd`

run `ntpdate pool.ntp.org` to perform an initial one-time sync.

#### ntpq

utility for monitoring the status of NTP. `ntpq -p` to print a summary of peers.

#### chrony

another way to implement NTP. `chronyd` is chrony daemon and `chronyc` is the CLI. `chronyc sources` to retrieve ntp servers. `chrony ntpdata` data about last ntp update. `chronyc tracking` will provide information about NTP and system time. `chronyc makestep` to manually step the clock.


# System Logging

Logging has been traditionally handled by three main services: `syslog` , `syslog-ng` (new generation) and `rsyslog` (rocket-fast system for log processing). `rsyslog` brought RELP support and became very popular.

all these services collect messages from other services and stores them in log files, tipically under `/var/log`.

`rsyslog` uses a client-server model (can be on the same or remote machines). it works together with `klogd` (manages kernel messages).

## Log Types


### System Logs

- `/var/log/auth.log`
    logged users, sudo information, cron jobs, failed login attempts, etc..
- `/var/log/syslog`
    centralized file for practically all of the logs captured by rsyslogd. Because it includes so much information, logs are distributed across files according to `/etc/rsyslog.conf`
- `/var/log/debug`
    debug information from programs
- `/var/log/kern.log`
    kernel messages
- `/var/log/messages`
    informative messages not related to the kernel but other services. default remote client log destination in a centralized log server implementation.
- `/var/log/daemon.log`
    information related to daemons or services running in background
- `/var/log/mail.log`
    information related to the email server, e.g. postfix.
- `/var/log/Xorg.0.log`
    graphics card
- `/var/run/utmp` and `/var/log/wtmp`
    successful logins, use `who` or `w`
- `/var/log/btmp`
    failed login attempts, `utmpdump /var/log/btmp` or `last -f`
- `/var/log/faillog`
    failed authentication attempts, use `faillog -a | less`
- `/var/log/lastlog`
    date and time of recent user logins, use `lastlog | less`

### Service Logs

- `/var/log/cups`
    common unix printing system
- `/var/log/apache2` or `/var/log/httpd`
    logs for apache web server
- `/var/log/mysql`
    logs for mysql
- `/var/log/samba`
    logs for Session Message Block (SMB) protocol.

### Reading Logs

- Use `less` or `more` to open logs with a pager
- User `zless` or `zmore` to open logs compressed with `gzip`
- `tail -f` to follow logs
- `head` to see first lines
- `grep` to search for patterns in files.

## Turning Messages Into Logs

1. Applications, services and the kernel write messages in sockets/memory buffers: `/dev/log` or `/dev/kmsg`
2. `rsyslogd` gets the info from sockets or memory buffers
3. Depending on the rules specified in /etc/rsyslog.conf and files in /etc/rsyslog.d/ , it will move information to the corresponding log file.

to list all sockets in the system you can run `systemctl list-sockets --all`

## `/etc/rsyslog.conf`

Normally divided into three sections: **MODULES**, **GLOBAL DIRECTIVES** and **RULES**.

Modules wil include modules support for logging, messages and UDP/TCP log reception.
Global directives allow us to configure logs and log directory permissions.
Rules is where **facilities, priorities and actions** come in. it tells the daemon to filter messages according to rules and log or send them where specified.
Each log message is given a facility number and a keyword associated with the linux internal subsystem that produces the message. For example:

| Number         | Keyword               | Description                                   |
|----------------|-----------------------|-----------------------------------------------|
| 0              | kern                  | Linux kernel messages                         |
| 1              | user                  | User-level messages                           |
| 2              | mail                  | Mail system                                   |
| 3              | daemon                | System daemons                                |
| 4              | auth, authpriv         | Security/Authorization messages               |
| 5              | syslog                | syslogd messages                              |
| 6              | lpr                   | Line printer subsystem                        |
| 7              | news                  | Network news subsystem                        |
| 8              | uucp                  | UUCP (Unix-to-Unix Copy Protocol) subsystem   |
| 9              | cron                  | Clock daemon                                  |
| 10             | auth, authpriv         | Security/Authorization messages               |
| 11             | ftp                   | FTP (File Transfer Protocol) daemon           |
| 12             | ntp                   | NTP (Network Time Protocol) daemon            |
| 13             | security              | Log audit                                     |
| 14             | console               | Log alert                                     |
| 15             | cron                  | Clock daemon                                  |
| 16 - 23        | local0 through local7 | Local use 0 - 7                               |


And each message is assigned a priority level:


| Code | Severity       | Keyword            | Description                              |
|------|----------------|--------------------|------------------------------------------|
| 0    | Emergency      | emerg, panic       | System is unusable                       |
| 1    | Alert          | alert              | Action must be taken immediately         |
| 2    | Critical       | crit               | Critical conditions                      |
| 3    | Error          | err, error         | Error conditions                         |
| 4    | Warning        | warn, warning      | Warning conditions                       |
| 5    | Notice         | notice             | Normal but significant condition         |
| 6    | Informational  | info               | Informational messages                   |
| 7    | Debug          | debug              | Debug-level messages                     |

An example of sample rules in `/etc/rsyslog.conf`:

```
# First some standard log files.
Log by facility.
#
auth,authpriv.*/var/log/auth.log
*.*;auth,authpriv.none-/var/log/syslog
#cron.*/var/log/cron.log
daemon.*-/var/log/daemon.log
kern.*-/var/log/kern.log
lpr.*-/var/log/lpr.log
mail.*-/var/log/mail.log
user.*-/var/log/user.log

#
# Logging for the mail system.
Split it up so that
# it is easy to write scripts to parse these files.
#
mail.info-/var/log/mail.info
mail.warn-/var/log/mail.warn
mail.err/var/log/mail.err
#
# Some "catch-all" log files.
#
*.=debug;\
auth,authpriv.none;\
news.none;mail.none
-/var/log/debug
*.=info;*.=notice;*.=warn;\
auth,authpriv.none;\
cron,daemon.none;\
mail,news.none -/var/log/messages
```

The rule format is: `<facility>.<priority> <action>`

The facility.priority filters messages to match. priorities are hierarchically inclusive (will log specified priority or higher). <action> shows what action to make, for example:

```
auth,authpriv.*     /var/log/auth.log # regarless of priority (*) all messages from auth and authpriv facilities will be send to /var/log/auth.log
*.*;auth,authpriv.none      -/var/log/syslog # all messages from all facilities and all priorities, except thos from auth/authpriv (.none suffix) will be written to /var/log/syslog (minus sign prevents excessive disk writes)
mail.err                    /var/log/mail.err # messages from mail facility with error or higher (critical, alert, or emergency) will be sent to /var/log/mail.err
*.=debug;\
    auth,authpriv.none;\
    new.none;mail.none      -/var/log/debug # mail from all facilities with debug and no other (hence =) will be written to /var/log/debug exluding some facilities
```

the `","` is used to concatenate facicilites in the same rule and `";"` semicolon to split the selector.

## Manual Entries into System Log: `logger`

```bash
logger this goes to /var/log/syslog
```

## Remote logs

on `/etc/rsyslog.conf`
```
*.* @@suse-server:514
```

## Log Rotation: `logrotate`

It is run by a cron job thourgh the script `/etc/cron.daily/logrotate` and read the config file in `/etc/logrotate.conf`. The file contains global options.

For exaple:

```
/var/log/messages
{
    rotate 4
    weekly
    missingok
    notifempty
    compress
    delaycompress
    sharedscripts
    postrotate
        invoke-rc.d rsyslog rotate > /dev/null
    endscript
}
```

## Kernel Ring Buffer

Kernel Ring is a fixed sized data structure. the `dmesg` command prints the kernel ring buffer.

## Use `omusrmgs` to notify emergencies

```
*.emerg         :omusrmgs:root,caetano
```

## Property based Filter and Expression-based filter

Expression
```
if $FROMHOST-IP=='192.168.1.4' then
?RemoteLogs
```

Property
```
:fromhost-ip, isequal, "192.168.1.4"
?RemoteLogs
```

## `systemd`

- Since `systemd` is used on major distributions, the journal daemon (`systemd-journald`) has become the standard logging service.
- Introduced in Fedora, has progressed to replace `SysV Init` as the system and service manager.
- Ease ofe config: unit files as opposed to SysV Init scripts
- Versatile: Apart from daemons and processes, manages devices, sockets and mount points.
- Backwards Compatibility: with SysV Init and Upstart
- Parallel Loading during boot-up: SysV Init would load sequentially
- LOgging Service (JOURNAL):
    - Centralizes logs in one place
    - Does not require log rotation
    - Logs can be disabled, loaded in RAM or made persistent

### Units and Targets

A unit is a resource that systemd can manage. Unit files are text files that live under `/lib/systemd/system`. Unit types can be: service,mount, automount, swap, timer, device, socket,path, timer, snapshot, slice, scope and target.

The format for a unit is: <resourcename>.<unittype>

A *target* is a special type of unit which resembles runlevels of SysV Init. It brings together various resources to represent a particular system state (for example: graphical.target is similar to runlevel 5).

### System Journal: `systemd-journald`

Receives logging information from a variety of sources: kernel messages, simple and structured system messages, stdout/stderr of services, audit records, kernel audit subsystem.

Configuration file is in `/etc/systemd/journald.conf` and it is a unit and can be queried, for example: `systemctl status systemd-journald`

#### Querying the Journal

`journalctl` can be used to query the journal and will by default print the entire journal with oldest entries listed at first.
`journalctl -r` will reverse.
`journalctl -f` will follow.
`journalctl -e` will jump to the end of the journal so the latest entries are visible within the pager.
`journalctl -n <value>, --lines=<value>` will print the value most recebt lines i.
`journalctl -k,--dmesg` is equivalent to `dmesg` command.

##### Navigating and Searching through the journal.

- Pgup, Pgdown, arrows
- `>` to go to the end of output
- `<` to go to beggining of output
- forward search strings: `/` and enter string
- backward search string: `?` and enter string
- navigate through matches `N` to go to next occurrence, `Shift + N` to go to previous one.

#### Filtering the Journal

**Boot**
- `--list-boots`
    will list all available boots, output is 3 columns, first column is the boot number and (0=current, -1=previous one; -2=one prior to previout...), second column is boot id, and third show timestamps
- `-b, --boot` will show messages for the current boot or another boot. to retrieve information from previous logs, persistence of the journal must be enabled

**Priority**
- `-p` will filter through priority: `journalctl -b -0 -p err` will filter messages from current boot with error or above.

**Time Interval**

- `journalctl --since "19:00:00" --until "19:01:00"` current day is assumed

Likewise you can use a slightly different time specification: "integer time-unit ago". Thus, to see messages logged two minutes ago you will type sudo journalctl --since "2 minutes ago". It is also possible to use + and - to specify times relative to the current time so --since "-2 minutes" and --since "2 minutes ago" are equivalent

yesterday
    As of midnight of the day before the current day.
today
    As of midnight of the current day.
tomorrow
    As of midnight of the day after the current day.
now
    The current time.

`journalctl --since "today" --until "21:00:00"`: last midnight until today at 21:00

consult `systemd.time` for more info.

**Program**

`journalctl /path/to/executable`, for example: `journalctl /usr/bin/sshd`

**Unit**

`journalctl -u unitname.unittype`, for example: `journaklctl -u ssh.service`

to view all loaded units: `systemctl list-units`
to view all installed unit files use: `systemctl list-unit-files`

**Fields**

• `<field-name>=<value>`

• _`<field-name>=<value>_`

• `__<field-name>=<value>`

for example:
- `journalctl PRIORITY=3` will print err, similar as `journalctl -p err`
- `journalctl SYSLOG_FACILITY=1` will print user-level messages 
- `journalctl _PID=1` will print messages produced py process with pid 1
- `journalctl _BOOT_ID=83df3e8653474ea5aed19b41cdb45b78` for specific boot id.
- `journalctl _TRANSPORT=journal` will print messages received from specific transport which can be: `audit` (kernel audit subsystem), `syslog` (syslog socket), `journal` (native journal protocol), `stdout` (services stdout or stderr), `kernel` (kernel ring buffer)

You can combine Fields , however only messages that match BOTH fields SIMULTANEOUSLY will be shown: `journalctl PRIORITY=2 SYSLOG_FACILITY=0`
You can use `+` to combine expressions similar to a logical OR, for example: `journalctl PRIORITY=2 + SYSLOG_FACILITY=0`
You can specify two calues for the same field, and all entries matching either value will be shown, for example: `journalctl PRIORITY=1 PRIORITY=2`

Journal fields fall in any of the following categories: “User Journal Fields”, “Trusted Journal Fields”, “Kernel Journal Fields”, “Fields on behalf of a different program” and “Address Fields”.
For more information on this topic — including a complete list of fields — see the man page for systemd.journal-fields(7).

#### Manual Entries `systemd-cat`

Similar to logger command. Allows us to send the `stdin`, `stdout` and `stderr` to the journal.

```
systemd-cat
oi.
^C
```

```
echo "oi" | systemd-cat
```

```
systemd-cat echo "oi" # will send command stoud and stderr
```

Specify priority:
```
systemd-cat -p emerg echo "This is not a real emergency."
```

Refer to systemd-cat man page to learn about its other options.


#### Persistent Journal Storage

Remembering:
- Journal can be turned off
- Keep in memory
- Keep on disk

If you turn journaling off, redirection to other facilities such as the console are still possible
If you keep in memory, on system reboots you will lose the logs, in this scenario `/run/log/journal/` will be created and used
If you keep on disk, will go to `/var/log/journal`

The default behaviour is as follows: if `/var/log/journal/` does not exist, logs will be saved in a volatile way to `/run/log/journal/` and -therefore- lost at reboot.

The name of the directory - the `/etc/machine-id` - is a hexadecimal, 32 char, lowercase string.

You are not able to read these logs using `less`, instead use `journalctl`

If `/var/log/journal/` exists, logs will be stored persistently there. Should this directory be deleted `systemd-journald` **would not recreate it**. if we create `/var/log/journal` again and restart the daemon `systemd-journald` persistent logging will be restablised.

By default, there will be journal files for evey logged in user, so together with system.journal files you will also find files of type user-1000.journal

On top of that, the way the journal deals wil log storage can be changed after installation by adjusting `/etc/systemd/journald.conf`. The key option is `Storage=` and can have the following values:

- `Storage=volatile` 
    Log data will be stored in memory under `/run/log/journal/`. If not present directory will be created.
- `Storage=persistent`
    Log data will be stored on disk under `/var/log/journal/` will fallback to `/run/log/journal`.. During early boot stages, if the disk is not writable. Both directories will be created if needed.
- `Storage=auto`
    `auto` is similar to persistent, but directory `/var/log/journal` is not created if needed.
- `Storage=none`
    All log data will be discarded, forwarding to other targes such as the console, kernel log buffer or a syslog socket are still possible.

For instance, to have systemd-journald create /var/log/journal/ and switch to persistent storage, you would edit /etc/systemd/journald.conf and set Storage=persistent, save the file and restart the daemon with sudo systemctl restart systemd-journald.

If log is corrupted, then name will be appended with `~` for example `system.journal~`. daemon will then start writing to new clean file.

#### Deleting Old Journal Data

- Logs are saved in journal files, this means they will end with `.journal` suffix.
- Run `journalctl --disk-usage` to check disk usage
- `systemd` logs are capped up to a 10% of the filesystem where they are stored. Once the limit is reached, old logs will start to disappear.
- You can change disk usage limits on `/etc/sysctl.conf/journald.conf`. The options are prefixed by Runtime/System for in-memory/disk usage.
    - SystemMaxUse=, RuntimeMaxUse=
        - Defaults to 10% of filesystem, can't surpass a maximum of 4GiB.
    - SystemKeepFree=, RuntimeKeepFree=
        - Defaults to 15% of the filesystem, can be modified but can't supass a maximum of 4GiB. If you have both MaxUse and KeepFree, systemd-journald will satisfy both by using the smaller of two values.
    - SystemKeepFree=, RuntimeKeepFree=
        - Max size each individual journal can grow, default is 1/8 of *MaxUse.
    - SystemMaxFiles=, RuntimeMaxFiles=
        - number of files and archived journal files, default is 100
    > apart from size-based and rotation of messages, you can also use time-based criteria like MaxRetentionSec ; MaxFileSec

##### Vacuuming the Journal

You can manually clean archived journal files with:

- --vacuum-time=
    will kill all messages with a timestamp older than specified. Values must be written with any of the following suffixes: s, m, h, days (or d), months, weeks (or w) and years (or y). For example: `journalctl --vacuum-time=1moths` will kill archived journal files that are older than 1 month
- --vacuum-files=
    will take care that no more archived journal files than the specified number remail. for example: `journalctl --vacuum-files=10` will limit the number of archived journal files to 10.
- --vacuum-size=
    will delete archived jorunal files until they occupy a value below the specified size. for example, eliminate archived journal files until they are below 100Mebibytes: `journalctl --vacuum-size=100M`

Vacuuming only removes **archived** journal files. If you want to get rid of everything (including active journal files), you need to use a signal (SIGUSR2) that requests immediate rotation of the active journal files), you need to use a signal (SIGUSR2) that requests immediate rotation of the journal files with the --rotate option.

- --flush(SIGUSR1)
    It requests flushing of journal files from /run/ to /var/ to make the journal persistent. It requires that persistent logging is enabled and /var/ is mounted.
- --sync(SIGRTMIN+1)
    request that all unwritten log data will be written to disk.

You can verify consistency of the journal by using `journalctl --verify`

#### Retrieving Journal Data from a Rescue System

`journalctl` looks for journal files in `/var/log/journal/<machineid>`. Since machineids on a rescue system is different, you must use:

- `-D /path/to/dir`, `--directory=/path/to/dir`
    So you will need to mount the faulty system `rootfs (/dev/sda1)` on the rescue filesystem and read journal files like: `journalctl -D /media/caetano/faultysystem/var/log/journal`

Options that might be useful in this scenario:

- `-m`, `--merge`
    merge entriels from all available journals under `/var/log/journal` including remote ones.
- `--file`
    will show entries in a specifid file, for example: `journalctl --file /var/log/journal/1239128498129512812/user-1000.journal`
- `--root`
    direcotry path meaning the root dir is passed as an argument, journalctl will search for the journal files: `journalctl --root /faultysystem/`

#### Forwarding to traditional `syslog` Daemon

You can make log data from the journal available to syslog daemon by:

- Forwarding messages to socket file `/run/systemd/journal/syslog` for `syslog` to read. You will need `ForwardToSyslog=yes` option.
- Have `syslog` daemon reading log messages directly from the journal files.

> Likewise, you can forward log messages to other destinations with the following options: ForwardToKMsg (kernel log buffer — kmsg), ForwardToConsole (the system console) or ForwardToWall (all logged-in users via wall). For more information, consult the man page for journald.conf.

print kernel ring buffer: journalctl --dmesg
print messages from the second boot: journalctl --boot 2
view most recent message and keep watching: journalctl --follow
print messages since now and continue updating: journalctl --since "now" -f
print messages from previous boot with warning priority: journalctl --boot -1 --priority=warning

#### Forward to tty5 example

```
ForwardToConsole=yes
TTYPath=/dev/tty5
```

#### Example filters

| Description | Filter |
| ----------- | ------ |
| Messages Belonging to User | _ID=<UID> |
| Belonging to host debian | _HOSTNAME=debian |
| Belonging to group | _GID=<GID>
| Belonging to root | _UID=0 |
| Based on executable print sudo messages | _EXE=/usr/bin/sudo |
| Based on command print sudo messages | _COMM=sudo |

#### Filtering Ranges of priorities

```bash
journalctl -p warning..crit
#or
journalctl -p 4..2
```

# Mail Transfer Agent (MTA)

In UNIX, every user has their own inbox: accessed by user and root, stores personal email messages. MTA collects messages sent by other local accounts as well as messages received from the network.

It is also responsible for sending messages to the network if the destination address refers to a remote account.

Filesystem location as an email *outbox* for all system users: as soon user places messages in the outbox, MTA will identify the target network from the domain name, then will try to transfer to remote MTA using (SMPT). SMPT was designed with unreliable networks in mid, so it will try to establish alternative delivery routes if the primary mail destination node is unreachable.

## Local/Remote MTA

User accounts in network connected machines make up the simples email exchange scenario, where every network node runs its own MTA daemon. In practice, it is more common to use remote email account and not have an active local MTA service.

Unlike local accounts, a remote email account (remote mailbox) requires user authentication to grant access to the user's mailbox and the remote MTA (SMTP Server). While the user interacting with a local inbox and MTA is already identified by the system, a remote sytem must verify the user identity before handling messages through IMAP or POP3.

> Nowadays, sending/receiving emails is usually through a hosted account on a remote server. Instead of collecting locally-delivered messages, the email client application will connect to the remote mailbox and retrieve the messages from there. POP3 and IMAP protocols are commonly used to retrieve the messages from the remote server.

When MTA daemon is running, local users can send email to othe local users, or to users on a remote machine. TCP port `25` is the standard port for SMTP. other ports may be used depennding on the auth/encryption schema (if any).

Leaving aside topologies involving the access to remote mailboxes, an email exchange network between ordinary Linux user accounts can be implemented as long as all network nodes have an active MTA that is able to perform the following tasks:
- Maintain the outbox queue of messages  to be sent. For each queued message, the local MTA will assess the destination MTA from the recipient’s address.
- Communicate with remote MTA daemons using SMTP. The local MTA should be able to use the Simple Mail Transfer Protocol (SMTP) over the TCP/IP stack to receive, send and redirect messages from/to other remote MTA daemons.
- Maintain an individual inbox for every local account. The MTA will usually store the messages in the mbox format: a single text file containing all email messages in sequence.

Normally email addresses specify a domain name as the location, example caetano@caetano.org. When this is the case, the sender MTA will query the DNS service for `MX record` containin the IP address of the MTA handling the email for `caetano.org` domain. If the domain has more than one MX record, MTA will contact it according to priority values. If the recipient address does not specify a domain name, or the domain does not have a MX Record, then the part after `@` will be treated as the host destination MTA.

It is recommended to only accept connectins from authorized domains and to implement authentication schema, to avoid unknown users from using the local MTA to impersonate anotehr user.

## Linux MTAs

Traditional MTA in Linux is *Sendmail*. other commong are: *postfix*, *qmail* and *exim*.

For *sendmail* MTA to accept non-local connections you should modify `/etc/mail/sendmail` to accept network address:
```
DAEMON_OPTIONS(`Port=smtp,Addr=127.0.0.1, Name=MTA')dnl
```

Writing SMTP commands directly to the MTA using `nc` will help you understand the protocol and other general email concepts better, but it can also help to diagnose problems in the mail delivery process.

After sending a message to another host, the user should get a mail in `/var/spool/mail/USER`.

By default MTA will only accept messages to local reciipients.

a relay SMTP server that can forward messages between MTAs. Therefore, if you have a intermediate SMTP server it is discouraged to connect directly to the host on recipient address.

Sendmail provide `sendmail` command. `mailq` will list undelivered messages and is equivalent to `sendmail -bp`.

Default location for outbox is `/var/spool/mqueue`.

If the primary email destination host (when provided from a MX DNS record) is unreachable, MTA will try to contact entries wil lower priorities (if specified). If none are reachable, message will stay in local outboxx queue to be sent later.

MTA can periodically check the availability of the remote hosts and perform a new delivery attempt.

Senmail will store incoming messages in a file name corresponding to the user, `/var/spool/mail/caetano`.

## The `mail` command and Mail User Agents (MUA)

MUA speed up the process of writing email messages. Desktop application like Thunderbird, webmail interfaces. console email clients.

The most common `mail` command nowadays is provided my `mailx` package. 

Regardless of their implementation, all modern variations of the `mail` command operate in two modes: normal mode and send mode.

In normal mode, the received messages are listed with a numerical index for each one, so the user can refer to them individually when typing commands in the interactive prompt. command prin 1 would display content of message number 1. The send mode is especially useful for sending automated email messages. It can be used, for example, to send an email to the system administrator if a scheduled maintenance script fails to perform its task.

In send mode, mail will use content from stdin as the message body:

```bash
mail -s "Maintenance fail" teste@caetano.org <<<"The maintenance script failed at `date`"
```

## Delivery Customization

By default email account on a linux system are associated with standard system account, for example username@hostname. you can extend email routing by the `/etc/aliases` file.

An email alias is a "virtual" email recipient whose receiving messages are redirected to local mailboxes. For example place messages from one email into another mailbox. after editing the file, you should run `newaliases` command to update. <alias>: <destination> is the format of an alias.

Other destination types are available:
- A full path (starting with /) to a file. Messages sent to the corresponding alias will be appended to the file.
- A command to process the message. The <destination> must start with a pipe character and, if the command contains special characters (like blank spaces), it must be enclosed in double quotes. For example, the alias subscribe: |subscribe.sh in lab2.campus will forward all messages sent to subscribe@lab2.campus to the standard input of the command subscribe.sh. If sendmail is running in restricted shell mode, the allowed commands — or the links to them — should be in /etc/smrsh/.
- An include file. A single alias can have multiple destinations (separated by commas), so it may be more practical to keep them in an external file. The :include: keyword must indicate the file path, as in :include:/var/local/destinations
- An external address. Aliases can also forward messages to external email addresses.
- Another alias.

An unprivileged local user can define aliases for their own email by editing the file .forward in their home directory. As the aliases can only affect their own mailbox, only the <destination> part is necessary.

It will forward all email messages sent to dave@lab2.campus to emma@lab1.campus. As with the /etc/aliases file, other redirection rules can be added to .forward, one per line. Nevertheless, the .forward file must be writable by its owner only and it is not necessary to execute the newaliases command after modifying it. Files starting with a dot do not appear in regular file listings, which could make the user unaware of active aliases. Therefore, it is important to verify if the file exists when diagnosing email delivery issues.

## Examples

Send message to user with file logs.tar.gz as attachment and the output of uname -a

```
uname -a | mail -a logs.tar.gz teste@org.com
```

Redirect all email sent to user test to /dev/null

add in /etc/aliases:
```
test: /dev/null
```

All messages sent to local maibox test will go to /dev/null.

sendmail -bi or sendmail -I or newaliases commands to update /etc/aliases

# Managing Printers and Printing

The Common Unix Printing System (CUPS) stack allows for printing and printer management. Outline of how a file is printed in Linux using CUPS:

1. User submits file to be printed.
2. `cupsd` (CUPS Daemon) *spools* the print job. The print job has a number, information abou which print queue holds the job and the name of the document.
3. CUPS uses filters to format a file that the printer can use.
4. CUPS sends the re-formatted file to the printer for printing.

## The CUPS Service

- `/etc/cups/cupsd.conf`
    This file contains configuration settings for the CUPS service. 
- `/etc/printcap`
    This is the legacy file that was used by the LPD protocol before the advent of CUPS. often times a symbolic link to `/run/cups/printcap`. Each line contains a printer that the system has access to.
- `/etc/cups/printers.conf`
    This file contains each printer configured to be used by the CUPS system. Each printer and its associated print queue is enclosed within `<Printer></Printer>` stanza.
- `/etc/cups/ppd`
    directory that holds the PostScript Printer Description (PPD) files for the printers that use them. Each printer operating capabilities will be stored within a PPD file.

## Using the Web Interface

the `/etc/cups/cupsd.conf` states if web interface is enabled

If the web interface is enabled, then CUPS can be managed from a browser at the default URL of http://localhost:631.

By default a user on the system can view printers and print queues but any form of configuration modification requires a user with root access to authenticate with the web service.

configuration restricting access to administrative capabilities
```
# All administration operations require an administrator to authenticate...
<Limit CUPS-Add-Modify-Printer CUPS-Delete-Printer CUPS-Add-Modify-Class CUPS-Delete-Class
CUPS-Set-Default>
AuthType Default
Require user @SYSTEM
Order deny,allow
</Limit>
```

- AuthType Default
    will use a basic authentication prompt when an action requires root access.
- Require user @SYSTEM
    indicates that a user with administrative privileges will be required for the operation. This could be changed to @groupname where members of groupname can administer the CUPS service or individual users could be provided with a list as in Require user carol, tim.
- Order deny,allow
    works much like the Apache 2 configuration option where the action is denied by default unless a user (or member of a group) is authenticated.

The web interface for CUPS can be disabled by first stopping the CUPS service, changing the WebInterface option from Yes to No, then restarting the CUPS service;

- Home
    The home page will list the current version of CUPS that is installed. It also breaks down CUPS into sections such as:
    - CUPS for Users
        Provides a description of CUPS, command-line options for working with printers and print queues, and a link to the CUPS user forum.
    - CUPS for Administrators
        Provides links in the interface to install and manage printers and links to information about working with printers on a network.
    - CUPS for Developers
        Provides links to developing for CUPS itself as well as creating PPD files for printers.
- Administration
    - Printers
        Here an administrator can add new printers to the system, locate printers connected to the system and manage printers that are already installed.
    - Classes
        Classes are a mechanism where printers can be added to groups with specific policies. For example, a class can contain a group of printers that belong to a specific floor of a building that only users within a particular department can print to. Another class can have limitations on how many pages a user can print. Classes are not created by default on a CUPS installation and have to be defined by an administrator. This is the section in the CUPS web interface where new classes can be created and managed.
    - Jobs
        This is where an administrator can view all print jobs that are currently in queue for all printers that this CUPS installation manages.
    - Server
        This is where an administrator can make changes to the /etc/cups/cupsd.conf file. Also, further configuration options are available via check boxes such as allowing printers connected to this CUPS installation to be shared on a network, advanced authentication, and allowing remote printer administration.
- Classes
    If printer classes are configured on the system they will be listed on this page. Each printer class will have options to manage all of the printers in the class at once, as well as view all jobs that are in queue for the printers in this class.
- Help
    This tab provides links for all of the available documentation for CUPS that is installed on the system.
- Jobs
    The Jobs tab allows for the searching of individual print jobs as well as listing out all of the current print jobs managed by the server.
- Printers
    The Printers tab lists all of the printers currently managed by the system as well as a quick overview of each printer’s status. Each printer listed can be clicked on and the administrator will be taken to the page where the individual printer can be further managed. The information for the printers on this tab comes from the /etc/cups/printers.conf file.


## Adding/Installing a Printer

- Go to administration tab and click add printer.
- Select options like port, third-party software.
- You can share this printer over the network.
- Search locally installed database for suitable drivers and PPD files.

A printer queue can be installed using legacy LPD/LPR commands: `sudo lpadmin -p ENVY-4510 -L "office" -v socket://192.168.150.25 -m everywhere`


