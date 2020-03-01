## setup
`mkdir -p /usr/local/etc/pdns/zones`

put pdns.conf in /usr/local/etc/pdns

put bind.conf in /usr/local/etc/pdns

put gencat-v2.py in /usr/local/etc/pdns

`pdnsutil create-bind-db /usr/local/etc/pdns/bind-dnssec.db`

...bind-dnssec-db requires building PowerDNS with SQLite3

...rebuild powerdns, and try again...

`pdnsutil create-bind-db /usr/local/etc/pdns/bind-dnssec.db`

`pdnsutil import-tsig-key tsig-z hmac-md5 '0jnu3SdsMvzzlmTDPYRceA=='`

It's important that the sqlite db has the same user as the pdns daemon is running on:

`chown -R 53:53 /usr/local/etc/pdns`

`service pdns start`

`./gencat-v2.py`

`ls zones`

## SOA serial
requires catzone SOA serial to be epoch

## filesystem
The max. number of file in a directory on a UFS file-system seems 32,767.
So beyond that you wish to use something better, probably ZFS.
