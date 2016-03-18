/* DB-PROJECT: DELIVRABLE1
  - Not null ? Constraints ? Cycles ?
  - FOREIGN KEYs: reciproques ? (i.e. in ENTITY iff in RELATIONSHIP)
*/

/* ENTITY, uniquely identified by its ID. */
CREATE TABLE Authors (id INTEGER,
  name CHAR(255) NOT NULL, --a été checké avec une regexp que aucun des champs n'était 
  legal_name CHAR(255),
  last_name CHAR(255),
  pseudo CHAR(255),
  birthplace CHAR(255),
  birthdate DATE,
  deathdate DATE,
  email CHAR(255),
  img_link CHAR(255),
  language_id INTEGER,
  note_id INTEGER,
  PRIMARY KEY (id)
);

/* ENTITY, uniquely identified by its ID.
    - IS A: translation ?
    - MAY BE in a SERIES-relationship with 0/1/more series_title ?
*/
CREATE TABLE Titles (id INTEGER,
  title CHAR(255),
  translator CHAR(255),
  note_id_synopsis INTEGER,
  note_id_title INTEGER,
  series_id INTEGER, --a title MAY BE part of a title_series
  series_number INTEGER,
  story_len ENUM('nv', 'ss', 'jvn', 'nvz', 'sf'), --NOT NULL ?
  type ENUM('ANTHOLOGY', 'BACKCOVERART', 'COLLECTION', 'COVERART', 'INTERIORART',
          'EDITOR', 'ESSAY', 'INTERVIEW', 'NOVEL', 'NONFICTION', 'OMNIBUS', 'POEM',
          'REVIEW', 'SERIAL', 'SHORTFICTION', 'CHAPBOOK') NOT NULL,
  parent INTEGER,  --ID of translated work. Or '0' if original work.
  language_id INTEGER,
  title_graphic BOOLEAN,
  PRIMARY KEY (id)
);

/* ENTITY, uniquely identified by its ID.
  - TODO: how to relate this entity with the rest ?

  - Titles 'in_series_with' titles ?
*/
CREATE TABLE Title_Series (id INTEGER,
  title CHAR(255),
  parent INTEGER,
  note_id INTEGER,
  PRIMARY KEY (id)
);

/* RELATIONSHIP between two titles: the review and the reviewed_one
    - Capacity constraints: 1-to-1
    - Partial Participation: no constraint
*/
CREATE TABLE Reviews (id INTEGER, --really useful ???
  title_id  INTEGER, --Constraint: title_id != review_id ?!
  review_id INTEGER, --Constraint: must have TYPE="REVIEW"
  PRIMARY KEY (id),
  FOREIGN KEY title_id REFERENCES Titles(id),
  FOREIGN KEY review_id REFERENCES Titles(id)
);

/* RELATIONSHIP between a title and 0/1/more awards
    - Capacity constraints: 1-to-many
    - Partial Participation: no constraint (a title may have no award :()
*/
CREATE TABLE Title_Awards (id INTEGER, --really useful ???
  award_id  INTEGER,
  title_id INTEGER,
  PRIMARY KEY (id),
  FOREIGN KEY (award_id) REFERENCES Awards(id),
  FOREIGN KEY (review_id) REFERENCES Titles(id)
);

/* RELATIONSHIP between a title and tags
    - Capacity constraints: 1-to-many
    - Partial Participation: no constraint
*/
CREATE TABLE Title_Tags (id INTEGER, --really useful ???
  tag_id  INTEGER,
  title_id INTEGER,
  PRIMARY KEY (id),
  FOREIGN KEY tag_id REFERENCES Tags(id),
  FOREIGN KEY title_id REFERENCES Titles(id)
);

/* ENTITY, uniquely identified by its ID. */
CREATE TABLE Publications (id INTEGER,
  title CHAR(255),
  date DATE,
  publisher_id INTEGER,
  nb_pages INTEGER,
  packaging_type CHAR(255) --ENUM ?
  publication_type ENUM('ANTHOLOGY', 'COLLECTION', 'MAGAZINE', 'NONFICTION',  /* CHECK VALUE IN ('','','') */
                         'NOVEL', 'OMNIBUS', 'FANZINE', 'CHAPBOOK'),
  isbn INTEGER, --TOCHECK: special chars '-' ?
  cover_img CHAR(255),
  price CHAR(255), /* Différentes devises... */ --> Nouveau champ 'currency' CHECK VALUE IN ('$','€', ...) ???
  note_id INTEGER,
  series_id INTEGER,
  series_number INTEGER,
  PRIMARY KEY (id)
);

/* RELATIONSHIP between 1 author with 1 publication
    - Capacity constraints: 1-to-1
    - Total Participation constraint: a publication must have an author
*/
CREATE TABLE Publication_Authors (id INTEGER,
  publication_id INTEGER,
  author_id INTEGER,
  PRIMARY KEY (id)
);

