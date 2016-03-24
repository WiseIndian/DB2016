package main.scala
import java.util.Date
import java.net.URL
import scala.util.parsing.combinator.RegexParsers
object tests extends AuthorParser {;import org.scalaide.worksheet.runtime.library.WorksheetSupport._; def main(args: Array[String])=$execute{;$skip(189); 
		lazy val authName: Parser[String] = name;System.out.println("""authName: => main.scala.tests.Parser[String]""");$skip(46); 
		lazy val authLegName: Parser[String] = name;System.out.println("""authLegName: => main.scala.tests.Parser[String]""");$skip(47); 
		lazy val authLastName: Parser[String] = name;System.out.println("""authLastName: => main.scala.tests.Parser[String]""");$skip(49); 
		lazy val pseudo: Parser[String] = name | intgr;System.out.println("""pseudo: => main.scala.tests.Parser[String]""");$skip(53); 
		lazy val birthPlace: Parser[String] = placeAddress;System.out.println("""birthPlace: => main.scala.tests.Parser[String]""");$skip(42); 
		lazy val birthDate: Parser[Date] = date;System.out.println("""birthDate: => main.scala.tests.Parser[java.util.Date]""");$skip(42); 
		lazy val deathDate: Parser[Date] = date;System.out.println("""deathDate: => main.scala.tests.Parser[java.util.Date]""");$skip(37); 
		lazy val imgUrl: Parser[URL] = url;System.out.println("""imgUrl: => main.scala.tests.Parser[java.net.URL]""");$skip(40); 
		lazy val lang: Parser[String] = intgr;System.out.println("""lang: => main.scala.tests.Parser[String]""");$skip(42); 
		lazy val noteID: Parser[String] = intgr;System.out.println("""noteID: => main.scala.tests.Parser[String]""");$skip(37); val res$0 = 
		parseAll(authName, "John doe, JR");System.out.println("""res0: main.scala.tests.ParseResult[String] = """ + $show(res$0))}
		
}
