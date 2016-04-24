package main.scala
import scala.util.parsing.combinator.Parsers
import scala.util.parsing.combinator.RegexParsers
import scala.util.matching.Regex

import java.io.File
import java.io.FileInputStream
import java.io.InputStreamReader
import java.io.BufferedReader
import java.io.InputStream
import java.util.Scanner

import java.nio.charset.StandardCharsets

import java.io.PrintStream

import java.io.FileOutputStream
import java.io.OutputStreamWriter
import Parsers.AuthorParser
//import parser.TildeToList._

trait PrintUtils {
	def printToFile(f: java.io.File)(op: java.io.PrintWriter => Unit) {
		val p = new java.io.PrintWriter(new OutputStreamWriter(new FileOutputStream(f), StandardCharsets.ISO_8859_1))
		try { op(p) } finally { p.close() }
	}
}

trait  ExprsParsers extends RegexParsers {
	 val value = 3
   lazy val mult: Parser[Int] = 
  		 "(" ~> mult <~ ")" ^^ { _ * value }  |||
  		 "()" ^^ { _ => value }
  
   lazy val plus: Parser[Int] = 
  	 (mult <~ "+") ~ plus ^^ { case m ~ p => m + p } ||| 
  	 mult
}

object MainObj extends AuthorParser with PrintUtils {

	def main(args: Array[String]): Unit = {
		parse("/home/simonlbc/workspace/DB/CSV/authors.csv", authorParser)	
	}
	
	def parse[T](csvFilePath: String, parser: Parser[T]) {
		val f = new File(csvFilePath)
		
		val in = new BufferedReader(new InputStreamReader(new FileInputStream(f), StandardCharsets.ISO_8859_1))
		val outFile = new File(f.getParent + "/" + f.getName.split("\\.")(0) + "_output.txt" )
		var nbFails: Int = 0;
		printToFile(outFile) {
			p =>

				def lines: Stream[Option[String]] = Option(in.readLine()) #:: lines
				lines.takeWhile(_.isDefined).flatten.foreach { s =>
					parseAll(parser, s) match {
						case f: Failure => p.println(f); nbFails+=1;
						case _ =>
					}
				}

				in.close()
				println(s"""$csvFilePath : number of parse failures: $nbFails""")
				println("done")

		}
	}
}


class AwardCategoriesParser {

}

class AwardsParser {

}

class AwardTypesParser {

}

class LanguagesParser {

}

class NotesParser {

}

class PublicationsAuthorsParser {

}

class PublicationsContentsParser {

}

class PublicationsParser {

}

class PublicationsSeriesParser {

}

class PublishersParser {

}

class ReviewsParser {

}

class TagsParser {
}

class TitlesAwardsParser {

}

class TitlesParser {

}

class TitlesSeriesParser {

}

class TitlesTagParser {

}

class WebpagesParser {

}