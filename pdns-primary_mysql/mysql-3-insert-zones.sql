USE powerdns;

-- The next 3 queries can easily be recycled to insert multiple domains
-- set two variables (domain id, zone apex):
SELECT 2, 'example.com' INTO @'i',@'d';
-- two insert queries
INSERT INTO domains (id, name, type) VALUES (@'i', @'d', 'NATIVE');
INSERT INTO records (domain_id, name, ttl, type, prio, content) VALUES
(@'i',                     @'d' , 86400, 'SOA' , NULL, 'localhost admin.example.net 1'),
(@'i',                     @'d' , 86400, 'NS'  , NULL, 'ns1.example.net'),
(@'i',                     @'d' , 86400, 'NS'  , NULL, 'ns2.example.net'),
(@'i', CONCAT(      'www.',@'d'),   120, 'A'   , NULL, '192.168.0.80'),
(@'i', CONCAT(      'www.',@'d'),   120, 'AAAA', NULL, 'fe00::80'),
(@'i', CONCAT('localhost.',@'d'),   120, 'A'   , NULL, '127.0.0.1'),
(@'i',                     @'d' ,   120, 'MX'  ,   10, 'mx1.example.net'),
(@'i',                     @'d' ,   120, 'MX'  ,   20, 'mx2.example.net');
