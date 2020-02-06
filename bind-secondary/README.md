Basic setup to have Bind as catalog-zone secondary server:

## Step 1: Server
- In all these examples we have the primary on 127.0.0.1 and secondary on 127.0.0.2
  Make sure these IP's are available.

## Step 2: Bind
- Install Bind
- Place (or replace) named.conf
- Start Bind
- Test `dig @127.0.0.2 example.com`
