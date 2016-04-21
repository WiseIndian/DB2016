/* DB-PROJECT: DELIVRABLE_1 */

CREATE TABLE Notes (
  id INTEGER,
  note TEXT NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE Languages (
  id INTEGER,
  name CHAR(32),
  code CHAR(10),
  script BOOLEAN,
  PRIMARY KEY (id)
);

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
  note_id INTEGER,
  PRIMARY KEY (id),
  FOREIGN KEY (note_id) REFERENCES Notes(id) ON DELETE SET NULL,
  FOREIGN KEY (language_id) REFERENCES Languages(id) ON DELETE SET NULL
);

CREATE TABLE Synopsis (
  id INTEGER,
  synopsis TEXT NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE Title_Series (
  id INTEGER,
  title CHAR(255) NOT NULL,
  parent INTEGER,
  note_id INTEGER,
  PRIMARY KEY (id),
  FOREIGN KEY (note_id) REFERENCES Notes(id) ON DELETE SET NULL
);

CREATE TABLE Titles (
  id INTEGER,
  title CHAR(255) NOT NULL,
  synopsis_id INTEGER,
  note_id INTEGER,
  story_len ENUM('nv', 'ss', 'jvn', 'nvz', 'sf'),
  type ENUM('ANTHOLOGY', 'BACKCOVERART', 'COLLECTION', 'COVERART', 'INTERIORART',
          'EDITOR', 'ESSAY', 'INTERVIEW', 'NOVEL', 'NONFICTION', 'OMNIBUS', 'POEM',
          'REVIEW', 'SERIAL', 'SHORTFICTION', 'CHAPBOOK'),
  parent INTEGER,
  language_id INTEGER,
  title_graphic BOOLEAN,
  PRIMARY KEY (id),
  FOREIGN KEY (synopsis_id) REFERENCES Synopsis(id) ON DELETE SET NULL,
  FOREIGN KEY (note_id) REFERENCES Notes(id) ON DELETE SET NULL,
  FOREIGN KEY (language_id) REFERENCES Languages(id) ON DELETE SET NULL
);

CREATE TABLE authors_have_publications (
  author_id  INTEGER,
  pub_id INTEGER,
  PRIMARY KEY (author_id, pub_id),
  FOREIGN KEY (author_id) REFERENCES Authors(id) ON DELETE CASCADE,
  FOREIGN KEY (pub_id) REFERENCES Publications(id) ON DELETE CASCADE
);

--TODO: modifier le schéma du ER model de manière à bien montrer que c'est
-- bien un many to many relationship(comme montré ici avec le code)
CREATE TABLE title_is_reviewed_by (
  title_id  INTEGER,
  review_title_id INTEGER,
  PRIMARY KEY (title_id, review_title_id),
  FOREIGN KEY (title_id) REFERENCES Titles(id) ON DELETE CASCADE,
  FOREIGN KEY (review_title_id) REFERENCES Titles(id) ON DELETE CASCADE,
  CONSTRAINT CK_rule CHECK (title_id != review_title_id)
);

CREATE TABLE title_is_part_of_Title_Series (
  title_id  INTEGER,
  series_id INTEGER NOT NULL,
  series_number INTEGER,
  PRIMARY KEY (title_id),
  FOREIGN KEY (title_id) REFERENCES Titles(id) ON DELETE CASCADE,
  FOREIGN KEY (series_id) REFERENCES Title_Series(id) ON DELETE CASCADE
);

CREATE TABLE title_is_translated_in (
  title_id  INTEGER,
  trans_title_id INTEGER,
  language_id INTEGER NOT NULL,
  translator CHAR(64),
  PRIMARY KEY (trans_title_id),
  FOREIGN KEY (title_id) REFERENCES Titles(id) ON DELETE CASCADE,
  FOREIGN KEY (trans_title_id) REFERENCES Titles(id) ON DELETE CASCADE,
  FOREIGN KEY (language_id) REFERENCES Languages(id) ON DELETE CASCADE

);

CREATE TABLE Award_Types (
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

CREATE TABLE Award_Categories (
  id INTEGER,
  name CHAR(255),
  type_id INTEGER,
  category_order INTEGER, 
  -- position INTEGER, TODO what is position, is this award category order?
  note_id INTEGER,
  PRIMARY KEY (id, type_id),
  FOREIGN KEY (note_id) REFERENCES Notes(id) ON DELETE SET NULL,
  FOREIGN KEY (type_id) REFERENCES Award_Types(id) ON DELETE CASCADE
);

CREATE TABLE Awards (
  id INTEGER,
  title CHAR(255),
  date DATE,
  type_id INTEGER,
  category_id INTEGER,
  note_id INTEGER,
  PRIMARY KEY (id),
  FOREIGN KEY (note_id) REFERENCES Notes(id) ON DELETE SET NULL,
  FOREIGN KEY (category_id) REFERENCES Award_Categories(id) ON DELETE SET NULL,
  FOREIGN KEY (type_id) REFERENCES Award_Types(id) ON DELETE SET NULL
);

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

CREATE TABLE Publishers (
  id INTEGER,
  name CHAR(255),
  note_id INTEGER,
  PRIMARY KEY (id),
  FOREIGN KEY (note_id) REFERENCES Notes(id)  ON DELETE SET NULL
);

CREATE TABLE Publication_Series (
  id INTEGER
  name CHAR(255),
  note_id INTEGER,
  PRIMARY KEY (id),
  FOREIGN KEY (note_id) REFERENCES Notes(id) ON DELETE SET NULL
);

CREATE TABLE Publication_is_of_Publication_Series (
  publication_id  INTEGER,
  series_id INTEGER,
  series_number INTEGER,
  PRIMARY KEY (publication_id),
  FOREIGN KEY (publication_id) REFERENCES Publications(id) ON DELETE CASCADE,
  FOREIGN KEY (series_id) REFERENCES Publication_Series(id) ON DELETE CASCADE
);

CREATE TABLE Publications (
  id INTEGER,
  /* we should use a view/relationship that just describes the many to many relationship
   * and references of Titles id and Publications id, see todoFromDeliv1Feedback file(on github)
   * for more info on how to do it.
   */ 
  title CHAR(255), --stay closer to definition of the csv file as described in todoFromDeliv1Feedback 
  date DATE,
  publisher_id INTEGER,
  nb_pages INTEGER,
  packaging_type CHAR(255),
  publication_type ENUM('ANTHOLOGY', 'COLLECTION', 'MAGAZINE', 'NONFICTION',
                         'NOVEL', 'OMNIBUS', 'FANZINE', 'CHAPBOOK'),
  isbn INTEGER,
  cover_img CHAR(255),
  price DECIMAL(6, 5), --valeurs un peu arbitraires, mais on peut imaginer qu'un livre 
			-- aura pas un prix > un million dans n'importe quelle currency?
  currency CHAR(1),
  note_id INTEGER,
  PRIMARY KEY (id),
  FOREIGN KEY (title_id) REFERENCES Titles(id) ON DELETE CASCADE,
  FOREIGN KEY (note_id) REFERENCES Notes(id) ON DELETE SET NULL,
  FOREIGN KEY (publisher_id) REFERENCES Publishers(id) ON DELETE CASCADE,
);

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
