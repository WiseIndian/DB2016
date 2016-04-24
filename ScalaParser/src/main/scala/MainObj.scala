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
import Parsers.Notes
//import parser.TildeToList._

trait PrintUtils {
	import java.nio.charset.Charset
	import java.io.PrintWriter
	def newPrintWriter(f: File, chSet: Charset) =
		new PrintWriter(new OutputStreamWriter(new FileOutputStream(f), chSet))

	def printToFile(f: File, chSet: Charset)(op: PrintWriter => Unit) {
		val p = newPrintWriter(f, chSet)
		try { op(p) } finally { p.close() }
	}

	def printTo2File(f1: File, f2: File, chSet: Charset)(op: (PrintWriter, PrintWriter) => Unit) {
		val p1 = newPrintWriter(f1, chSet)
		val p2 = newPrintWriter(f2, chSet)
		try {
			op(p1, p2)
		} finally {
			p1.close()
			p2.close()
		}
	}
}

trait ExprsParsers extends RegexParsers {
	val value = 3
	lazy val mult: Parser[Int] =
		"(" ~> mult <~ ")" ^^ { _ * value } |||
			"()" ^^ { _ => value }

	lazy val plus: Parser[Int] =
		(mult <~ "+") ~ plus ^^ { case m ~ p => m + p } |||
			mult
}

object MainObj extends AuthorParser with PrintUtils with Notes {

	val base = "/home/simonlbc/workspace/DB/DB2016/CSV/"

	def main(args: Array[String]): Unit = {
		parse(base + "authors.csv", authorParser)
	}
	import Parsers.Wrappers.CSVAble
	def parse[T <: CSVAble](csvFilePath: String, parser: Parser[T]) {
		val f = new File(csvFilePath)

		val in = new BufferedReader(new InputStreamReader(new FileInputStream(f), StandardCharsets.ISO_8859_1))
		val fileParsedName = f.getParent + "/" + f.getName.split("\\.")(0)
		val errFile = new File(fileParsedName + "_output.txt")
		val cleanCSVFile = new File(fileParsedName + "_clean.csv")
		var nbFails: Int = 0;
		printTo2File(errFile, cleanCSVFile, StandardCharsets.ISO_8859_1) { (pErr, pSucc) =>

			def lines: Stream[Option[String]] = Option(in.readLine()) #:: lines
			
			lines.takeWhile(_.isDefined).flatten.foreach { s =>
				parseAll(parser, s) match {
					case f: NoSuccess =>
						pErr.println(f); nbFails += 1
					case Success(t, _) => pSucc.println(t.toCSV)
				}
			}

			in.close()
			println(s"""${csvFilePath} : number of parse failures: ${nbFails}""")
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