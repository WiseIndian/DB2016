package controllers
 

object DBConf {
  val defaultDB = "cs322"
  val baseConn = Seq("mysql", "-u", "group8", "-h", "localhost",
                       "-ptoto123", "cs322")
}

import scala.sys.process._ //for executing bash 
import play.api.mvc._
import scala.collection.JavaConversions._
class Application extends Controller {
  import PredefQueries._
  import DBConf._
  def executeQuery(query: String): Option[String] = 
    Some{ (s"""echo ${query}""" #| baseConn).!! }

  def getQueryOut(qidOpt: Option[String]) = Action { req => 
    qidOpt.map { qid => 
      idToQuery.get(qid).flatMap { executeQuery }.map { 
        queryResult => 
          Ok(views.html.redirector(queryResult))
      }.getOrElse{ BadRequest(views.html.redirector("bad request!")) }
    }.getOrElse{ 
        BadRequest(
          views.html.redirector("Provide which query you need! [a-g]2 or [a-o]3")
        ) 
    }
  }

}

object PredefQueries {

  val idToQueryExplanation: Map[String, List[String]] = 
    Map(
      "a2" -> 
        ("a)For every year, output the year and the number of publications for said year." ::
        "then we can groupby result by year and then for each set by year we count nb of elements" ::
        "in the subset, and we output that number and the year" :: Nil)
    ) 

  val idToQueryBeforeTransform: Map[String, List[String]] = 
    Map(
      "a2" -> 
         (s"""SELECT year, COUNT(*) FROM""" ::
         s"""  (SELECT id, YEAR(pb_date) AS year  FROM Publications) AS Res1""" ::
         s"""GROUP BY year;""" :: Nil)
    )
  val idToQuery = 
    idToQueryBeforeTransform.mapValues{ 
      _.foldLeft("") { case (str, h) => str + h + "\n" }
    }
    
}

