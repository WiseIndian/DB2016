/* DB-PROJECT: DELIVRABLE_1 */

CREATE TABLE Notes (
  id INTEGER,
  note TEXT NOT NULL,
  PRIMARY KEY (id)
);

	
LOAD DATA LOCAL INFILE '/home/simonlbc/workspace/DB/DB2016/CSV/notes_rem.csv'
INTO TABLE Notes
CHARACTER SET UTF8
FIELDS TERMINATED BY '\t' ENCLOSED BY '' ESCAPED BY '\\'
LINES TERMINATED BY '\n' STARTING BY '';

	


CREATE TABLE Languages (
  id INTEGER,
  name CHAR(32),
  code CHAR(10),
  script BOOLEAN,
  PRIMARY KEY (id)
);

LOAD DATA LOCAL INFILE '/home/simonlbc/workspace/DB/DB2016/CSV/languages_rem.csv'
INTO TABLE Languages 
CHARACTER SET UTF8
FIELDS TERMINATED BY '\t' ENCLOSED BY '' ESCAPED BY '\\'
LINES TERMINATED BY '\n' STARTING BY '';


CREATE TABLE Authors_temp (
  id INTEGER,
  name CHAR(64),
  legal_name CHAR(255),
  last_name CHAR(64),
  pseudo CHAR(64),
  birthplace CHAR(255),
  birthdate DATE,
  deathdate DATE,
  email CHAR(255),
  img_link CHAR(255),
  language_id INTEGER,
  note_id INTEGER,
  PRIMARY KEY (id),
  FOREIGN KEY (note_id) REFERENCES Notes(id) ON DELETE SET NULL,
  FOREIGN KEY (language_id) REFERENCES Languages(id) ON DELETE SET NULL
);

LOAD DATA LOCAL INFILE '/home/simonlbc/workspace/DB/DB2016/CSV/authors_rem.csv'
INTO TABLE Authors_temp 
CHARACTER SET UTF8
FIELDS TERMINATED BY '\t' ENCLOSED BY '' ESCAPED BY '\\'
LINES TERMINATED BY '\n' STARTING BY '';


/*then import the data into Authors_temp
and do the following query:*/
CREATE TABLE Authors (
	  id INTEGER,
	  name CHAR(64),
	  legal_name CHAR(255),
	  last_name CHAR(64),
	  pseudo CHAR(64),
	  birthplace CHAR(255),
	  birthdate DATE,
	  deathdate DATE,
	  email CHAR(255),
	  img_link CHAR(255),
	  language_id INTEGER,
	  note TEXT, 
	  PRIMARY KEY (id),
	  FOREIGN KEY (language_id) REFERENCES Languages(id) ON DELETE SET NULL
	) 
	SELECT a.id, a.name, a.legal_name, a.last_name, a.pseudo, a.birthplace,
		a.birthdate, a.deathdate, a.email, a.img_link, a.language_id, NULL
	FROM Authors_temp a
	WHERE a.note_id = NULL
	UNION
	SELECT a.id, a.name, a.legal_name, a.last_name, a.pseudo, a.birthplace,
		a.birthdate, a.deathdate, a.email, a.img_link, a.language_id, n.note 
	FROM Authors_temp a, Notes n
	WHERE a.note_id = n.id;

/*https://dev.mysql.com/doc/refman/5.5/en/create-table-select.html
 *for the syntax of CREATE TABLE ... SELECT
 * http://stackoverflow.com/questions/4081842/sql-conditional-select-within-conditional-select#4081897
 * for how to use it in our case.
 */


CREATE TABLE Title_Series_temp (
  id INTEGER,
  title CHAR(255) NOT NULL,
  parent INTEGER,
  note_id INTEGER,
  PRIMARY KEY (id),
  FOREIGN KEY (note_id) REFERENCES Notes(id) ON DELETE SET NULL
);

LOAD DATA LOCAL INFILE '/home/simonlbc/workspace/DB/DB2016/CSV/title_series_rem.csv'
INTO TABLE Title_Series_temp
CHARACTER SET UTF8
FIELDS TERMINATED BY '\t' ENCLOSED BY '' ESCAPED BY '\\'
LINES TERMINATED BY '\n' STARTING BY '';


