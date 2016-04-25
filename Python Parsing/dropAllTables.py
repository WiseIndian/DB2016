#!/usr/bin/env python
# coding=utf-8

##################################################################
### Delete all the 28 SQL Tables created for the Book Database ###
##################################################################

import MySQLdb


def dropAllTables():

    sql = '''
    SET FOREIGN_KEY_CHECKS=0;
    DROP TABLE award_categories_referenced_by, award_types_referenced_by, publication_series_referenced_by, title_series_referenced_by,
               titles_referenced_by, publishers_referenced_by, authors_referenced_by, Webpages, publications, publication_is_of_Publication_Series,
               publication_series, Publishers, title_has_tag, Tags, title_can_win_award, Awards, Award_Categories, award_types,
               title_is_translated_in, title_is_part_of_Title_Series, title_is_reviewed_by, author_writes_title, Titles, Title_Series,
               Synopsis, Authors, Languages, Notes;
    SET FOREIGN_KEY_CHECKS=1;
    '''
    try:
        cursor.execute(sql)
        db.commit()
    except:
        db.rollback()


if __name__ == '__main__':

    db = MySQLdb.connect('db4free.net','group8','toto123', 'cs322')
    cursor = db.cursor()

    dropAllTables()

    cursor.close()
    db.close()
