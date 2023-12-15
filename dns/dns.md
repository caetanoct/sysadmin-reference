# DNS Core

- Name Resolution
- Name Space
- Name Registration

## Domain Name Format

Domain name is interpreted from **right-to-left**.

The first component is the root, or a single dot "."

The root (".") is the rightmost component of a domain name.

After the root comes the Top-Level Domain (TLD).

What follows TLD is the second level domains.

The second level domain along with the TLD makes the zone apex/naked domain.

The third-level domain is usually a arbitrary string. The components of a domain name is know as name and the root contains a label of null.

www.example.com would be the Fully-Qualified-Domain-Name (FQDN).


```txt
             ┌───────────┐
         │   │           │
  null   │   │   Root    │
  label  │   │           │
         │   └───────────┘

             ┌───────────┐
         │   │           │   │
         │   │    TLD    │   │
         │   │           │   │
         │   └───────────┘   │
         │                   │  zone apex / naked domain
labels   │   ┌───────────┐   │
         │   │           │   │
         │   │ Second-Lv │   │
         │   │           │   │
         │   └───────────┘   │
         │
         │   ┌───────────┐
         │   │           │
         │   │ Third-Lv  │
         │   │           │
             └───────────┘
             
             	...
             	
             	N - Lv 
```

Each labels is a subdomain of its parent domain.
FQDN maximum size is 255 characters, including periods.
DNS names are case-insensitive.
Each label can be 63 characters long.
LDH rule (letters, digits and hypens) but cannot start or end with an hyphen. and a top level domain can not be all numberic.
PQDN - Partially Qualified domain name starts with a host but does not go until the root.

## The DNS Tree

Since having a copy of the entire interned domain name mappings is too large and does not scale well, therefore DNS uses an hierarchical structure. Globally distributed database forming a tree-like structure where each domain name is just a path in this tree.

Name uniqueness is guaranteed.
Authority is distributed.

Every organization administering a domain, can further divide it into subdomains. Each subdomain can in turn be delegated to other organizations.

```txt
             ┌─┐
       ┌─────┴┼┴─────┐      root
       │      │      │
       │      │      │
      ┌┼┐    ┌┼┐    ┌┼┐     top level domains
    ┌─┴─┘    ├─┘    └─┴┐
    │        │         │
    │        │         │
   ┌┼┐      ┌┼┐       ┌┼┐   authoritative
 ┌─┴─┘      └─┘       └─┘   name servers
 │
┌┼┐
└─┘
```

# Name Space

## Root Servers

The root server is the first component of the DNS tree that receives a DNS query.

The root server main purpose is to reply with a referral to the TLD server to be contacted.

Each root server is labelled from "A" to "M".

You can find them in https://root-servers.org/.

Does not know about the server hosting www.yahoo.com, but knows the .com name servers.

## TLD servers

Main task is to provide a referral for an authoritative name server (has authority over the requested domain).

Main categories are: 

* Generig TLDs (gTLDs) - com , edu, gov, mil, net, org, arpa
* Country-Code TLDs (ccTLDs) - gr, jp, br

> Full list of TLDs can be found on: https://www.iana.org/domains/root/db

Countries can use organisational subdomains in their ccTLDs.

It does now know which server is hosting www.yahoo.com, but knows about the name server responsible for yahoo.

## Authoritative Name Servers

Most abstract.

A single authority can manage multiple domains, levels of the tree.

Provides the final answer in a DNS request.

# Name Resolution

## Local Name Resolution / Host Table Resolution

No contact with TLD's or root servers. Just consulting a host table. Back in the day you would need to send an e-mail to ARPA to request an anddress and hosts.txt would be distributed by NICC and manually installed.

- Windows: C:/Windows/System32/drivers/etc/hosts
- Linux: /etc/hosts

Use cases: small networks, improved performancce, local domain redirection for testing, basic URL filtering, bootstrapping networks, fallback name system.

## DNS Resolver

The first server that receives the request is the resolver.
The resolver sits between the client and the DNS tree.
The resolver when receives a request will try to resolve it directly, if he can't he will assume the role of the client and try to resolve using the DNS ecosystem (ROOT -> TLD -> AUTHORITATIVE NS).
Caches the result of the query.

The resolver knows about the root server thanks to the **root hints file**, which is where the root servers are stored.

Usually your router or an IP address provided by ISP.

You can have your own resolver or use an openDNS resolver. Google Resolver is 8.8.8.8, Cloudfare is 1.1.1.1.

