import Database as DB

if __name__ == "__main__":

    db = DB.Database('db4free.net', 'group8', 'toto123', 'cs322')

    sql = 'SELECT * FROM Languages;'
    result = db.query(sql)

    for r in result:
        print str(r['id']) + ' --> ' + r['name']
