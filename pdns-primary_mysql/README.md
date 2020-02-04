Basic setup to have PowerDNS as catalog-zone master server:
using two triggers which add the PTR records

## Server
- Besides having 127.0.0.1 (pri) add 127.0.0.2 (sec)

## MySQL
- Install MySQL server
- Start it
- Run the pdns.sql

## PowerDNS
- Install PowerDNS server
- Replace pdns.conf
- Start it

If all went well then the example domains are now being served by both PowerDNS and the secondary.
One MySQL query like `DELETE FROM domains WHERE name='example.be'` will the domains and it's records from both.