/* RELATIONSHIP between 1 title with 1 publication
    - Capacity constraints: 1-to-1
    - Total Participation constraint: a publication must have a title
*/
CREATE TABLE Publication_Content (id INTEGER,
  publication_id INTEGER,
  title_id INTEGER,
  PRIMARY KEY (id)
);

/* TODO:
    - Publication_Series and Publishers: how to relate them with the rest ?

    - Publishers 'publish' Publications ?
    - Publications 'edited_by' Publication_Series ?
*/
/* ENTITY, uniquely identified by its ID. */
CREATE TABLE Publication_Series (id INTEGER
  name CHAR(255),
  note_id INTEGER,
  PRIMARY KEY (id)
);

/* ENTITY, uniquely identified by its ID. */
CREATE TABLE Publishers (id INTEGER,
  name CHAR(255),
  note_id INTEGER
  PRIMARY KEY (id)
);


/* TODO: #YOLO */
/* ENTITY, uniquely identified by its ID. */
CREATE TABLE Awards (id INTEGER,
  title CHAR(255),
  date DATE,
  type_code CHAR(255), /**/ --> On peut récupérer le code, grâce au type_id, dans la table "Award_Types"
  type_id INTEGER,
  category_id INTEGER,
  note_id INTEGER,
  PRIMARY KEY (id)
);

/* ENTITY, uniquely identified by its ID. */
CREATE TABLE Award_Categories (id INTEGER,
  name CHAR(255),
  type_id INTEGER,
  order /** ??? **/,
  note_id INTEGER,
  PRIMARY KEY (id)
);

/* TODO:
  RELATIONSHIP between 1 award with 1 category
    - Capacity constraints: 1-to-1
    - Total Participation constraint ? an award MUST_BE of a category ?
*/
CREATE TABLE Award_is_of_Category (
  award_id INTEGER,
  category_id INTEGER,
  PRIMARY KEY (award_id, category_id),
  FOREIGN KEY (award_id) REFERENCES Awards(id),
  FOREIGN KEY (category_id) REFERENCES Award_Categories(id)
);

/* ENTITY, uniquely identified by its ID. */
CREATE TABLE Award_Types (id INTEGER,
  code CHAR(5),
  name CHAR(255),
  note_id INTEGER,
  awarded_by CHAR(1000),
  awarded_for CHAR(1000),
  short_name CHAR(255),
  is_poll BOOLEAN,
  non_genre BOOLEAN,
  PRIMARY KEY (id)
);

/* TODO:
RELATIONSHIP between 1 award with 1 type
  - Capacity constraints: 1-to-1
  - Total Participation constraint ? an award MUST_BE of one type ?
*/
CREATE TABLE Award_is_of_type (
award_id INTEGER,
type_id INTEGER,
PRIMARY KEY (award_id, type_id),
FOREIGN KEY (award_id) REFERENCES Awards(id),
FOREIGN KEY (type_id) REFERENCES Award_Types(id)
);

/*************************/

/* ENTITY, uniquely identified by its ID. */
CREATE TABLE Tags (id INTEGER,
  name CHAR(255),
  PRIMARY KEY (id)
);

/*
  ENTITY, uniquely identified by its ID.
  - TODO: how to relate this entity with the rest ?

  - In a 'translation'-RELATIONSHIP between titles ?
  - Are all of these informations really useful ?!
    -> instead of 'language_id' in other ENTITYs, directly put the 'name' of the language
*/
CREATE TABLE Languages (id INTEGER,
  name CHAR(50),
  code CHAR(4),
  script BOOLEAN, /** WHAT THE HELL IS THAT ? **/
  PRIMARY KEY (id)
);

/*
  ENTITY, uniquely identified by its ID.
  - TODO: how to relate this entity with the rest ?
*/
CREATE TABLE Webpages (id INTEGER,
  url CHAR(255),
  author_id INTEGER,
  publisher_id INTEGER,
  publication_series_id INTEGER,
  title_id INTEGER,
  award_type_id INTEGER,
  title_series_id INTEGER,
  award_categories_id INTEGER,
  PRIMARY KEY (id)
);

/* TODO:
RELATIONSHIP between 1 webpage with 1 ENTITY ?
  - Capacity constraints: 1-to-1 ?
  - Partial Participation: no constraint.
*/
CREATE TABLE Webpage_XXX (
  url CHAR(255),
  webpage_id INTEGER,
  XXX_id INTEGER,
  PRIMARY KEY (webpage_id, XXX_id)
  --FOREIGN KEY (webpage_id) REFERENCES Webpages(id)
);

/* ENTITY, uniquely identified by its ID. */
CREATE TABLE Notes (id INTEGER,
  note TEXT, --TEXT ??
  PRIMARY KEY (id)
);


/** Actually do : NO FOREIGN KEY AT THE MOMENT */
/** Add foreign key later, with : **/
ALTER TABLE Title_Awards
ADD CONSTRAINT fk_PerOrders??? FOREIGN KEY (award_id) REFERENCES Awards(id)
ON DELETE SET NULL
