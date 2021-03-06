Basic setup to have Bind as catalog-zone primary server:

## Step 1: Server
- In all these examples we have the primary on 127.0.0.1 and secondary on 127.0.0.2
  Make sure these IP's are available.

## Step 2: Bind
- Install Bind, make sure to include the ISC python module.
- Place (or replace) named.conf
- Create the directories `mkdir -p /usr/local/etc/named/zones`
- Change the directories `chown -R 53:53 /usr/local/etc/named`
- Place zonefiles all `*.zone` files in the `zones` directory
- Start Bind
- Test `dig @127.0.0.1 -t AXFR catzone`
- Test `dig @127.0.0.1 example.com` - should return NXDOMAIN
- Test `dig @127.0.0.2 example.com` - should return NXDOMAIN (on condition you run already a secondary)
- Test `dig @127.0.0.1 example.org` - should return NOERROR
- Test `dig @127.0.0.2 example.org` - should return NOERROR (on condition you run already a secondary)

## Step 3: Additional
- Install dnspython
- Place `add.py` and `del.py` in `/usr/local/etc/named`
- Run `./add.py example.com 12345678`
- Test `dig @127.0.0.1 example.com` - should return NOERROR
- Test `dig @127.0.0.2 example.com` - should return NOERROR (on condition you run already a secondary)
- Run `./del.py example.com 12345678`
- Test `dig @127.0.0.1 example.com` - should return NXDOMAIN
- Test `dig @127.0.0.2 example.com` - should return NXDOMAIN (on condition you run already a secondary)
