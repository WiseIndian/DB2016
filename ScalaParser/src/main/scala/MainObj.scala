package main.scala
import scala.util.parsing.combinator.Parsers
import scala.util.parsing.combinator.RegexParsers
import scala.util.matching.Regex
import java.text.SimpleDateFormat
import java.io.File
import java.io.FileInputStream
import java.io.InputStreamReader
import java.io.BufferedReader
import java.io.InputStream
import java.util.Scanner
import java.time.LocalDate
import java.nio.charset.StandardCharsets
import java.time.Year
import java.time.YearMonth
import java.time.temporal.Temporal
import java.time.format.DateTimeFormatter
import java.time.format.DateTimeParseException
import java.io.PrintStream
import java.net.URL
import java.text.ParseException
import java.net.MalformedURLException
import java.io.FileOutputStream
import java.io.OutputStreamWriter
//import parser.TildeToList._

trait PrintUtils {
	def printToFile(f: java.io.File)(op: java.io.PrintWriter => Unit) {
		val p = new java.io.PrintWriter(new OutputStreamWriter(new FileOutputStream(f), StandardCharsets.ISO_8859_1))
		try { op(p) } finally { p.close() }
	}
}

object MainObj extends AuthorParser with PrintUtils {

	def main(args: Array[String]): Unit = {
		normalParsing
	}

	def normalParsing {
		val authorPath = "/home/simonlbc/workspace/DB/CSV/authors.csv"
		val f = new java.io.File(authorPath)
		val in = new BufferedReader(new InputStreamReader(new FileInputStream(f), StandardCharsets.ISO_8859_1))
		val outFile = new File("/home/simonlbc/workspace/DB/DB2016/outputAuthor.txt")
		printToFile(outFile) {
			p =>

				def lines: Stream[Option[String]] = Option(in.readLine()) #:: lines
				lines.takeWhile(_.isDefined).flatten.foreach { s =>
					parseAll(authorParser, s) match {
						case f: Failure => p.println(f)
						case _ =>
					}
				}

				in.close()
				println("done")

		}
	}
}

trait MyRegexUtils {
	val alpha = """[a-zA-Z]""".r
	val alphaWord = """[a-zA-Z]+""".r
	val latinWord = """\p{IsLatin}+""".r
	val isocodePart = """&#\d+;""".r
	val Null = "\\N"
	val intgrRegx = """\d+""".r
	val year = """\d{4}""".r
	val day20 = """[0-2]\d""".r
	val day30 = """3[01]""".r
	val month0 = """0\d""".r
	val month1 = """1[0-2]""".r
	val anyButTab = """[^\t]+""".r
	val oSpc = " *".r // optional space
	val cSpc = " +".r // compulsory space
}

trait TildeToList[T] {
	type Elem
	def apply(t: T): List[Elem]
}

trait TildeToListMethods extends RegexParsers {
	type Aux[T, E] = TildeToList[T] { type Elem = E }

	implicit def baseTildeToList[E]: Aux[E ~ E, E] = new TildeToList[E ~ E] {
		type Elem = E
		def apply(t: E ~ E): List[E] = List(t._1, t._2)
	}

	implicit def recTildeToList[I, L](implicit ttl: Aux[I, L]): Aux[I ~ L, L] =
		new TildeToList[I ~ L] {
			type Elem = L
			def apply(t: I ~ L): List[L] = ttl(t._1) :+ t._2
		}

	def tildeToList[T <: _ ~ _](t: T)(implicit ttl: TildeToList[T]): List[ttl.Elem] = ttl(t)
}

trait ParserUtils extends TildeToListMethods with MyRegexUtils with RegexParsers {
	override val skipWhitespace = false

	def asr[G, T, H](l: Parser[G], t: Parser[T], r: Parser[H]): Parser[T] =
		(l ~> t) <~ r //aSR veut dire add surrounding rule

	def asrSpaces[T](p: Parser[T]): Parser[T] = asr(oSpc, p, oSpc)
	def tildeToStr[T <: _ ~ String](t: T)(implicit ttl: TildeToList[T]): String =
		tildeToList(t).mkString

	/*this subset of the grammar of name separators, included in nameSep can be used 
	 * as name terminator too, thus the definition of the subset.
	 */
	lazy val nameSepSubset: Parser[String] = (
		rep1(" ") ^^ { _ => " " }
		||| "." ~ rep1(" ") ^^ { _ => ". " }
		||| ("." <~ oSpc) ~ ("," <~ oSpc) ^^ { _ => ".," }
		||| ".")

	lazy val nameSep: Parser[String] = (
		nameSepSubset
		||| oSpc ~ "," ~ oSpc ^^ { _ => ", " }
		||| oSpc ~> "-" <~ oSpc
		||| "'")

	lazy val nameChar = isocodePart ||| """\p{IsLatin}""".r
	lazy val nameSub = rep1(nameChar) ^^ { _.mkString }

	lazy val termPart: Parser[String] =
		opt(nameSepSubset) ^^ { _.getOrElse("") }

