/** SEE ALL DETAILS WITH ASSISTANTS : **/
/** Not null ? Constraints ? Cycles ? **/

CREATE TABLE Authors (
  id            INT PRIMARY KEY AUTO_INCREMENT,
  name          VARCHAR(255),
  legal_name    VARCHAR(255),
  last_name     VARCHAR(255),
  pseudo        VARCHAR(255),
  birthplace    VARCHAR(255),
  birthdate     DATE,
  deathdate     DATE,
  email         VARCHAR(255),
  image         VARCHAR(255), /* Lien vers une note ?? --> Non, en brute dans la table */
  language_id   INT FOREIGN KEY REFERENCES Languages(id)
);

CREATE TABLE Titles (
  id            INT PRIMARY KEY AUTO_INCREMENT
  title         VARCHAR(255),
  translator    VARCHAR(255),
  synopsis      INT FOREIGN KEY REFERENCES Notes(id), /* Lien vers une note */
  note_id       INT FOREIGN KEY REFERENCES Notes(id), /* PAS UN PROBLEME ??? */
  series_id     INT FOREIGN KEY REFERENCES Title_Series(id),
  series_number INT,
  story_length  ENUM('nv', 'ss', 'jvn', 'nvz', 'sf'),
  type          ENUM('ANTHOLOGY', 'BACKCOVERART', 'COLLECTION', 'COVERART', 'INTERIORART',
                     'EDITOR', 'ESSAY', 'INTERVIEW', 'NOVEL', 'NONFICTION', 'OMNIBUS', 'POEM',
                     'REVIEW', 'SERIAL', 'SHORTFICTION', 'CHAPBOOK') NOT NULL,
  parent        INT FOREIGN KEY REFERENCES Titles(id),  /* ID of translated work. Or '0' if original work. */
  language_id   INT FOREIGN KEY REFERENCES Languages(id),
  graphic       BOOLEAN
);

CREATE TABLE Title_Series (
  id        INT PRIMARY KEY AUTO_INCREMENT,
  title     VARCHAR(255),
  parent    INT FOREIGN KEY REFERENCES Title_Series(id),
  note_id   INT FOREIGN KEY REFERENCES Notes(id),
);

/* RELATION */
CREATE TABLE Reviews (
  id        INT PRIMARY KEY AUTO_INCREMENT,
  title_id  INT FOREIGN KEY REFERENCES Titles(id),
  review_id INT FOREIGN KEY REFERENCES Titles(id)  --> Un Title qui a le type (enum) "REVIEW"
);

/* RELATION */
CREATE TABLE Title_Awards (
  id        INT PRIMARY KEY AUTO_INCREMENT,
  title_id  INT FOREIGN KEY REFERENCES Titles(id),
  award_id  INT FOREIGN KEY REFERENCES Awards(id)
);

/* REALATION */
CREATE TABLE Title_Tags (
  /* id        INT PRIMARY KEY AUTO_INCREMENT, */
  title_id  INT FOREIGN KEY REFERENCES Titles(id),
  tag_id    INT FOREIGN KEY REFERENCES Tags(id),
  CONSTRAINT pk_title_tags PRIMARY KEY(title_id, tag_id)
);

CREATE TABLE Publications (
  id                INT PRIMARY KEY AUTO_INCREMENT,
  title             VARCHAR(255),
  date              DATE,
  publisher_id      INT FOREIGN KEY REFERENCES Publishers(id),
  nb_pages          INT,
  packaging_type    ENUM??? VARCHAR(255),
  publication_type  ENUM('ANTHOLOGY', 'COLLECTION', 'MAGAZINE', 'NONFICTION',   /* CHECK VALUE IN ('','','') */
                         'NOVEL', 'OMNIBUS', 'FANZINE', 'CHAPBOOK'),
  isbn              INT,
  cover_image       VARCHAR(255),
  price             /** Différentes devises... */ --> Nouveau champ 'currency' CHECK VALUE IN ('$','€', ...) ???
  note_id           INT FOREIGN KEY REFERENCES Notes(id),
  series_id         INT FOREIGN KEY REFERENCES Publication_Series(id),
  series_number     INT
);

/* RELATION */
CREATE TABLE Publication_Authors (
  id              INT PRIMARY KEY AUTO_INCREMENT,
  publication_id  INT FOREIGN KEY REFERENCES Publications(id),
  author_id       INT FOREIGN KEY REFERENCES Authors(id)
);

/* RELATION */
CREATE TABLE Publication_Content (
  id              INT PRIMARY KEY AUTO_INCREMENT,
  publication_id  INT FOREIGN KEY REFERENCES Publications(id),
  title_id        INT FOREIGN KEY REFERENCES Titles(id)
);

