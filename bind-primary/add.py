#!/usr/bin/env python3.7

import os, sys
import isc.rndc
import dns.query
import dns.update

ZONEPATH='zones/'
MASTER='127.0.0.1'
DNSPORT=53
RNDCPORT=953
RNDCALGO='sha256'
RNDCKEY='U7oTLYsJTzJoB7E7x/I/VIYIXSTjhzHzLhrqMx3qxpk='
CATZONE='catzone'

def add_zone():

  # domain:
  d,i = sys.argv[1], sys.argv[2]
  
  # add the zone:
  r = isc.rndc((MASTER, RNDCPORT), RNDCALGO, RNDCKEY)
  response = r.call('addzone %s {type master; file "%s%s.zone";};' % (d, ZONEPATH, d))
  if response['result'] != b'0':
    raise Exception("Error adding zone to master: %s" % (b"%s" % response['err']))
  print ("added zone %s (%s)" % (d, i))

  # add PTR to catalog zone using DDNS:
  update = dns.update.Update(CATZONE)
  update.add('%s.zones' % i, 3600, 'PTR', '%s.' % d)  
  response = dns.query.tcp(update, MASTER, port=DNSPORT)  
  if response.rcode() != 0:
    raise Exception("Error updating catalog zone: %d" % response.rcode())
  print ("added record: %s.zones 3600 PTR %s." % (i, d))

add_zone()