CREATE TABLE Title_Series (
	  id INTEGER,
	  title CHAR(255) NOT NULL,
	  parent INTEGER,
	  note TEXT,
	  PRIMARY KEY (id)
	) 
	SELECT t.id, t.title, t.parent, n.note 
	FROM Title_Series_temp t, Notes n 
	WHERE t.note_id = n.id 
	UNION 
	SELECT t.id, t.title, t.parent, NULL
	FROM Title_Series_temp t
	WHERE t.note_id = NULL
	;


CREATE TABLE Titles_temp (
  id INTEGER,
  title CHAR(255) NOT NULL,
  title_translator CHAR(64),
  synopsis_id INTEGER,
  note_id INTEGER,
  series_id INTEGER,
  series_number INTEGER,
  story_len ENUM('nv', 'ss', 'jvn', 'nvz', 'sf'),
  title_type ENUM('ANTHOLOGY', 'BACKCOVERART', 'COLLECTION', 'COVERART', 'INTERIORART',
          'EDITOR', 'ESSAY', 'INTERVIEW', 'NOVEL', 'NONFICTION', 'OMNIBUS', 'POEM',
          'REVIEW', 'SERIAL', 'SHORTFICTION', 'CHAPBOOK'),
  parent INTEGER,
  language_id INTEGER,
  title_graphic BOOLEAN,
  PRIMARY KEY (id),
  FOREIGN KEY (synopsis_id) REFERENCES Notes(id) ON DELETE SET NULL,
  FOREIGN KEY (note_id) REFERENCES Notes(id) ON DELETE SET NULL,
  FOREIGN KEY (language_id) REFERENCES Languages(id) ON DELETE SET NULL
);

LOAD DATA LOCAL INFILE '/home/simonlbc/workspace/DB/DB2016/CSV/titles_rem.csv'
INTO TABLE Titles_temp
CHARACTER SET UTF8
FIELDS TERMINATED BY '\t' ENCLOSED BY '' ESCAPED BY '\\'
LINES TERMINATED BY '\n' STARTING BY '';

CREATE TABLE title_is_translated_in (
  title_id  INTEGER,
  trans_title_id INTEGER,
  language_id INTEGER NOT NULL,
  translator CHAR(64),
  PRIMARY KEY (trans_title_id),
  FOREIGN KEY (title_id) REFERENCES Titles(id) ON DELETE CASCADE,
  FOREIGN KEY (trans_title_id) REFERENCES Titles(id) ON DELETE CASCADE,
  FOREIGN KEY (language_id) REFERENCES Languages(id) ON DELETE CASCADE

)
SELECT parent, title_id, language_id, title_translator
FROM Titles_temp 
WHERE parent IS NOT NULL AND title_id IS NOT NULL AND language_id IS NOT NULL
AND title_translator IS NOT NULL;


CREATE TABLE Titles (
	  id INTEGER,
	  title CHAR(255) NOT NULL,
	  synopsis TEXT,
	  note TEXT,
	  story_len ENUM('nv', 'ss', 'jvn', 'nvz', 'sf'),
	  type ENUM('ANTHOLOGY', 'BACKCOVERART', 'COLLECTION', 'COVERART', 'INTERIORART',
		  'EDITOR', 'ESSAY', 'INTERVIEW', 'NOVEL', 'NONFICTION', 'OMNIBUS', 'POEM',
		  'REVIEW', 'SERIAL', 'SHORTFICTION', 'CHAPBOOK'),
	  parent INTEGER,
	  language_id INTEGER,
	  title_graphic BOOLEAN,
	  PRIMARY KEY (id),
	  FOREIGN KEY (language_id) REFERENCES Languages(id) ON DELETE SET NULL
	) /*this solution is pretty unelegant as we have to look for all cases manually..*/
	SELECT t.id, t.title, syn.note, n.note, t.story_len, t.parent, 
		t.language_id, t.title_graphic
	FROM Titles_temp t, Notes syn, Notes n
	WHERE t.note_id = n.id AND t.synopsis_id = syn.id
	UNION 
	SELECT t.id, t.title, NULL, n.note, t.story_len, t.parent, 
		t.language_id, t.title_graphic
	FROM Titles_temp t, Notes n
	WHERE t.synopsis_id = NULL AND t.note_id = n.id
	UNION
	SELECT t.id, t.title, syn.note, NULL, t.story_len, t.parent, 
		t.language_id, t.title_graphic
	FROM Titles_temp t, Notes syn
	WHERE t.note_id = NULL AND t.synopsis_id = syn.id
	UNION
	SELECT t.id, t.title, NULL, NULL, t.story_len, t.parent, 
	t.language_id, t.title_graphic
	FROM Titles_temp t
	WHERE t.note_id = NULL AND t.synopsis_id = NULL
	;