	lazy val name: Parser[String] =
		(nameSub ~ nameSep ~ name ^^ { case sub ~ sep ~ tail => sub + sep + tail }
			||| nameSub ~ (oSpc ~> termPart) ^^ { case w ~ t => w + t }
			| failure("unexpected character in name part"))

	lazy val placeAddress: Parser[String] = rep1(name ||| """\d+""".r) ^^ { _.mkString }
	lazy val day: Parser[String] = day20 ||| day30 ||| failure("day format invalid")
	lazy val month: Parser[String] = month0 ||| month1 | failure("month format invalid")

	val ymdFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd")

	lazy val dateStrToParsRes = (s: String) => {
		try success(LocalDate.parse(s, ymdFormatter))
		catch { case pe: DateTimeParseException => failure("date format invalid") }
	}

	lazy val unknMthDayDate: Parser[Year] = year <~ "-00-00" >> { y =>
		try success(Year.parse(y))
		catch {
			case dte: DateTimeParseException =>
				failure("year format invalid in unknown month, day case")
		}
	}

	val ymFormatter = DateTimeFormatter.ofPattern("yyyy-MM")
	lazy val unknDayDate: Parser[YearMonth] = year ~ "-" ~ month <~ "-00" >> {
		case y ~ "-" ~ m =>
			try success(YearMonth.parse(y + "-" + m, ymFormatter))
			catch { case dtpe: DateTimeParseException => failure("year-month format invalid in unknown day case") }
	}

	lazy val normalDate: Parser[LocalDate] = (year ~ "-" ~ month ~ "-" ~ day) >>
		{ case y ~ "-" ~ m ~ "-" ~ d => dateStrToParsRes(y + "-" + m + "-" + d) }

	lazy val date: Parser[Temporal] = normalDate ||| unknMthDayDate ||| unknDayDate

	/* cf wikipedia https://en.wikipedia.org/wiki/Email_address#Valid_email_addresses 
  * j'ai pas ajouté "Other special characters are allowed with restrictions"
  * et 
  * "A quoted string may exist as a dot separated entity within the local-part, 
  * or it may exist when the outermost quotes are the outermost characters of the local-par"
  * parce qu'il y en a pas dans le fichier (checké avec la regex *"*@)
  */
	lazy val emailChars: Parser[String] = alpha ||| """\d""".r ||| """[!#$%&'*+-/=?^_`{|}~]""".r
	lazy val localPart: Parser[String] =
		rep1(emailChars) ~ rep("." ~ rep1(emailChars)) ^^ {
			case emStr ~ ls => emStr.mkString + ls.foldLeft("") { case (s, "." ~ chrLs) => s + "." + chrLs.mkString }
		} | failure("localPart failed")
	lazy val ipSub: Parser[String] = """\d""".r ||| """[1-9]\d""".r ||| """1\d\d""".r ||| """2[0-4]\d""".r ||| """25[0-5]""".r

	lazy val ip: Parser[String] = ipSub ~ "." ~ ipSub ~ "." ~ ipSub ~ "." ~ ipSub ^^ {
		case i1 ~ "." ~ i2 ~ "." ~ i3 ~ "." ~ i4 => List(i1, i2, i3, i4).mkString(".")
	} | failure("ip failed")

	lazy val domainPart: Parser[String] = (
		("""[a-zA-Z0-9-]+""".r ~ rep1("." <~ alphaWord) ^^ {
			case head ~ ls =>
				head + ls.map { "." + _ }.mkString
		})
		||| ("[" ~ ip ~ "]" ^^ { case "[" ~ ip ~ "]" => "[" + ip + "]" })) | failure("domainPart failed")

	lazy val email: Parser[String] = localPart ~ "@" ~ domainPart ^^
		{ case loc ~ "@" ~ dom => loc + "@" + dom }

	lazy val url: Parser[URL] =
		anyButTab >> { s: String =>
			try success(new URL(s))
			catch { case m: MalformedURLException => failure("error parsing from URL class:" + m) }
		}

}

trait AuthorParser extends ParserUtils {

	//TODO déplacer addNullRule et asr dans ParserUtils une fois que ça marchera
	def addNullRule[T](p: Parser[T]): Parser[Option[T]] =
		p ^^ { Some(_) } ||| "\\N" ^^ { _ => None }

	lazy val intParser: Parser[Int] = intgrRegx ^^ { _.toInt }
	lazy val id: Parser[Int] = intParser

	/**
	 *  a trait for supplementary info that can follow an author name like (1994-2005) or (II) ...
	 *  it allows us to parse this supplementary info and manipulate it in the tldToName, tldToBirthDate.. methods.
	 */
	sealed trait NameSupInfo
	case class YearRange(begDate: String, endDate: String) extends NameSupInfo
	lazy val yearRange1: Parser[String ~ String] = (year <~ oSpc <~ "-" <~ oSpc) ~ year
	lazy val yearRange2: Parser[String ~ String] = oSpc ~> yearRange1 <~ oSpc
	lazy val yearRange: Parser[YearRange] = "(" ~> yearRange2 <~ ")" ^^ { case beg ~ end => YearRange(beg, end) }