Not all resolvers support the same features.

Not all resolvers use the same method in choosing which name server to contact.

### /etc/resolv.conf

If no nameserver is specified only the nameserver in local machine would be queried.

Nameserver must be an IP.

You can have up to three name server.

Queried in listed order, will query other servers when a query timeouts. (repets until hits max-tries)

## DNS Resolution Types

### Iterative Resolution

A client request to a DNS server requesting a specific domain name, the DNS server will look in it's local data and if it does not have the answer it will send a referral closer to the domain name requested, the referral will contain **all nameservers** in its local data and the client will have to choose which to contact next.

If client receives a referral, it will request this referral and receive another referral or an answer.

Client responsability to keep querying.

### Recursive Resolution

Upon receiving a request, the server checks if it has the answer. If it doesn't has the answer, instead of returning the referral, the server will assume the role of the client and will send a series of iterative requests on the DNS tree, starting from the root until it finds the authoritative answer for the domain name being requested. 

The client in this case only sends one query, its type is **recursive query**, and cannot receive referral answers.

Server is responsible for obtaining DNS information.

### Caching

Whenever a name is resolved, the result is cached.

As soon as a server resolves it will cache it, including most resolvers (some don't).

Unsuccesful request (errors) are also cached.

There are dedicated cache-only DNS servers and they don't have any authority over any domain.

TTL determines the cache retention period.

Viewing DNS cache windows `ipconfig /displaydns` you can also use `ipconfig /flushdns` to flush cache.

In addition to OS caches and Server caches, the browser also have a DNS cache. You can clear on chrome using : `chrome://net-internals/#dns

`resolvectl flush-caches`

Not all queries are cached, for example, reverse queries are not cached.

Negative answers are cached with different ttl.

```bash
pkill -USR1 systemd-resolve
journalctl -r -u systemd-resolved
```

## DNS Name Resolution Workflow

1. User types www.example.com, and assuming there is no entry on DNS cache for this domain.
2. The browsers asks the OS about the domain.
3. The OS checks its host table and cache, if it does not find then it sends a recursive query to the DNS resolver.
4. The DNS resolver will check its cache, if domain is not present, the resolver will check its root hints file and contact a **root nameserver**.
5. The queries root nameserver will send back a referral containing a list of nameservers for the `.com` TLD along with its IP addresses.
6. The resolver then selects one of the nameservers and sends an interactive query for www.example.com, the query .com name server returns a list of authoritative name servers for example.com domain.
7. The resolver selects one of these authoritative name servers and sends a query for www.example.com.
8. The authoritative name server replies with an authoritative answer.
9. The resolver caches the result and forwards to the client.
10. OS caches.
11. Browser caches.

> Each resolver will choose in its own way which server to contact, the FQDN is www.example.com.
> The name of this process is forward resolution.

## Reverse Name Resolution

There is a special domain called **in-addr.arpa**.

This domain contains a numerical hierarchy that covers the entire IP address space.

Four levels of numerical subdomains from 0 to 255. Structured so each ip address has its own node and this node can point to a domain name.

Reverse lookup goes from the least specific to the most specific octet.

IP addresses have the least specific octets on the left and the most specific on the right.

On windows you can use: `ping -a "ipaddr"`
On linux: `dig +x "ipaddr"` or `nslookup "ipaddr"`

For ipv6 is **ip6.arpa**.
# Name Registration

## Domain Name Registration Hierarchy

ICANN (manages gTLDs and ccTLDs)
Five Regional Internet Registries (responsible for obtaining IP addresses from ICANN)
Registrar (ICANN accredited organization) -> GoDaddy, BlueHost, Namesheap
Resellers (Third Party through registers) -> Route 53
Registrants

## Domain Name Registration Process

1. The registrant chooses a domain name and submits a request to register it with a reseller or ICANN Registrar.
2. If the domain name is available, the registrar register the names and creates a whois record.
3. The registrar then send the domain name to the Registry.
4. The registry will file all information provided and add the zone to the master servers, which will tell other servers where the websited is located.

---

### Choosing a TLD

1. DNSSEC support?
2. IDN's support? (Domain name with non-ascii characters)
3. Privacy Protection?
4. Target Audience?
5. Relevant Field?

### DNS Twist

Check for URL Hijacking.

### Which Registrar to choose?

Check Pricing:
Registration fee
Renewal fee
Domain transfers
Check Add-On Services: ssl/customer service, web hosting, wordpress, email hosting
Check Supported TLDs
Check Policies: domain transfer / domain expiration.

### EPP Status Codes

- Indicates status of domain name registration
- Every domain has at least one code
- Useful for troubleshooting

client - set by registar
server - set by registry

clientHold - tell domain registry to not activate the domain in DNS
clientTransferProhibited - tell domain registry to reject request to transfer from one registrar to another.
clientUpdateProhibited - rejecct request to update the domain.

ok - standard status for a domain
autoRenewPeriod - grace period after domain is expired 
serverTransferProhibited - prevents transfer from current registrar to another.

whois lookup to see the EPP status code. lookup.icann.org

# DNS Data Storage

- DNS data is stored in a database called **zone**.
- There are two types of zones:
	- Forward Lookup Zone
	- Reverse Lookup Zone

**Each zone is a collection of resource records (RRs)**

There are many type of resource records (RR), and each resource type contains a specific type of data, for example:
- A record contains a name and its IPv4 address
- AAAA recourd contains a name and its IPv6 address

**Common RR format**

- All types share this format:
	- Name
	- Type (A=1, NS=2,..)
	- Class (99% of cases is IN for internet)
	- TTL (Length of time cached information)
	- RDLength (Size of resource data field)
	- RData (Actual data)

## SOA record

Start of Authority (SOA) indicates the beginning of a zone and should be the first record in any zone file.

There is only one SOA per zone.

The SOA format is: `<domain> <ttl> <class> SOA <m-name> <r-name>`

Where `m-name` which is the primary authorative name server for the zone.

And `r-name` signifies the email address of the administrator responsible for the zone.

**Format**:
```txt
<domain> <ttl> <class> SOA <m-name> <r-name> (
	<serial-num> - version number of the zone, incremented everytime a change is made to zone file (never decreases)
	<refresh-interval>
	<retry-interval>
	<expire-interval>
	<minimum> - represents ttl value for negative caching (negative caching for negative answers)
)
```

You can check SOA using `nslookup -type-soa $DOMAIN` or `dig -t soa $domain`

Incrementing serial number will initiate replication process.

## NS Record

Points to authoritative name servers for a zone. These name servers hold the actual DNS information.

If it does not exist, the TLDs servers can't point to the second level domain.

Since this ensured the availability of the domain, every zone must have at least two NS records where each points to a differente name server.

**Format**:

```txt
<domain> <ttl> <class> NS <nameserver hostname>
```

you can use `nslookup -type=ns $host` or `dig -t ns $host`

## A and AAAA record

Address Record (A)

Queried in forward name resolution.

**Format**:
```txt
<domain> <ttl> <class> A <ipv4 address>
```

```txt
<domain> <ttl> <class> AAAA <ipv6 address>
```

AAAA because it consumes 4 more times bytes (32 bits - 128bits)

You can have an A and AAAA record point to the same domain where dual stack is required.

## PTR record

Pointer Record (PTR)

Queried in reverse name resolutions.

**Format**:

```txt
<reverse domain name> <class> PTR <domain name>
```

Reverse domain name is: 8.10.23.43.in-addr.arpa, if the ipv4 address is 43.23.10.8.

You can query by using `nslookup -type=ptr $ip` or `nslookup $ip` or `dig +x $ip`.

## CNAME record

Canonical Name Record (CNAME)

Maps one domain name to another

**Format**:

```txt
<alias> <class> CNAME <ttl> <canonical-name>
```

Use cases: map subdomains to their apex domain, example: www.example.com -> example.com
Redirect TLDs to same second level domain.

**Restrictions**:

- Must always point to another domain and never to an IP
- Can't point to a NS or MX record
- Cannot co-exist with another record for the same nam

Use cases: map subdomains to their apex domain, example: www.example.com -> example.com
Redirect TLDs to same second level domain.

**Restrictions**:

- Must always point to another domain and never to an IP
- Can't point to a NS or MX record
- Cannot co-exist with another record for the same name.


It is not recommended to point a cname to another cname.

## TXT record

Associates text data to a domain.

**Format**:

```txt
<domain> <class> txt <ttl> <textual-data>
```

Text can have any format
The same comain can contain multiple txt records

## MX record

Mail Exchange record (MX)

Maps domain to email server

**Format**:

```txt
<domain> <class> MX <ttl> <preference-value> <email-server>
```

Lower preference value, higher the priority.