CREATE TABLE authors_have_publications (
  author_id  INTEGER,
  pub_id INTEGER,
  PRIMARY KEY (author_id, pub_id),
  FOREIGN KEY (author_id) REFERENCES Authors(id) ON DELETE CASCADE,
  FOREIGN KEY (pub_id) REFERENCES Publications(id) ON DELETE CASCADE
);

LOAD DATA LOCAL INFILE '/home/simonlbc/workspace/DB/DB2016/CSV/publications_authors_rem.csv'
INTO TABLE authors_have_publications
CHARACTER SET UTF8
FIELDS TERMINATED BY '\t' ENCLOSED BY '' ESCAPED BY '\\'
LINES TERMINATED BY '\n' STARTING BY '';


/*TODO: modifier le schéma du ER model de manière à bien montrer que c'est
 bien un many to many relationship(comme montré ici avec le code)*/
CREATE TABLE title_is_reviewed_by (
  title_id  INTEGER,
  review_title_id INTEGER,
  PRIMARY KEY (title_id, review_title_id),
  FOREIGN KEY (title_id) REFERENCES Titles(id) ON DELETE CASCADE,
  FOREIGN KEY (review_title_id) REFERENCES Titles(id) ON DELETE CASCADE,
  CONSTRAINT CK_rule CHECK (title_id != review_title_id)
);

LOAD DATA LOCAL INFILE '/home/simonlbc/workspace/DB/DB2016/CSV/reviews_rem.csv'
INTO TABLE title_is_reviewed_by 
CHARACTER SET UTF8
FIELDS TERMINATED BY '\t' ENCLOSED BY '' ESCAPED BY '\\'
LINES TERMINATED BY '\n' STARTING BY '';


CREATE TABLE title_is_part_of_Title_Series (
  title_id  INTEGER,
  series_id INTEGER NOT NULL,
  series_number INTEGER,
  PRIMARY KEY (title_id),
  FOREIGN KEY (title_id) REFERENCES Titles(id) ON DELETE CASCADE,
  FOREIGN KEY (series_id) REFERENCES Title_Series(id) ON DELETE CASCADE
);

LOAD DATA LOCAL INFILE '/home/simonlbc/workspace/DB/DB2016/CSV/titles_series_rem.csv'
INTO TABLE title_is_part_of_Title_Series 
CHARACTER SET UTF8
FIELDS TERMINATED BY '\t' ENCLOSED BY '' ESCAPED BY '\\'
LINES TERMINATED BY '\n' STARTING BY '';






CREATE TABLE Award_Types_temp (
  id INTEGER,
  code CHAR(5),
  name CHAR(255),
  note_id INTEGER,
  awarded_by CHAR(255),
  awarded_for CHAR(255),
  short_name CHAR(255),
  is_poll BOOLEAN,
  non_genre BOOLEAN,
  PRIMARY KEY (id),
  FOREIGN KEY (note_id) REFERENCES Notes(id) ON DELETE SET NULL
  CONTRAINT CK_not_null CHECK (name != NULL OR code != NULL)
);

LOAD DATA LOCAL INFILE '/home/simonlbc/workspace/DB/DB2016/CSV/award_types_rem.csv'
INTO TABLE Award_Types_temp
CHARACTER SET UTF8
FIELDS TERMINATED BY '\t' ENCLOSED BY '' ESCAPED BY '\\'
LINES TERMINATED BY '\n' STARTING BY '';