CREATE TABLE Publication_Series (
  id       INT PRIMARY KEY AUTO_INCREMENT,
  name     VARCHAR(255),
  note_id  INT FOREIGN KEY REFERENCES Notes(id)
);

CREATE TABLE Publishers (
  id       INT PRIMARY KEY AUTO_INCREMENT,
  name     VARCHAR(255),
  note_id  INT FOREIGN KEY REFERENCES Notes(id)
);


/** EN CONSTRUCTION : **/

CREATE TABLE Awards (
  id            INT PRIMARY KEY AUTO_INCREMENT,
  title         VARCHAR(255),
  date          DATE
  type_code     /**/ --> On peut récupérer le code, grâce au type_id, dans la table "Award_Types"
  type_id       INT FOREIGN KEY REFERENCES Award_Types(id), --> Déjà un "type_id" dans "Award_Categories" :/
  category_id   INT FOREIGN KEY REFERENCES Award_Categories(id),
  note_id       INT FOREIGN KEY REFERENCES Notes(id)
);

CREATE TABLE Award_Categories (
  id        INT PRIMARY KEY AUTO_INCREMENT,
  name      VARCHAR(255),
  type_id   INT FOREIGN KEY REFERENCES Award_Types(id),
  order     /** ??? **/,
  note_id   INT FOREIGN KEY REFERENCES Notes(id)
);

CREATE TABLE Award_Types (
  id            INT PRIMARY KEY AUTO_INCREMENT,
  code          VARCHAR(5),
  name          VARCHAR(255),
  note_id       INT FOREIGN KEY REFERENCES Notes(id),
  awarded_by    VARCHAR(1000),
  awarded_for   VARCHAR(1000),
  short_name    VARCHAR(255),
  is_poll       BOOLEAN,
  non_genre     BOOLEAN
);

/*************************/



CREATE TABLE Tags (
  id    INT PRIMARY KEY AUTO_INCREMENT,
  name  VARCHAR(255),
);

CREATE TABLE Languages (
  id      INT PRIMARY KEY AUTO_INCREMENT,
  name    VARCHAR(50),
  code    VARCHAR(4),
  script  BOOLEAN, /** WHAT THE HELL IS THAT ? **/
);

/** Il faudrait voir comment sont référencé les webpages pour les authors, etc... **/
/* CREATE TABLE Webpages (
  id
  author_id
); */

CREATE TABLE Webpage_Authors (
  id          INT PRIMARY KEY AUTO_INCREMENT,
  url         VARCHAR(255),
  author_id   INT FOREIGN KEY REFERENCES Authors(id)
);

CREATE TABLE Webpage_Publishers (
  id            INT PRIMARY KEY AUTO_INCREMENT,
  url           VARCHAR(255),
  publisher_id  INT FOREIGN KEY REFERENCES Publishers(id)
);

CREATE TABLE Webpage_Publication_Series (
  id                      INT PRIMARY KEY AUTO_INCREMENT,
  url                     VARCHAR(255),
  publication_series_id   INT FOREIGN KEY REFERENCES Publication_Series(id)
);

CREATE TABLE Webpage_Titles (
  id         INT PRIMARY KEY AUTO_INCREMENT,
  url        VARCHAR(255),
  title_id   INT FOREIGN KEY REFERENCES Titles(id)
);

CREATE TABLE Webpage_Title_Series (
  id               INT PRIMARY KEY AUTO_INCREMENT,
  url              VARCHAR(255),
  title_series_id  INT FOREIGN KEY REFERENCES Authors(id)
);

CREATE TABLE Webpage_Award_Types (
  id             INT PRIMARY KEY AUTO_INCREMENT,
  url            VARCHAR(255),
  award_type_id  INT FOREIGN KEY REFERENCES Award_Types(id)
);

CREATE TABLE Webpage_Award_Categories (
  id                 INT PRIMARY KEY AUTO_INCREMENT,
  url                VARCHAR(255),
  award_category_id  INT FOREIGN KEY REFERENCES Award_Categories(id)
);


CREATE TABLE Notes (
  id    INT PRIMARY KEY AUTO_INCREMENT,
  note  TEXT
);


/** Actually do : NO FOREIGN KEY AT THE MOMENT */
/** Add foreign key later, with : **/
ALTER TABLE Title_Awards
ADD CONSTRAINT fk_PerOrders??? FOREIGN KEY (award_id) REFERENCES Awards(id)
ON DELETE SET NULL
