package controllers
 

object DBConf {
  val defaultDB = "cs322"
  val baseConn = Seq("mysql", "-u", "group8", "-h", "localhost",
                       "-ptoto123", "cs322")
}

class InvalidSqlInputException extends java.lang.Exception 

import scala.sys.process._ //for executing bash 
import play.api.mvc._
class Application extends Controller {
  import PredefQueries._
  import DBConf._
  import queriesInfos._

  val redirector = views.html.redirector
  val index = views.html.index

  def executeQuery(query: String): String = 
      (s"""echo ${query}""" #| baseConn).!! 

  def executeQueryWrapper(qid: String, qExpl: String, queryStrFun: String => String, 
     userExtraInpt: Option[String]): Result = 
    userExtraInpt.map { in => 
      Ok(redirector(qExpl, executeQuery(queryStrFun(in))))
    }.getOrElse { //userExtraInpt is None 
      if (!queriesWithInput.contains(qid))
        Ok(redirector(qExpl, executeQuery(queryStrFun("some bullshit"))))
      else 
        BadRequest(index(Some("provide some extra input for query "+qid)))
    } 

  def getQueryOut(qidOpt: Option[String], userExtraInpt: Option[String]) = 
    Action { req => 
      (for {
        qid <- qidOpt
        qStrFun <- idToQuery.get(qid)
        qStrExpl <- idToQueryExplanation.get(qid)
      } yield {
        try { executeQueryWrapper(qid, qStrExpl, qStrFun, userExtraInpt) }
        catch { 
          case invE: InvalidSqlInputException =>
            BadRequest(index(Some("invalid input in additional query info")))
          case e: Exception => 
            Redirect("localost:9000/", 500) //internal server error
        }
      }).getOrElse {
        BadRequest(index(Some("Provide which query you need! format: [a-g]2 or [a-o]3")))
      }
    }

}

object PredefQueries {

  val idToQueryExplanation: Map[String, String] = 
    Map(
      "a2" -> 
        ("a)For every year, output the year and the number of publications for said year.\n" +
        "then we can groupby result by year and then for each set by year we count nb of elements\n" +
        "in the subset, and we output that number and the year" ),
      "b2" -> 
        """b)Output the names of the ten authors with most publications.""" ,
      "c2" -> 
        """c)What are the names of the youngest and oldest authors to publish something in 2010?""" , 
      "d2" -> 
        ("How many comics (graphic titles) have publications with less than 50 pages, less than 100 pages, and\n" +
        """ more (or equal) than 100 pages?""" ),
      "e2" -> 
        ("For every publisher, calculate the average price of its published novels (the ones that have\n" +
         """a dollar price).""" ),
      "f2" -> 
        ("""f) What is the name of the author with the highest number of titles that are tagged as """ +
             """“science fiction”?""" ),
      "g2" -> """List the three most popular titles (i.e., the ones with the most awards and reviews)""" ,
      "a3" -> ("""Compute the average price per currency of the publications of the most popular title (i.e, the title with\n""" + 
               """most publications overall """ ),
      "b3" -> """Output the names of the top ten title series with most awards""" ,
      "c3" -> """Output the name of the author who has received the most awards after his/her death""" ,
      "d3" -> """For a given year, output the three publishers that published the most publications""" ,
      "e3" -> """Given an author, compute his/her most reviewed title(s)""" ,
      "f3" -> """For every language, find the top three title types with most translations.""" ,
      "g3" -> """For each year, compute the average number of authors per publisher.""" ,
      "h3" -> """Find the publication series with most titles that have been given awards of “World Fantasy Award”""" ,
      "i3" -> """For every award category, list the names of the three most awarded authors.""" ,
      "j3" -> "Output the names of all living authors that have published at least one anthology from youngest to oldest" ,
      "k3" -> """Compute the average number of publications per publication series (single result/number expected).""" ,
      "l3" -> "Find the author who has reviewed the most titles.",
      "m3" -> """ For every language, list the three authors with the most translated titles of “novel” type.""" ,
      "n3" -> ("Order the top ten authors whose publications have the largest pages per dollar ratio (considering all\n" +
              """publications of an author that have a dollar price).""" ),
      "o3" -> ("For publications that have been awarded the Nebula award, find the top 10 with the most extensive\n" + 
              "web presence (i.e, the highest number of author websites, publication websites, publisher websites,\n" +
              """publication series websites, and title series websites in total).""" )
    ) 