CREATE TABLE Award_types (
  id INTEGER,
  code CHAR(5),
  name CHAR(255),
  note TEXT,
  awarded_by CHAR(255),
  awarded_for CHAR(255),
  short_name CHAR(255),
  is_poll BOOLEAN,
  non_genre BOOLEAN,
  PRIMARY KEY (id),
  CONTRAINT CK_not_null CHECK (name != NULL OR code != NULL) 
) 
SELECT a_t.id, code, name, n.note, awarded_by, awarded_for, short_name,
	is_poll, non_genre  
FROM Award_Types_temp a_t, Notes n
WHERE a_t.note_id = n.id
UNION
SELECT a_t.id, code, name, NULL, awarded_by, awarded_for, short_name,
	is_poll, non_genre  
FROM Award_Types_temp a_t
WHERE a_t.note_id = NULL
;


CREATE TABLE Award_Categories_temp (
  id INTEGER,
  name CHAR(255),
  type_id INTEGER,
  category_order INTEGER, 
  /* position INTEGER, TODO what is position, is this award category order?*/
  note_id INTEGER,
  PRIMARY KEY (id, type_id),
  FOREIGN KEY (note_id) REFERENCES Notes(id) ON DELETE SET NULL,
  FOREIGN KEY (type_id) REFERENCES Award_Types(id) ON DELETE CASCADE
);

LOAD DATA LOCAL INFILE '/home/simonlbc/workspace/DB/DB2016/CSV/award_categories_rem.csv'
INTO TABLE Award_Categories_temp
CHARACTER SET UTF8
FIELDS TERMINATED BY '\t' ENCLOSED BY '' ESCAPED BY '\\'
LINES TERMINATED BY '\n' STARTING BY '';


CREATE TABLE Award_Categories (
  id INTEGER,
  name CHAR(255),
  type_id INTEGER,
  category_order INTEGER, 
  /* position INTEGER, TODO what is position, is this award category order?*/
  note TEXT,
  PRIMARY KEY (id, type_id),
  FOREIGN KEY (type_id) REFERENCES Award_Types(id) ON DELETE CASCADE
)
SELECT a_c.id, name, type_id, category_order, note
FROM Award_Categories_temp a_c, Notes n
WHERE note_id = n.id  
UNION
SELECT id, name, type_id, category_order, NULL 
FROM Award_Categories_temp 
WHERE note_id = NULL
;




CREATE TABLE Awards_temp (
  id INTEGER,
  title CHAR(255),
  aw_date DATE,
  type_id INTEGER,
  category_id INTEGER,
  note_id INTEGER,
  PRIMARY KEY (id),
  FOREIGN KEY (note_id) REFERENCES Notes(id) ON DELETE SET NULL,
  FOREIGN KEY (category_id) REFERENCES Award_Categories(id) ON DELETE SET NULL,
  FOREIGN KEY (type_id) REFERENCES Award_Types(id) ON DELETE SET NULL
);

LOAD DATA LOCAL INFILE '/home/simonlbc/workspace/DB/DB2016/CSV/awards_rem.csv'
INTO TABLE Awards_temp
CHARACTER SET UTF8
FIELDS TERMINATED BY '\t' ENCLOSED BY '' ESCAPED BY '\\'
LINES TERMINATED BY '\n' STARTING BY '';


CREATE TABLE Awards (
  id INTEGER,
  title CHAR(255),
  aw_date DATE,
  type_id INTEGER,
  category_id INTEGER,
  note_id TEXT,
  PRIMARY KEY (id),
  FOREIGN KEY (category_id) REFERENCES Award_Categories(id) ON DELETE SET NULL,
  FOREIGN KEY (type_id) REFERENCES Award_Types(id) ON DELETE SET NULL
)
SELECT aw.id, title, aw_date, type_id, category_id, note
FROM Awards_temp aw, Notes n
WHERE n.id = note_id 
UNION 
SELECT id, title, aw_date, type_id, category_id, NULL 
FROM Awards_temp
WHERE note_id = NULL
;


CREATE TABLE title_wins_award (
  award_id  INTEGER,
  title_id INTEGER,
  PRIMARY KEY (award_id, title_id),
  FOREIGN KEY (award_id) REFERENCES Awards(id) ON DELETE CASCADE,
  FOREIGN KEY (title_id) REFERENCES Titles(id) ON DELETE CASCADE
);

CREATE TABLE Tags (
  id INTEGER,
  name CHAR(255),
  PRIMARY KEY (id)
);

