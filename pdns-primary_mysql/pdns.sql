-- This code will make MySQL automaintain one single master catalog-zone containing all zones
-- NOTE: the catalog-zone is depending on using "1" as zone_id "1" (so should be available).

-- in case you wish to start with an empty DB:
-- DROP   DATABASE IF     EXISTS pdns;
-- CREATE DATABASE IF NOT EXISTS pdns;
-- USE pdns;

-- ##########################################################################################################
-- the next CREATE queries are identical to https://doc.powerdns.com/authoritative/guides/basic-database.html
-- ##########################################################################################################

CREATE TABLE domains (
  id                    INT AUTO_INCREMENT,
  name                  VARCHAR(255) NOT NULL,
  master                VARCHAR(128) DEFAULT NULL,
  last_check            INT DEFAULT NULL,
  type                  VARCHAR(6) NOT NULL,
  notified_serial       INT UNSIGNED DEFAULT NULL,
  account               VARCHAR(40) CHARACTER SET 'utf8' DEFAULT NULL,
  PRIMARY KEY (id)
) Engine=InnoDB CHARACTER SET 'latin1';

CREATE UNIQUE INDEX name_index ON domains(name);

CREATE TABLE records (
  id                    BIGINT AUTO_INCREMENT,
  domain_id             INT DEFAULT NULL,
  name                  VARCHAR(255) DEFAULT NULL,
  type                  VARCHAR(10) DEFAULT NULL,
  content               VARCHAR(64000) DEFAULT NULL,
  ttl                   INT DEFAULT NULL,
  prio                  INT DEFAULT NULL,
  disabled              TINYINT(1) DEFAULT 0,
  ordername             VARCHAR(255) BINARY DEFAULT NULL,
  auth                  TINYINT(1) DEFAULT 1,
  PRIMARY KEY (id)
) Engine=InnoDB CHARACTER SET 'latin1';

CREATE INDEX nametype_index ON records(name,type);
CREATE INDEX domain_id ON records(domain_id);
CREATE INDEX ordername ON records (ordername);

CREATE TABLE supermasters (
  ip                    VARCHAR(64) NOT NULL,
  nameserver            VARCHAR(255) NOT NULL,
  account               VARCHAR(40) CHARACTER SET 'utf8' NOT NULL,
  PRIMARY KEY (ip, nameserver)
) Engine=InnoDB CHARACTER SET 'latin1';

CREATE TABLE comments (
  id                    INT AUTO_INCREMENT,
  domain_id             INT NOT NULL,
  name                  VARCHAR(255) NOT NULL,
  type                  VARCHAR(10) NOT NULL,
  modified_at           INT NOT NULL,
  account               VARCHAR(40) CHARACTER SET 'utf8' DEFAULT NULL,
  comment               TEXT CHARACTER SET 'utf8' NOT NULL,
  PRIMARY KEY (id)
) Engine=InnoDB CHARACTER SET 'latin1';

CREATE INDEX comments_name_type_idx ON comments (name, type);
CREATE INDEX comments_order_idx ON comments (domain_id, modified_at);

CREATE TABLE domainmetadata (
  id                    INT AUTO_INCREMENT,
  domain_id             INT NOT NULL,
  kind                  VARCHAR(32),
  content               TEXT,
  PRIMARY KEY (id)
) Engine=InnoDB CHARACTER SET 'latin1';

CREATE INDEX domainmetadata_idx ON domainmetadata (domain_id, kind);

CREATE TABLE cryptokeys (
  id                    INT AUTO_INCREMENT,
  domain_id             INT NOT NULL,
  flags                 INT NOT NULL,
  active                BOOL,
  published             BOOL DEFAULT 1,
  content               TEXT,
  PRIMARY KEY(id)
) Engine=InnoDB CHARACTER SET 'latin1';

CREATE INDEX domainidindex ON cryptokeys(domain_id);

CREATE TABLE tsigkeys (
  id                    INT AUTO_INCREMENT,
  name                  VARCHAR(255),
  algorithm             VARCHAR(50),
  secret                VARCHAR(255),
  PRIMARY KEY (id)
) Engine=InnoDB CHARACTER SET 'latin1';

CREATE UNIQUE INDEX namealgoindex ON tsigkeys(name, algorithm);

-- ###################################################################################################
-- ###################################################################################################

-- #### some personal prefereces

-- keep records valid:
ALTER TABLE domains CHARACTER SET 'ascii';
ALTER TABLE records CHARACTER SET 'ascii';

-- obtain data-hygiene:
ALTER TABLE records ADD CONSTRAINT FOREIGN KEY domains (domain_id) REFERENCES domains(id) ON DELETE CASCADE;
-- so when deleting from table `domain` all corresponding records will be deleted from `records`

-- prevent duplicate records
delimiter //
CREATE TRIGGER `unique_record` BEFORE INSERT ON records
FOR EACH ROW BEGIN
  IF( SELECT COUNT(*) FROM records WHERE name=NEW.name AND type=NEW.type AND content=NEW.content) > 0
  THEN
    SIGNAL SQLSTATE '45000' SET message_text = 'DNS record alread exist';
  END IF;
END;
//
delimiter ;

-- insert the catzone:
INSERT INTO domains (id, name, type) VALUES (1, 'catzone', 'NATIVE');
INSERT INTO records (domain_id, name, ttl, type, content) VALUES
(1,         'catzone', 14400, 'SOA', 'localhost admin.localhost 1'),
(1,         'catzone', 14400, 'NS',  'ns1.example.net'),
(1,         'catzone', 14400, 'NS',  'ns2.example.net'),
(1, 'version.catzone',     0, 'TXT', '2');

-- insert catalog-zone PTR on domain insert
delimiter //
CREATE TRIGGER `catzone_add` AFTER INSERT ON domains
FOR EACH ROW BEGIN
  INSERT INTO records (domain_id, name, type, content) VALUES(1, CONCAT(NEW.id, '.zones.catzone'), 'PTR', CONCAT(NEW.name,'.'));
  UPDATE records SET content=CONCAT('localhost admin.localhost', ' ', UNIX_TIMESTAMP()) WHERE domain_id=1 AND type='SOA';
END;
//
delimiter ;

-- delete catalog-zone PTR on domain removal
delimiter //
CREATE TRIGGER `catzone_del` AFTER DELETE ON domains
FOR EACH ROW BEGIN
  DELETE FROM records WHERE domain_id=1 AND type='PTR' AND content=CONCAT(OLD.name, '.');
  UPDATE records SET content=CONCAT('localhost admin.localhost', ' ', UNIX_TIMESTAMP()) WHERE domain_id=1 AND type='SOA';
END;
//
delimiter ;

-- The next 3 queries can easily be recycled to insert multiple domains
-- set two variables (domain id, zone apex):
SELECT 2, 'example.nl' INTO @'i',@'d';
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
