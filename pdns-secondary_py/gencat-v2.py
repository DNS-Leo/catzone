#!/usr/bin/env python3.7

import os
import dns.query
import dns.tsigkeyring
import dns.zone

CAT='catzone.'                                                                  # zone apex of the catalog zone
PRI='127.0.0.1'                                                                 # primary
CNF='/usr/local/etc/pdns/bind.conf'                                             # location of bind.conf which pdns is using
DIR='/usr/local/etc/pdns/zones'                                                 # directory where zones are stored 
TSK = dns.tsigkeyring.from_text({ 'tsig-z' : '0jnu3SdsMvzzlmTDPYRceA==' })      # TSIG - 'hmac-md5' seems the default?

if __name__ == '__main__':

  q = dns.query.udp(dns.message.make_query(CAT, 'SOA'), PRI)                    # Query the SOA of the catalog zone,
  changed_r = int(q.answer[0].to_text().split(' ')[6])                          # and use the returned serial,
  changed_l = int(os.path.getmtime(CNF))                                        # and to the mtime of our config,
  if changed_r > changed_l:                                                     # to compare / detect a SOA serial raise.
  
    z = dns.zone.from_xfr(dns.query.xfr(PRI, CAT, keyring=TSK))                 # If so, then do AXFR the catzone
    if z is not None:
      cf = open(CNF,"w")                                                        # and write a new bind.conf
      cf.write('options { directory "%s"; };\n' % DIR)
      
      for n in z.nodes.keys():
        for r in z[n].rdatasets:
          l = r.to_text(n).split(' ')
          if l[3] == 'PTR':                                                     # extract only PTR's
            d = l[4].rstrip('.')                                                # domain
            cf.write('zone "%s" IN { type slave; file "%s.zone"; masters { %s; }; };\n' % (d, d, PRI))
            if not os.path.exists("%s/%s.zone" % (DIR, d)):                     # indication that the domain may be new
              os.system('pdnsutil activate-tsig-key %s tsig-z slave' % d)       # activate TSIG for that zone
              
      cf.close()
      os.utime(CNF,(changed_r, changed_r))                                      # used to detect SOA bumps of catzone
      os.system('pdns_control rediscover')                                      #
      os.system('pdns_control reload')                                          # make the AXFR's of the zones happen