CREATE TABLE title_has_tag (
  tag_id  INTEGER,
  title_id INTEGER,
  PRIMARY KEY (tag_id, title_id),
  FOREIGN KEY (tag_id) REFERENCES Tags(id) ON DELETE CASCADE,
  FOREIGN KEY (title_id) REFERENCES Titles(id) ON DELETE CASCADE
);

CREATE TABLE Publishers_temp (
  id INTEGER,
  name CHAR(255),
  note_id INTEGER,
  PRIMARY KEY (id),
  FOREIGN KEY (note_id) REFERENCES Notes(id)  ON DELETE SET NULL
);

CREATE TABLE Publishers (
  id INTEGER,
  name CHAR(255),
  note TEXT,
  PRIMARY KEY (id)
)
SELECT pb.id, name, note
FROM Publishers_temp pb, Notes n 
WHERE n.id = pb.note_id
UNION
SELECT id, name, NULL
FROM Publishers_temp 
WHERE n.id = NULL
;


CREATE TABLE Publication_Series_temp (
  id INTEGER
  name CHAR(255),
  note_id INTEGER,
  PRIMARY KEY (id),
  FOREIGN KEY (note_id) REFERENCES Notes(id) ON DELETE SET NULL
);

CREATE TABLE Publication_Series (
  id INTEGER
  name CHAR(255),
  note TEXT,
  PRIMARY KEY (id),
)
SELECT pb_s.id, name, note
FROM Publication_Series_temp pb_s, Notes n
WHERE pb_s.note_id = n.id 
UNION 
SELECT id, name, NULL
FROM Publication_Series_temp 
WHERE note_id = NULL
;


CREATE TABLE Publication_is_of_Publication_Series (
  publication_id  INTEGER,
  series_id INTEGER,
  series_number INTEGER,
  PRIMARY KEY (publication_id),
  FOREIGN KEY (publication_id) REFERENCES Publications(id) ON DELETE CASCADE,
  FOREIGN KEY (series_id) REFERENCES Publication_Series(id) ON DELETE CASCADE
);

CREATE TABLE Publications_temp (
  id INTEGER,
  /* we should use a view/relationship that just describes the many to many relationship
   * and references of Titles id and Publications id, see todoFromDeliv1Feedback file(on github)
   * for more info on how to do it.
   */ 
  title CHAR(255), /*stay closer to definition of the csv file as described in todoFromDeliv1Feedback */
  pb_date DATE,
  publisher_id INTEGER,
  nb_pages INTEGER,
  packaging_type CHAR(255),
  publication_type ENUM('ANTHOLOGY', 'COLLECTION', 'MAGAZINE', 'NONFICTION',
                         'NOVEL', 'OMNIBUS', 'FANZINE', 'CHAPBOOK'),
  isbn INTEGER,
  cover_img CHAR(255),
  price DECIMAL(6, 5), /*valeurs un peu arbitraires, mais on peut imaginer qu'un livre 
			 aura pas un prix > un million dans n'importe quelle currency?*/
  currency CHAR(1),
  note_id INTEGER,
  PRIMARY KEY (id),
  FOREIGN KEY (title_id) REFERENCES Titles(id) ON DELETE CASCADE,
  FOREIGN KEY (note_id) REFERENCES Notes(id) ON DELETE SET NULL,
  FOREIGN KEY (publisher_id) REFERENCES Publishers(id) ON DELETE CASCADE
);


CREATE TABLE Publications (
  id INTEGER,
  /* we should use a view/relationship that just describes the many to many relationship
   * and references of Titles id and Publications id, see todoFromDeliv1Feedback file(on github)
   * for more info on how to do it.
   */ 
  title CHAR(255), /*stay closer to definition of the csv file as described in todoFromDeliv1Feedback */
  pb_date DATE,
  publisher_id INTEGER,
  nb_pages INTEGER,
  packaging_type CHAR(255),
  publication_type ENUM('ANTHOLOGY', 'COLLECTION', 'MAGAZINE', 'NONFICTION',
                         'NOVEL', 'OMNIBUS', 'FANZINE', 'CHAPBOOK'),
  isbn INTEGER,
  cover_img CHAR(255),
  price DECIMAL(6, 5), /*valeurs un peu arbitraires, mais on peut imaginer qu'un livre 
			 aura pas un prix > un million dans n'importe quelle currency?*/
  currency CHAR(1),
  note TEXT,
  PRIMARY KEY (id),
  FOREIGN KEY (title_id) REFERENCES Titles(id) ON DELETE CASCADE,
  FOREIGN KEY (publisher_id) REFERENCES Publishers(id) ON DELETE CASCADE
)
SELECT pb.id, title, pb_date, publisher_id, nb_pages, packaging_type, 
	publication_type, isbn, cover_img, price, currency, note