	case class BirthYear(y: String) extends NameSupInfo

	lazy val birthYear1: Parser[String] = (
		year <~ oSpc <~ "-" <~ oSpc <~ ")"
		||| year <~ oSpc <~ ")")
	lazy val birthYear: Parser[BirthYear] = "(" ~> oSpc ~> birthYear1 ^^ { case y => BirthYear(y) }
	//we first apply the parentheses

	lazy val nameID: Parser[String] = (
		("(" ~> rep1("I")) <~ ")" ^^ { "(" + _.mkString + ")" }
		||| "(" ~> oSpc ~> year ~ "s" <~ oSpc <~ ")" ^^ { case y ~ "s" => y + "s" })

	lazy val authName1: Parser[String] = name ~ (oSpc ~> opt(nameID)) ^^ { case n ~ opt => n + opt.getOrElse("") }
	lazy val authName: Parser[String ~ Option[NameSupInfo]] = (
		authName1 ~ (oSpc ~> opt(yearRange))
		||| authName1 ~ (oSpc ~> opt(birthYear)))

	lazy val authLegName: Parser[Option[String]] = addNullRule(name)
	lazy val authLastName: Parser[Option[String]] = addNullRule(name)
	lazy val pseudo: Parser[Option[String]] = addNullRule(name ||| intgrRegx)
	lazy val birthPlace: Parser[Option[String]] = addNullRule(placeAddress)
	lazy val birthDate: Parser[Option[Temporal]] = addNullRule(date)
	lazy val deathDate: Parser[Option[Temporal]] = addNullRule(date)
	lazy val imgUrl: Parser[Option[URL]] = addNullRule(url)
	lazy val lang: Parser[Option[Int]] = addNullRule(intParser)
	lazy val noteID: Parser[Option[Int]] = addNullRule(intParser)

	def asrCSV[T](p: Parser[T]): Parser[T] = asr(oSpc, p, oSpc ~ "\t")

	type AuthTilde = Int ~ ~[String, Option[NameSupInfo]] ~ Option[String] ~ Option[String] ~ Option[String] ~ Option[String] ~ Option[Temporal] ~ Option[Temporal] ~ Option[String] ~ Option[URL] ~ Option[Int] ~ Option[Int]

	def tldToName(tld: AuthTilde): String = tld match {
		case id ~ (n1 ~ _) ~ n2 ~ n3 ~ ps ~ bp ~ bd ~ dd ~ email ~ img ~ lng ~ nteId =>
			n1
	}
	def tldToBirthDate(tld: AuthTilde): Option[Temporal] = tld match {
		case id ~ (n1 ~ _) ~ n2 ~ n3 ~ ps ~ bp ~ Some(t) ~ dd ~ email ~ img ~ lng ~ nteId =>
			Some(t)
		case id ~ (n1 ~ Some(BirthYear(y))) ~ n2 ~ n3 ~ ps ~ bp ~ None ~ dd ~ email ~ img ~ lng ~ nteId =>
			try Some(Year.parse(y))
			catch { case e: DateTimeParseException => None }
		case id ~ (n1 ~ Some(YearRange(beg, end))) ~ n2 ~ n3 ~ ps ~ bp ~ None ~ dd ~ email ~ img ~ lng ~ nteId =>
			try Some(Year.parse(beg))
			catch { case e: DateTimeParseException => None }
		case id ~ (n1 ~ None) ~ n2 ~ n3 ~ ps ~ bp ~ None ~ dd ~ email ~ img ~ lng ~ nteId =>
			None
	}

	lazy val authorTilde: Parser[AuthTilde] =
		asrCSV(id) ~ asrCSV(authName) ~ asrCSV(authLegName) ~ asrCSV(authLastName) ~
			asrCSV(pseudo) ~ asrCSV(birthPlace) ~ asrCSV(birthDate) ~ asrCSV(deathDate) ~
			asrCSV(addNullRule(email)) ~ asrCSV(imgUrl) ~
			asrCSV(lang) ~ (oSpc ~> (noteID <~ oSpc))

	lazy val authorParser: Parser[Author] = authorTilde ^^ {
		case t @ (id ~ (n1 ~ n1Tail) ~ n2 ~ n3 ~ ps ~ bp ~ bd ~ dd ~ email ~ img ~ lng ~ nteId) =>
			Author(id, tldToName(t), n2, n3, ps, bp, tldToBirthDate(t), dd, email, img, lng, nteId)
	}

}

case class Author(id: Int, name: String, legName: Option[String], lastName: Option[String],
		pseudo: Option[String], birthPlace: Option[String], birthDate: Option[Temporal],
		deathDate: Option[Temporal], email: Option[String], img: Option[URL], lang: Option[Int],
		noteID: Option[Int]) {
	override val toString: String = id + name + legName + lastName + pseudo + birthPlace + birthDate + deathDate + email + img + lang + noteID + "\n"
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