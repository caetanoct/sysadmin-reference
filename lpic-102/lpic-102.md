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

# Networking

IPv4 address classes:

| Class | First Octet Range | Example              |
|-------|-------------------|----------------------|
| A     | 1-126             | 10.25.13.10          |
| B     | 128-191           | 141.150.200.1        |
| C     | 192-223           | 200.178.12.242       |

224 - Reserved Multicast Purposes
127 - Reserved Loopback Addresses

## Private IP ranges

Class A: 10.0.0.0 - 10.255.255.255
Class B: 172.16.0.0 - 172.31.255.255
Class C: 192.168.0.0 - 192.168.255.255

## Converting Decimal to Binary

Example:

105/2 - R: 1 / Q: 52
52/2  - R: 0 / Q: 26
26/2  - R: 0 / Q: 13
13/2  - R: 1 / Q: 6
6/2   - R: 0 / Q: 3
3/2   - R: 1 / Q: 1

Subsequentially divide the value by 2, store the rest, group the last quotient followed by the remainder of all divisions.

So binary of 152: 1101001

## Netmask

| Decimal      | Binary                                           | CIDR |
|--------------|--------------------------------------------------|------|
| 255.0.0.0    | 11111111.00000000.00000000.00000000              | /8   |
| 255.255.0.0  | 11111111.11111111.00000000.00000000              | /16  |
| 255.255.255.0| 11111111.11111111.11111111.00000000              | /24  |

Every subnetwork has a network ip address and broadcast ip address (first and last), the rest of available ip addresses on the range will be available for hosts.

To obtain the network address just use bitwise *logical and* between the IP address and the mask in their binary formats.

To obtain the broadcast address we must use the network address where all host bits  are set to 1.

## Protocols

- 16-bit: port -> 65,535 values.
- socket/non-privileged ports and privileged ports: 1 to 1023 are privileged ports (they have root access to the system). Origin of the connection will use range of ports from 1024 to 65,535, callet non-privileged ports or socket ports.
- On linux, fou can find standard service ports on `/etc/services`

| Port | Service | Description |
|------|---------|-------------|
| 20   | FTP     | Data        |
| 21   | FTP     | Control     |
| 22   | SSH     | Secure Socket Shell |
| 23   | Telnet  | Remote connection without encryption |
| 25   | SMTP    | Simple Mail Transfer Protocol, Sending Mails |
| 53   | DNS     | Domain Name System |
| 80   | HTTP    | Hypertext Transfer Protocol |
| 110  | POP3    | Post Office Protocol, Receiving Mails |
| 123  | NTP     | Network Time Protocol |
| 139  | Netbios | - |
| 143  | IMAP    | Internet Message Access Protocol, Accessing Mails |
| 161  | SNMP    | Simple Network Management Protocol |
| 162  | SNMPTRAP| SNMP Notifications |
| 389  | LDAP    | Lightweight Directory Access Protocol |
| 443  | HTTPS   | Secure HTTP |
| 465  | SMTPS   | Secure SMTP |
| 514  | RSH     | Remote Shell |
| 636  | LDAPS   | Secure LDAP |
| 993  | IMAPS   | Secure IMAP |
| 995  | POP3S   | Secure POP3 |

### TCP

Connection is established between client through socket port and service through the service standard port.

### UDP

Does not control data transmission of the connection (does not check if packets have been lost or are out of order).

### ICMP

- Traffic Volume Control
- Detection of Unreachable Destinations
- Routes Redirection
- Checking the status of remote hosts.

### IPv6

- Unicast: identifies single network interface (by default 64 bits on the left identify the network and 64 bits on the right identify the interface)
- Multicast: identifies a set of network interfaces. packet sent to multicast address will be sent to all interfaces belonging to a group. (should not be confused with broadcast)
- Anycast: also identifies a set of network interfaces, but the packet forwarded to an anycast address will be delivered to only one address in that set.

IPv6 ip addresses when representing ip:port must be enclosed in `[]`, for example: `[2001::1319:8a2d:2342:1232]:443`

IPv6 does not implement the broadcast feature exactly as it exists in IPv4. However the same result can be achieved by sending the packet to the address ff02::1, reaching all hosts on the local network. Something similar to using 224.0.0.1 on IPv4 for multicasting as a destination
They are able to sel configure using SLAAC
TTL has been replaced by HOP LIMIT on IPv6
IPv6 interfaces have a local address, called link-local, prefixed with fe80::/10
IPv6 implements NDP (Neighbor Discovery Protocol), similar to ARP and can also obtain information about duplicate addresses, routes, DNS servers, gateways.

## Persistent Network Configuration

- Display network interfaces: `nmcli device` or `ip link show`.
- Older linux distros name network interfaces as eth0, eth1, etc. and are numbered in order which the kernel identifies the devices.
- Interface Naming Convertion:
  - en: ethernet
  - ib: infiniband
  - sl: serial line
  - wl: wireless LAN
  - ww: wireless WAN

From higher to lower priority, the following rules are used by the operating system to name and number network interfaces:

1. Name the interface after the index provided by the BIOS or by the firmware (eno1)
2. Name the interface after the PCI Express slot index, as given by the BIOS. (ens1)
3. Name the interface after its address at the corresponding bus. (enp3s5)
4. Name the interface after the interface MAC. (enx78e7d1ea46da)
5. Name the interface using legacy convertion (eth0)

The Network Interfaces are created by the kernel, and there are many commands to interact with it.

### Interface Management

The old `ifconfig` command can still be used to do simple network interface configurations, but it is deprecated due to its limited support of non ethernet interfaces.

`ip` command can be used to manage many other aspect of TCP/IP interfaces, like routes and tunnels.

Command `ifup` and `ifdown` may be used to configure network interfaces based on interface definitions on `/etc/network/interfaces`.

All network interfaces managed by ifup and ifdown should be listed in the `/etc/network/interfaces`. Lines beginning with the work `auto` are used to identify the physical interfaces to be brought on `ifup -a`. The interface name should follow the word `auto` on the same line.

CentOS uses `/etc/sysconfic/network-scripts/` directory and the format is different.

The following example shows a basic configuration file for interfaces lo (loopback) and enp3s5

```txt
auto lo
iface lo inet loopback

auto enp3s5
iface enp3s5 inet dhcp
```

The address family should be inet for TCP/IP networking, but there is also support for IPX networking (ipx), and IPv6 networking (inet6). Loopback interfaces use the loopback configuration method. With the dhcp method, the interface will use the IP settings provided by the network’s DHCP server. The settings from the example configuration allow the execution of command ifup using interface name enp3s5 as its argument `ifup enp3s5`.

In networks without a DHCP server, the static method could be used instead and the IP settings provided manually in /etc/network/interfaces. For example:

```txt
iface enp3s5 inet static
    address 192.168.1.2/24
    gateway 192.168.1.1
```

Interfaces using the static method do not need a corresponding auto directive, as they are brought up whenever the network hardware is detected.

