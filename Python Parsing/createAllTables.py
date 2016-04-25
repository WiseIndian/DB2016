#!/usr/bin/env python
# coding=utf-8

#################################################################
### Create all the 28 needed SQL Tables for the Book Database ###
#################################################################

import MySQLdb


def createTable(createTableQuerry):
    try:
        cursor.execute(createTableQuerry)
        db.commit()
    except:
        db.rollback()


def createAllTables():

    notes = '''
    CREATE TABLE Notes (
    id INTEGER,
    note TEXT NOT NULL,
    PRIMARY KEY (id)
    ); '''
    createTable(notes)

    languages = '''
    CREATE TABLE Languages (
    id INTEGER,
    name CHAR(32),
    code CHAR(4),
    script BOOLEAN,
    PRIMARY KEY (id)
    ); '''
    createTable(languages)

    authors = '''
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
    ); '''
    createTable(authors)

    synopsis = '''
    CREATE TABLE Synopsis (
    id INTEGER,
    synopsis TEXT NOT NULL,
    PRIMARY KEY (id)
    ); '''
    createTable(synopsis)

    title_series = '''
    CREATE TABLE Title_Series (
    id INTEGER,
    title CHAR(255) NOT NULL,
    parent INTEGER,
    note_id INTEGER,
    PRIMARY KEY (id),
    FOREIGN KEY (note_id) REFERENCES Notes(id) ON DELETE SET NULL
    ); '''
    createTable(title_series)

    titles = '''
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
    ); '''
    createTable(titles)

    author_writes_title = '''
    CREATE TABLE author_writes_title (
    author_id  INTEGER,
    title_id INTEGER,
    PRIMARY KEY (author_id, title_id),
    FOREIGN KEY (author_id) REFERENCES Authors(id) ON DELETE CASCADE,
    FOREIGN KEY (title_id) REFERENCES Titles(id) ON DELETE CASCADE
    ); '''
    createTable(author_writes_title)

    title_is_reviewed_by = '''
    CREATE TABLE title_is_reviewed_by (
    title_id  INTEGER,
    review_title_id INTEGER,
    PRIMARY KEY (title_id, review_title_id),
    FOREIGN KEY (title_id) REFERENCES Titles(id) ON DELETE CASCADE,
    FOREIGN KEY (review_title_id) REFERENCES Titles(id) ON DELETE CASCADE,
    CONSTRAINT CK_rule CHECK (title_id != review_title_id)
    ); '''
    createTable(title_is_reviewed_by)

    title_is_part_of_Title_Series = '''
    CREATE TABLE title_is_part_of_Title_Series (
    title_id  INTEGER,
    series_id INTEGER NOT NULL,
    series_number INTEGER,
    PRIMARY KEY (title_id),
    FOREIGN KEY (title_id) REFERENCES Titles(id) ON DELETE CASCADE,
    FOREIGN KEY (series_id) REFERENCES Title_Series(id) ON DELETE CASCADE
    ); '''
    createTable(title_is_part_of_Title_Series)

    title_is_translated_in = '''
    CREATE TABLE title_is_translated_in (
    title_id  INTEGER,
    trans_title_id INTEGER,
    language_id INTEGER NOT NULL,
    translator CHAR(64),
    PRIMARY KEY (trans_title_id),
    FOREIGN KEY (title_id) REFERENCES Titles(id) ON DELETE CASCADE,
    FOREIGN KEY (trans_title_id) REFERENCES Titles(id) ON DELETE CASCADE,
    FOREIGN KEY (language_id) REFERENCES Languages(id) ON DELETE CASCADE
    ); '''
    createTable(title_is_translated_in)

    award_types = '''
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
    ); '''
    createTable(award_types)

    award_categories = '''
    CREATE TABLE Award_Categories (
    id INTEGER,
    name CHAR(255),
    position INTEGER,
    note_id INTEGER,
    PRIMARY KEY (id),
    FOREIGN KEY (note_id) REFERENCES Notes(id) ON DELETE SET NULL
    ); '''
    createTable(award_categories)

    awards = '''
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
    ); '''
    createTable(awards)

    title_can_win_award = '''
    CREATE TABLE title_can_win_award (
    award_id  INTEGER,
    title_id INTEGER,
    PRIMARY KEY (award_id, title_id),
    FOREIGN KEY (award_id) REFERENCES Awards(id) ON DELETE CASCADE,
    FOREIGN KEY (title_id) REFERENCES Titles(id) ON DELETE CASCADE
    ); '''
    createTable(title_can_win_award)

    tags = '''
    CREATE TABLE Tags (
    id INTEGER,
    name CHAR(255),
    PRIMARY KEY (id)
    ); '''
    createTable(tags)

    title_has_tag = '''
    CREATE TABLE title_has_tag (
    tag_id  INTEGER,
    title_id INTEGER,
    PRIMARY KEY (tag_id, title_id),
    FOREIGN KEY (tag_id) REFERENCES Tags(id) ON DELETE CASCADE,
    FOREIGN KEY (title_id) REFERENCES Titles(id) ON DELETE CASCADE
    ); '''
    createTable(title_has_tag)

    publishers = '''
    CREATE TABLE Publishers (
    id INTEGER,
    name CHAR(255),
    note_id INTEGER,
    PRIMARY KEY (id),
    FOREIGN KEY (note_id) REFERENCES Notes(id)  ON DELETE SET NULL
    ); '''
    createTable(publishers)

    publication_series = '''
    CREATE TABLE Publication_Series (
    id INTEGER
    name CHAR(255),
    note_id INTEGER,
    PRIMARY KEY (id),
    FOREIGN KEY (note_id) REFERENCES Notes(id) ON DELETE SET NULL
    ); '''
    createTable(publication_series)

    publication_is_of_Publication_Series = '''
    CREATE TABLE Publication_is_of_Publication_Series (
    publication_id  INTEGER,
    series_id INTEGER,
    series_number INTEGER,
    PRIMARY KEY (publication_id),
    FOREIGN KEY (publication_id) REFERENCES Publications(id) ON DELETE CASCADE,
    FOREIGN KEY (series_id) REFERENCES Publication_Series(id) ON DELETE CASCADE
    ); '''
    createTable(publication_is_of_Publication_Series)

    publications = '''
    CREATE TABLE Publications (
    id INTEGER,
    title id INTEGER,
    date DATE,
    publisher_id INTEGER,
    nb_pages INTEGER,
    packaging_type CHAR(255),
    publication_type ENUM('ANTHOLOGY', 'COLLECTION', 'MAGAZINE', 'NONFICTION',
    'NOVEL', 'OMNIBUS', 'FANZINE', 'CHAPBOOK'),
    isbn INTEGER,
    cover_img CHAR(255),
    price CHAR(255),
    currency CHAR(1),
    note_id INTEGER,
    PRIMARY KEY (id),
    FOREIGN KEY (title_id) REFERENCES Titles(id) ON DELETE CASCADE,
    FOREIGN KEY (note_id) REFERENCES Notes(id) ON DELETE SET NULL,
    FOREIGN KEY (publisher_id) REFERENCES Publishers(id) ON DELETE CASCADE,
    ); '''
    createTable(publications)

    webpages = '''
    CREATE TABLE Webpages (
    id INTEGER,
    url CHAR(255),
    PRIMARY KEY (id)
    ); '''
    createTable(webpages)

    authors_referenced_by = '''
    CREATE TABLE authors_referenced_by (
    webpage_id INTEGER,
    author_id INTEGER,
    PRIMARY KEY (webpage_id, author_id),
    FOREIGN KEY (webpage_id) REFERENCES Webpages(id) ON DELETE CASCADE,
    FOREIGN KEY (webpage_id) REFERENCES Authors(id) ON DELETE CASCADE
    ); '''
    createTable(authors_referenced_by)

    publishers_referenced_by = '''
    CREATE TABLE publishers_referenced_by (
    webpage_id INTEGER,
    publisher_id INTEGER,
    PRIMARY KEY (webpage_id, publisher_id),
    FOREIGN KEY (webpage_id) REFERENCES Webpages(id) ON DELETE CASCADE,
    FOREIGN KEY (publisher_id) REFERENCES Publishers(id) ON DELETE CASCADE
    ); '''
    createTable(publishers_referenced_by)

    titles_referenced_by = '''
    CREATE TABLE titles_referenced_by (
    webpage_id INTEGER,
    title_id INTEGER,
    PRIMARY KEY (webpage_id, title_id),
    FOREIGN KEY (webpage_id) REFERENCES Webpages(id) ON DELETE CASCADE,
    FOREIGN KEY (title_id) REFERENCES Titles(id) ON DELETE CASCADE
    ); '''
    createTable(titles_referenced_by)

    title_series_referenced_by = '''
    CREATE TABLE title_series_referenced_by (
    webpage_id INTEGER,
    title_series_id INTEGER,
    PRIMARY KEY (webpage_id, title_series_id),
    FOREIGN KEY (webpage_id) REFERENCES Webpages(id) ON DELETE CASCADE,
    FOREIGN KEY (title_series_id) REFERENCES Title_Series(id) ON DELETE CASCADE
    ); '''
    createTable(title_series_referenced_by)

    publication_series_referenced_by = '''
    CREATE TABLE publication_series_referenced_by (
    webpage_id INTEGER,
    publication_series_id INTEGER,
    PRIMARY KEY (webpage_id, publication_series_id),
    FOREIGN KEY (webpage_id) REFERENCES Webpages(id) ON DELETE CASCADE,
    FOREIGN KEY (publication_series_id) REFERENCES Publications_Series(id) ON DELETE CASCADE
    ); '''
    createTable(publication_series_referenced_by)

    award_types_referenced_by = '''
    CREATE TABLE award_types_referenced_by (
    webpage_id INTEGER,
    award_type_id INTEGER,
    PRIMARY KEY (webpage_id, award_type_id),
    FOREIGN KEY (webpage_id) REFERENCES Webpages(id) ON DELETE CASCADE,
    FOREIGN KEY (award_type_id) REFERENCES Award_Types(id) ON DELETE CASCADE
    ); '''
    createTable(award_types_referenced_by)

    award_categories_referenced_by = '''
    CREATE TABLE award_categories_referenced_by (
    webpage_id INTEGER,
    award_category_id INTEGER,
    PRIMARY KEY (webpage_id, award_category_id),
    FOREIGN KEY (webpage_id) REFERENCES Webpages(id) ON DELETE CASCADE,
    FOREIGN KEY (award_category_id) REFERENCES Award_Categories(id) ON DELETE CASCADE
    ); '''
    createTable(award_categories_referenced_by)


if __name__ == '__main__':

    db = MySQLdb.connect('db4free.net','group8','toto123', 'cs322')
    cursor = db.cursor()

    createAllTables()

    cursor.close()
    db.close()
