#!/usr/bin/env python2.7

import sys
import os
import isc
import dns.query
import dns.update
import dns.name
import hashlib

ZONEPATH='/tmp/'
MASTER='127.0.0.1'
DNSPORT=53
RNDCPORT=953
RNDCALGO='sha256'
RNDCKEY='e3pzIpblablablaetcetcetc+PQ='
CATZONE='catzone'

def add_zone():

  # domain:
  d = sys.argv[1]
  
  # add the zone:
  h = hashlib.sha1(dns.name.from_text(d).to_wire()).hexdigest()
  r = isc.rndc((MASTER, RNDCPORT), RNDCALGO, RNDCKEY)  
  response = r.call('addzone %s {type master; file "zones/%s.db";};' % (d, d))
  if response['result'] != '0':
    raise Exception("Error adding zone to master: %s" % response['err'])
  print ("added zone %s" %d)

  # add PTR to catalog zone using DDNS:
  update = dns.update.Update(CATZONE)
  update.add('%s.zones' % h, 3600, 'PTR', '%s.' % d)  
  response = dns.query.tcp(update, MASTER, port=DNSPORT)  
  if response.rcode() != 0:
    raise Exception("Error updating catalog zone: %d" % response.rcode())
  print ("added record: %s.zones 3600 PTR %s." % (h, d))

add_zone()