If the same interface has more than one iface entry, then all of the configured addresses and options will be applied when bringing up that interface. This is useful to configure both IPv4 and IPv6 addresses on the same interface, as well as to configure multiple addresses of the same type on a single interface.

### Local and Remote Names

The local name often matches the network name of the machine.

If the file `/etc/hostname` exist, the OS will use contents of the first line as its local name.

you can also use `hostnamectl set-hostname $name` to set the machine host name.

The name in `/etc/hostname` is the static hostname, that is, the name which is used to initialize the system's hostname at boot. can contain up to 64 characters.

#### Pretty hostname

Unlike the static hostname, the pretty hostname may include all kinds of special characters. It can be used to set a more descriptive name for the machine, e.g. “LAN Shared Storage”:

`hostnamectl --pretty set-hostname "LAN Shared Storage"`

#### Transient hostname

Used when the static hostname is not set or when it is the default localhost name. The transient hostname is normally the name set together with other automatic configurations, but it can also be modified by the command hostnamectl, e.g.

`hostnamectl --transient set-hostname generic-host`

If neither the --pretty nor --transient option is used, then all three hostname types will be set to the given name. To set the static hostname, but not the pretty and transient names, the option --static should be used instead. In all cases, only the static hostname is stored in the /etc/hostname file. Command hostnamectl can also be used to display various descriptive and identity bits of information about the running system:

`hostnamectl status`

#### Hostname Priority

The system can use a local source or a remote server to translate names into IP numbers and vice versa. Methods priority can be defined in the `Name Service Switch` at `/etc/nsswitch.conf`.

This configuration file is used to determine the source for name-ip and also the sources from which to obtain name-service information in a range of categories, called *databases*.

The *hosts* database keeps track of mapping between host names and host numbers.

##### Hosts database

if the entry is `hosts: files dns` files and dns are the service names that specify how the lookup process for host names will work. First will match local files then it will ask DNS services.

The local file for the Hosts database is `/etc/hosts`.

You can add aliases or alternate spelling at the end of the line, for example:

```txt
192.168.1.10 foo.mydomain.org foo
```

It also supports IPv6 entries. for example the IPv6 loopback:

```txt
::1 localhost ip6-localhost ip6-loopback
```

##### Local DNS Configuration

Following the `files` specification, the `dns` specification tells the system to ask a DNS service for the desired name/IP association. The responsible set of routines is called the *resolver* and its configuration file is `/etc/resolv.conf`.

The following entries shows entries for Google public DNS server:

```txt
nameserver 8.8.4.4
nameserver 8.8.8.8
```

`nameserver` keyword indicates the ip address of the DNS server, only one is needed but up to three can be given.

The other ones are used ass fallback.

If no nameserver entries are present, the default behaviour is to use the name server on the local machine.

The resolver can be configured to automatically add the domain to names before consulting them on the name server. For example:

```txt
nameserver 8.8.4.4
nameserver 8.8.8.8
domain mydomain.org
search mydomain.net mydomain.com
```

The `domain` entry sets `mydomain.org` as the local domain name. so queries for names within `mydomain.org` will be allowed to use short names relative to the local domain.
The `search` entry has a similar purpose, but it accepts a list of domains to try when a short name is provided. By default, it contains only the local domain name.

## NetworkManager

Most linux distributions use NetworkManager to configure and control network connections.

When using DCHP, NetworkManager arranges route changes, IP address fetching and updates to the local list of DNS servers. When there is a cabled and wi-fi connection, NetworkManager will prioritize the wired connection.

By default, NetworkManager daemon controls the interfaces that are **not** listed in the  `/etc/network/interfaces`.

It runs in the background with root privileges.

NetworkManager comes in both CLI (nmcli and nmtui) and graphical environment (nm-tray, network-manager-gnome, nm-applet or plasma-nm).

`nmcli` separates all network related properties controlled by NetworkManager in categories called *objects*:

- `general`
    NM general status and operations
- `networking`
    Overall networking contrl
- `radio`
    radio switches
- `connection`
    connections
- `device`
    devices managed by NM
- `agent`
    NM secret agent or polkit agent
- `monitor`
    Monitor NM changes

`nmcli device wifi list` to scan available networks. Then you can run `nmcli device wifi connect $SSID`. If the command is executed inside a terminal emulator a dialog box will appear, when executed in a text only console the password may be provided together with other arguments.

If the network hides its SSID name you should connect to it usind `nmclide device wifi connect $SSID password $password hidden yes`. If the OS has more than one wi-fi adapted, when you can indicate the one you want to connect using `nmcli device wifi connect $SSID password $pass ifname $ifname`

After connecting you should be able to visualize connections using `nmcli connection show`. After a connection is saved you can run `nmcli connection up $name` and `nmcli connection down $name`. The interface name can also be used to recconect, for example: `nmcli device disconnect wlo2`. Note that the connection UUID changes every time the connection is brought up.

If the wireless adapter is not being used it can be turned off to save power using `nmcli radio wifi off`

`nmcli device wifi list` lists a local database found in last scan, to re-run a scan run `nmcli device wifi rescan`.

## systemd-networkd

Systems running systemd can use its built-in daemon to manage network connectivity and `systemd-resolved` to manage local name resolution. The configuration files used by `systemd-networkd` to setup network interfaces can be found in:

- `/lib/systemd/network`
- `/run/systemd/network`
- `/etc/systemd/network`

The files are processed in lexicographic order, so it is recommended to start their names with numbers to make the ordering easier to read and see.

Files in `/etc` have the highest priority. whilst files in `/run` take precedence over files with the same name in `/lib`.

Files with the same name in different directories will be ignored based on their priority.

Files ending with `.netdev` are used to create virtual network devices (like *bridges* or *tun* devices).
Files ending with `.link` set low-level configurations. systemd-networkd detect and configures network devices automatically as they appear.
Files ending with `.network` can be used to setup network addresses and routes. The network interface to which the config file refers to is defined in the `[Match]` section.

For example, the ethernet network interface `enp3s5` can be selected within `/etc/systemd/network/30-lan.network` by using

```ini
[Match]
Name=enp3s5
```

A list of whitespace separated names is also accepted to match many network interfaces with this same file at one. It can also contain shell style globs like `en*`. You can also match by mac address:

To match all ethernet interfaces you should use `name=en*`.

```ini
[Match]
MACAddress=00:12:2d:a2:23:3d
```

The settings device are in `[Network]` section:

```ini
[Match]
Name=wlp3s0

[Network]
Address=192.168.0.254/24
Gateway=192.168.0.1
```

or

```ini
[Match]
Name=wlp3s0

[Network]
DCHP=yes
```

Using `DHCP=yes` the daemon will search for both IPv4 and IPv6 addresses. To use IPv4 only you should use `DHCP=ipv4`.

Password-protected wireless networks can also be configured by systemd-networkd, but the network adapter must be already authenticated in the network before systemd-networkd can configure it.

