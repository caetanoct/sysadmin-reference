```txt
                                                                        ┌──────────────┐
                                                                 ┌──────┤ root servers │
                                                                 │      └──────────────┘
                                                                 │
                                                                 │      ┌──────────────┐
┌────────┐       ┌──────────────────────┐     ┌──────────┐       ├──────┤ tld servers  │
│ client ├───────┤ cache-only forwarder ├─────┤ resolver ├───────┤      └──────────────┘
└────────┘       └────────────┬─────────┘     └──────────┘       │
                              │                                  │     ┌──────────────────────┐
                              │                                  └─────┤ authoritative servers│
                              │                                        └──────────────────────┘
                              │
                              │
                        ┌─────┴──────────────────┐
                        │ HA Pair of Nameservers │
                        └────────────────────────┘
```


# Setting up Infrastructure

```bash
terraform init
terraform apply -auto-approve
```

# Configuring client

```bash
cat > /etc/resolv.conf <<EOF
#cache-only server
nameserver 192.168.1.254
EOF
```

# Configuring the cache-only dns resolver

Forwards Client Queries to the Resolver
Forward Queries against internet local domain to authoritative name servers
Cache client dns requests


Install DNS daemon
`sudo dnf install isc-bind`

Configure server IP address
`sudo ip addr add 192.168.1.254/24 dev eth0`

Edit
`named.conf.options`

Define access control list (ACL): which are clients allowed to query this server.

```shell
acl "trusted" {
	192.168.1.0/24;
}
```

Enable recursion so server can respond recursive queries using: `recursion yes;`

Enable acls: `allow-query { localhost; trusted; };`
Allow clients to use server cache: `allow-query-cache { localhost; trusted; };`
Allow recursion: `allow-recursion { localhost; trusted; };`
Configure forwarders.
Make sure server trusts only the forwarders specified in the file.
Add `forward only;` option. Means it will still answer queries but will rely on the forwarder specified.


https://bind9.readthedocs.io/en/v9.18.20/

In named.conf.local specify internal zone:

```shell
zone "intranet.local" {
	type forward;
	forward only;
	forwarders {
		192.168.1.100;
		192.168.1.101;
	}
};
```

run sudo named-checkconf named.conf

run systemctl restart bind9

you can clear cashe using sudo rndc flush

# Configure Pair of Authoritative Name Servers

Install bind9

rpm -q bind9

configure ip address for first server

ip addr add 192.168.1.100/24 dev eth0


Then you need to turn the server into an authoritateve dns server.

Navigate to /etc/bind directory and define two zones for the intranet.local domain. THe forward zone and the reverse zone. YOu will need to edit named.conf.local configuration file.


define forward and reverse zone

```
zone "intranet.local" IN {
	type master;
	file "/etc/bind/zones/forward.intranet.local";
	allow-query { 192.168.1.0/24 };
}

zone "1.168.192.in-addr.arpa" IN {
	type master;
	file "/etc/bind/zones/reverse.intranet.local";
}
```

create zones file

mkdir -p /etc/bind/zones
sudo touch /etc/bind/zones/{forward, reverse}.intranet.local

Configure forward zone file:

```
; configure default ttl
$TTL 3h
@	IN	SOA	ns1.intranet.local. intranet.local. (
	1 ; Serial
	604800 ; Refresh
	86400 ; Retry
	2419200 ; Expire
	604800 ; Negative Cache TTL
)

; NAMESERVER DEFINITIONS
@ IN NS ns1.intranet.local.
@ IN NS ns2.intranet.local.

; A record definitions
ns1	IN 	A	192.168.1.100
ns2	IN	A	192.168.1.101
```

Configure reverse zone file:

```txt
$TTL 3h
@ IN SOA ns1.intranet.local. intranetl.local. (
	1
	604800
	86400
	2419200
	604800
)

@ IN NS ns1.intranet.local.
@ IN NS ns2.intranet.local.

100 IN PTR ns1.intranet.local.
101 IN PTR ns2.intranet.local.
```

Run the named-checkconf -z named.conf.
Confirm there are no issues in zones using named-checkzone intranet.local zones/forward.intranet.local
and do the same for zones/reverse.intranet.local

You need to restart the service for the change to take effect.

# Configure the secondary nameserver


Edit named.conf.options

```
	recursion yes;
	allow-recursion { localhost; 192.168.1.0/24; };
	listen-on port 53 { 192.168.1.0/24 };
	allow-query { localhost; 192.168.1.0/24 };
	allow-transfer { none; };
	notify yes;
```

Edit named.conf.local

```
zone "intranet.local" IN {
	type slave;
	file "/var/cache/bind/forward.intranet.local";
	allow-query { 192.168.1.0/24; };
	masters { 192.168.1.100; };
}

zone "1.168.192.in-addr.arpa" IN {
	type slave;
	file "/var/cache/bind/reverse.intranet.local";
	masters { 192.168.1.100; };
}
```

run named-checkconf -z /etc/bind/named.conf
restart service using systemctl restart bind9

# Finish Configuring Master Server

edit named.conf.options

```txt
	recursion yes;
	allow-recursion { localhost; 192.168.1.0/24; };
	listen-on port 53 { 192.168.1.0/24 };
	allow-query { localhost; 192.168.1.0/24 };
	allow-transfer { localhost; 192.168.1.101; };
	notify yes;
```


add the following on the zone file
```txt
	notify yes;
	also-notify { 192.168.1.101; };
	allow-transfer { 192.168.1.101; };
```

Then simulate a change on dns zone on master server and see if it is replicated. Increment serial and add an A record.

