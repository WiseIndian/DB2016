import MySQLdb

class Database:

    def __init__(self, host, user, password, db_name):

        self.host = host
        self.user = user
        self.password = password
        self.db_name = db_name

        self.connection = MySQLdb.connect(self.host, self.user, self.password, self.db_name)
        self.cursor = self.connection.cursor()

    def insert(self, query):
        try:
            self.cursor.execute(query)
            self.connection.commit()
        except MySQLdb.Error, e:
            print "MySQL Error [%d]: %s" % (e.args[0], e.args[1])
            self.connection.rollback()

    def insertMany(self, query, data):  # data is an array of tuples (to insert in database)
        try:
            self.cursor.executemany(query, data)
            self.connection.commit()
        except MySQLdb.Error, e:
            print "MySQL Error [%d]: %s" % (e.args[0], e.args[1])
            self.connection.rollback()

    def query(self, query):
        cursor = self.connection.cursor(MySQLdb.cursors.DictCursor) # Return data as a dict, whose keys are columns names in the DB
        cursor.execute(query)
        return cursor.fetchall()

    def __del__(self):
        self.cursor.close()
        self.connection.close()
