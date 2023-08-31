# Linux LPIC

Strictly speaking, the operating system is just the kernel and its components which
control the hardware and manages all processes

/table

OS INITIALIZATION PROCESS

POST → UEFI or BIOS → GRUB (Grnad Unified Bootloader) → Load Kernel into RAM

The initialization of the operating system starts when the bootloader loads the kernel into RAM.

- kernel will take charge of the CPU and will start to detect and setup the fundamental
aspects of the operating system, like basic hardware configuration and memory addressing
- kernel will then open the initramfs (initial RAM filesystem). to provide the required modules so the kernel can access the “real” root fileststen
- As soon as ROOTFS is available the kernel mount will be configured in `/etc/fstab` and then will execute the first program, a utility named init. The init program is responsible for running all initialization scripts and system daemons. There are distinct implementations of such system initiators apart from the traditional init, like systemd and Upstart. Once the init program is loaded, the initramfs is removed from RAM.
- Kernel stores messages in the ******************************************************kernel ring buffer****************************************************** - use `dmesg --human`
- On systemd
    
    **journalctl** will show the initialization messages with
    options **-b, --boot, -k** or **--dmesg**. Command **journalctl --list-boots** shows a list of boot
    numbers relative to the current boot, their identification hash and the timestamps of the first and
    last corresponding messages: ******-d******  can be used to read on different directories
    

**GRUB**

can be invoked sometimes pressing esc or shift

`/proc/cmdline` contains kernel parameters used for loading

To change Kernel Parameters:

`/etc/default/grub` in the line `GRUB_CMDLINE_LINUX` to make them persistent across reboots.

and run

`grub-mkconfig -o /boot/grub/grub.cfg.`

---

# Runlevels

change default runlevel on systemd

`systemd.unit=multi-user.target`

`/etc/systemd/system/default.target`

`systemctl set-default multi-user.target`

the directory `/etc/rc[0-9].d`

will have files that start with either K or S .. K means kill, S means start and it will contains scripts executed when the system enters this runlevel

the actual scripts are in `/etc/init.d` and it will contain symbolic links linking to it

With the adoption of **`systemd`** in many modern Linux distributions, this traditional structure and methodology are less frequently used. However, it's still present on some systems for backward compatibility or in distributions that still utilize the SysV init system.

```bash
telinit 0 #(shutdown)

telinit 1 #(single user mode/s without network and other nonessential)

telinit 2 #(multiuser without network)

telinit 3 #(multiuser with network)

telinit 4 #(undefined/unused - for user defined purpose)

telinit 5 #(graphical)

telinit 6 #(reboot)
```

to get current runlevel type `runlevel`

to change runlevels on systemd use

`systemd isolate [runlevel0.target](http://runlevel0.target) (1,2,3… [multi-user.target](http://multi-user.target) )`

**multi-user.target**: This target is designed for multi-user systems. Most of the daemon services are started when this target is reached. This is similar to the traditional runlevel 3 in SysV init systems.

When the system boots, systemd starts units (like services, sockets, etc.) and progresses through various targets. Eventually, it will reach a "default target," which defines what state the system should boot into by default. In many systems, the default target is either **`multi-user.target`** or **`graphical.target`** (which is similar to the traditional runlevel 5 in SysV and is designed for systems with a graphical interface).

You can check the default target of your system with the following command:

```arduino
systemctl get-default
```

And you can set the default target with:

```arduino
sudo systemctl set-default <target-name>
```

For instance, to set the default to **`multi-user.target`**, you'd use:

```arduino
sudo systemctl set-default multi-user.target
```

**LIST ALL AVAILABLE UNITS**

`systemctl list-unit-files = shows all units and if they are inabled`

`systemctl list-unit-files --type=service`

`systemctl list-unit-files --type=target`

**LIST ACTIVE IN CURRENT SYSTEM SESSION**

`systemctl list-units`

**get default target**

`systemctl get default`

**ALSO RESPONSIBLE FOR POWER RELATED EVENTS EXAMPLE:**

`systemctl suspend   - keep data in memory`

`systemctl hibernate  - keep data in disk`

However, this systemd feature can only be used when there is
no other power manager running in the system, like the acpid daemon. The acpid daemon is the
main power manager for Linux and allows finer adjustments to the actions following power
related events, like closing the laptop lid, low battery or battery charging levels.

to restart systemd daemon and reload units run `systemctl daemon-reload`

systemd default systems directory `/etc/systemd/system`

**`rc.local`** is a traditional script that gets executed by the init system at the end of the system's boot process. Historically, in Unix-like systems that used System V init (SysV) or its equivalent, the **`/etc/rc.local`** file was a place where system administrators could put custom startup commands that needed to run at the end of the system initialization process.

In **`systemd`**, there might be a service unit (like **`rc-local.service`**) that's responsible for this execution.

**`.target`** units provide a way to manage the order and dependencies of other units, making the boot and shutdown processes more flexible and manageable.

---

# Hard Disk Layout

parition table contains information about first/last sectors.

filesystem - how directories are organized, relationship, where data is stored for each file etc

LVM (Logical Volume Manager) -  multiple partitions can be combined, even across disks, to form a single logical volume

Before a filesystem can be used it must be mounted (attaching filesystem to a point in your system tree).

************************Mount Points************************

Traditionally, `/mnt` was the directory under which all external devices would be mounted.

This has been superseded by `/media`, which is now the default mount point. Format is `/media/USER/LABEL`

**Separating Things**

It is good to separate some directories in other partitions, for example, bootloader related files stored on `/boot` you ensure the system can still boot if root fs is corrupted.

user’s personal directories (under `/home`) on a separate partition makes it easier to
reinstall the system without the risk of accidentally touching user data.

Keeping data related to a web or database server (usually under `/var`) on a separate partition (or even a separate disk) makes system administration easier should you need to add more disk space for those use cases.

Example; root fs on NVME SSD and bigger directories like /home and /var on HDD

****************************Boot Partition****************************

Usually mounter on /boot contains boot/grub files.

original IBM PC BIOS addressed disks using cylinders, heads and sectors (CHS), with a maximum of 1024 cylinders, 256 heads and 63 sectors, resulting in a maximum disk size of 528 MB (504 MB under MS-DOS).

So for maximum compatibility, the boot partition is usually located at the start of the disk and
ends before cylinder 1024 (528 MB), ensuring that no matter what, the machine will be always
able to load the kernel.

Good SIZE: 300mb

The EFI System Partition (ESP) is used by machines based on the Unified Extensible Firmware
Interface (UEFI) to store boot loaders and kernel images for the operating systems installed

**************************Variable Data**************************

system must be able to write during operation

`/var/www/html /var/lib/mysql /var/cache /var/tmp /var/log`

Example: faulty application writes to /var until there is no more space and triggers a kernel panic / filesystem corruption. if /var is on separate partition the rootfs would be unnafected

****Swap****

Swap memory pages to disk

---

# GRUB

files in boot partition will have a version suffix

for the Linux kernel version 4.15.0-65-generic would be called
config-4.15.0-65-generic.

**Config File**

configuration param for the linux kernel, generated when kernel is compiled

**System map**

symbols map, good for knowing which variable or fuction was being called on kernel panic event

**Linux Kernel**

OS Kernel, `vmlinux-VERSION` also found as `vmlinuz` when file is compressed

**Initial RAM disk**

`initrd.img`contains minimal rootDS loaded into RAM, utilities and kernel modules needed to mount the real FS.

**************************************Boot loader related files**************************************

