#!/usr/bin/env python3.7

import os, sys
import isc.rndc
import dns.query
import dns.update

MASTER='127.0.0.1'
DNSPORT=53
RNDCPORT=953
RNDCALGO='sha256'
RNDCKEY='U7oTLYsJTzJoB7E7x/I/VIYIXSTjhzHzLhrqMx3qxpk='
CATZONE='catzone'

def del_zone():

  # domain:
  d,i = sys.argv[1], sys.argv[2]

  # Update catalog zone
  update = dns.update.Update(CATZONE)
  update.delete('%s.zones' % i)
  response = dns.query.tcp(update, MASTER, port=DNSPORT)
  if response.rcode() != 0:
    raise Exception("Error updating catalog zone: %s" % response.rcode())
     
  # Delete zone from master using RNDC
  r = isc.rndc((MASTER, RNDCPORT), RNDCALGO, RNDCKEY)
  response = r.call('delzone -clean %s' % d)
  # -clean also delete zonefile and journal
     
del_zone()