Authentication is performed by *WPA supplicant*, a program dedicated to configure network adapters for password protected networks.

`wpa_passphrase MyWifi > /etc/wpa_supplicant/wpa_supplicant-wlo1.conf`

The command above will take the passphrase from stdin and store its hash in the `/etc/wpa_supplicant/wpa_supplicant-wlo1`.

The systemd manager read the WPA passphrase files in `/etc/wpa_supplicant/` and creates the corresponding service to run WPA supplicant and bring the interface up.

The passphrase file will have a corresponding service unit called `wpa_supplicant@wlo1.service`. Command `systemctl start wpa_supplicant-wlo1@wlo1.service` will associate the wireless adapter with the remote access point. command `systemctl enable wpa_supplicant-wlo1@wlo1.service` makes the association on boot time.

Finally a `.network` file matching the `wlo1` interface must be present in `/etc/systemd/network/`, as `systemd-networkd` will use it to configure the interface as soon as WPA supplicant finishes the association with the AP.

## Network Troubleshooting and Management

packet sniffers, hex viewers and protocol analyzers can help.

### `ip` command

each subcommand of `ip` has its own man page. you can see more information on SEE ALSO section or add `-` and the name of the subcommand, for example: `man ip-route`

#### Routing Review

Ethernet is not a routable protocol, there is a limitation to how much you can control the flow of network traffic. Routable protocols like ipv4 and ipv6 allow network designers to segment networks to reduce the processing requirements of connectivity devices, provide redudancy and manage traffic.

When a IPv4 or IPv6 host with routing enabled receives a packet that is not for the host itself it will:

- match the network protion of the destination network in the routing table
  - if a matching entry is found it sends the packet to the destination specified in the routing table
  - if no entries are found and a default route is configured, it is sent to the defualt route.
  - if no entry and no default rule is present, the packet is discarded.

#### Configuring an Interface

you can use `ifconfig` and `ip`. `net-tools` package will provide legacy networking commands.

to list all interfaces use `ifconfig -a` or `ip addr`, `ip a`.
you can also list the contents of `sys/class/net` using `ls /sys/class/net`. you can also use `ip link`

to configure using ifconfig you must be logged in as root and run:

```bash
ifconfig enp1s0 192.168.50.50/24
```

you can specify netmask in different formats, for example:

```bash
ifconfig eth2 192.168.50.50 netmask 255.255.255.0
ifconfig eth2 192.168.50.50 netmask 0xffffff00
ifconfig enp0s8 add 2001:db8::10/64
```

to configure with `ip`

```bash
ip addr add 192.168.5.5/24 dev enp0s8
ip addr add 2001:db8::10/64 dev enp0s8
```

#### Configuring Low Level Options

`ip link` command is used to configure low level interface or porotocol settings, such as VLANS, ARP or MTUS's.

a common task is to enable/disable an interface:

```bash
ip link set dev enp0s8 down
ip link show dev enp0s8
```

this can be done with `ifconfig enp0s8 down`, for example.

to adjust the interface MTU you can run `ip link set enp0s8 mtu 2000` or `ifconfig enp0s8 mtu 2000`

#### Routing Table

You can use the following commands to view the routing table:

- `route`
- `netstat -r`
- `ip route`

To view ipv6 routing table:

- `route -6`
- `netstat -6r`
- `ip -6 route`

The `Flag` column provides some information about the route.

- The `U` flag indicates that the route is up
- The `!` flag means reject route (a route with ! will not be user)
- The `n` flag means the route hasn't been cached (the kernel maintains a cache of routes for faster lookups separately from all known routes)
- The `G` flag indicates a gateway

The `Metric` or `Met` colun is not used by the kernel (refers to administrative distance to the target). It can be used by routing protocols to determine dynamic routes.
The `Ref` column is the reference count or number of uses of a route. Also not used by the linux kernel.
The `Use` column show the number of lookups for a route.

In the output of `netstat -r`, MSS indicates the maximum segment size for TCP connections over that route.
The `Window` column shows you the defualt TCP window size.
The `irtt` shows the round trip time for packets on this route.

The output of ip route and ip -6 route reads as follows:

1. Destination.
2. Optional address followed by interface.
3. The routing protocol used to add the route.
4. The scope of the route. If this is omitted, it is global scope, or a gateway.
5. The route’s metric. This is used by dynamic routing protocols to determine the cost of the route. This isn’t used by most systems.
6. If it is an IPv6 route, the RFC4191 route preference.

##### IPv4 Example

`default via 10.0.2.2 dev enp0s3 proto dhcp metric 100`

1. The destination is the default route.
2. The gateway address is 10.0.2.2 reachable through interface enp0s3.
3. It was added to the routing table by DHCP.
4. The scope was omitted, so it is global.
5. The route has a cost value of 100.
6. No IPv6 route preference.

##### IPv6 Example

`fc0::/64 dev enp0s8 proto kernel metric 256 pref medium`

1. The destination is fc0::/64.
2. It is reachable through interface enp0s8.
3. It was added automatically by the kernel.
4. The scope was omitted, so it is global.
5. The route has a cost value of 256.
6. It has an IPv6 preference of medium.

```bash
ping6 -c 2 2001:db8:1::20
route -6 add 2001:db8:1::/64 gw 2001:db8::3
# now ping would work
route -6 del 2001:db8:1::64 gw 2001:db8::3
```

instead of route -6 you could use `ip route add 2001:db8:1::/64 via 2001:db8::3`

##### Other Examples

Link up/down:

```bash
ip link set wlan1 up
ip link set wlan1 down
```

List interfaces:

```bash
ls /sys/class/net
```

List hardware capabilities:

```bash
lshw -class network
```

ethtool is a program that displays and changes Ethernet card settings such as auto-negotiation, port speed, duplex mode, and Wake-on-LAN:

```bash
ethtool eth4
```

Adding IP address to interface:

```bash
ip addr add 172.16.15.16/16 dev enp0s9 label enp0s9:sub1 # label adds an alias to interface.
```

Adding Vlan:

```bash
ip link add link enp0s9 name enp0s9.20 type vlan id 20
```

Configuring default route:

```bash
route add default gw 192.168.1.1
ip route add default via 192.168.1.1
```

Display ARP cache:

```bash
ip neighbour
```

Backing up route table:

```bash
ip route save > routebackup
ip route restore < routebackup
```

Configure STP priority 50:

```bash
ip link add link enp0s9 name enp0s9.50 type bridge priority 50
```

Puger all IP address configuration:

```bash
ip addr flush eth0
```

