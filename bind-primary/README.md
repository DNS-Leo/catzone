Basic setup to have Bind as catalog-zone primary server:

## Step 1: Server
- In all these examples we have the primary on 127.0.0.1 and secondary on 127.0.0.2
  Make sure these IP's are available.

## Step 2: Bind
- Install Bind
- Place (or replace) named.conf
- Create the directories `mkdir -p /usr/local/etc/named/{working,zones}`
- Place zonefiles (`catzone.zone`, `example.com.zone`, `example.org.zone`) in the zones directory
- place add.py where you like it. Probably `/usr/local/etc/named` is a good place.
- Start Bind
- Test `dig @127.0.0.1 -t AXFR catzone`
- Test `dig @127.0.0.1 example.com`