modules for grub for example, like translation files and fonts or [grub.cf](http://grub.cf) file

`grub-install --boot-directory=/boot /dev/sda`

Default grub config file is on `/boot/grub/grub.cfg` editing not reccomended.

better to edit the `/etc/default/grub` and run `update-grub`

```yaml
# Default entry to boot, can be numerid or the name (ex. debian)
# first menu entry is 0
GRUB_DEFAULT=0
# if set to true, than GRUB_DEFAULT <= saved which means that the default boot option
# is always the last one to be selected
GRUB_SAVEDEFAULT=
#timeout in second before the default menu entry is selected 
# if 0 , then boot without waiting
# if -1, then system will wait till a selection
GRUB_TIMEOUT=
# options added to linux kernel entry
GRUB_CMDLINE_LINUX=
# add extra params that will be added ony to the default entry
GRUB_CMDLINE_LINUX_DEFAULT=
# if y then command will look for encrypted disks and add the comands needed to access
GRUB_ENABLE_CRYPTODISK=
```

Command to update file:

```bash
update-grub
grub-mkconfig -o /boot/grub/grub.cfg
```

**Booting from the grub2 shell**

```bash
set root=(hd0,msdos1)
linux /vmlinuz root=/dev/sda1
initrd /initrd.img
```

**********************************************Booting from the rescue shell**********************************************

After finding out which partition is the boot partition and where grub files are located

run the following:

```bash
set prefix=(hd0,msdos1)/boot/grub

#load modules normal and linux
insmod normal
insmod linux
```

then run

```bash
set root=(hd0,msdos1)
linux /vmlinuz root=/dev/sda1
initrd /initrd.img

boot
```

**In GRUB LEGACY**

`/boot/grub/menu.lst`

```bash
kernel (hd0,0/vmlinuz root=dev/hda1
===== equivalent to
root (hd0,0)
kernel /vmlinuz root=/dev/hda1

# to load modules you run a command with .mod in the end
# example: module /boot/grub/i386-pc/915resolution.mod
```

**************************************Find boot partition**************************************

```bash
fdisk -l /dev/sda
```

**Find UUID**

```bash
ls -la /dev/disk/by-uuid/
```

Grub menu find disk of uuid

`search --set=root --fs-uuid 5dda0af3-c995-481a-a6f3-46dcd3b6998d`

From grub legacy shell, to install grub to the first partition of second disk

the first step is to set the boot device, which contains the /boot directory.

`root (hd1,0)`

to install GRUB
Legacy to the MBR and copy the needed files to the disk

`setup (hd1)`

to find devide that contains /boot directory run

`find /boot/grub/stage1`

# Shared Libraries

Shared Libraries are a way of storing reusable code and linking it on runtime (decreasing programs size). usually located on `/lib /lib32 /lib64 /usr/lib /usr/local/lib`

```bash
ls /etc/ld.so.conf.d
# configure dynamc linker
ldconfig
#info from object file
objdump
#Print shared objects dependencies of a program.
ldd
#readelf
readelf
```

# Package Managers

Before Package Managers people donwloded `tar.gz` files extracted and compiled.

## dpkg (debian package tool)

**Install `.deb` package or update**

`dpkg -i packagename.deb`

DPKG wil check for dependencies and will fail to install if they are not present, it will list which packages are missing.

**Removing packages**

`dpkg -r NAME.deb`

the removal will not let you remove untill all packages that depends on it are removed

After they are removed config files are still stored, if you want to remove all run `-P` flag (PURGE)

**Package information** (version, architecrute, maintaner, dependencies etc)

`dpkg -I NAME.deb`

**List installed packages and installed files** 

`dpkg --get-selections` 

`dpkg -L unrar` 

`-L` list every file installed by a specific package

**********************************************************Find which package own a file**********************************************************

`dpkg-query -S PATH`

********Reconfigure********

Re-run post-install script and unpack new config files in the correct irectories

`dpkg-reconfigure PACKAGENAME`

## apt (advanced package tool)

advanced search and automatic dependency resolution

is like a “frontend” for dpkg

APT works with repositories (local or remote). Ubuntu and Debian mantain their own repositories, there are orgs or user groups/developer that provide their own repositories

`apt-get` install/uprage/remove packages

`apt-cache` searches

`apt-file` seraching files inside packages

`apt` bundles most used options of apt-get and apt-cache but is not always installed

`apt-get update` - updated package index

to remove config files run `apt-get remove --purge` (they are left on the system when not run with —purge)

**to fix broken depencencies**

`apt-get install -f`

**********************************************upgrade package version**********************************************

`apt-get upgrade`

**********************local cache**********************

when packages are install or updated the `.deb` files are stored to a local cache:

`/var/cache/apt/archives`

`/var/cache/apt/archives/partial`

when installing / upgrading the cache can get quite large, use `apt-get clean` to reclaim space

****************************searching the package index****************************

`apt-cache search PACKAGENAME`

searching for a package or listing which packages contain a specific file

`apt-cache show`

**Sources List**

apt uses a list of sources to get packages from.

`/etc/apt/sources.list`

the format of the `sources.list` file is

```bash
deb http://us.archive.ubuntu.com/ubuntu/ disco main restricted universe multiverse
```

**********************`**ARCHIVE TYPE**`**********************

DEB-SRC (Source Code) or DEB (Binary)

**`URL`**

Repo url

**`DISTRIBUTION`**

distribution for which packages are provided.

**`COMPONENTS`**

main - officialy supported open-source

restricted - closed source /device drivers

universe - community maintaned open-source

multiverse - usupported, closerd-sorce

additional conf files on `/etc/apt/sources.list.d`

using `apt-file` you can perform operations on the package index, like listing the contents or finding a package that contains a file

to list the contents of a package

`apt-file list PACKAGENAME`

search all packages for a file using search

`apt-file search libSDL2.so`

rpm

yum (for rpm)

dnf fork of yum

zypper opensuse

**LPIC 01 TOPIC 102.5 - for packages other than debian/**

---

# Linux as Virtualization Guest

**Hypervisors**

**Xen**

open source type1 (bare metal hypervisor). Can boot directly into the hypervisor

**KVM**

Kernel Virtual Machine is a linux kernel module. Both type 1 and type2. It needs a generic linux OS to run.

**Virtualbox**

type2 hypervisor (needs linux macos or windows)

**Types os VM’s**

**Fully** **virtualized**

All instructions that a guest operating system is expected to execute must be able to run within
a fully virtualized operating system installation. The reason for this is that no additional
software drivers are installed within the guest to translate the instructions to either simulated
or real hardware.

A fully virtualized guest is one where the guest (or HardwareVM) is unaware that it is a running virtual machine instance.

the Intel VT-x or AMD-V CPU extensions must be enabled on the
system that has the hypervisor installed on x86 arch.

**Paravirtualized**

PVM the guest OS is aware that it is running a VM instance. 

These types of guests will make use of a modified kernel and
special drivers (known as guest drivers)

The performance of a paravirtualized
guest is often better than that of the fully virtualized guest due to the advantage that these
software drivers provide.

**Hybrid**

near native I/O performance by using paravirtualized drivers on fully
virtualized operating systems. The paravirtualized drivers contain storage and network device drivers with enhanced disk and network I/O performance

**Types of Disk provisioning for the Guest**

******COW******

copy on write, disk file is created with a pre-defined upper size limit. dynamically increases

******RAW******

raw or full disk, all of the space is pre-allocated. 10GB consumes 10GB

**************NAS/SAN**************

NETWORK ATTACHED STORAGE can use LVM

Since VM’s are just files running on a hypervisor, templating is really easy.

MACHINE ID (cant have two of the same on the same hypervisor)

`dbus-uuid` —get

`/var/lib/dbus/machine-id`

**************************************ACESSING REMOTE/CLOUD VMS**************************************

generate key pair using `ssh-keygen`

run `ssh-copy-id -i <publickey> user@cloudserver` to copy the public key to the remote server and record in ~/.ssh/authorized_key

permissions must be `0600` for private key and `0644` for public key

---

# Containers

container is kind of a Vm but it is just enough software to run an application instead of an entire computer.

user `cgroups` within linux kernel. partition system resource such as memory, processor time, network bandwidth and disk.

---

**Unix commands / Basic Shell**

history command are only written to disk when terminal session is closed

single quotes - preserve literals

double quotes - preserve all charactes except `$ ` \ !`

list of special characters `& ; | * ? " ' [ ] ( ) $ < > { } # / \ ! ~`

---

# Text processing

cat reads from stdin and redirect to stdout

bzcat `bzip`

xzcat `xz`

zcat `gzip`

to show line number run

```bash
cat /var/log/syslog | nl
```

to know the number of lines on a text run

```bash
cat /var/log/syslog | wc -l
```

when using `tail` or `head` you can use `-n` flag to specify more or less than 10 lines

when using grep you can use the `-v` flag to invert the query

******************using sed******************

you can you sed to filter and process text

when running

```bash
sed -n /cat/p < ftu.txt
```

/cat/ is the search pattern, -n is to not produce output

to operate sed on a file directly use the `-i`flag.

********************debug text********************

use `od` command that dumps file in octal format with `-c` flag to show characters

`wc`
Short for “word count” but depending on the parameters you use it will count characters,
words and lines.
`sort`
Used for the organizing the output of a listing alphabetically, reverse alphabetically, or in a
random order.

`uniq`
Used to list (and count) matching strings.
`od`
The “octal dump” command is used to display a binary file in either octal, decimal, or
hexadecimal notation.

`nl`
The “number line” command will display the number of lines in a file as well as recreate a file
with each line prepended by its line number.
`sed`
The stream editor can be used to find matching occurrences of strings using Regular
Expressions as well as editing files using pre-defined patterns.
`tr`
The translate command can replace characters and also removes and compresses repeating
characters.
`cut`
This command can print columns of text files as fields based on a file’s character delimiter.
`paste`
Join files in columns based on the usage of field separators.
`split`
This command can split larger files into smaller ones depending on the criteria set by the
command’s options.
`md5sum`
Used for calculating the MD5 hash value of a file. Also used to verify a file against an existing
hash value to ensure a file’s integrity.
`sha256sum`
Used for calculating the SHA256 hash value of a file. Also used to verify a file against an
existing hash value to ensure a file’s integrity.
`sha512sum`
Used for calculating the SHA512 hash value of a file. Also used to verify a file against an
existing hash value to ensure a file’s integrity.

to print users name that has bash you can use `grep "bash$" /etc/passwd | cut -d: -f1`

`-d` uses “:” as filed separator and `-f1` is the first field .

to view the number of groups in my system you can run `cut -d: -f4 /etc/passwd | sort -u | wc -l`

```bash
sed -n /:1000:[A-Z]/p pass | cut -d: -f5 | cut -d, -f1
```

folder names and owner

```bash
ls -l /etc | grep ^d | tr -s ' ' | cut -d" " -f9,3
```

---

# File Globbing

`rm *`
Delete all files in current working directory.
`ls l?st`
List all files with names beginning with l followed by any single character and ending with st.
`rmdir [a-z]*`
Remove all directories whose name starts with a letter.

******************wildcards******************

**`* (asterisk)`**
which represents zero, one or more occurrences of any character.
`? (question mark)`
which represents a single occurrence of any character.
`[] (bracketed characters)`
which represents any occurrence of the character(s) enclosed in the square brackets. It is
possible to use different types of characters whether numbers, letters, other special characters.
For example, the expression [0-9] matches all digits.

`ls [tfkdsf]ig`

`ls ?ig`

`ls ??g`

---

# Finding Files

`find STARTING_PATH OPTIONS EXPRESSION`

`find /home/frank -name "*.png"`

## Using Criteria to Speed Search

`-type f`-file search

`-type d`- directory type

`-type l`-symbolic link search

`-name -iname`  iname is case insentivite

`-not` return those who does not match test case

-`maxdepth N` maximum amount of subdirectories

**************************************************find by modification time**************************************************

`-mtime 7` last 7 days

`sudo find / -name "*.conf" -mtime 7` find all .conf files in system that was modified in last 7 days

********************find by size********************

`sudo find /var -size +2G`

files larger than 2G

+- or exact value example 20m , -20m , +20m

************************************************acting on the result set************************************************

possible to perform an action on the resulting set

`find . -name "*.conf" -exec chmod 644 '{}' \;`

******************grep to filter for files based on content******************

`find . -type f -exec grep "lpi" '{}' \; -print`

This would search every object in the current directory hierarchy (.) that is a file (-type f) and
then executes the command grep "lpi" for every file that satisfies the conditions. The files that
match these conditions are printed on the screen (-print). The curly braces ({}) are a
placeholder for the find match results. The {} are enclosed in single quotes (') to avoid passing
grep files with names containing special characters. The -exec command is terminated with a
semicolon (;), which should be escaped (\;) to avoid interpretation by the shell.

## Archiving FIles (tar)

`tar`=tape archive

`tar [OPERATION_AND_OPTIONS] [ARCHIVE_NAME] [FILE_NAME(S)]`

create archive

`tar -cvf archive.tar stuff stuff2`

extract to directory

`tar -xvf archive.tar -C /tmp`

to create and compress use `-czfv` craetas tar.gz (gzip)

to use bzip use `-cjvf` creates tar.bz

to decompress use `-zxfv` archive.tar.gz

you can use `gzip` to compress also

---

# Redirects

`0 - stdin`

`1 - stdout`

`2 - stderr`

the communications chennals above can also be accesed via the devices `/dev/std[in|out|err]`

in ternal sessions stind= keyboard and stdout = terminal screen by default

`1> or >` redirect stdout of process to a file

`&>` or `>&` redricetd stdout and stderr to file

`1>&2` redirect stoud to stderr

`2>&1` redirect sterr to stdout

- the & indicated that the following is not a file but a file descriptor

stoud to stin is ok, stderr to stin not, need to first redirect stderr to stdout then stdin

outtput can be discarded

For example, `>log.txt 2>/dev/null` saves the contents of stdout in the file
log.txt

Files are **overwritten** by output redirects **unless** Bash option noclobber is enabled, which can be done for the current
session with the command `set -o noclobber` or `set -C`

To unset run `set +o noclobber` or `set +C`

`/dev/null` is an exception to noclobber

you can redirect to stdin of a process also using `<` 

`uniq -c < /tmp/error.txt` is the same as `uniq -c 0< /tmp/error.txt`

********************************************************here docmunets (HEREDOC)********************************************************

allow multiline text and will be used as redirected content. `<<`

`wc -c <<EOF`

`How many characters`

`in this document?`

`EOF`

the insertion and as soons as an `EOF` is found

`cat <<.>/dev/stdout`

for the command above bash will enter heredoc mode until a `.` appears, and will then redirect the output to dev/stdout

**********************here strings**********************

`wc -c <<< "how many chracters?"`

---

# Pipelines and Streams

## PIPE

the pipe character `|` tells shell to start all the distinct commands at the same time and connect the output of the previous command to the input of the following (left to right_

`cat /proc/cpuinfo | wc`

will get lines, word and chracters count

you can redirect output to a file and to the sceen using `tee`

`cat /proc/cpuinfo | tee cpu.txt`

to not overwrite the file and append use `tee -a`

only logs stdout if you want to log sterr use something like

`make 2>&1 | tee log.txt`

## COMMAND SUBSTITUTION

you can capture the output of a command using command substitution using ````

bash replaces it with its stdout

`mkdir `date +%Y-%m-%d``

or `mkdir $(date +%Y-%m-%d)`

## XARGS

The program xargs uses
the contents it receives via stdin to run a given command with the contents as its argument. The
following example shows xargs running the program identify with arguments provided by
program find

`find /usr/share/icons -name 'debian*' | xargs identify -format "%f: %wx%h\n”`

Option `-n 1` requires xargs to run the given command with only one argument at a time. In the
example’s case, instead of passing all paths found by find

In multiline contents the option `-L` can be used to limit how many lines will be used as arguments per
command execution.

the option `-0` tells xargs the null character should be used as separator.

from my machine to ssh remote

`cat etc.tar.gz | ssh user@storage "cat > /srv/backup/etc.tar.gz”`

or

`ssh user@storage "cat > /srv/backup/etc.tar.gz" < etc.tar.gz`

---

# Create, monitor and kill processes

********jobs********

jobs are processes started interactively through the terminal

if you run `sleep 60` and `Ctrl + z` you will suspend/stop execution and run jobs you can find

the number [1] that appears is the ID and can be used with % to access the jobs con commands like `bg, fg and kill`

the `+` sign indicates the current defualt jobs (last one being sent to background), the prior has a `-` and other are not flagged

if you use `-l` flag you get the PID

using `&` at the end of a command sends it to backgroud

**************************detached jobs (nohup)**************************

jobs are attached to the session of the user, however you can detach the job from the session using nohup

`nohup COMMAND &`

nohup will by default send stdout and sterr to nohup.out

you can send the output to a file using `nohup command > path/file &`

********kill********

`pgrep` can be used to find process id by name

`pkill` can be used to kill process based on name

`killall sleep` kill multiple instances of sleep

KILL sends a `SIGTERM`

but the signal can be changed by using

```bash
kill -SIGHUP 1247
kill -1 1247
kill -s SIGHUP 1247
```

to view all codes use `kill -l`

## TOP

top is sorted by % CPU by default in descending order.

`M` sort by memory

`x` show current column

`N` sort by PID

`T` sort by running time

`P`sort by CPU usage

`R` change from descending/acesding orger

---

`? or h` help

`k` kill

`r` change priority (renice - give `nice` value) range from -20 to 19, only root can set it to value lower than current or negative

`u` list process by user

`c` show programs absolute paths

`V` forest hierarchy

`t and m` change the look of CPU and memory readings

`W` save config setting to ~/.toprc

top output is divided in two areas (summary area and task area)

the summary area gives us the following

`top - 11:10:29 up 2:21, 1 user, load average: 0,11, 0,20, 0,14`

- current time
- uptime
- number of users logged in and CPU load avarege for last 1,5 and 15 minutes

`Tasks: 73 total, 1 running, 72 sleeping, 0 stopped, 0 zombie7`

- total nuber of process in active mode
- running processes (being executed)
- suspendend (waiting to resume execution)
- stopped (by a jobs control signal)
- zombie (completed execution but are waiting for their parent process to remove them from the process table)

`%Cpu(s): 0,0 us, 0,3 sy, 0,0 ni, 99,7 id, 0,0 wa, 0,0 hi, 0,0 si, 0,0 st`

- user processes
- system/kernel processes (percentage of sys processes)
- processes set to a nice value
- nothing (idle cpu time)
- processes waiting for i/o
- oprocesses serving hardware interrupts - peripherals sending the processor signals that require attention
- processes serving software interrupts
- processes serving other VM’s tasks in a VM environtemt (steal time)

`KiB Mem : 1020332 total, 909492 free, 38796 used, 72044 buff/cache`

- the total amount of memory
- unused memory
- memory used
- memory buffered and cached to avoid excessive disk access
- total is the sum of all three

`MiB Swap: 2048,0 total, 2048,0 free, 0,0 used. 9149,4 avail Mem`

- total ammount of swap space
- unused swap space
- swap space in use
- the amount of swap memory that can be allocated to processes without causing more swapping

![Untitled](Linux%20LPIC%20d164a7bad2d1425485d742e0f4d46f4f/Untitled.png)

- PID
- USER user who issued the command
- PR kernel priority
- NI nice value (lowe values have higher priority than higher values)
- VIRT amount of memory used by process (including swap)
- RES RAM used by process
- SHR shared memory of the process with other processes
- S status of the proccess
    - S - interruptible sleep (waiting event to finish)
    - R - runnable (executing or in the queue to execute)
    - Z - zombie - terminated child
- %CPU
- %MEM - Res value as percentage
- TIME+ total time of activity of process
- COMMAND

---

## PS

ps displays statically and can accept three styles (BSD, UNIX and GNU)

BSD no dash

UNIX one dash `-`

GNU two dashes `--`

- ps `U` carol (BSD)
- ps `-u` carol (UNIX)
- ps `--user` carol (GNU)

`ps aux` produces useful information

a - process attached to a tty or terminal

u - user oriented format

x - not attached to a tty or terminal

![Untitled](Linux%20LPIC%20d164a7bad2d1425485d742e0f4d46f4f/Untitled%201.png)

USER - owner of process

PID - PID

%CPU - %CPU

%MEM - %MEM

VSZ - virtual memory of proccess in KiB

RSS - non swapped physical memory used by procces in Kib

TT - terminal attached

STAT - code represetning the state (apart from S, R and Z) there is D (uninterruptible sleep - usually waiting I/O), T (stopped, normally by control signal). < high priority , N low priorite, + in the foregroung group

START - time started

TIME - CPU time

---

`screen` and `tmux` share a series of features

- succesful invocation will result in at least a session that includes at least a window
- window can be split into regions or panes
- command prefix/command key to run most commands
- session can be detached from their terminal (sent to background and continue running)
- socket connection
- copy mode
- highly customizablbe

## GNU SCREEN

**************WINDOWS**************

type `screen -t windowname` or `ctrl + a + c`

set window title `ctrl+ a + A`

`ctrl + a + w`show windows

move next `ctrl + a + n`

move previous `ctrl + a + p`

move to number `ctrl + a + $num`

using `ctrl + a + "` you can see a list of windows

   windows run their programns independently from each other

Programs will continue to run even if their window is not visible (also when the screen session
is detached

kill window (exit) or `ctrl + a + k`

**REGIONS**

scren can divite the screen into multiple regions 

`ctrl + a + S     = HORIZONTAL`

`ctrl + a + |     = VERTICAL`

the new region will show `--` meaning it is empty

to move to another region type `ctrl + a + tab` and create a window, or retrieve a window using `ctrl + a + $num`

you can terminate all regions except the current with `ctrl + a + Q`

terminate current region `ctrl + a + X`

terminating a region does not terminate a window

****************SESSIONS****************

so far we talked about regions and windows, but they all belong to the same session. to see all sessions type

`screen -list`  or `screen -ls`

![Untitled](Linux%20LPIC%20d164a7bad2d1425485d742e0f4d46f4f/Untitled%202.png)

pts-0.9ce9f1ca6c is the terminal/pseudo terminal slave

create a new session using `screen -S “new session”`

to kill a session, either quit all of its windows or run `screen -S SESSION-PID -X quit`

Session Detachment
For a number of reasons you may want to detach a screen session from its terminal:
• To let your computer at work do its business and connect remotely later from home.
• To share a session with other users.

to detach current session press `ctrl+a - d`

to attach again type `screen -r SESSION-PID`

or type `screen -r SESSION-NAME`

**options for reattaching**

d -r
Reattach a session and — if necessary — detach it first.
-d -R
Same as -d -r but screen will even create the session first if it does not exist.
-d -RR
Same as -d -R. However, use the first session if more than one is available.
-D -r
Reattach a session. If necessary, detach and logout remotely first.
-D -R
If a session is running, then reattach (detaching and logging out remotely first if necessary). If it
was not running create it and notify the user.
-D -RR
Same as -D -R — only stronger.
-d -m
Start screen in detached mode. This creates a new session but does not attach to it. This is
useful for system startup scripts.
-D -m
Same as -d -m, but does not fork a new process. The command exits if the session terminates.

**Copy & Paste: Scrollback Mode**

py or scrollback mode. Once entered, you can move the cursor in the
current window and through the contents of its history using the arrow keys

you can mark text and copy it across windows

enter copy/scrollback mode `ctrl+a-[`

**Customization of screen**
The system-wide configuration file for screen is `/etc/screenrc`. Alternatively, a user-level
`~/.screenrc` can be used. The file includes four main configuration sections:

## tmux

released in 2007, similar to screen but has some differences:

- client-server model ; the server supplies a number of sessions, each may have a number of windows linked to it that can be shared by various clients
- interactive selection of sessions, windows and clients via menus
- the same window can be linked to a number of sessions
- availability of both vim and emacs key layout
- utf-8 and 256 color terminal

to invoke `tmux` simply type `tmux`

**`tmux new -s session-name`**

![Untitled](Linux%20LPIC%20d164a7bad2d1425485d742e0f4d46f4f/Untitled%203.png)

tmux automatically updates the name of the program running inside the window.

tmux command prefix is `ctrl + b`

create a new window typing `ctrl + b + c`

rename window by typing ********************`ctrl + b-,`********************

move between windows `ctrl + b-w`

you can also jump using `ctrl + b-  [n / p / number]` like screen

to get rid of a window use `ctrl+b-&`

FIND WINDOW BY NAME `ctrl + b + f`

CHANGE window by INDEX NUMBER ******************`ctrl +b + .`******************

****************************PANES (are similar to regions in screen)****************************

to split a window horizontally use `ctrl + b + "`

to split a window vertically use `ctrl + b + %`

To destroy the current pane (along with its pseudo-terminal running within it, along with any
associated programs), use `Ctrl + b - x`

MOVING BETWEEN PANES

`ctrl + b + arrow keys`

move between panes

ctrl + b + ; 

move to the last active

`ctrl + b  - ctrl + arrow key`

resize pane by one line

`ctrl + b  - alt + arrow key`

resize pane by five lines

ctrl b - {

swap from current to previous

ctrl b - }

current to next

`ctrl + b -z` 

zoom in/out panel

ctrl + b - t

fancy clcok

`ctrl + b-!`

trun pane into window

****************SESSIONS****************

to list session and move between sessions in tmux use `ctrl+b - s`

or use `tmux ls` to list

to create a new session type the command prefix ************`ctrl+b` and type `:new`** in the prompt

to rename a session use `ctrl + b - $`

`tmux kill-session -t SESSION-NAME`

if you type the command from within the current attached session, you will be taken out of tmux and back to initial terminal session

to reattach to a session outside type

`tmux a`

`tmux at`

`tmux attach -t session-name`

to detach from current sesion

type `ctrl+b-d`

Ctrl b - D
select what client to detach.

Ctrl b - r

refresh the client’s terminal.

**Copy & Paste: Scrollback Mode**

`ctrl + b + [`

`ctrl + space` to mark the beggining of selection

`alt + w` to copy text

The configuration files for tmux are typically located at `/etc/tmux.conf` and `~/.tmux.conf`

for list of all binding trype `ctrl +b-?` or man page

if two users want to share a session they must share the groups and permissions

---

# LOCATING FILES

whereis

locate

which

find

---

# Scheduling

OS processes share the processor, most process activities are *syscalls*, which transfers the CPU to the OS perform the requested operation, for example, reading/writing to filesystem, allocate memory, print text on screen, inter-device communication, network communication. OS are made preemtive, so processes can be put on the scheduler queue even if they did not request a syscall

In linux there are processes that follow real-time policies and normal policies. when tuning process scheduling, only normal scheduling policies processes will be affected.

lower ⇒ more priority

0-99 -real time processes

100-139 - normal processes

the priority of a process can be found in /proc directory on the sched file

`grep ^prio /proc/1/sched`

the default priority for normal processes is 120 (so it can be increased and decreased)

when you run `ps -el` you can see the priorities, but they are subctrated by 40, due to historical reasons (back in the day the range was -40 to 99)

`top`also displays it, but subtracts 100, to make easier to spot realtime processes.

- every process begins with a default nice value of 0 (priority 120)
    - nicenumbers range from (-20) to (19) , the more amount of nice, the less priority example 19 is the least amount of priority and -20 is the max
    - you can assign nice values to threads within a process

Only the root user can decrease the niceness of a process below zero

you can start a process with a different nice value `nice -n 15 tar czf home_backup.tar.gz /home`  The command renice can be used to change the priority of a running process. The option -p indicates the PID number of the target process. For example: `renice -10 -p 2164`

The options -g and -u are used to modify all the processes of a specific group or user,
respectively. With renice +5 -g users, the niceness of processes owned by users of the group
users will be raised in five.

using top you can press `r` to renice

manually scheduling nice values is usually used when there is a process ocuppying too much CPU time.

---

# Searching text files using regex

linux implementetaion:

- simplest regular contains at least one atom
    - . (dot)
        - atom matches with any character
    - ^ (caret)
        - atom maches with the beggining of a line
    - $ (dollar)
        - atom matches with the end of a line
- **Bracket Expression**
    - Brackets [] are considered a single atom, usually a list of literal characters, making the atom match any single character from the list, example [1b] can be found in abcd and a1cd.
    - to specify characters the atom should not correspond to the list must begin with `^` example `[^1b]` . you can have ranges like `[0-9]`
    - [:alnum:] alphanumeric char
    - [:alpha:] alphabetic char
    - [:ascii:] chat that fits in ascii set
    - [:blank:] space or tab/blank character
    - [:cntrl:] control chract
    - [:digit:] digit (0-9)
    - [:graph:] any printable character except space
    - [:lower:] lowecase char
    - [:print:] any printable char including space
    - [:punct:] any character which is not a space of alphanumeric
    - [:space:] whitespace characters ( form feed, newline, carriage return, horizontal tab and vertical tab \f, \n, \r, \t, \v
    - [:upper:] uppercase letter
    - [:xdigit] hexadecimal 0 to F
- Quantifiers
    - the reach of an atom (either single or bracket) can be adjusted using quantifiers
    - defines atom sequences, matches that occur when a contiguous repetition for the atom is found. the substring corresponding to the match is called a *piece.* quantifiers and other features of RE are treated differently depending on which standard is being used
    - POSIX:
        - there are two forms of RE’s: **basic** RE and **extended** RE, most text related programs in linux supports both forms.
        - the * quantifier has the same function in both basic and extended RE’s ( 0 or more times)
        - + (pieces with one or more in atoms matches in sequence)
        - ? match will occure if the attom appears once of if it doesn’t appear at all.
        - on basic RE’s you need to use \ before +,*,? and on extended you use \ if you want it to be a literal
- Bounds
    - Atom quantifier, user specify a precise quantity boundaries for an atom.
    - {i}
        - the atom must appear exactly i times, example [[:blank:]]{2} - exactly two
    - {i,}
        - the atom must appear eat least i time, example [[:blank:]]{2,} - two or more blank chars
    - {i,j}
        - the atom must appear at least i times and at most j times. example xyz{2,4} matches xy followed by two of more z’s.

Basic regular expressions also support bounds, but the delimiters must be preceded by \: \{ and
\}. By themselves, { and } are interpreted as literal characters. A \{ followed by a character other
than a digit is a literal character, not the beginning of a bound.

- Branches and Back references
    - an extended RE can be divided into branches, each one an independent RE. branches are separated by `|` and the combined RE will match anything that correspond to any of the branches. Example `he|him` will match if either he or him is found on the string. on basic RE sometimes you can use branches with `\|`
    - an extended RE can be enclosed in `()` to be used in a *back reference.* For example, ([[:digit:]])\1 will match any regular expression that repeats itself at least once. the \1 in the expression is the back reference to the piece matched by the first parenthesized subexpression.

Basic regular expressions also support bounds, but the delimiters must be preceded by \: \{ and
\}. By themselves, { and } are interpreted as literal characters. A \{ followed by a character other
than a digit is a literal character, not the beginning of a bound.

- Searching with RE’s

```bash
find $HOME -regex '.*/\..*' -size +100M
find /usr/share/fonts -regextype posix-extended -iregex
'.*(dejavu|liberation).*sans.*(italic|oblique).*'
```

using less, to stay on place but highlight regex matches type `ctrl + K`

using less, you can filter the outpus so only lines which match a RE are displayed (press & and search expression)

---

**grep**

`grep -n or —line-number`

`grep -o or —only-matching`

`grep -v or —invert-match`

`grep -i or —ignore-case`

`grep z or --null-data`
Rather than have grep treat input and output data streams as separate lines (using the newline
by default) instead take the input or output as a sequence of lines. When combining output
from the find command using its -print0 option with the grep command, the -z or --null
-data option should be used to process the stream in the same manner

`grep -H`tell from which file it came from

```bash
find /usr/share/doc -type f -exec grep -i -H '3d modeling' "{}" \; | cut -c -100
```

`egrep === grep -E`

```bash
find /usr/share/doc -type f -exec egrep -i -H -1 '3d (modeling|printing)' "{}" \; | cut -c
-100
```

`fgrep === grep -F`

does not parse reg expression, good if you want to grep a $ for example

**sed**

works similarly to a template parser, given text as input it places custom content at predefined positions or when it finds a match for a RE. you can use sed -f SCRIPT or sed -e COMMANDS. if neither -f or 0e are present, sed uses the first non option parameter.

delete 1 line `sed 1d`

delete 1,7 lines `factor $(seq 12) | sed 1,7d`

more than one instruction can be used example `sed “1,7d;11d”`

is sed everything placed between slashes `/` is considered regular expressions,

```bash
factor `seq 12` | sed "1d;/:.*2.*/d" # matchess :.*2.*
sed -e "/^#/d" /etc/services # show contents without commend
factor $(seq 12) | sed "/:.*2.*/c REMOVED" # replace line that matches regex with REMOVED
```

instruction `c REMOVED`, every line matching replaces with REMOVED

instruction `a TEXT`copies text indicated by TEXT to a new line after the line with match

instruction `r FILE` does the sasme but copies the content of the file indicated by FILE.

instruction `w` does the opposito of `r` that is, the line will be appended to the file.

instruction `s/FIND/REPLACE` is used to replace a match to the RE

`s/hda/sda` for example, replaces hda with sda, but only the first match found in the line will be replaced, to replace all occurences use /g `s/hda/sda/g`

By default, parenthesis should be escaped to use backreferences in sed.

to show only body

```bash
sed -n -e
'/<body>/,/<\/body>/p'
```

instruction `p` to print matching lines, and `-n` to not print by default. start on addr 1 and go till addr2

assuming ca.crt, client.crt, client.key, ta.key are in the directory, use sed to replace each filename by its content

```bash
sed -r -e 's/(^[^.]*)\.(crt|key)$/cat \1.\2/e' < client.template > client.ovpn
```

instruction `e` replaces matches with the output of command cat \1.\2 that are backreferences.

---

## Basic File Editing

vi is preinstalled and the stander editor in shell environment.

an alternative, vi improved (vim), has features like syntax highlight, multilevel undo/redo and multi-document editing. backwards compatible with vi.

you can pass a plus sign + line number to open directly on line, for example:

```bash
vi +9 /etc/fstab
```

without a number and only plus sign, you are directed to the end of the file.

**Normal Mode**

0, $

go to the beggining/end of line

1G, G

beggining/end of the doc

(, )

beginning/end of sentence

{, }

beggining and end of paragraph

w, W

jump word and jump word and punctuation

hjkl

left,down,up,right

e or E

go to the end of current word

/, ?

search forward and backwards

i, I

enter insert mode before the current cursor position and at the beggining of current line

a, A

enter inser mode adter the current cursos position and at the end of current line

o, O

adds a new line and enter insert mode in the next line or previous line

s, S

erase the character under the cursor or the entire line and enter insert mode

c

change caracter under the cursor

r

replace the character under the cursor

x

delete selected chars or the chars under cursos

v, V

start a new selection with cursor on current char or entire line

y,yy

copy the char or the entire line

p,P

paste copied content, after/before current position

u

undo last action

CTRL + R

redo last action

ZZ

close and save

ZQ

close and not save

`Select + > or <`

ident left or right

t

jump to the following character, example: dt. delete until find a period

```markdown
:%s/pattern/replacement/gci
```

if preceded by a number, the command will be executed the same number of times, for example, press 3yy to copy the current line plus the following two, press d5w to delete the current word and the following for words

most editing tasks are a combination of commands, for example, key `vey` is selection of current word and copy it. so `v3ey` would copy a selection starting on the current position until the end of third word

vi can organize copied text in registers, allowing to keep distinc contents at the same time. register is specified by a character preceded by “,

the key sequence `“ly` creates a register containing the current selection, which will be accesible through the key `l` then the register can be pasted with `“lp`

there is also a way of setting custom marks along the file, example press `m` and a key to register the address, then return to the address by `‘` followed by the key used for the addres

Any key sequence can be recorded as a macro for future execution. A macro can be recorded, for
example, to surround a selected text in double-quotes. First, a string of text is selected and the key
q is pressed, followed by a register key to associate the macro with, like d. The line recording @d
will appear in the footer line, indicating that the recording is on. It is assumed that some text is
already selected, so the first command is x to remove (and automatically copy) the selected text. 

The key i is pressed to insert two double quotes at the current position, then Esc returns to normal
mode. The last command is P, to re-insert the deleted selection just before the last double-quote.

Pressing q again will end the recording. Now, a macro consisting of key sequence x, i, "", Esc and P
will execute every time keys @d are pressed in normal mode, where d is the register key associated
with the macro.

However, the macro will be available only during the current session. To make macros persistent,
they should be stored in the configuration file. As most modern distributions use vim as the vi
compatible editor, the user’s configuration file is ~/.vimrc. Inside ~/.vimrc, the line let @d =
'xi""^[P' will set the register d to the key sequence inside single-quotes. The same register
previously assigned to a macro can be used to paste its key sequence.

****************************Colon Commands****************************

are executed after pressing the colon key : in normal mode.

- :s/REGEX/TEXT/g
    - replaces all ocurrences of regex with text in the current line
- :!
    - run a following shell command
- :q! , :wq , :exit or :x or :e
- :visual
    - go to nav mode

**Alternatives (NANO)**

Commands in nano are given using the CTRL key or META key (alt)

Ctrl-6 or Meta-A
Start a new selection. It’s also possible to create a selection by pressing Shift and moving the
cursor.
Meta-6
Copy the current selection.
Ctrl-K
Cut the current selection.
Ctrl-U
Paste copied content.
Meta-U
Undo.
Meta-E
Redo.
Ctrl-\
Replace the text at the selection.
Ctrl-T
Start a spell-checking session for the document or current selection.

**Bash uses the session variables
VISUAL or EDITOR** to find out the default text editor for the shell environment. For example, the
command export EDITOR=nano defines nano as the default text editor in the current shell
session. To make this change persistent across sessions, the command should be included in
~/.bash_profile.

select all line except newline

`0v$h`

homevendh

`**VIM VISUAL BLOCKS**`

press 0, CTRL + V and 8l5jd will select and delete a block

******`DISCARD SWAP FILE`******

press d when prompted by vi

In a vim session, a line was previously copied to the register l. What key combination would
record a macro in register a to paste the line in register l immediately before the current line?
The combination qa"lPq, meaning q (“start macro recording”), a (“assign register a to macro”),
"l (“select text in register l”), P (“paste before the current line”) and q (“end macro recording”).

---

# Creating Partitions and Filesystems

every OS needs a disk to be partitioned before it can be used. information about partitions are stored in a partition table (first/last secter, where it ends, where it starts, partition type, and etc)

on windows partitions are assigned letters `C:` `D:` and so on.

on linux partitions is assigned to a directory under `dev` example: `/dev/sda1`

this topic will explain  how to create, delete, restore and resize partitions using the three
most common utilities (fdisk, gdisk and parted), how to create a filesystem on them and how to
create and set up a swap partition or swap file to be used as virtual memory.

There are two main ways of storing partition information on hard disks:

************Master Boot Record (MBR)************

remnant from MS-DOS. partition table is stored on the first sector of the disk (boot sector), along with the boot loader (on linux, GRUB). MBR main limitations are: only addresses up to 2TB disks and limit to 4 primary partitions per disk

**GUID Partition Table (GPT)**

addresses limitations of MBR, there is no practical limit on disk size, the maximum number of partitions is limit by the OS itself. more common on modern machines with UEFI.

************************MANAGING MBR DISK (FDISK)************************

the standart utility for managing MBR partitions in linux is `fdisk` . interactive/menu-driven utility

```bash
fdisk /dev/sda
```

would edit the partition table of `/dev/sda`.You can create, edit or delete partitions at will, but nothing will be written to disk unless you use the write (w) command, to exit use (q). To print the current partition table on a disk, inside fdisk 

- press `p` (print).
- to create a partition use the `n` command.
    - by default partitions are created at the start of unallocated space on the disk. you need to input type (primary/extended), first and last sector. first sector usually accept the default value unless you want it to start on a specific sector. instead of specifying the last sector, you can specify the size follow by lettes (K,M,G,T,P). So to create a 1GB partition specify +1G as the last sector.
- to check for unallocated space press `F`
- to delete a partition use the `d` command.fdisk will ask the num,ber of the partition to delete. if you delete a extended partition, all the logical partitions inside it will also be deleted.
- to change partition type press `t` followed by the number of the partition you want  to change. (usually when you want to use a disk on other OS / platform)
    - the partition type is identified by its hex code, to see a list press `l`
    
    **PARTITION TYPE ≠ FILESYSTEM**
    

**Primary vs Extended Partitions**

on a MBR disk, partitions can be either primary or extender. you can have only 4 partitions on a mbr disk. if you want to make the disk bootable, the first partition must be a primary. One workaround is to create an extended partition that act as a container for logical partitions. for example: you have a primary partition, and a extended partitionoccupying the remainder of the disk space and five logical partitions inside it. for a OS like linux, there is no advantages in using one or another.

**************************Mind the Gap!**************************

the maximum size of a partition is limited to the maximum amount of contiguous unallocated space on the disk.

![Untitled](Linux%20LPIC%20d164a7bad2d1425485d742e0f4d46f4f/Untitled%204.png)

when you delete a partition, you can not add up the size it freed + free space in disk and create a contiguous partition, for example, lets say we have 300MB mor on the example above, by adding to 512 we would have 812Mb free, but if you try to allocate a partition for 700Mb it will fail!

************************MANAGING GPT DISK (GDISK)************************

each disk has a unique disk identifie (GUID) 128bit random hex, 10^38 possible values. the GUID can be uses to identify which filesystems to mount at boot time and where, eliminating the need to use device patch`(dev/sdb /dev/nvmn)`etc.. . you can have up to 128 entries in the partition table (128 partitions). free space is shown in the last line

- print current partition table `p`
- create partition `n`. besided first/last sector you can also specify the type. there are more types than in MBR
    - list all supported type with `l`
- delete partition press `d`. and provide the partition number
- partitions can be sorted to avoid gaps in the numbering sequence, type `s`
- `r` aid recovery tasks
- rebuild corrupt main GPT header or partition table with `b` and `c`.

Recovery menu `r`

- use main hader and table to rebuild a backup with `d`and`e`.
- convert a MBR to GPT with `f` and do the opposite with `g`.
- type ? in recovery menu

**Gap? What gap?**

unlike MBR disk, gpt disks are not limited by the max amount of contiguous space, you can use every last bit of a free sector, no matter where.

********************************Recovery Options********************************

GPT disks store backup copis of the GPT header and partition table, making it easy to recover disks in case the data has been damaged.

## Creating File Systems (mkfs)

to use a disk you need to partition and format the partition with the filesystem before storing data. a filesystem  controls how data is stored and accessed. Linux supports many Filesystems, like

- ext family
- fat (ms-dos)
- ntfs (windows nt)
- hfs , hfs+ (mac-os)

the standart tool to create a filesystem in linux is `mkfs`

****************************************************Create and ext2/ext3/ext4 filesystem****************************************************

ext was the first filesystem for linux, and through the years it was replaced by new versions, up to ext4. utilities mkfs.ext2 , mkfs.ext3 and mkfs.ext4 are used to create ext2, ext3, ext4 filesystems. In fact, all of these utilities exist as symbolic links to `mke2fs`. the most basic command would be `mkfs.ext2 TARGET` where target is the partition where the filesystem should be created (ex. /dev/sdb1)

you can also use `-t` parameter.

`mke2fs -t ext4 /dev/sdb1`

some useful parameter are:

- -b SIZE
    - sets the size of the data blocks in the device to SIZE, 1024,2048 or 4096 bytes per block
- -c
    - checks the target device for bad blocks before creating the fs. you can run a thorough but slower check by passing it two times example: mkfs.ext4 -c -c target
- -d DIRECTORY
    - copies the contents of the specified directory to the root of the new FS. useful to pre-populate the disk.
- -F
    - danger! this option will force mke2fs to create a fs, even if the other options are dangerous or make no sense at all, if used twice -F -F it can create a fs on a device which is mounted or in use.
- -L VOLUME_LABEL
    - will set the volume label to the one specified. must be at most 16 chars long
- -n
    - simulates the creation of the filesystem, displays what would be done if executed without this option.
- -q
    - will run normally but dont produce output to temrinal
- -U ID
    - will set the UUID of a partition to the value specified. this number is a 32-digit string in the format 8-4-4-4-12, example: D249E380-7719-45A1-813C-35186883987E. if you write `clear` YOU CLEAR THE FILESYSTEM UUID, `random` to generate random uuid, `time` to reate time-based uuid
- -V
    - verbose mode

****************************************************Creating an XFS filesystem****************************************************

XFS is a high performance filesystem, created for IRIX OS by Silicon Graphics in 1993. Commonly used on servers and envrionment that require high/guaranteed filesystem bandwidth.

tools for managing XFS are part of the `xfsprogs` package. RED HAT LINUX 8 use XFS as the default filesystem. XFS filesystems has 2 parts, log section where a log of all fs operationds (called a journal) are mantained and the data section. the log may be located inside the data section, or on a separate disk. basic operation `mkfs.xfs TARGET` where target is the partition you want the filesystem to be created.

- b size=VALUE
Sets the block size on the filesystem, in bytes, to the one specified in VALUE. The default value is
4096 bytes (4 KiB), the minimum is 512, and the maximum is 65536 (64 KiB).
-m crc=VALUE
Parameters starting with -m are metadata options. This one enables (if VALUE is 1) or disables
(if VALUE is 0) the use of CRC32c checks to verify the integrity of all metadata on the disk. This
enables better error detection and recovery from crashes related to hardware issues, so it is
enabled by default. The performance impact of this check should be minimal, so normally
there is no reason to disable it.
-m uuid=VALUE
Sets the partition UUID to the one specified as VALUE. Remember that UUIDs are 32-character
(128 bits) numbers in hexadecimal base, specified in groups of 8, 4, 4, 4 and 12 digits separated
by dashes, like 1E83E3A3-3AE9-4AAC-BF7E-29DFFECD36C0.
-f
Force the creation of a filesystem on the target device even if a filesystem is detected on it.
-l logdev=DEVICE
This will put the log section of the filesystem on the specified device, instead of inside the data
section.
-l size=VALUE
This will set the size of the log section to the one specified in VALUE. The size can be specified in
bytes, and suffixes like m or g can be used. -l size=10m, for example, will limit the log section
to 10 Megabytes.
-q
Quiet mode. In this mode, mkfs.xfs will not print the parameters of the file system being
created.
-L LABEL
Sets the filesystem label, which can be at most 12 characters long.
-N
Similar to the -n parameter of mke2fs, will make mkfs.xfs print all the parameters for the
creation of the file system, without actually creating it.

**************************************************************Creating FAT or VFAT filesystem**************************************************************

FAT filesystem originated from MS-DOS. received many revisions culminating on the FAT32 format.

VFAT is an extension of the FAT16 format with support for long file names (up to 255 characters).

`mkfs.fat / mkfs.vfat` utilies

FAT has drawbacks which restrict its use on large disks. FAT16, supoprts volumes of at most 4GB and max file size of 2GB. FAT32 upts the volume size up to 2PB and max file size to 4GB. FAT are more commonly used on small flash drives or memory cards, legacy devices and OSs that do not support a more advanced filesystem.

`man mkfs.fat` for options

- -c
    - checks for bad blocks before creating filesystem
- -C FILENAME BLOCK_COUNT
    - will create the file specified in filename and create a fat system inside it,effectively creating an empty disk image. that can be later written to a device using utility such as dd
- -F SIZE
    - Selects the size of the FAT (File Allocation Table), between 12, 16 or 32, i.e., between FAT12 FAT16 or FAT32
- -n NAME
    - sets volume label, or name for the filesystem, up to 11 characters
- -v
    - verbose

> `mkfs.fat` cannot create a bootable filesystem
> 

**exFAT filesystem**

created by microsoft in 2006, addresses on of the most important FAT32 limitation (file and sdisk size). exFAT max file size is 16exabytes and max disk size is 128 petabytes.good choice when interoperability is needed, like on large capacity flash drives, memory cards, external disks. default filesystem for SDXC memory cards larger than 32GB. `mkfs.exfat TARGET` utilty.

- -i VOL_ID
    - volume id , 32bit hex number, if not tdefined id based on current time
- -n NAME
    - volume label, up to 15 chars, default no name
- -p SECTOR
    - specified the first sector of the first partition, default is zero
- -s SECTORS
    - number of physical sectors

********************************btrfs filesystem********************************

b-tree filesystem, pronounced as butter fs, butterfuss … in development since 2007, specifically for linux by oracle and other companies, including fujitsu, red hat, intel and SUSE. attractive for modern systems where massive amounts of storage are common. multiple devices support (striping, mirroring and striping+mirroring as in RAID setup). tansparent compression, ssd optimizations, incremental backups. online defragmentation, offline checks support for subvolu,es ,deduplication…

it is a copy-on-write fs and resilient to ccrashes. siple touse and supported don many linux distros. SUSE uses it as the default filesystem.

> NOTE: copy-on-write, new data is written to free disk space and original file metadate is updated to refer to the new data, only then the old data is freed up. reduces chance of data loss on crashes.
> 

utility is `mkfs.btfrs TARGET`

you can pass multiple devices to the mkfs.btrfs command.
Passing more than one device will span the filesystem over all the devices which is similar to a
RAID or LVM setup

For example, to create a filesystem spanning /dev/sdb1 and /dev/sdc1, concatenating the two
partitions into one big partition, use: `mkfs.btrfs -d single -m single /dev/sdb /dev/sdc`

To specify how metadata will be distributed in the disk array, use the -m
parameter. Valid parameters are raid0, raid1, raid5, raid6, raid10, single and dup.

**Managing Subvolumes**
Subvolumes are like filesystems inside filesystems. Think of them as a directory which can be
mounted as (and treated like) a separate filesystem. Subvolumes make organization and system
administration easier, as each one of them can have separate quotas or snapshot rules.

Subvolumes are not partitions. A partition allocates a fixed space on a drive. This
can lead to problems further down the line, like one partition running out of space
when another one has plenty of space left. Not so with subvolumes, as they “share”
the free space from their root filesystem, and grow as needed.

Suppose you have a Btrfs filesystem mounted on /mnt/disk, and you wish to create a subvolume
inside it to store your backups. Let’s call it BKP: `btrfs subvolume create /mnt/disk/BKP`

check if active with `btrfs subvolume show /mnt/disk/BKP/`

You can mount the subvolume on /mnt/BKP by passing the -t btrfs -o subvol=NAME
parameter to the mount command: `mount -t btrfs -o subvol=BKP /dev/sdb1 /mnt/bkp`

**Working with Snapshots**
Snapshots are just like subvolumes, but pre-populated with the contents from the volume from
which the snapshot was taken.

When created, a snapshot and the original volume have exactly the same content. But from that
point in time, they will diverge. Changes made to the original volume (like files added, renamed or
deleted) will not be reflected on the snapshot, and vice-versa. 

Keep in mind that a snapshot does not duplicate the files, and initially takes almost no disk space.
It simply duplicates the filesystem tree, while pointing to the original data.

The command to create a snapshot is the same used to create a subvolume, just add the snapshot
parameter after btrfs subvolume. The command below will create a snapshot of the Btrfs filesysten mounted in /mnt/disk in /mnt/disk/snap: `btrfs subvolume snapshot /mnt/disk /mnt/disk/snap`

It is also possible to create read-only snapshots. They work exactly like writable snapshots, with
the difference that the contents of the snapshot cannot be changed, they are “frozen” in time. Just
add the -r parameter when creating the snapshot: `btrfs subvolume snapshot -r /mnt/disk /mnt/disk/snap`

**A Few Words on Compression**
Btrfs supports transparent file compression, with three different algorithms available to the user.
This is done automatically on a per-file basis, as long as the filesystem is mounted with the -o
compress option. The algorithms are smart enough to detect incompressible files and will not try
to compress them, saving system resources. So on a single directory you may have compressed
and uncompressed files together. The default compression algorithm is ZLIB, but LZO (faster,
worse compression ratio) or ZSTD (faster than ZLIB, comparable compression) are available, with
multiple compression levels (see the cooresponding objective on mount options).

## Managing Partitions with GNU Parted

can be used to create, delete, move, resize, rescue and copy partitions. It can work with both GPT and MBR disks, and cover almost all of your disk management needs. 

There are many graphical front-ends that make working with parted much easier, like **GParted**
for GNOME-based desktop environments and the **KDE Partition Manager** for KDE Desktops.

PARTED changes are made immediately after the command is issued

to start run `parted DEVICE`

to select a different disk you can run `select /dev/sdb`

`print` to print information about the currently selected partition

`print devices` to list all block devices connected to the system

`print all` to get info about all connected device at once

`print free` to know how much free space there is in each device

`mklabel` command, followed by partition table type to create a partition table on empty disk.

main types: msdos (mbr) and gpt (gpt partition table), example: mklabel gpt ; mklabel msdos

`mkpart` to create a partition, syntax: `mkpart PARTTYPE FSTYPE START END`

PARTYPE - can be primary, logical, or extended in case an MBR partition table is used

FSTYPE - specified which fs will be used on the partition. it will not create the FS but only flags it!

START - exact point where the partition begins. 2s can be used to refer to the second sector of the disk, while 1m referst to the beginning of the first megabyte of the disk. common unites are B (bytes) and % (percentage of the disk)

END - specified the end of the partition. this is not the size of the partition, it is the point on the disk where it ends. for example if you specify 100m the partition will end 100MB ater the start of the disk.

example: `mkpart primary ext4 1m 100m`

creates a primary partition flaged as ext4, starting at the first megabyte of the disk and ending after the 100th megabyte

`rm` followed by the partition number to remove a partition. example: rm 2

************Recovering Partitions in Parted************

parted can recover a deleted partition.

`rescue` command to recover, syntax is `rescue START END` where start is the approx location where the partition started and end the approximate location where it ended. parted iwll scan the disk in search of partitions and offter to restory any that are found.

**************************************************Resizing ext2/3/4 partitions**************************************************

parted can be used to resize partitions.

- during resize the partition must be unused and unmounted
- you need enough **free space after the partition to grow it** to the size you want

`resizepart` followed by the partition number and where it should end.

in the image above, only sda1 could be resized.

But resizing the partition is only one part of the task. You also need to resize the filesystem that
resides in it. For ext2/3/4 filesystems this is done with the resize2fs command. if you use parted to resize, and exit, then run df -h /dev/sdb3 (your partition) it will still show the old size. to adjust the size the command `resize2fs DEVICE SIZE` can be used.  If you omit the size parameter, it will use all of the available space of the partition. Before resizing, it is advised to unmount the partition.

example:

resizepart 3 350m

sudo resize2fs /dev/sdb3

To shrink a partition, the process needs to be done in the reverse order. First you resize the
filesystem to the new, smaller size, then you resize the partition itself using parted.

> Pay attention when shrinking partitions. If you get the order of things wrong,
you will lose data!
> 

example:

resize2fs /dev/sdb3 88m

parted /dev/sdb3

resizepart 3 300m

*Instead of specifying a new size, you can use the -M parameter of resize2fs to
adjust the size of the filesystem so it is just big enough for the files on it.*

************************************************Creating SWAP partitions************************************************

On linux, the system can swap memory pages from ram to disk. usually on a separate partition on a disk, the partition needs to be of a specific type and set-up with a proper utility (`mkswap`), to create it, create the partition like any other one but set the partition type to linux swap. 

fdisk - use `t` , select partition, change type to 82, and quit with `w`

gdisk - use `t`, but the code is 8200, write and quit with `w`

parted - `mkpart primary linux-swap 301m 800m` in parted the partition should be identified as swap during creation.

after setting up the partition run the command mkswap :

********`mkswap /dev/sda2`********

to enable swap on the partition use swapon

`**swapon /dev/sda2**`

similarly, you can disable swap with `swapoff`

Linux also supports the use of **swap files** instead of partitions. Just create an empty file of the size
you want using dd and then use mkswap and swapon with this file as the target. for example: `dd if=/dev/zero of=myswap bs=1M count=1024` `mkswap myswap` `swapon myswap` this creates a 1GB file called myswap in the current directory, filled with zeroes and than set-up and enable it as swap file

Using the commands above, this swap file will be used only during the current system session. If
the machine is rebooted, the file will still be available, but will not be automatically loaded. You
can automate that by adding the new swap file to /etc/fstab, which we will discuss in a later
lesson

Both mkswap and swapon will complain if your swap file has insecure permissions.
The recommended file permission flag is 0600. Owner and group should be root.

---

# Integrity of Filesystems

modern linux filesystems are journaled. this means every operation is registered in an internal log (journal) before it is executed. if the operation is interrupted due to a system error (like power failure or kernel panic) it can be reconstructed. This reduces the need for manual filesystem checks.

********************************Check disk usage********************************

to check how much space is being used and how much is left

`du` for disk usage, recusive in nature. the basic form will show how many 1Kbyte blocks are being used by the current directory and all its subdirectories

`du -h` for human readable

`du -d 0` to limit depth to zero meaning NO SUBDIRECTORIES example: `du -Shd0` to view disk usage of only files on current directory

`-S`to separate output of current directory from subdiretories

by default du only shows usage for directories, to list individual count for all files use `du -a`

default behaviour is to show the usage of every subdirectory, then total usage of current.

to know how much space files in the current directory occupy excluding subdirectories use `du -Sh`

to get the grand total at the end, use `du -c`

you can control du depth wih `-d N` parameter, for example `du -d 1` will show current directory and its subdirectories

you can use `--exclude=PATTERN`

******************************************Check free disk space******************************************

the command `df` will provide a list of all mounted filesystems on the system, including total size.

you can use `df -i` to show used/available inodes insted of blocks

another useful flag is `-T` which displays filesystem type

exclude tmpfs fs `df -hx tmpfs`

show only ext4 fs `df -ht ext4`

you can format output using `--output=` followd by comma separated list of field

********************************************************************************Maintain ext2, ext3 and ext4 filesystems********************************************************************************

`fsck` filesystem check,

never run fsck on mounted filesystem, data may be lost

you can specifyt he filesystem type, example: `fsck -t vfat`

-A all filesystem in /etc/fstab

-C progres bar (works on exr2/3/4 filesystems)

-N what would be done and exit, without actually checking

-R will skip checking the foor filesystem when used in conjuntcion with -A

-V verbose

e2fsck also called fsck.ext2 , fsck.ext3 , fsck.ext4 has some options:

-p will try to automatically fix errors found

-y answer yes to questions

-n opposito of -y, will cause the filesystem to be mounted read-only so it cannot be modified

-f forces to check filesystem even if is marked as clean (has been correctly unmounted)

************Fine Tunin an ext filesystem************

`tune2fs` to adjust the ext family filesystem

to see the current parameters for any given filesystem, use the `-l` parameter followed by the device representing the partition, example `tune2fs -l /dev/sda1`

to make fs check on next reboot do `tune2fs -c current_mount+1 device`

the maximum mount count can be set with the `-c N` parameter, where N is the number the filesystem will be mounted without being checked.  The `-C N` parameter sets the number of
times the system has been mounted to the value of N. you can also specify a time interval between checks using `-i 10d` would check filesystem at the next reboot every 10 days. `-L` is used to set a label to the filesystem (up to 16chars). `-U` sets the UUID. both label and UUID can be used instead of device name `/dev/sda1`

the `-e` behaviour defines what kernel will do then a filesystem error is found: CONTINUE, REMOUNT-RO, PANIC (causes kernel panic).

The default behaviour is to continue. remount-ro might be useful in data-sensitive applications,
as it will immediately stop writes to the disk, avoiding more potential errors.

ext3 is a ext2 with journal by default, you can convert a ext2 to ext3 by `-j` parameter to tune2fs, followed by the device containing the filesystem: `tune2fs -j /dev/sda1`

Afterwards, when mounting the converted filesystem, do not forget to set the type to ext3 so the
journal can be used

When dealing with journaled filesystems, the -J parameter allows you to use extra parameters to
set some journal options, like -J size= to set the journal size (in megabytes), -J location= to
specify where the journal should be stored (either a specific block, or a specific position on the
disk with suffixes like M or G) and even put the journal on an external device with -J device=.
You can specify multiple parameters at once by separating them with a comma. For example: -J
size=10,location=100M,device=/dev/sdb1 will create a 10 MB Journal at the 100 MB position
on the device /dev/sdb1

********************Maintining XFS filesystems********************

the equivalent to `fsck` is `xfs_repair` . you can scan the filesystem for damage using `-n`. parameter. if errors are found call xfs_repair again without -n. -l LOGDEV and -r RTDEV these are needed if the filesystem hast external log and realtime sections, in this case replace RTDEV and LOGDEV with the devices. -m N is used to limit memory usage of xfs_repair to N megabytes. -d is to enable repair of filesystems that are mounted read-only. -v verbose

xfs_repair can not repair filesystems with a dirty log, you can zer out a corrupt log with `-L` parameter as a last resort and can cause data loss/fileystem corruption

xfs_db can be used, like in xfs_db /dev/sdb1 to debug.

Another useful utility is xfs_fsr, which can be used to reorganize (“defragment”) an XFS
filesystem. When executed without any extra arguments it will run for two hours and try to
defragment all mounted, writable XFS filesystems listed on the /etc/mtab/ file

---

# Control Mount/Umount of filesystems

after creating a partition and creating a filesystem, the filesystem need to be mounted so it can be accessed. Meaning it will attach the filesystem to a specific point in the directory tree (mount point).

`mount -t TYPE DEVICE MOUNTPOINT`

the mounted-on directory need not be empty.   although it must exist. Any files in it, however, will be inaccessible by name while the filesystem is mounted.

example: `mount -t exfat /dev/sdb1 ~/flash/`

if you type just mount you will get a list of all filesystems currently mounted, besides disk attached to the system it also contains runtime filesystems in memory that serve other purposes. you can filter using `mount -t ext4,btrfs` to show only ext4 and btfrs mmounts, for example.

SOURCE on TARGET type TYPE OPTIONS … options are the options passed to the mount command.

to remount use `mount -o remount /dev/sdb1`

**mount parameters**

-a

will mount all filesystem listed in /etc/fstab. the `noauto` option in fstab means it will not be mounted

-o or —options

will pass a list of comma-separated mount options.

-r or -ro

read-only

-w or -rw

writable

to umount you can use `umount mountpoint` or `umount device`

-a

will umount all filesystems in /etc/fstab

-f

will force the umount of system, useful if a remote filesystem is unreachable

-r

if the filesystem cannot be unmounted, make it read only

******************************dealing with open files******************************

if files on the filesystem are in use, you will get **************target is busy************** message. you can use `lsof` command followed by the device name containing the filesystem to see a list of processes accessing it and which files are open, for example:

`lsof /dev/sdb1`

**common warning** 

lsof: WARNING: can't stat() fuse.gvfsd-fuse file system /run/user/1000/gvfs
Output information may be incomplete.

This warning message is raised
because lsof has encountered a GNOME Virtual file system (GVFS). This is a special
case of a filesystem in user space (FUSE). It acts as a bridge between GNOME, its APIs
and the kernel. No one—not even root—can access one of these file systems, apart
from the owner who mounted it (in this case, GNOME).

# Manage File Permissions and Ownership

linux multi-user has a three level permission system.

Every file on disk is owned by:

- a user
- a user group
- has 3 sets of permissions:
    - one for the owner who owns the file
    - one for the group who owns the file
    - one for everyone else

when you use `ls -l` you can view the file type, permission size etc..

for example the first column might contain:`drwxrwxr-x`

![Untitled](Linux%20LPIC%20d164a7bad2d1425485d742e0f4d46f4f/Untitled%205.png)

and then you get the third and fourth column, being the user and group respectively.

the second column shows the number of hard links poiting to file

<permissions> <hardlinks> <user> <user group> <file size> <last modified> <filename>

you can use `ls -d` to query info about a directory

**file types:**

- - (normal file)
- d (directory)
- l (symbolic link)
- b (block device)
    - usually disks of other kind of storage
- c (character device)
    - terminals or serial ports, for example
- s (socket)
    - pass information between two programs

**Permissions Octal values for files:**

- r (4) - open and read
- w (2) - edit or delete
- x (1) - run as executable

**Permissions Octal values for directories:**

- r (4) - read directory like filenames, but does not imply permissions to read files themselves
- w (2) - create or delete files on directory
- x (1) - permission to enter but not to list (needds r to list)
    - example: ls -l /directory would get an error but if you have a file inside it you can do sh /directory/script.sh

order check is USER → USER GROUP → EVERYONE ELSE . this means that if the current user is the owner of the file, only the owner permissions are effective, even if group or other are more permissive.

## Modifying File Permissions

`chmod` takes two args (permission and pointer to file/directory), **only the owner or root can change the permissions of a file**

you can use symbolic mode or octal mode to describe permissions.

symbolic mode allows you to add or revoke a single permission without modifying others.

example: `chmod ug+rw-x,o-rwc text.txt`

and `chmod 660 text.txt`

**************************Symbolic mode**************************

you need to prefix

- u (user)
- g (group)
- o (others)
- a (everyone)

then you tell what to do

- + (grant)
- - (revoke)
- = (set value)

then you tell which permission to act on (r, w,x)

`chmor u-r text.txt` means *for the user revoke read*

`chmod a=rw- text.txt` means for all, set rw and no execute

you can set multiple at the same time using comma (,) example `chmod u+rwx,g-x text.txt`

WHEN RUN ON DIRECTORY WILL CHANGE ONLY THE DIRECTORY, TO USE RECURSIVE MODE USE `-R` example: `chmor -R u+rwx another_dir` means recursively grant rwx 

**********Octal mode**********

each permission has a value (r - 4 , w -2 , x -1) and no permission is **(0)**

octal mode is recommended if you want to change perms to specific value, symbolic when you want to flip a specific value, example chmor u+x script.sh

## Modifying File Ownership

`chown` is used to change ownership, syntax is `chown USERNAME:GROUPNAME FILENAME`

you can ommit either USERNAME or GROUPNAME if you want them to remain the same, example:

`chown :students file == chgrp students file`

`chown caetano: file  == chown caetano file`

Unless you are the system administrator (root), you cannot change ownership of a file to another
user or group you do not belong to. If you try to do this, you will get the error message Operation
not permitted.

************Querying Groups************

to see groups and group memberships, type `getent group` to get groups and `groups caetano` to see which groups caetano belongs. to get the group members of a group use `groupmemb -g GROUP -l`  and you can check `/etc/groups`

**************************************Default Permissions**************************************

`umask` sets the default permissions for every file created, if you type umask you will get the current value.

to get the value in symbolic mode use `umask -S`

you can set the umask for the current shell session using `umask u=rwx,g=rwx,o=`

umask table

![Untitled](Linux%20LPIC%20d164a7bad2d1425485d742e0f4d46f4f/Untitled%206.png)

007 for example, would be rwxrwx—-

**************************************Special Permissions**************************************

besides rwx for user groups and other, each file can have three othe special permissions, which can alter the way a directory works or how a program runs (you would use 4 digit representation)

- sticky bit (octal 1 // symbolic t on `o`)
    - restric deletion flag, has octal value of 1, in symbolic mode is represented by t. only applies to directories, prevents users from removing or renaming a file unless they own it.
    - example: `chmod 1755 directory/`
    - directories with sticky bit show a `t` replacing the `x` on the others permissions
- Set GID (octal 2 // symbolic s in `g`)
    - SGID or Set Group ID bit, can be applied to executables or directories. on files, it will make the process run with privileges of the group who owns the file. on directories it would make every file or subdirectory to inherit the group from the parent directory
    - example: `chmod g+s test.sh`
    - files and dirs with SGID will have an `s` replacing the `x` on the permissions for the group
- Set UID (octal 4 // symbolic s in `u`)
    - only applies to files and does not work on directories. similar to SGID, but the process wil run with the privileges of the user who owns the file.
    - example: `chmod 6755 file` to set both SGID and SUID
    - files with SUID will have a `s` replacing the `x` on the users permissions

uppercase S would mean that it dont have the underlying permission, example -rwS on first set would mean user dont have execute permission.

lowercase means the user has the underlying permission.

---

# Create and Manage Hard and Symbolic Links

In linux everything is treated as a file, but there is a special kind of file called link:

## ********************Hard Links (pointer to inode)********************

Think of it as a second name for the original file. Not duplicates, but instead are an additional entry in the filesystem pointing to the same place in the disk (**inode**)

example: `ln TARGET LINK_NAME`

The TARGET must exist. `ln target.txt /home/caetano/hardlink` if you leave link_name blank, a link with the same name as the target will be created

******************************Managing Hard Links******************************

Hard links are entries on the filesystem that have different names but points to the same data on disk. if you change the contents of one of the files, the contents of all other names change, since they all point to the same data, if you delete one file, the others will still work. because when you delete a file, it delestes the entry on the filesystem table pointing to the inode corresponding to the disk.

**Seeing the Inode**

run `ls -li` to display the index number (inode)

note that every hard link pointing to a file increases the **********link count********** of the file (this is the number right after permissions column). default values are:

file (1) directory (2)

In contrast to symbolic links, you can only create hard links to files, and both the link and target
must reside in the same filesystem.

**Moving and Removing Hard Links**

They can be moved freely without breaking the link because it points to data in the disk

## Symbolic Links (point to name)

Also called soft links. they point to a path, if you delete what is in the path the link still exists but point to nothing.

to create a symbolic link run `ln -s TARGET LINK_PATH`, example: `ln -s target.txt /home/caetano/softlink` will create a softlink pointing to target.txt

**********************************************Managing Symbolic Links**********************************************

they point to another path in the system. you can create soft links to files and directories, even on differente partitions (hard links cant because of differente inodes/filesystem entries table).

the first character of soft links is `l`, the permisssions might show rwx for everybody but the permissions that will be used are the same as the `target`

when you move it from one place to another you need to make sure it didn’t brake.

---

# Find System Files and Place them in the correct Location

almos all linux distros share the same **Filesystem Hierarchy Standard (FHS)**, which defines a standard layout for the filesystem, making interoperation and system administration much easier.

- FHS is an effort by the linux foundation to standardize directory contents on linux systens
- compliance with the standart is not mandatory, but most distros follow it

[https://refspecs.linuxfoundation.org/FHS_3.0/fhs/index.html](https://refspecs.linuxfoundation.org/FHS_3.0/fhs/index.html)

basic directory standart would be:

```
/

root directory, topmost, everyother directory is inside it, it would the the **TRUNK** where all branches are connected.

/bin

essential binaries available to all users

/boot

files to boot, including initrd (initial ram disk) and linux kernel

/dev

devices (either physical or virtual, provided by the kernel)

/home

personal files

/lib

shared libs (some are needed to run binaries under /bin and /sbin)

/media

user mountable removable media (flash drives, cd, dvd-rom, flopy diks, memory card, external disk)

/mnt

temporarily mounted filesystems

/opt

application software packages

/root

home for the superuser

/run

run-time variable data

/sbin

system binaried

/srv
	data served by the system. for example pages under /srv/www to webservers
/tmp
	temp files
/usr
	read-only user data, including data needed by some secondary utilities/application
/proc
	virtual filesystem containing data related to running processes
/var
	variable data written during system operation, print queue, log, mailboxex, temporry files, browser cache etc
```

******************************************************Location of Temporary Files******************************************************

FHS defines standard locations for temporary files with different purposes and behavior.

**/tmp**

according to FHS, programs should not assume that files written here will be preserved, the directory usually is cleared during system boot-up (not mandatory)

**/var/tmp**

this one should not be cleared during boot-up . usually persist during reboots

**/run**

contains data used bby running processes, example `.pid` files (process identified files). this location must be cleared on boot-up. this directory was once served on **/var/run** and some systems contain a symbolic link to /run

## **************************Finding files using find**************************

example to find all .png files `find . -name '*.png`'

remember -name is case sensitive, to make a case insensitive search use `-iname`

the ‘’ quotes is to avoid shell from interpreting the wildcard

you can use `-maxdepth N` to limit the amount of directories to search (mindepth is reverse, searching at least N levels down)

-maxdepth 1 - current -maxdepth 2 current+1

you can use `-mount` parameter to avoind find going down inside mounted filesystems.

you can restrict fs type using `-fstype` example: `find /mnt -fstype exfat -iname "*report*"` would only search exFAT filesystems under /mnt

******************Searching for attributes******************

**-user**

matches files owned by user

**-group**

matches files owned by group

**-readable**

files readable by current user

**-writable**

files writeable by current user

**-executable**

executable by user (in case of directories, directory user can enter)

**-perm NNNN**

match files having permission example `-perm 0777`

example find at least readable on group bit -perm 040

**-empty**

empty files and directories

**-size N**

you can add suffix to N for units example:

Nc will count the size in bytes

Nk in kibibytes (multiples of 1024bytes)

NM in mebibytes (multiples of 1024*1024)

NG in gibibytes

again you can add the + or - prefixes (meaning bigger than and smaler than)

**Searching by Time**

**-amin N, -cmin N, -mmin N**

match files that have been accessed, had attributes changed or were modifient N minutes ago

**-atime N, ctime N, mtime N**

match files that have been accessed, had attributes changed or were modified N*24 hours ago

For -cmin N and -ctime N, any attribute change will cause a match, including a change in
permissions, reading or writing to the file. This makes these parameters especially powerful, since
practically any operation involving the file will trigger a match

you can prefix with +,-

-mmin -120

example to find files that were modified less than 24h ago and is bigger than 100m

`find . -size +100M -mtime -1`

## Using locate and updatedb

locate and updatedb are usend to quickly find a pattern on linux.

`locate`

- runs on database, not filesystem (it runns updatedb)
- quick results but not always precise (depends when the database was last updated)
- it searchs for patterns (by defult case sensitive)
- to run case insenstive use `locate -i .jpg`
- you can pass multiple parameters, example: `locate -i zip jpg` would search for zip and jpg pattern
- when using multiple you can tell locate to display only files that matches all of the patterns `locate -A .jpg .zip` would should Pentar.jpg.zip, for example
- to count the number of files instead of showing the path, you can use `-c` option
- the database generated by `updatedb` is on `/var/lib/mlocate.db` or `/var/lib/plocate/plocate.db`
- COMMON PROBLEM: only shows entris on database, therefore it could show a file that does not exist anymore, you can avoid this using `-e` parameter, which would check if the file exists before showing it to the user
- COMMON PROBLEM: file was created and database was not updated (you can’t run from this, you would need to run updatedb)ca
- behavior of `updatedb` is controlled by `/etc/updatedb.conf`
    - PRUNEFS=
        - Any fileysstem types indicated after this parameter will not be scanned. (case insenstive)
    - PRUNENAMES=
        - space separated list of directory names that wont be scanned
    - PRUNEPATHS=
        - list of paths names that should be ifnored, paths separated by space
    - PRUNE_BIND_MOUNTS=
        - yes or no variable, is yes then bind mounts (mount —bind) will be ignored

********************************************************************************************Finding BInaries, manual pages and source code********************************************************************************************

`which` is a useful command to show full path of an executable.

`which -a` will show all pathnames that match the executable

to see which directories are in path type `echo $PATH`

`type` is asimilar command, it will show where the binary is located and its type

`type -a` works in the same way as which

`type -t` will show the type of the command which can be an `ALIAS, KEYWORD, FUNCTION, BUILTIN` or `FILE`

`whereis` is more versatiles and besides binaries it can also show the location of man pages or even source code.

`whereis -b` would limit results to binaries

`whereis -m` will limit to man pages

`whereis -s`will limit to source code

---

**Managing Sockets**

`cat /proc/sys/net/core/somaxconn`

`ulimit -n`

`proc/sys/net/tcp`