Basic setup to have PowerDNS as catalog-zone master server:
using two triggers which add the PTR records

## Step 1: Server
- In all these examples we have the primary on 127.0.0.1 and secondary on 127.0.0.2
  Make sure these IP's are available.

## Step 2: MySQL
- Install MySQL server
- Start it
- Run `root@localhost [(none)]> \. pdns-1-create-db.sql`
- Run `root@localhost [(pdns)]> \. pdns-2-catzone-and-triggers.sql`
- Run `root@localhost [(pdns)]> \. pdns-3-insert-zones.sql`

## Step 3: PowerDNS
- Install PowerDNS server
- Replace pdns.conf
- Start it

If all went well then the example domains are now being served by PowerDNS and the catalog zone is to.

Test with:

`dig @127.0.0.1 example.be`

`dig @127.0.0.1 -t AXFR catzone`


When you have setup a secondary it now would do to.

Test with:

`dig @127.0.0.2 example.be`


So one MySQL query like `DELETE FROM domains WHERE name='example.be'` will delete the domains and it's records from both.

Test with:

`dig @127.0.0.1 example.be`

`dig @127.0.0.2 example.be`
