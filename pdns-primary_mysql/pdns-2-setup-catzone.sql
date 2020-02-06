-- <some personal prefereces> ##########################

-- prevent invalid records:
ALTER TABLE domains CHARACTER SET 'ascii';
ALTER TABLE records CHARACTER SET 'ascii';

-- prevent dormant records:
ALTER TABLE records ADD CONSTRAINT FOREIGN KEY domains (domain_id) REFERENCES domains(id) ON DELETE CASCADE;
-- so when deleting from table `domain` all corresponding records will be deleted from `records`

-- prevent duplicate records - workaround `content`s VARCHAR(84000) makes UNIQUE KEY impossible
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

-- </some personal prefereces> #########################

-- insert the catzone:
INSERT INTO domains (id, name, type) VALUES (1, 'catzone', 'NATIVE');
INSERT INTO records (domain_id, name, ttl, type, content) VALUES
(1,         'catzone', 14400, 'SOA', 'localhost admin.localhost 1'),
(1,         'catzone', 14400, 'NS',  'ns1.example.net'),
(1,         'catzone', 14400, 'NS',  'ns2.example.net'),
(1, 'version.catzone',     0, 'TXT', '2');

-- insert catalog-zone PTR record on inserts on `domain`
delimiter //
CREATE TRIGGER `catzone_add` AFTER INSERT ON domains
FOR EACH ROW BEGIN
  INSERT INTO records (domain_id, name, type, content) VALUES(1, CONCAT(NEW.id, '.zones.catzone'), 'PTR', CONCAT(NEW.name,'.'));
  UPDATE records SET content=CONCAT('localhost admin.localhost', ' ', UNIX_TIMESTAMP()) WHERE domain_id=1 AND type='SOA';
END;
//
delimiter ;

-- delete catalog-zone PTR record on deletes on `domain`
delimiter //
CREATE TRIGGER `catzone_del` AFTER DELETE ON domains
FOR EACH ROW BEGIN
  DELETE FROM records WHERE domain_id=1 AND type='PTR' AND content=CONCAT(OLD.name, '.');
  UPDATE records SET content=CONCAT('localhost admin.localhost', ' ', UNIX_TIMESTAMP()) WHERE domain_id=1 AND type='SOA';
END;
//
delimiter ;