[Ubuntu Network Configuration: Refer to this link](https://ubuntu.com/server/docs/network-configuration)

### Ping

`ping` and `ping6` can be used to test connectivity. Remember that firewalls can block ICMP, therefore empty replies does not always mean that you have no connectivity.

Other reasons a ping can fail:

- Remote host is down.
- Router ACL blocking the ICMP request.
- Remote Host Firewall.
- Incorrect name/addres
- Incorrect command / version (v4/v6)
- Machine Firewall
- Machine network configuration
- Name resolution returning wrong address
- Remote host network configuration is incorrect
- Machine interface disconnected
- Remote machine interface disconnected
- Network component between switch/cable/route is no longer functioning.

### Tracing Routes

`traceroute` and `traceroute6` can be used to show the root (by incrementing the TTL field of IP Header). Each router along the way respons with a TTL exceeded ICMP message.

By default, traceroute sends 3 UDP packets with junk data to port 33434, incrementing it each time it sends a packet. Each line in the output is a router interface the packet traverses through. The times shown in each line of the output is the RTT for each packet.

If DNS is available, traceroute will use it.

If you see a `*` in place of time, it means that traceroute never received the TTL exceeded message for this packet.

If you use `traceroute -I` will set traceroute to use ICMP echo instead of UDP packets.

Some application block ICMP echo requests. To get arount you can use TCP by using a known open TCP port.

To use TCP on port: `traceroute -m 60 -T -p 80 HOST`.

You can use a specific interface for traceroute: `traceroute -i eth2 HOST.COM`

You can also report MTUs using: `traceroute -I --mtu host.com`

### Finding MTUs with `tracepath`

`tracepath` is similar to traceroute, but it tracks the MTU sizes along the path. it will either be a setting on NIC or a hardware limitation of the largest protocol data unit that it can transmit or receive.

Work by incrementing the TTL. It sends a very large UDP datagram.

It is almost inevitable for the datagram to be larger than the device with the smallest MTU along the route. When the packet reaches this device, device usually respond with a destination unreachable packet. The ICMP destination unreachable has a MTU field of the link it would send the packet on if it weere able. tracepath then sends all subsequent packets with this size:

### Creating Arbitrary Connections

`nc` program, or netcat, can send or receive data over a TCP or UDP network.

for example: listener on port 1234:

```bash
nc -l 1234
```

sender to send packet to net2.example on port 1234:

```bash
nc net2.example 1234
```

The -u option is for UDP. -e instructs netcat to send everything it receives to standard input of the executable following it. For example:

```bash
hostname
# net1
nc -u net2.example 1234
hostname
#net2
pwd
#/home/emma
```

### Viewing Current Connections and Listeners

`netstat` and `ss` can be used to view the status of the current listeners and connections.

Common options:

- `-a`
    shows all sockets
- `-l`
    shows listening sockets
- `-p`
    shows the process associated with the connection
- `-n`
    prevents name lookups for both ports and addresses
- `-t`
    tcp
- `-u`
    udp

The `Recv-Q` column is the number of packets a socket has received but not passed off to its program.
The `Send-Q` command is the number of packet a socket has sent that have not been acknowleged by the receiver.

### Some examples

Enter HTTP request using nc

```bash
nc host.com 80
>
GET / HTTP/1.1
HOST: host.com
# enter blank line
```

Show connections lisetint for TCP on port 8000:

```bash
ss -tnl | grep ":8000"
```

Show process listening on port 443:

```bash
ss -np | grep ":8000"
```

## Networking Summary

Networking is usually configured by a system’s startup scripts or a helper such as NetworkManager.

Most distributions have their own tools, you should consult the distribution documentation.

## Client-side DNS

### Name Resolution Process

Programs that resolve names to numbers will almost always use standard `glibc` on linux systems. The first things these functions do is read the file in `/etc/nsswitch.conf` for instructions on how to resolve that type name. Besides host name resolution, it can also be appliad to group names, port numbers, user names and others.

After receiving instructions from `/etc/nsswitch.conf` it will loop up the name in the manner specified.

What comes next could be anything (`/etc/nsswitch.conf` supports plugins). After the function is done looking up it will return the result to the calling process.

### DNS Classes

DNS has three records classes:

- IN - internet addresses (TCP/IP)
- HS - Hesiod (way of storing things like passwd and group entries in DNS)
- CH - ChaosNet (short lived, no longer used)

### Example of `/etc/nsswitch.conf`

```txt
passwd:compat
group:compat
shadow:compat
hosts:dns [!UNAVAIL=return] files
networks:nis [NOTFOUND=return] files
ethers:nis [NOTFOUND=return] files
protocols:nis [NOTFOUND=return] files
rpc:nis [NOTFOUND=return] files
services:nis [NOTFOUND=return] files
# This is a comment. It is ignored by the resolution functions
```

The left columns is the type of name database. The rest are the methods the resolution functions should use to lookup a name. Columns with `[]` are used to provide some limited conditional logic to the immediately left method.

> For example, is a process calls C library call `gethostbyname`, it will read from the config file, and since the process is looking for a host it will find a line starting with hosts and use the method. It will try to use dns to resolve the name, the column `[!UNAVAIL=return]` means that if the service is not unavailable, then do not try the next source, i.e., if DNS is available, stop trying to resolve the host name even if the name servers are unable to. If DNS is unavailable, then continue on to the next source (files).

When you see a column in the format `[result=action]`, it means that when a resolver lookup of the column to the left of it is `result`, than `action` is performed. if `result` is preceded with a  `!`, it means if the result is not  `result`, then perform `action`.

Now suppose a process is trying to resolve a port number to a service name. It would read the `services` line. The first source is `NIS`. NIS stands for *Network Information Service* (sometimes referred to as yellow pages). It is an old service that allowed central management of things such as users (rarely used due to weak security). The column `[NOTFOUND=return]` means that if the lookup succeeded but the service was not found to stop looking. If the condition does not apply, use local files.

### `/etc/resolv.conf` file

It is used to configure host resolution via DNS. Some distributions has startup scripts, daemons and other tools that write to this file.

The format is: `option name` `option values`.

You can specify up to three `nameservers` using the `nameserver` option. for example:

```txt
search test.org
nameserver 8.8.8.8
nameserver 8.8.4.4
```

The `search` option is used to allow short form searches. This means that any attempt to resolve a host name withou a domain portion will have `test.org` appended before the search. For examplo, you are trying to search a host called `learning`, the resolver would search for `learning.lpi.org`. You can have up to six search domains configured.

The `domain` option is used to set the local domain name. If this option is missing, this defaults to everything after the first `.` in the machine host name. if the hostname does not contain a `.`, it is assumed that the machine is part of the root domain.

`domain` and `search` are **mutually exclusive**. If both are present, the last instance in the file is used.

you can set some options to affect the behaviour of the resolver, for example:

`option timeout:3`

### `/etc/hosts` file

Used to resolve names to ip addresses and vice versa.

format is: `ip-address name [alias...]`

### systemd-resolved

this service provides mDNS, DNS and LLMNR.

When running, it listens to DNS requests on `127.0.0.53`.

Does not provide a full fledged DNS server.

Any DNS requests it receives are looked up by querying servers configured in `/etc/systemd/resolv.con` or `/etc/resolv.conf`.

If you wish to use this, use `resolve` for `hosts` in `/etc/nsswitch.conf`. Keep in mind that the OS package that has `systemd-resolved` library may not be installed by default.

### Name Resolution Tools

- `getent` -  real world requests will resolve.
- `host` - simple dns queries.
- `dig` - complex DNS operations for troubleshooting.

#### `getent` command

The command display entries from name service databases. can retrieve records from any source configurable by `/etc/nsswitch.conf`. for example: `getent hosts` or `getent hosts dns1.teste.org`

Starting with glibc version 2.2.5, you can force getent to use a specific data source with the -s option, for example: `getent -s files hosts teste.org` or `getent -s dns hosts teste.org`

It is a good way to see how the resolver will resolve the name (it uses `/etc/nsswitch.conf`). The other tools query only for DNS.

#### `host` command

simple program for looking up DNS entries. With no options, it returns A, AAAA and MX records sets. If given IPv4 or IPv6 addres, it outputs the PTR record if available.

example: `host wipikedia.org` and `host 208.80.154.224`

to query specific recort type specify using `host -t NS lpi.org` or `host -t SOA lpi.org`.

host can also be used to query a specific name server if you do not wish to use the ones in `/etc/resolv.conf`. Simply add the IP address or host name of the server you wish to use as the last argument: `host -t MX test.com dns1.dnsserver.com`

#### `dig` command

Verbose output, good for debugging DNS troubles.

```txt
; <<>> DiG 9.18.12-0ubuntu0.22.04.3-Ubuntu <<>> google.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 62043
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;google.com.			IN	A

;; ANSWER SECTION:
google.com.		300	IN	A	142.251.128.142

;; Query time: 1300 msec
;; SERVER: 127.0.0.53#53(127.0.0.53) (UDP)
;; WHEN: Thu Sep 21 15:31:50 -03 2023
;; MSG SIZE  rcvd: 55
```

The first section of the output display version and query sent, along with options.

Next section shows information about the query and the response.
Next section shows information about ENDS extensions used and the query. (OPT PSEUDOSECTION)
Next section shows the result of the query. Number in the second column is the TTL of the resource in seconds.

The rest of the output provides information about the domain’s name servers, including the NS records for the server along with the A and AAAA records of the servers in the domain’s NS record.

You can specify the record type using `dig -t SOA teste.org`
You can use many options for example: `dig +short` to query only the result or `dig +nocookie` to not use cookie EDNS extension.

You can override defaults in `.digrc`

# Security

Some common security tasks as sysadmin:

- special permissions on files
- user password aging
- open ports and sockets
- use of system resourcers
- logged-in users
- privilege escalation through su and sudo

## Checking files with SUID and SGID

SUID will allow the file to be executed with privileges of the file's owner. (4000, represented by s or S on the owners execute permission bit). An example is `passwd` command.

It has SUID so users can change their own password.

SGID can be set on FILES and DIRECTORIES.
SGID on file is similar to SUID but the file is with group owner privileges.
SGID on directory will allow files created on this directory to inherit the ownership of the directory group.
SGID is represented by s or S on the group execute permission bit (numerical 2000).

To find files with either or both SUID and SGID set you can use the  `find` command with `-perm` option.

- `-perm numericvalue` or `-perm symbolicvalue`
    will find files having special permissions exclusively
- `-perm -numericvalue` or `-perm -symbolivalue` (- prefix)
    will find files having the special permissions and other permissions
- `-perm /numericvalue` or `-perm /numericvalue` (/ prefix)
    will find files having either of the speciel permissions (and other permissions)

Example:

To find files with only SUID set in current directory: `find . -perm 4000` or use `u+s`
To find files matching SUID (irrespective of other permissions in /usr/bin): `find /usr/bin -perm -4000` or use `-u+s`
To find files with either SUID or SGID add 4 and 2 and use /: `find /usr/bin -perm /6000`

## Password management and Aging

You can use `passwd -S` to get status information about the current account.

There will usually be 7 fields: `caetano P 12/07/2019 0 99999 7 -1`

1. The login name
2. Indication if user has valid password (P) or locket password(L)/no password (NP)
3. Date of last password change
4. Minimum age in days (number of days between password change) 0 means change anytime
5. Maximum age in days (number of days password is valid) 99999 will disable password expiration
6. 7 warning perion (number of days prior to password expiration a user will be warned)
7. password inactivity perion (number of inactive days after password expiration before account is locked) value -1 will remove account inactivity.

You can lock and unlock accounts with `-l` and `-u`
You can force a user to change their password on the next login using `-e`
You can delete a user’s password with the  `-d` option

You can also lock/unlock user password with `usermod` command:

- `usermod -L USERNAME`
- `usermod -U USERNAME`

The `chage` (change age) utility is good to deal with password and account aging. as root you can run `chage -l` followed by a username to have that users current password and account expiry infromation.

run without options to run **interactively**.

or you can specify options manually:

-m days username or --mindays days username

Specify minimum number of days between password changes (e.g.: chage -m 5 carol). A value of 0 will enable the user to change his/her password at any time.

-M days username or --maxdays days username

Specify maximum number of days the password will be valid for (e.g.: chage -M 30 carol). To disable password expiration, it is customary to give this option a value of 99999.

-d days username or --lastday days username

Specify number of days since the password was last changed (e.g.: chage -d 10 carol). A value of 0 will force the user to change their password on the next login.

-W days username or --warndays days username

Specify number of days the user will be reminded of their password being expired.

-I days username or --inactive days username

Specify number of inactive days after password expiration (e.g.: chage -I 10 carol) — the same as usermod -f or usermod --inactive. Once that number of days has gone by, the account will be locked. With a value of 0, the account will not be locked, though.

-E date username or --expiredate date username

Specify date (or number of days since the epoch — January, 1st 1970) on which the account will be locked. It is normally expressed in the format YYYY-MM-DD(e.g.: chage -E 2050-12-13 carol).

Examples:
Make password valid for 365 days: `chage -M 365 carol`
Make user change password on next login: `chage -d 0 carol`
Minimum number of days between password cahnges to 1: `chage -m 1 carol`
Disable password expiration: `chage -M 99999 carol`
Enable user to change password at any time: `chage -m 0 carol`
Set warning period to 7 days and accounte xpiration to 20/08/20250: `chage -W 7 -E 2050-08-20 carol`
Print current password information: `chage -l mary`

## Discovering Open Ports

### lsof

To keep an eye in open ports four powerful utilities are present: `lsof`, `fuser`, `netstat` and `nmap`

`lsof` stands for list open files (which is a lot!)

to limit the output  to only "internet" network files, run `lsof -i` (you can use i4 or i6 also)

you can specify a particular host to check for its connection, for example: `lsof -i@192.168.10.2`

you can specify multiple ports separated by commas, for example: `lsof -i@192.168.10.2:22,80`

---

### fuser

`fuser` is to find a file's user, which involves knowing what processes ar eaccessing what files.

`fuser -v .` will get some information about the current working directory.

Breaking down the output:

File is the file we are getting information about (/home/user, for example)

USER column is the owner of the file
PID column is the process identified
ACCESS column is the type of access (..c..) one of:
`c` current directory
`e` executable being run
`f` open file (ommited in default display mode)
`F` open file for writing (ommited in default display mode)
`r` root dir
`m` nmap'ed file or shared library
`.` placeholder
COMMAND column is the command affiliated with the file (bash)

with the `-n` (or `--namespace`) you can find informationa about network ports/sockets. You **must** supply the network protocol and port number. for example: `fuser -vn tcp 80`.

you can kill processes acessing the file, for example `fuser -k 80/tcp`.

---

### netstat

running netstat without options will display both internet connections and unix sockets.

some options:

`-e` extend will display additional information.
without `-l` only established connections will show, with `-l` will list listening connections

---

### nmap

it can port scan by using `nmap $ipaddress`.

aside from a single host you can scan:

multiple host (separating them by space): `nmap 192.168.0.1 localhost`
host ranges: `nmap 192.168.0.3-10`
subnets: `nmap 192.168.0.*` or `nmap 192.168.0.0/24`
to scan  a port use `nmap -p 22 localhost`
scan multiple ports: `nmap -p ssh,80 localhost`
`nmap -p 20-80 localhost`

`-F` will host a fast scan on the 100 most common ports
`-v` wil show a verbose output and `-vv` will show even more verbose output

## Examples

Examples:
Show network files for host 192.168.1.55 on port 22: `lsof -i@192.168.1.55:22`
Show processes accessing the default por of the apache web server on your machine: `fuser -vn tcp 80`
List all listening udp sockets: `netstat -ul`
Scan ports 80 to 443 on host 192.168.1.55: `nmap -p 80-443 192.168.1.55`

## Limits on User Logins, Processes and Memory Usage

Resources are not unlimited, you can ensure a good balance between user limites on resources using `ulimit`.

There are **soft** and **hard** limits with `ulimit`. Specified by `-S` and `-H` options.

Running ulimit without options or arguments will display the soft file blocks of the current user.

to display all soft limits use `-Sa` or `-a`. to display all hard limits use `-Ha`.

`-b` will display maximum socket buffer size.
`-f` maximum size of files written by the shell and its children.
`-l` maximum size that may be locked into  memory
`-m` maximum resident size (RSS), the current portion of memory held by a process in main RAM.
`-v` maximum amount of virtual memory
`-u` maximum number of processes available to a single user.

When displaying limts you can display soft/hard limits: `ulimit -u`. `ulimit -Su`. `ulimit -Hu`
To set a limit just use: `ulimit -f 500` (will set both hard and soft). To make limits persistent accross reboots use `/etc/security/limits.conf`
Since ulimit is a bash builtin, you need to refer to bash manual to read it.
Once hard limit is set, regular users can't increase it.

## Dealing with logged users

Three utilities that can help tracking logged in users:

- `last` - list of last logged users
- `lasb` - bad login attempts
- `who` - information abot logged in user
  - --runlevel display current curnt level
  - --boot shows last system boot
  - --heading show column heading
- `w` - more verbose output (including JCPU (All processes atached to TTY) and PCPU (process under WHAT)) you can use `w $user`

> remember pts (pseudo terminal slaved) and tty (teletypewriter).

## Basic sudo configuration and usage

running `su - root` will ensure the user environment is being loaded, without `-` the old user environment will be kepts.

the default security policy is `sudoers` and specified in `/etc/sudoers` and `/etc/sudoers.d/*`

basic usage of sudo: `sudo -u TARGET-USERNAME command`.

> sudoers will use a per-user (and per-terminal) timestamp for credential caching, so that you can use sudo without a password for a default period of fifteen minutes. This default value can be modified by adding the timestamp_timeout option as a Defaults setting in /etc/sudoers (e.g.: Defaults timestamp_timeout=1 will set credential caching timeout to one minute).

### `/etc/sudoers`

specification of who can run what commands as what users on what machines.

- % indicates groups
- should use visudo to edit
- can use aliases

The privilege specification for the root user is ALL=(ALL:ALL) ALL. This translates as: user root (root) can log in from all hosts (ALL), as all users and all groups ((ALL:ALL)), and run all commands (ALL). The same is true for members of the sudo group — note how group names are identified by a preceding percent sign (%).

To have forexample ser carol be able to check apache2 status from any host as any user or group:

```txt
carol ALL=(ALL:ALL) /usr/bin/systemctl status apache2
```

To let carol not provide her password to run systemctl status, you can use:

```txt
carol ALL=(ALL:ALL) NOPASSWD: /usr/bin/systemctl status apache2
```

To restrict your hosts to 192.168.10.1 and enable carol to run systemctl status apache2 as user mimi (`sudo -u mimi systemctl status apache2`):

```txt
carol 192.168.10.1=(mimi) /usr/bin/systemctl status apache2
```

To give privileges to carol , you can run `sudo usermod -aG sudo carol`

> in red hat distros, the `wheel` is the counterpart to the special administrative sudo group on debian systems.

to change the default text editor, add in `/etc/sudoers`:

```txt
Defaults    editor=/usr/bin/nano
```

or specify a text editor via EDITOR env var: EDITOR=/usr/bin/nano visudo

three types of aliases:

- host aliases (Host_Alias)
  - comma separated list of hostnames, ip addresses, networks and netgroups (preceded by +), netmasks
- user aliases (User_Alias)
  - list of usernames, groups (preceded by %), netgroups (preceded by +). can exclude users with !.
- command aliases(Cmnd_Alias)
  - list of commands and rirectories, if a directory is specified, any file in that directory will be included (subdirs ignored). the example contains a single command with all its subcommands
for example:

```txt
# Host alias specification
Host_Alias SERVERS = 192.168.1.7, server1, server2

# User alias specification
User_Alias REGULAR_USERS = john, mary, alex
User_Alias PRIVILEGED_USERS = mimi, alex
User_Alias ADMINS = carol, %sudo, PRIVILEGED_USERS, !REGULAR_USERS

# Cmnd alias specification
Cmnd_Alias SERVICES = /usr/bin/systemctl *

# User privilege specification
root ALL=(ALL:ALL) ALL
ADMINS SERVERS=SERVICES
# Allow members of group sudo to execute any command
%sudo
ALL=(ALL:ALL) ALL
```

As a result of the alias specifications, the line ADMINS SERVERS=SERVICES under the User privilege specification section translates as: all users belonging in ADMINS can use sudo to run any command in SERVICES on any server in SERVERS.

## Improve authentication security with Shadow Passwords

A way of remembering the order of the field in `/etc/passwd` is to think about the process of a user logging in:
first enter login name, then the system will map the name to a uid, and then into a gid. then the system asks for a password, the fifht lookps up the comment and the sixth enters the home directory. and the seventh is the default shell.

the `x` in passwd indicated that the password is hashed an stored in `/etc/shadow`

you can lock a user password using `sudo passwd -l user`
you can test the lock using `sudo login user`
to list information about the password you can use `sudo chage -l user`
to change a user passwd you can use `sudo passwd user`

To prevent all users except the root user from logging into the system temporarily, the superuser may create a file named /etc/nologin. This file may contain a message to the users notifying them as to why they can not login (for example, system maintenance notifications). For details see man 5 nologin. Note there is also a command nologin which can be used to prevent a login when set as the default shell for a user. For example:
`sudo usermod -s /sbin/nologin emma`
See man 8 nologin for more details.

## Superdaemon to Listen for Incoming Network Connections

on Sys-V init systems you would control services using `service`. on systemd systems you use `systemctl`.

in former times, where availability of resources were smaller. To run a service, you would need a superdameon listening for incoming network connections that will start the service when a network connection to the appropriate service was made. For example: `inetd` and `xinetd`.

On current systems, the `systemd.socket` can be used in a similar way.

Before configuring the xinetd service some preparation is necessary.

To use xinetd to intercept connections to sshd, we can do the following:
first make sure you have openssh-server and xinetd installed.
check that ssh is listening on port 22: lsof -i :22
stop the ssh service with systemctl stop sshd.service
create xinetd configuration file in `/etc/xinet.d/ssh`:

```txt
service ssh
{
disable = no
socket_type = stream
protocol= tcp
wait= no
user= root
server = /usr/sbin/sshd
server_args = -i
flags= IPv4
interface= 192.168.178.1
}
```
restart the xinetd: systemctl restart xinetd.service

check lsof -i:22 and you will see xinetd is listening on that port

by default systemd already has a systemd socket unit to ssh. it is used to substitute xinetd:

you just have to start the ssh socket unit: systemctl start ssh.socket

when you run lsof -i :22 -P you will see systemd is taking over the control of the port.

## Checking Services for Unnecessary Daemons

on sysv-init systems you can check status of all services with:
`sudo service --status-all`

to disable Unnecessary services run `sudo update-rc.d SERVICE-NAME remove` on debian or `sudo chkconfig SERVICE-NAME off` on redhat

on systemd servites you can use `systemctl list-units --state active --type service`
to disable you can run `systemctl disable UNIT --now`

the command will stop the service and remove it from the list.

you get a surver of listenint network services with netstat (provided by net-tools packages) with netstat -ltu

## TCP Wrappers as Sort of a Simple Firewall

it is a legacy way to secure network connections. 

to make the ssh service available only from the local network:

check wheter the ssh daemon uses libwrap which offers tcp wrappers support:

ldd /usr/bin/sshd | grep "libwrap"

now add the file on `/etc/hosts.deny`

```
sshd: ALL
```

configure an exceptionin `/etc/hosts.allow`

```
sshd: LOCAL
```

changes take effect immediately

# Encryption


## SSH

SSH (Secure Shell) was designed with security in mind. It uses public key cryptography to authenticate both hosts and users and encryps all subsequent information exchange.

SSH can be used to establish *port tunnels*. This allows non-encrypted protocol to transmit data over an encrypted ssh connection. Current recommended version of the SSH protocol is 2.0. OpenSSH is free and open source implementation of the SSH Protocol.

The message "authenticity of host can't be establised" on the first connection is normal because there is not any data about the ECDSA Key fingerprint of the host public key (it uses SHA256). Once accepting the connection the public key of the remote server will be stored the *known hosts* database. it is kepts unde `~/.ssh/known_hosts`.

On a local DHCP Network where adress can change, you can get a man-in-the-middle attack message because the host public key fingerprint is not the same.

You can then remove the offending key: `ssh-keygen -f "/home/USER/.ssh/known_hosts" -R "HOSTIP"`.

### Key-based Logins

The process consists of:

1. Create a key pair on the client machine (ssh-keygen -t ALOGRITHM)
2. Add the public key to the `~/.ssh/authorized_keys` file of the user on the remote host.

For example:

```bash
ssh-keygen -t ecdsa -b 521 #-b to specify key size in bits
```

It will generate assymetric keys where only one can decrypt the other encryption result.

one way of doing  the step two is:

```bash
cat id_ecdsa.pub | ssh user@remote_ip 'cat >> .ssh/authorized_keys'
```

or use `scp`.


using the SSH authentication agent (ssh-agent). The authentication agent needs to spawn its own shell and will hold your private keys — for public key authentication — in memory for the remainder of the session. Let us see how it works in a little bit more detail:

use ssh agent to start a new bash shell.

```bash
ssh-agent /bin/bash
```

Use the ssh-add command to add your private key to a secure area of memory. If you supplied a passphrase when generating the key pair — which is recommended for extra security — you will be asked for it:

Once your identity has been added, you can login to any remote server on which your public key is present without having to type your passphrase again. It is common practice on modern desktops to perform this command upon booting your computer, as it will remain in memory until the computer is shutdown (or the key is unloaded manually).

Some algorithms that can be used with ssh-keygen:

- **RSA**
  - published in 1977. Minimum key size is 1024 (default 2048)
- **DSA**
  - digital signature algorithms has been proven to be insecure and is deprecated. must be exactly 1024 bits in length
- **ecdsa**
  - eliptic curve digital signature algorithm is an improvement of DSA, considered more secure. it uses elyptic  curve cryptography. ECDSA key size can be: 256, 384 or 521
- **ed25519**
  - an implementation of EdDSA that uses the 25519 curve. considered most secure of all. fixed key lengths of 256 bits.

### Role of OpenSSH Server Host Keys

The global configuration directory for OpenSSH lives in `/etc/ssh`

Configuration for the client: `/etc/ssh/ssh_config`
Configuration for the server: `/etc/ssh/sshd_config`
The server uses the host keys to identify itself to clients as required. Their name pattern is:

**private keys**: `ssh_host_` prefix + `algorithm` + `key` suffix, example: `ssh_host_rsa_key`
**public keys**: `ssh_host_` prefix + `algorithm` + `key.pub` suffix, example: `ssh_host_rsa_key.pub`

A fingerprint is created by applying a cryptographic hash function to a public key. They simplify key management.

permissions for private keys are 0600 and for public keys are 0644.

To view the fingerprint of the key use `ssh-keygen -l -f /etc/ssh/ssh_host_ed25519_key`
To view the fingerprint of the key and random art use `ssh-keygen -lv -f /etc/ssh/ssh_host_ed25519_key`

### SSH Port Tunnels

OpenSSH features a forwarding facility where traffic on a source port is tunneled and encrypted through an SSH Process which then redirects it to a port on a destination host.

This mechanism is known as port tunneling or port forwarding

* allows to bypass firewalls to access ports on remote hosts
* allows access from the outside to a host on the private network
* encryption for all data exchange

#### Local Port Tunnel

You can define a port locally to forward traffic to the destination host through the SSH process.

The SSH process can run on the local host or on a remote server.

For example, if you want to tunnel a connection to `www.gnu.org` through SSH using port 8585 on the local machine, you can do: `ssh -L 8585:www.gnu.org:80 debian`

with the -L switch, we specify the local port 8585 to connect to http port 80 on www.gnu.org using the SSH process running on debian — our localhost.

We could have written ssh -L 8585:www.gnu.org:80 localhost with the same effect. If you now use a web browser to go to http://localhost:8585, you will be forwarded to www.gnu.org. For demonstration purposes, we will use lynx (the classic, text-mode web browser): `lynx http://localhost:8585`

If you wanted to do the exact same thing but connecting through an SSH process running on another host, you would have proceeded like so: `ssh -L 8585:www.gnu.org:80 -Nf remoteuser@remoteip`

- Thanks to the -N option we did not login to halof but did the port forwarding instead.
- The -f option told SSH to run in the background.
- We specified user remoteuser to do the forwarding: remoteuser@remoteip

Some use cases are:
* Acessing a database (MySQL, MongoDB) using a fancy UI tool from your laptop
* Using a browser to access a web application exposed to a private network
* Acessing a container port from your laptop without publishing it on the server public interface.

```bash
ssh -L [local_addr:]local_port:remote_addr:remote_port [user@]sshd_addr
```

The -L flag indicates we're starting a local port forwarding. What it actually means is:
- On your machine, the SSH client will start listening on local_port (likely, on localhost, but t it depends - check the GatewayPorts setting).
- Any traffic to this port will be forwarded to the remote_private_addr:remote_port on the machine you SSH-ed to.

##### Local Port Forwarding with a Bastion Host

It might not be obvious at first, but the ssh -L command allows forwarding a local port to a remote port on any machine, not only on the SSH server itself. Notice how the remote_addr and sshd_addr may or may not have the same value.

so the sshd would be at the bastion host.

#### Remote Port Tunnel

In remote port tunnelling (or reverse port forwarding) the traffic coming on a port on the remote server is forwarded to the SSH process running on your local host, and from there to the specified port on the destination server (which may also be your local machine).

For example, say you wanted to let someone from outside your network access the Apache web server running on your local host through port 8585 of the SSH server running on halof (192.168.1.77). You would proceed with the following command: `ssh -R 8585:localhost:80 -Nf ina@192.168.1.77`

Now anyone who establishes a connection to halof on port 8585 will see Debian's Apache2 default homepage

Use case:
Another popular scenario is when you want to momentarily expose a local service to the outside world. Of course, for that, you'll need a public-facing ingress gateway server.

```bash
ssh -R [remote_addr:]remote_port:local_addr:local_port [user@]gateway_addr
```

#### X11 Tunnels

Through an X11 tunnel, X window system on the remote host is forwarded to the local machine. for example: `ssh -X ina@halof`

you can now launch a graphical application such as firefox: the app will be run on the remote server but its display will be forwarded to your local host.

If you start a new SSH session with the -x option instead, X11forwarding will be disabled.

> The three configuration directives related to local port forwarding, remote port forwarding and X11 forwarding are AllowTcpForwarding,GatewayPorts and X11Forwarding, respectively. For more information, type man ssh_config and/or man sshd_config.

To enable root logins add `PermitRootLogin` in `/etc/ssh/sshd_config`.
To specify only a local account to accept ssh connections use `AllowUsers` in `/etc/ssh/sshd_config`.
To transfer the client public key to the server you can use `ssh-copy-id` command.

## GnuPG (GPG)

GNU Privacy Guard is a free, open-source implementation of the Pretty Good Privacy (PGP).

GPS uses the OpenPGP standard as defined by OpenPGP Working Group of the IETF in RFC 4880.

The command to work with GPG is `gpg`

### Configuration, Usage and Revocation

the underlying mechanism to GPG is that of assymetric cryptography.

To generate a key pair for a user, you will use: `gpg --gen-key`.

After generating you can see whats inside `~/.gnupg` directory.

It may include:
**opengp-revocs.d**: revocation certificate that was created along with the key pair is kept here. The permissions on this directory are quite restrictive as anyone who has access to the certificate could revoke the key
**private-keys-v1.d**: This is the directory that keeps your private keys, therefore permissions are restrictive
**pubring.kbx**: This is your public keyring. It stores your own as well as any other imported public keys.
**trustdb.gpg**: The trust database. This has to do with the concept of Web of Trust

> The arrival of GnuPG 2.1 brought along some significant changes, such as the disappearance of the secring.gpg and pubring.gpg files in favour of private- keys-v1.d and pubring.kbx, respectively.

after creating the keypar you can use `gpg --list-keys` which will display the contents of your publickeyring. it will display the public key fingerprint. The KEY-ID consists of the last 8 hexadecimal digits in your public key fingerprint. You can check your key fingerprint with the command gpg --fingerprint USER-ID.

#### Key Distribution and Revogation

After having your public key, you can export it and make it available to other recipients.

They will be able to encrypt files intended for you.

You can export your key using: `gpg --export carol > carol.pub.key`
To export all keys you can use: `gpg --export --output all.keys`
to export all private keys you can use: `gpg --export-secret-keys --output all_private.key`
you can use `--edit-key` to use a menu for key management tasks.

> Passing the -a or --armor option to gpg --export(e.g.: gpg --export --armor carol > carol.pub.key) will create ASCII armored output (instead of the default binary OpenPGP format) which can be safely emailed.

> A means of public key distribution is through the use of key servers: you upload your public key to the server with the command gpg --keyserver keyserver-name --send-keys KEY-ID and other users will get (i.e. import) them with gpg --keyserver keyserver-name --recv-keys KEY-ID.

Key revogation: should be used when a private key have been retired or compromised. First, create a revogation certificate by using `--gen-revoke` followed by UID. you can preceed the option with `--output` to save the result to a file. For example: `gpg --output revocation_file.asc --gen-revoke sonya`

To effectively revoke your private key, you now need to merge the certificate with the key, which is done by importing the revocation certificate file to your keyring: `gpg --import revocation_file.asc`. if you list keys again you will see it was revoked.

#### Encrypt/Decrypt

The recipient must import the public key to its keyring: `gpg --import carol.pub.key`

To encrypt a file use: `gpg --output encrypted-message.txt --recipient carol --armor --encrypt unencrypted-message.txt`
To decrypt use: `gpg --decrypt encrypted-message.txt`

#### Sign/Verify files

to sign use: `gpg --output message.sig --sign message.txt`
to verify use: `gpg --verify message.sig`
to read the files use: `gpg --output message --decrypt message.sig`
cleartext signature: `gpg --clearsign`
#### GPG-Agent

gpg-agent is the daemon that manages private keys for GPG (it is started on demand by gpg). To view a summary of the most useful options, run gpg-agent --help or gpg-agent -h
