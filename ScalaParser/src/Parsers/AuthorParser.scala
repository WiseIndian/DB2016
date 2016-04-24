
package Parsers
import scala.util.parsing.combinator.Parsers
import java.time.Year
import java.time.YearMonth
import java.time.temporal.Temporal
import java.time.format.DateTimeFormatter
import java.time.format.DateTimeParseException
import java.net.URL
import java.text.ParseException
import java.net.MalformedURLException

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
	lazy val yearRange: Parser[YearRange] =
		"(" ~> oSpc ~> yearRange1 <~ oSpc <~ ")" ^^
			{ case beg ~ end => YearRange(beg, end) }

	case class BirthYear(y: String) extends NameSupInfo

	lazy val birthYear1: Parser[String] = (
		year <~ oSpc <~ "-" <~ oSpc <~ ")"
		||| year <~ oSpc <~ ")"
		||| year <~ "s" <~ oSpc <~ ")"
		||| "b." ~> oSpc ~> year <~ oSpc <~ ")"
		||| "c." ~> oSpc ~> year <~ oSpc <~ ")")
	lazy val birthYear: Parser[BirthYear] = "(" ~> oSpc ~> birthYear1 ^^ { case y => BirthYear(y) }

	lazy val nameID: Parser[String] = (
		"(" ~> rep1("I") <~ ")" ^^ { "(" + _.mkString + ")" } 
		||| "(" ~> rep1sep(latinWord, oSpc) <~ ")" ^^ { _.mkString(" ") } )

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