  //list of strings because of \n to insert in queries otherwise
  val idToQueryBeforeTransform: Map[String, String => List[String]] = 
    Map(
      "a2" -> (in =>   
        s"""SELECT year, COUNT(*) FROM""" ::
        s"""  (SELECT id, YEAR(pb_date) AS year  FROM Publications) AS Res1""" ::
        s"""GROUP BY year;""" :: Nil ), 

      "b2" -> (in =>  
        s"""SELECT  a.name, COUNT(*) AS nb_publications  """ ::
        """FROM Authors a, authors_have_publications pb_as """ ::
        """WHERE a.id = pb_as.author_id """ ::
        """GROUP BY a.id""" ::
        """ORDER BY nb_publications DESC""" ::
        """LIMIT 10;""" :: Nil ), 


      "c2" -> (in =>   
        s"""SELECT a.name AS "oldest author name", pb_date, a.birthdate""" ::
        """FROM Authors a, authors_have_publications pb_as, Publications pb""" ::
        """WHERE YEAR(pb_date) = 2010 AND a.id = pb_as.author_id AND pb.id = pb_as.pub_id""" ::
        """AND a.birthdate IS NOT NULL AND a.birthdate != Date(0000-00-00)""" ::
        """AND Year(a.birthdate) != Year(0000-00-00) """ ::
        """ORDER BY a.birthdate""" ::
        """LIMIT 1;""" ::
        """SELECT a.name AS "youngest author name", pb_date, a.birthdate""" ::
        """FROM Authors a, authors_have_publications pb_as, Publications pb""" ::
        """WHERE YEAR(pb_date) = 2010 AND a.id = pb_as.author_id AND pb.id = pb_as.pub_id""" ::
        """AND a.birthdate IS NOT NULL AND a.birthdate != Date(0000-00-00)""" ::
        """AND Year(a.birthdate) != Year(0000-00-00)""" ::
        """ORDER BY a.birthdate DESC""" ::
        """LIMIT 1;""" :: Nil ), 


      "d2" -> (in =>   
        s"""SELECT `less than 50 pages`, `less than 100 pages`, `more than 100 pages` FROM (""" ::
        """ (SELECT COUNT(*) AS `less than 50 pages`""" ::
        """ FROM Titles t, Titles_published_as_Publications t_p, Publications p""" ::
        """ WHERE t.id = t_p.title_id AND t_p.pub_id = p.id AND""" ::
        """ t.title_graphic = 1 AND nb_pages < 50) AS res1""" ::
        """ ,""" ::
        """ (SELECT COUNT(*) AS `less than 100 pages`""" ::
        """ FROM Titles t, Titles_published_as_Publications t_p, Publications p""" ::
        """ WHERE t.id = t_p.title_id AND t_p.pub_id = p.id AND""" ::
        """ t.title_graphic AND p.nb_pages < 100) AS res2""" ::
        """ ,""" ::
        """ (SELECT COUNT(*) AS `more than 100 pages`""" ::
        """ FROM Titles t, Titles_published_as_Publications t_p, Publications p""" ::
        """ WHERE t.id = t_p.title_id AND t_p.pub_id = p.id AND""" ::
        """ t.title_graphic = 1 AND nb_pages >= 100) AS res3""" ::
        """);""" :: Nil ), 


      "e2" -> (in =>   
        """SELECT pbsher.name AS "Publisher name", pbsher.id AS "Publisher id", """ ::
        """ AVG(pb.price) AS "Average Publisher publication price"""" ::
        """FROM Publishers pbsher, Publications pb""" ::
        """WHERE pbsher.id = pb.publisher_id AND pb.price IS NOT NULL""" ::
        """GROUP BY pbsher.id;""" :: Nil ), 


      "f2" -> (in =>   
        """SELECT * FROM (""" ::
        """ SELECT a.name, COUNT(*) AS "number of science fiction titles written" """ ::
        """ FROM Authors a, authors_have_publications ap,""" ::
        """   Titles_published_as_Publications tp, title_has_tag tt, Tags""" ::
        """ WHERE a.id = ap.author_id AND ap.pub_id = tp.pub_id AND """ ::
        """   tp.title_id = tt.title_id AND tt.tag_id = Tags.id AND """ ::
        """   Tags.name = 'science fiction'""" ::
        """ GROUP BY a.name""" ::
        """) AS r1 """ ::
        """ORDER BY `number of science fiction titles written` DESC """ ::
        """LIMIT 1;""" :: Nil ), 


      "g2" -> (in =>   
        """SELECT r1.title /*if testing the query use * instead of tr.title_id to see the popularity column*/""" ::
        """FROM (""" ::
        """ SELECT t.title AS title, (tit_rev.nb_reviews + tit_awrds.nb_awards) AS popularity""" ::
        """ FROM Titles t,""" ::
        """ (SELECT title_id, COUNT(*) AS nb_reviews""" ::
        """ FROM title_is_reviewed_by """ ::
        """ GROUP BY title_id) AS tit_rev,""" ::
        """ (SELECT title_id, COUNT(*) AS nb_awards""" ::
        """ FROM title_wins_award""" ::
        """ GROUP BY title_id) AS tit_awrds""" ::
        """ WHERE tit_rev.title_id = tit_awrds.title_id AND""" ::
        """   t.id = tit_awrds.title_id """ ::
        """ ORDER BY popularity DESC""" ::
        """ LIMIT 3""" ::
        """) AS r1;""" :: Nil ), 


      "a3" -> (in =>   
        """SELECT Avg(price) """ ::
        """FROM Publications P, """ ::
        """(SELECT pub_id AS pid""" ::
        """FROM Titles_published_as_Publications""" ::
        """WHERE title_id = (SELECT title_id FROM (""" ::
        """                        SELECT title_id, COUNT(*) AS nbPublications""" ::
        """                        FROM Titles_published_as_Publications""" ::
        """                        GROUP BY title_id""" ::
        """                        ORDER BY nbPublications DESC""" ::
        """                        LIMIT 1""" ::
        """                  ) as r1 ) """ ::
        """) as r2""" ::
        """WHERE pid = P.id  AND  currency = 'DOLLAR'/*'POUND'*/ ;""":: Nil ), 
        

      "b3" -> (in =>  
        """SELECT t_s.title, """ ::
        """ SUM(tit_awrds.nb_awards) AS popularity""" ::
        """FROM Titles t, Title_Series t_s,""" ::
        """(SELECT title_id, COUNT(*) AS nb_awards""" ::
        """FROM title_wins_award""" ::
        """GROUP BY title_id) AS tit_awrds""" ::
        """WHERE t.series_id = t_s.id AND t.id = tit_awrds.title_id""" ::
        """GROUP BY t_s.id""" ::
        """ORDER BY popularity DESC""" ::
        """LIMIT 10;""" :: Nil ), 


      "c3" -> (in =>   
        """SELECT a.name,  COUNT(*) AS nb_awards_when_dead""" ::
        """FROM Awards aw, title_wins_award t_w_a, """ ::
        """ Titles_published_as_Publications t_p, authors_have_publications a_p,""" ::
        """ Authors a""" ::
        """WHERE aw.aw_date IS NOT NULL AND a.deathdate IS NOT NULL AND""" ::
        """(""" :: 
        """ DATEDIFF(aw.aw_date, a.deathdate) > 0  OR""" ::
        """ YEAR(aw.aw_date) > YEAR(a.deathdate) OR """ ::
        """ (""" ::
        """   YEAR(aw.aw_date) >= YEAR(a.deathdate) AND""" ::
        """   MONTH(aw.aw_date) > MONTH(a.deathdate) AND """ ::
        """   MONTH(aw.aw_date) != 0 AND MONTH(a.deathdate) != 0""" ::
        """ )""" ::
        """) AND""" ::
        """aw.id = t_w_a.award_id AND t_w_a.title_id = t_p.title_id AND """ ::
        """t_p.title_id AND t_p.pub_id = a_p.pub_id AND""" ::
        """a_p.pub_id AND a_p.author_id = a.id""" ::
        """GROUP BY a.id """ ::
        """ORDER BY nb_awards_when_dead DESC""" ::
        """LIMIT 10;""" :: Nil ), 

      "d3" -> (in => { 
        if (!in.matches("[0-9]+")) 
          throw new InvalidSqlInputException
        //using prepared statement in a hope to prevent sql code injection
        """PREPARE stmtD3 FROM '""" ::
        """SELECT pbshr.name as pbshr_name, p.pb_date,""" ::
        """  COUNT(*) AS nb_publications_by_publisher""" ::
        """FROM Publications p, Publishers pbshr""" ::
        """WHERE p.publisher_id = pbshr.id AND YEAR(p.pb_date) = ?""" ::
        """GROUP BY pbshr.id""" ::
        """ORDER BY nb_publications_by_publisher DESC""" ::
        """LIMIT 3;""" ::
        """ '; """ ::
        s"""SET @date=${in};""" :: //notice "in" here
        """EXECUTE stmtD3 USING @date;""" :: Nil }), 

      "e3" -> (in =>   
        """PREPARE stmtE3 FROM '""" ::
        """SELECT t.title, COUNT(*) AS "nb of reviews"""" ::
        """FROM Titles t, Titles_published_as_Publications t_p, authors_have_publications a_p,""" ::
        """  title_is_reviewed_by t_r_b""" ::
        """WHERE a_p.author_id =""" ::
        """  (SELECT a.id""" ::
        """  FROM Authors a WHERE a.name = ?""" ::
        """  LIMIT 1) AND""" ::
        """a_p.pub_id = t_p.pub_id AND t.id = t_p.title_id AND  """ ::
        """t_p.title_id = t_r_b.title_id""" ::
        """GROUP BY a_p.pub_id""" ::
        """ORDER BY `nb of reviews` DESC""" ::
        """LIMIT 1;""" ::
        """ '; """ ::
        s"""SET @authName='${in}';""" ::
        """EXECUTE stmtE3 using @authName;""" :: Nil ), 


      "f3" -> (in =>   
          """SET @currcount = NULL, @currvalue = NULL;""" :: 
          """SELECT lname AS "language name", """ :: 
          """  tname AS "title",""" :: 
          """  nb_translations AS "number of translation of this title originally written in this language"""" :: 
          """FROM""" :: 
          """  (""" :: 
          """    SELECT """ :: 
          """      lid, tid, nb_translations, lname, tname,""" :: 
          """      @currcount := IF(@currvalue = lid, @currcount + 1, 1) AS rank,""" :: 
          """      @currvalue := lid""" :: 
          """    FROM(""" :: 
          """      SELECT""" :: 
          """        l.id AS lid, t.id AS tid,""" :: 
          """        l.name AS lname, t.title AS tname, COUNT(*) AS nb_translations""" :: 
          """      FROM Languages l, Titles t, title_is_translated_in t_i_t""" :: 
          """      WHERE l.id = t.language_id AND t.id = t_i_t.title_id """ :: 
          """      GROUP BY l.id, t.id""" :: 
          """      ORDER BY l.id, nb_translations DESC""" :: 
          """    ) AS r1""" :: 
          """  ) as r2""" :: 
          """WHERE rank <= 3""" :: Nil),

      "g3" -> (in =>  
        """SELECT years2.y, AVG(result1.authors_per_publisher)""" ::
        """FROM""" ::
        """(SELECT DISTINCT YEAR(pb_date) AS y FROM Publications ORDER BY y) AS years2,""" ::
        """(""" ::
        """ SELECT pbshr.name, COUNT(*) as authors_per_publisher, years.y as y""" ::
        """ FROM """ ::
        """ (SELECT DISTINCT YEAR(pb_date) AS y FROM Publications ORDER BY y) AS years,""" ::
        """ Publishers pbshr, Publications p, authors_have_publications a_p, Authors a""" ::
        """ WHERE pbshr.id = p.publisher_id AND p.id = a_p.pub_id AND a_p.author_id = a.id""" ::
        """ AND YEAR(p.pb_date) = years.y""" ::
        """ GROUP BY pbshr.id""" ::
        """) as result1""" ::
        """WHERE years2.y = result1.y""" ::
        """GROUP BY years2.y;""" :: Nil ), 

        "h3" -> (in => 
          """SELECT p_s.name AS "publication series name",""" ::
          """    COUNT(*) AS "number of titles of the publication serie awarded the world fantasy award"""" ::
          """FROM Publication_Series p_s, Publications p, Titles_published_as_Publications t_p, """ ::
          """     Titles t, title_wins_award t_w_a, Awards aw, Award_Types a_t""" ::
          """WHERE p_s.id = p.publication_series_id AND p.id = t_p.pub_id AND """ ::
          """    t_p.title_id = t.id AND t.id = t_w_a.title_id AND t_w_a.award_id = aw.id AND""" ::
          """    aw.type_id = a_t.id AND a_t.name = 'World Fantasy Award'""" ::
          """GROUP BY p_s.id""" ::
          """ORDER BY `number of titles of the publication serie awarded the world fantasy award` DESC""" ::
          """LIMIT 1;""" :: Nil), 

        "i3" -> (in => 
          """SET @currcount = NULL, @currvalue = NULL, @str = NULL;""" ::
          """SELECT r.aname, r.a_c_name, r.nb_awards_for_author  FROM (""" ::
          """  SELECT a.name AS aname, a_c.name AS a_c_name, a_c.id AS a_c_id,""" ::
          """       COUNT(*) AS nb_awards_for_author,""" ::
          """       @currcount := IF(@currvalue = a_c.id, @currcount + 1, 1) AS rank,""" ::
          """       @currvalue := a_c.id""" ::
          """  FROM Award_Categories a_c, Awards aw, title_wins_award t_w_a,""" ::
          """    Titles_published_as_Publications t_p, authors_have_publications a_h_p, Authors a""" ::
          """  WHERE a_c.id = aw.category_id AND aw.id = t_w_a.award_id AND""" ::
          """    t_w_a.title_id = t_p.title_id AND t_p.pub_id = a_h_p.pub_id AND""" ::
          """    a_h_p.author_id = a.id""" ::
          """  GROUP BY a_c.id, a.id""" ::
          """  ORDER BY a_c.id, nb_awards_for_author DESC""" ::
          """  ) AS r""" ::
          """WHERE r.rank <= 3;""" :: Nil),


      "j3" -> (in =>   
        """SELECT a.id, a.name, a.birthdate, COUNT(a_p.pub_id) AS nb_published_anthologies""" ::
        """FROM Authors a, authors_have_publications a_p,""" ::
        """Titles_published_as_Publications t_p, Titles t""" ::
        """WHERE a.deathdate IS NULL AND a.birthdate IS NOT NULL AND """ ::
        """DATEDIFF(CURDATE(), a.birthdate) / 365 < 100  AND""" ::
        """a.id = a_p.author_id AND a_p.pub_id IS NOT NULL AND""" ::
        """a_p.pub_id = t_p.pub_id AND t_p.title_id = t.id AND """ ::
        """t.title_type = 'ANTHOLOGY'""" ::
        """GROUP BY a.id""" ::
        """HAVING nb_published_anthologies > 0""" ::
        """ORDER BY a.birthdate DESC, nb_published_anthologies;""" :: Nil ), 


      "k3" -> (in =>   
        """SELECT AVG(nb_publications_for_this_serie) AS "average number of publications per serie"""" ::
        """FROM (""" ::
        """ SELECT p.title, COUNT(p.id) AS nb_publications_for_this_serie""" ::
        """ FROM Publication_Series ps, Publications p""" ::
        """ WHERE p.publication_series_id = ps.id AND """ ::
        """ ps.name IS NOT NULL AND p.title IS NOT NULL""" ::
        """ GROUP BY ps.id""" ::
        """) AS r1;""" :: Nil ), 


      "l3" -> (in =>   
        """SELECT a.name, COUNT(t_w_b.review_title_id) AS "number of reviews written"""" ::
        """FROM title_is_reviewed_by t_w_b, Titles_published_as_Publications t_p,""" ::
        """authors_have_publications a_p, Authors a""" ::
        """WHERE t_w_b.review_title_id = t_p.title_id AND t_p.pub_id AND""" ::
        """t_p.pub_id = a_p.pub_id AND a_p.author_id = a.id  """ ::
        """GROUP BY a.id""" ::
        """ORDER BY `number of reviews written` DESC """ ::
        """LIMIT 1;""" :: Nil ), 


      "n3" -> (in =>   
        """SELECT a.name, a.id, AVG(p.nb_pages / p.price) AS "pages per dollar ratio"""" ::
        """FROM Publications p, authors_have_publications a_p, Authors a""" ::
        """WHERE p.id = a_p.pub_id AND a_p.author_id = a.id AND p.currency = 'DOLLAR'""" ::
        """GROUP BY a.id""" ::
        """ORDER BY `pages per dollar ratio` DESC""" ::
        """LIMIT 10;""" :: Nil ), 


      "o3" -> (in =>   
        """SELECT pid AS "publication ID", """ ::
        """ (SELECT p.title FROM Publications p WHERE p.id = pid) AS "publication name",""" ::
        """SUM(inner_sum) as tot_refs""" ::
        """FROM (""" ::
        """ (SELECT p.id AS pid, COUNT(*) as inner_sum""" ::
        """ FROM Publications p, authors_have_publications a_p, authors_referenced_by a_r_b""" ::
        """ WHERE p.id = a_p.pub_id AND  a_p.author_id = a_r_b.author_id""" ::
        """ GROUP BY p.id) """ ::
        """ UNION""" ::
        """ (SELECT p.id AS pid, COUNT(*) as inner_sum""" ::
        """ FROM Publications p, Titles_published_as_Publications t_p, title_wins_award t_w_a,""" ::
        """   Awards aw, award_categories_referenced_by a_c_r""" ::
        """ WHERE p.id = t_p.pub_id AND t_p.title_id = t_w_a.title_id AND """ ::
        """   t_w_a.award_id = aw.id AND aw.category_id = a_c_r.award_category_id""" ::
        """ GROUP BY p.id)""" ::
        """ UNION""" ::
        """ (SELECT p.id AS pid, COUNT(*) as inner_sum""" ::
        """ FROM Publications p, Titles_published_as_Publications t_p, title_wins_award t_w_a,""" ::
        """   Awards aw, award_types_referenced_by a_t_r""" ::
        """ WHERE p.id = t_p.pub_id AND t_p.title_id = t_w_a.title_id AND""" ::
        """   t_w_a.award_id = aw.id AND aw.type_id = a_t_r.award_type_id""" ::
        """ GROUP BY p.id)""" ::
        """ UNION""" ::
        """ (SELECT p.id AS pid, COUNT(*) as inner_sum""" ::
        """ FROM Publications p, Publication_Series p_s, publication_series_referenced_by p_s_r""" ::
        """ WHERE p.publication_series_id = p_s.id AND p_s.id = p_s_r.publication_series_id""" ::
        """ GROUP BY p.id)""" ::
        """ UNION""" ::
        """ (SELECT p.id AS pid, COUNT(*) as inner_sum""" ::
        """ FROM Publications p, publishers_referenced_by p_r""" ::
        """ WHERE p.publisher_id = p_r.publisher_id""" ::
        """ GROUP BY p.id)""" ::
        """ UNION""" ::
        """ (SELECT p.id AS pid, COUNT(*) as inner_sum""" ::
        """ FROM Publications p, Titles_published_as_Publications t_p, Titles t, """ ::
        """   title_series_referenced_by t_s_r""" ::
        """ WHERE p.id = t_p.pub_id AND t_p.title_id = t.id AND """ ::
        """   t.series_id = t_s_r.title_series_id""" ::
        """ GROUP BY p.id)""" ::
        """ UNION""" ::
        """ (SELECT p.id AS pid, COUNT(*) as inner_sum""" ::
        """ FROM Publications p, Titles_published_as_Publications t_p, titles_referenced_by t_r""" ::
        """ WHERE p.id = t_p.pub_id AND t_p.title_id = t_r.title_id""" ::
        """ GROUP BY p.id)""" ::
        """) AS r,""" ::
        """Titles_published_as_Publications outter_t_p, title_wins_award outter_t_w_a, """ ::
        """ Awards outter_aw, Award_Types outter_a_t""" ::
        """WHERE r.pid = outter_t_p.pub_id AND outter_t_p.title_id = outter_t_w_a.title_id AND""" ::
        """ outter_t_w_a.award_id = outter_aw.id AND """ ::
        """ outter_aw.type_id = (SELECT id FROM Award_Types WHERE name = 'Nebula award')""" ::
        """GROUP BY pid """ ::
        """ORDER BY tot_refs DESC""" ::
        """ LIMIT 10;""" :: Nil )
    )

  val idToQuery: Map[String, String => String] = 
    idToQueryBeforeTransform.mapValues { 
      _.andThen (_.foldLeft("") { _ + _ + "\n" })
    }
    
}

