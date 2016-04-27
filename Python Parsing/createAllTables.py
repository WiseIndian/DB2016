#!/usr/bin/env python
# coding=utf-8

#################################################################
### Create all the 28 needed SQL Tables for the Book Database ###
#################################################################

import MySQLdb
import traceback


def createTable(createTableQuerry):
    try:
        cursor.execute(createTableQuerry)
        db.commit()
    except Exception:
	print(traceback.format_exc(15)) 
	print(createTableQuerry)
        db.rollback()


def createAllTables():

	notes = '''
	CREATE TABLE Notes (
	id INTEGER,
	note TEXT NOT NULL,
	PRIMARY KEY (id)
	) ENGINE=InnoDB;'''
	createTable(notes)

	languages = '''
	CREATE TABLE Languages (
	id INTEGER,
	name VARCHAR(32),
	code VARCHAR(10),
	script BOOLEAN,
	PRIMARY KEY (id)
	) ENGINE=InnoDB;'''
	createTable(languages)

	authorsTemp = '''
	CREATE TABLE Authors_temp (
	id INTEGER,
	name VARCHAR(64),
	legal_name VARCHAR(255),
	last_name VARCHAR(64),
	pseudo VARCHAR(64),
	birthplace VARCHAR(255),
	birthdate DATE,
	deathdate DATE,
	email VARCHAR(255),
	img_link VARCHAR(255),
	language_id INTEGER,
	note_id INTEGER,
	PRIMARY KEY (id),
	FOREIGN KEY (note_id) REFERENCES Notes(id) ON DELETE SET NULL,
	FOREIGN KEY (language_id) REFERENCES Languages(id) ON DELETE SET NULL
	) ENGINE=InnoDB;'''
	createTable(authorsTemp)

	authors = '''
	CREATE TABLE Authors (
	id INTEGER,
	name VARCHAR(64),
	legal_name VARCHAR(255),
	last_name VARCHAR(64),
	pseudo VARCHAR(64),
	birthplace VARCHAR(255),
	birthdate DATE,
	deathdate DATE,
	email VARCHAR(255),
	img_link VARCHAR(255),
	language_id INTEGER,
	note TEXT,
	PRIMARY KEY (id),
	FOREIGN KEY (language_id) REFERENCES Languages(id) ON DELETE SET NULL
	) ENGINE=InnoDB;'''
	createTable(authors)

	title_series_temp ='''
	CREATE TABLE Title_Series_temp (
	id INTEGER,
	title VARCHAR(255) NOT NULL,
	parent INTEGER,
	note_id INTEGER,
	PRIMARY KEY (id),
	FOREIGN KEY (note_id) REFERENCES Notes(id) ON DELETE SET NULL
	) ENGINE=InnoDB;'''
	createTable(title_series_temp)


	title_series='''
	CREATE TABLE Title_Series (
	id INTEGER,
	title VARCHAR(255) NOT NULL,
	parent INTEGER,
	note TEXT,
	PRIMARY KEY (id)
	) ENGINE=InnoDB;'''
	createTable(title_series)

	titles_temp ='''
	CREATE TABLE Titles_temp (
	  id INTEGER,
	  title VARCHAR(255) NOT NULL,
	  title_translator VARCHAR(64),
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
	) ENGINE=InnoDB;'''
	createTable(titles_temp)



	titles = '''
	CREATE TABLE Titles (
	  id INTEGER,
	  title VARCHAR(255) NOT NULL,
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
	) ENGINE=InnoDB;'''
	createTable(titles)

	title_is_translated_in = '''
	CREATE TABLE title_is_translated_in (
	  title_id  INTEGER,
	  trans_title_id INTEGER,
	  language_id INTEGER NOT NULL,
	  translator VARCHAR(64),
	  PRIMARY KEY (trans_title_id),
	  FOREIGN KEY (title_id) REFERENCES Titles(id) ON DELETE CASCADE,
	  FOREIGN KEY (trans_title_id) REFERENCES Titles(id) ON DELETE CASCADE,
	  FOREIGN KEY (language_id) REFERENCES Languages(id) ON DELETE CASCADE
	) ENGINE=InnoDB;'''
	createTable(title_is_translated_in);


	title_is_reviewed_by = '''
	CREATE TABLE title_is_reviewed_by (
	title_id  INTEGER,
	review_title_id INTEGER,
	PRIMARY KEY (title_id, review_title_id),
	FOREIGN KEY (title_id) REFERENCES Titles(id) ON DELETE CASCADE,
	FOREIGN KEY (review_title_id) REFERENCES Titles(id) ON DELETE CASCADE,
	CHECK (title_id != review_title_id)
	) ENGINE=InnoDB;'''
	createTable(title_is_reviewed_by)

	title_is_part_of_Title_Series = '''
	CREATE TABLE title_is_part_of_Title_Series (
	title_id  INTEGER,
	series_id INTEGER NOT NULL,
	series_number INTEGER,
	PRIMARY KEY (title_id),
	FOREIGN KEY (title_id) REFERENCES Titles(id) ON DELETE CASCADE,
	FOREIGN KEY (series_id) REFERENCES Title_Series(id) ON DELETE CASCADE
	) ENGINE=InnoDB;'''
	createTable(title_is_part_of_Title_Series)


	award_types_temp = '''
	CREATE TABLE Award_Types_temp (
	  id INTEGER,
	  code VARCHAR(5),
	  name VARCHAR(255),
	  note_id INTEGER,
	  awarded_by VARCHAR(255),
	  awarded_for VARCHAR(255),
	  short_name VARCHAR(255),
	  is_poll BOOLEAN,
	  non_genre BOOLEAN,
	  PRIMARY KEY (id),
	  FOREIGN KEY (note_id) REFERENCES Notes(id) ON DELETE SET NULL,
	  CHECK (name IS NOT NULL OR code IS NOT NULL)
	) ENGINE=InnoDB;'''
	createTable(award_types_temp)

	award_types = '''
	CREATE TABLE Award_Types (
	  id INTEGER,
	  code VARCHAR(5),
	  name VARCHAR(255),
	  note TEXT,
	  awarded_by VARCHAR(255),
	  awarded_for VARCHAR(255),
	  short_name VARCHAR(255),
	  is_poll BOOLEAN,
	  non_genre BOOLEAN,
	  PRIMARY KEY (id),
	  CHECK (name IS NOT NULL OR code IS NOT NULL)
	) ENGINE=InnoDB;'''
	createTable(award_types)

	award_categories_temp = '''
	CREATE TABLE Award_Categories_temp (
	  id INTEGER,
	  name VARCHAR(255),
	  type_id INTEGER,
	  category_order INTEGER,
	  note_id INTEGER,
	  PRIMARY KEY (id, type_id),
	  FOREIGN KEY (note_id) REFERENCES Notes(id) ON DELETE SET NULL,
	  FOREIGN KEY (type_id) REFERENCES Award_Types(id) ON DELETE CASCADE
	) ENGINE=InnoDB;'''
	createTable(award_categories_temp)

	award_categories = '''
	CREATE TABLE Award_Categories (
	  id INTEGER,
	  name VARCHAR(255),
	  type_id INTEGER,
	  category_order INTEGER,
	  /* position INTEGER, TODO what is position, is this award category order?*/
	  note TEXT,
	  PRIMARY KEY (id, type_id),
	  FOREIGN KEY (type_id) REFERENCES Award_Types(id) ON DELETE CASCADE
	) ENGINE=InnoDB;'''
	createTable(award_categories);


	awards_temp = '''
	CREATE TABLE Awards_temp (
	  id INTEGER,
	  title VARCHAR(255),
	  aw_date DATE,
	  type_id INTEGER,
	  category_id INTEGER,
	  note_id INTEGER,
	  PRIMARY KEY (id),
	  FOREIGN KEY (note_id) REFERENCES Notes(id) ON DELETE SET NULL,
	  FOREIGN KEY (category_id) REFERENCES Award_Categories(id) ON DELETE SET NULL,
	  FOREIGN KEY (type_id) REFERENCES Award_Types(id) ON DELETE SET NULL
	) ENGINE=InnoDB;'''
	createTable(awards_temp)

	awards = '''
	CREATE TABLE Awards (
	  id INTEGER,
	  title VARCHAR(255),
	  aw_date DATE,
	  type_id INTEGER,
	  category_id INTEGER,
	  note_id TEXT,
	  PRIMARY KEY (id),
	  FOREIGN KEY (category_id) REFERENCES Award_Categories(id) ON DELETE SET NULL,
	  FOREIGN KEY (type_id) REFERENCES Award_Types(id) ON DELETE SET NULL
	) ENGINE=InnoDB;'''
	createTable(awards)

	title_wins_award = '''
	CREATE TABLE title_wins_award (
	award_id  INTEGER,
	title_id INTEGER,
	PRIMARY KEY (award_id, title_id),
	FOREIGN KEY (award_id) REFERENCES Awards(id) ON DELETE CASCADE,
	FOREIGN KEY (title_id) REFERENCES Titles(id) ON DELETE CASCADE
	) ENGINE=InnoDB;'''
	createTable(title_wins_award)

	tags = '''
	CREATE TABLE Tags (
	id INTEGER,
	name VARCHAR(255),
	PRIMARY KEY (id)
	) ENGINE=InnoDB;'''
	createTable(tags)

	title_has_tag = '''
	CREATE TABLE title_has_tag (
	tag_id  INTEGER,
	title_id INTEGER,
	PRIMARY KEY (tag_id, title_id),
	FOREIGN KEY (tag_id) REFERENCES Tags(id) ON DELETE CASCADE,
	FOREIGN KEY (title_id) REFERENCES Titles(id) ON DELETE CASCADE
	) ENGINE=InnoDB;'''
	createTable(title_has_tag)

	publishers_temp = '''
	CREATE TABLE Publishers_temp (
	  id INTEGER,
	  name VARCHAR(255),
	  note_id INTEGER,
	  PRIMARY KEY (id),
	  FOREIGN KEY (note_id) REFERENCES Notes(id)  ON DELETE SET NULL
	) ENGINE=InnoDB;'''
	createTable(publishers_temp)

	publishers = '''
	CREATE TABLE Publishers (
	  id INTEGER,
	  name VARCHAR(255),
	  note TEXT,
	  PRIMARY KEY (id)
	) ENGINE=InnoDB;'''
	createTable(publishers)

	publication_series_temp = '''
	CREATE TABLE Publication_Series_temp (
	  id INTEGER,
	  name VARCHAR(255),
	  note_id INTEGER,
	  PRIMARY KEY (id),
	  FOREIGN KEY (note_id) REFERENCES Notes(id) ON DELETE SET NULL
	) ENGINE=InnoDB;'''
	createTable(publication_series_temp)

	publication_series = '''
	CREATE TABLE Publication_Series (
	  id INTEGER,
	  name VARCHAR(255),
	  note TEXT,
	  PRIMARY KEY (id),
	) ENGINE=InnoDB;'''
	createTable(publication_series)

	publication_is_of_Publication_Series = '''
	CREATE TABLE Publication_is_of_Publication_Series (
	publication_id  INTEGER,
	series_id INTEGER,
	series_number INTEGER,
	PRIMARY KEY (publication_id),
	FOREIGN KEY (publication_id) REFERENCES Publications(id) ON DELETE CASCADE,
	FOREIGN KEY (series_id) REFERENCES Publication_Series(id) ON DELETE CASCADE
	) ENGINE=InnoDB;'''
	createTable(publication_is_of_Publication_Series)

	publications_temp = '''
	CREATE TABLE Publications_temp (
	  id INTEGER,
	  /* we should use a view/relationship that just describes the many to many relationship
	   * and references of Titles id and Publications id, see todoFromDeliv1Feedback file(on github)
	   * for more info on how to do it.
	   */
	  title VARCHAR(255), /*stay closer to definition of the csv file as described in todoFromDeliv1Feedback */
	  pb_date DATE,
	  publisher_id INTEGER,
	  nb_pages INTEGER,
	  packaging_type VARCHAR(255),
	  publication_type ENUM('ANTHOLOGY', 'COLLECTION', 'MAGAZINE', 'NONFICTION',
				 'NOVEL', 'OMNIBUS', 'FANZINE', 'CHAPBOOK'),
	  isbn INTEGER,
	  cover_img VARCHAR(255),
	  price DECIMAL(6, 5), /*valeurs un peu arbitraires, mais on peut imaginer qu'un livre 
				 aura pas un prix > un million dans n'importe quelle currency?*/
	  currency VARCHAR(1),
	  note_id INTEGER,
	  PRIMARY KEY (id),
	  FOREIGN KEY (title_id) REFERENCES Titles(id) ON DELETE CASCADE,
	  FOREIGN KEY (note_id) REFERENCES Notes(id) ON DELETE SET NULL,
	  FOREIGN KEY (publisher_id) REFERENCES Publishers(id) ON DELETE CASCADE
	) ENGINE=InnoDB;'''
	createTable(publications_temp)

	publications = '''
	CREATE TABLE Publications (
	  id INTEGER,
	  /* we should use a view/relationship that just describes the many to many relationship
	   * and references of Titles id and Publications id, see todoFromDeliv1Feedback file(on github)
	   * for more info on how to do it.
	   */
	  title VARCHAR(255), /*stay closer to definition of the csv file as described in todoFromDeliv1Feedback */
	  pb_date DATE,
	  publisher_id INTEGER,
	  nb_pages INTEGER,
	  packaging_type VARCHAR(255),
	  publication_type ENUM('ANTHOLOGY', 'COLLECTION', 'MAGAZINE', 'NONFICTION',
				 'NOVEL', 'OMNIBUS', 'FANZINE', 'CHAPBOOK'),
	  isbn INTEGER,
	  cover_img VARCHAR(255),
	  price DECIMAL(6, 5), /*valeurs un peu arbitraires, mais on peut imaginer qu'un livre 
				 aura pas un prix > un million dans n'importe quelle currency?*/
	  currency VARCHAR(1),
	  note TEXT,
	  PRIMARY KEY (id),
	  FOREIGN KEY (title_id) REFERENCES Titles(id) ON DELETE CASCADE,
	  FOREIGN KEY (publisher_id) REFERENCES Publishers(id) ON DELETE CASCADE
	) ENGINE=InnoDB;'''
	createTable(publications)

	authors_have_publications = '''
	CREATE TABLE authors_have_publications (
	  author_id  INTEGER,
	  pub_id INTEGER,
	  PRIMARY KEY (author_id, pub_id),
	  FOREIGN KEY (author_id) REFERENCES Authors(id) ON DELETE CASCADE,
	  FOREIGN KEY (pub_id) REFERENCES Publications(id) ON DELETE CASCADE
	) ENGINE=InnoDB;'''
	createTable(authors_have_publications)

	title_publications = '''
	CREATE TABLE Title_Publications (
                title_id INTEGER,
                pub_id INTEGER,
                PRIMARY KEY (title_id, pub_id),
                FOREIGN KEY (title_id) REFERENCES Titles(id),
                FOREIGN KEY (pub_id) REFERENCES Publications(id)
        ) ENGINE=InnoDB;'''
	createTable(title_publications)

	webpages = '''
	CREATE TABLE Webpages (
	id INTEGER,
	url VARCHAR(255),
	PRIMARY KEY (id)
	) ENGINE=InnoDB;'''
	createTable(webpages)

	authors_referenced_by = '''
	CREATE TABLE authors_referenced_by (
	webpage_id INTEGER,
	author_id INTEGER,
	PRIMARY KEY (webpage_id, author_id),
	FOREIGN KEY (webpage_id) REFERENCES Webpages(id) ON DELETE CASCADE,
	FOREIGN KEY (webpage_id) REFERENCES Authors(id) ON DELETE CASCADE
	) ENGINE=InnoDB;'''
	createTable(authors_referenced_by)

	publishers_referenced_by = '''
	CREATE TABLE publishers_referenced_by (
	webpage_id INTEGER,
	publisher_id INTEGER,
	PRIMARY KEY (webpage_id, publisher_id),
	FOREIGN KEY (webpage_id) REFERENCES Webpages(id) ON DELETE CASCADE,
	FOREIGN KEY (publisher_id) REFERENCES Publishers(id) ON DELETE CASCADE
	) ENGINE=InnoDB;'''
	createTable(publishers_referenced_by)

	titles_referenced_by = '''
	CREATE TABLE titles_referenced_by (
	webpage_id INTEGER,
	title_id INTEGER,
	PRIMARY KEY (webpage_id, title_id),
	FOREIGN KEY (webpage_id) REFERENCES Webpages(id) ON DELETE CASCADE,
	FOREIGN KEY (title_id) REFERENCES Titles(id) ON DELETE CASCADE
	) ENGINE=InnoDB;'''
	createTable(titles_referenced_by)

	title_series_referenced_by = '''
	CREATE TABLE title_series_referenced_by (
	webpage_id INTEGER,
	title_series_id INTEGER,
	PRIMARY KEY (webpage_id, title_series_id),
	FOREIGN KEY (webpage_id) REFERENCES Webpages(id) ON DELETE CASCADE,
	FOREIGN KEY (title_series_id) REFERENCES Title_Series(id) ON DELETE CASCADE
	) ENGINE=InnoDB;'''
	createTable(title_series_referenced_by)

	publication_series_referenced_by = '''
	CREATE TABLE publication_series_referenced_by (
	webpage_id INTEGER,
	publication_series_id INTEGER,
	PRIMARY KEY (webpage_id, publication_series_id),
	FOREIGN KEY (webpage_id) REFERENCES Webpages(id) ON DELETE CASCADE,
	FOREIGN KEY (publication_series_id) REFERENCES Publications_Series(id) ON DELETE CASCADE
	) ENGINE=InnoDB;'''
	createTable(publication_series_referenced_by)

	award_types_referenced_by = '''
	CREATE TABLE award_types_referenced_by (
	webpage_id INTEGER,
	award_type_id INTEGER,
	PRIMARY KEY (webpage_id, award_type_id),
	FOREIGN KEY (webpage_id) REFERENCES Webpages(id) ON DELETE CASCADE,
	FOREIGN KEY (award_type_id) REFERENCES Award_Types(id) ON DELETE CASCADE
	) ENGINE=InnoDB;'''
	createTable(award_types_referenced_by)

	award_categories_referenced_by = '''
	CREATE TABLE award_categories_referenced_by (
	webpage_id INTEGER,
	award_category_id INTEGER,
	PRIMARY KEY (webpage_id, award_category_id),
	FOREIGN KEY (webpage_id) REFERENCES Webpages(id) ON DELETE CASCADE,
	FOREIGN KEY (award_category_id) REFERENCES Award_Categories(id) ON DELETE CASCADE
	) ENGINE=InnoDB;'''
	createTable(award_categories_referenced_by)


if __name__ == '__main__':

    db = MySQLdb.connect('localhost','group8','toto123', 'cs322')
    cursor = db.cursor()

    createAllTables()

    cursor.close()
    db.close()