FROM Publications_temp pb, Notes n
WHERE pb.note_id = n.id
UNION
SELECT id, title, pb_date, publisher_id, nb_pages, packaging_type, 
	publication_type, isbn, cover_img, price, currency, NULL 
FROM Publications_temp 
WHERE pb.note_id = NULL
;



CREATE TABLE Title_Publications (
                title_id INTEGER,
                pub_id INTEGER,
                PRIMARY KEY (title_id, pub_id),
                FOREIGN KEY (title_id) REFERENCES Titles(id),
                FOREIGN KEY (pub_id) REFERENCES Publications(id)
        )
        SELECT t.id AS title_id, p.id AS pub_id
        FROM Publications p, Titles t
        WHERE p.title = t.title
	;

CREATE TABLE Webpages (
  id INTEGER,
  url CHAR(255),
  PRIMARY KEY (id)
);

CREATE TABLE authors_referenced_by (
  webpage_id INTEGER,
  author_id INTEGER,
  PRIMARY KEY (webpage_id, author_id),
  FOREIGN KEY (webpage_id) REFERENCES Webpages(id) ON DELETE CASCADE,
  FOREIGN KEY (webpage_id) REFERENCES Authors(id) ON DELETE CASCADE
);

CREATE TABLE publishers_referenced_by (
  webpage_id INTEGER,
  publisher_id INTEGER,
  PRIMARY KEY (webpage_id, publisher_id),
  FOREIGN KEY (webpage_id) REFERENCES Webpages(id) ON DELETE CASCADE,
  FOREIGN KEY (publisher_id) REFERENCES Publishers(id) ON DELETE CASCADE
);

CREATE TABLE titles_referenced_by (
  webpage_id INTEGER,
  title_id INTEGER,
  PRIMARY KEY (webpage_id, title_id),
  FOREIGN KEY (webpage_id) REFERENCES Webpages(id) ON DELETE CASCADE,
  FOREIGN KEY (title_id) REFERENCES Titles(id) ON DELETE CASCADE
);

CREATE TABLE title_series_referenced_by (
  webpage_id INTEGER,
  title_series_id INTEGER,
  PRIMARY KEY (webpage_id, title_series_id),
  FOREIGN KEY (webpage_id) REFERENCES Webpages(id) ON DELETE CASCADE,
  FOREIGN KEY (title_series_id) REFERENCES Title_Series(id) ON DELETE CASCADE
);

CREATE TABLE publication_series_referenced_by (
  webpage_id INTEGER,
  publication_series_id INTEGER,
  PRIMARY KEY (webpage_id, publication_series_id),
  FOREIGN KEY (webpage_id) REFERENCES Webpages(id) ON DELETE CASCADE,
  FOREIGN KEY (publication_series_id) REFERENCES Publications_Series(id) ON DELETE CASCADE
);

CREATE TABLE award_types_referenced_by (
  webpage_id INTEGER,
  award_type_id INTEGER,
  PRIMARY KEY (webpage_id, award_type_id),
  FOREIGN KEY (webpage_id) REFERENCES Webpages(id) ON DELETE CASCADE,
  FOREIGN KEY (award_type_id) REFERENCES Award_Types(id) ON DELETE CASCADE
);

CREATE TABLE award_categories_referenced_by (
  webpage_id INTEGER,
  award_category_id INTEGER,
  PRIMARY KEY (webpage_id, award_category_id),
  FOREIGN KEY (webpage_id) REFERENCES Webpages(id) ON DELETE CASCADE,
  FOREIGN KEY (award_category_id) REFERENCES Award_Categories(id) ON DELETE CASCADE
);
