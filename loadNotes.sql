CREATE TABLE Notes (
  id INTEGER,
  note TEXT NOT NULL,
  PRIMARY KEY (id)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;


LOAD DATA LOCAL INFILE 'Python\ Parsing/Books/notes.csv'
INTO TABLE Notes
CHARACTER SET UTF8
FIELDS TERMINATED BY '\t' ENCLOSED BY '' ESCAPED BY '\\' 
LINES TERMINATED BY '\n' STARTING BY '';

LOAD DATA LOCAL INFILE '/home/simonlbc/workspace/DB/DB2016/CSV/notes_rem.csv'
INTO TABLE Notes 
FIELDS TERMINATED BY '\t' ENCLOSED BY '' LINES TERMINATED BY '\n';
