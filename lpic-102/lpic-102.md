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

Accurate timekeeping is crucial. When a linux computer boots up, it starts keeping time (system clock). In addition, modern
