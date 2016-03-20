package parser
import scala.util.parsing.combinator.Parsers
import scala.util.parsing.combinator.RegexParsers
import scala.util.matching.Regex
import java.text.SimpleDateFormat
import java.util.Date
import java.io.File
import java.io.FileInputStream
import java.io.InputStream
import java.util.Scanner
import java.io.PrintStream
import java.net.URL
import java.text.ParseException
import java.net.MalformedURLException
//import parser.TildeToList._

object MainObj extends AuthorParser {
	def main(args: Array[String]): Unit = {
		val authorPath = "/home/simonlbc/workspace/DB/CSV/authors.csv"
		val f =  new java.io.File(authorPath)
		val in: InputStream =  new FileInputStream(f)
		val sc: Scanner = new Scanner(in)
		while (sc.hasNext())
				print(parseAll(authorParser, sc.nextLine()))
	}
}

trait RegexUtils {
	val alpha = """[a-zA-Z]""".r
	val alphaWord = """[a-zA-Z]+""".r
	val Null = "\\N"
	val spaces = """ +""".r
	val intgr = """\d+""".r
	val year = """\d{4}""".r
	val day20 = """[0-2]\d""".r
	val day30 = """3[01]""".r
	val month0 = """0\d""".r
	val month1 = """1[0-2]""".r
	val anyButTab = """[^\t]""".r
	val tab = """\t""".r
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

trait ParserUtils extends TildeToListMethods with RegexUtils with RegexParsers {
	import parser.TildeToList
	//TODO rajouter les nulls
	//TODO checker que j'ai bien ajouté space a la fin et au debut des parsers

	lazy val namePrtEnd: Parser[String] = "." | "," | failure("unexpected character in name part end")

	lazy val namePart: Parser[String] = (
		alphaWord ~ opt(namePrtEnd) ^^ {
			case regexRes ~ strOpt => regexRes + strOpt.getOrElse("")
		}
		| failure("unexpected character in name part"))

	lazy val name: Parser[String] = (spaces ~> namePart ~ repsep(namePart, spaces) ~ alphaWord ~ opt(".") <~ spaces ^^ {
		case headStr ~ ls ~ alphaWord ~ opt => (headStr :: ls).mkString(" ") + alphaWord + opt.getOrElse(".")
	}
		| failure("unexpected token in name"))

	lazy val addChrs: Parser[String] = alpha | "-"
	lazy val placeAddress: Parser[String] = repsep(addChrs ~ rep(addChrs), ",") ^^ { lsOfLocs =>
		lsOfLocs.map {
			case chLsHead ~ chLsTail => chLsHead + chLsTail.mkString("")
		}.mkString(",")
	}

	//un parser de date pour birthdate et deathdate(year en 4 digits)-mois(en 2 digits qui peut être 00 si inconnu?)-jour(0 si inconnu ou sinon 1-31 si connu)
	//est-ce qu'on se fait chier avec fevrier et ses 28 jours et les mois avec 30 ou 31 jours?
	lazy val day: Parser[String] = day20 | day30 | failure("day format invalid")
	lazy val month: Parser[String] = month0 | month1 | failure("month format invalid")

	val formatter: SimpleDateFormat = new SimpleDateFormat("yyyy-MM-dd")
	formatter.setLenient(false)
	lazy val simpleDate: Parser[String] = (
		(year ~ "-" ~ month ~ "-" ~ day) ^^
		{ case y ~ "-" ~ m ~ "-" ~ d => y + "-" + m + "-" + d }
		| failure("wrong date format"))

	lazy val date: Parser[Date] = simpleDate >> (s =>
		try success(formatter.parse(s))
		catch { case pe: ParseException => failure("date format invalid") })

	/* cf wikipedia https://en.wikipedia.org/wiki/Email_address#Valid_email_addresses 
  * j'ai pas ajouté "Other special characters are allowed with restrictions"
  * et 
  * "A quoted string may exist as a dot separated entity within the local-part, 
  * or it may exist when the outermost quotes are the outermost characters of the local-par"
  * parce qu'il y en a pas dans le fichier (checké avec la regex *"*@)
  */
	lazy val normalEmailCh = alpha | """\d""".r | """[!#$%&'*+-/=?^_`{|}~]""".r
	lazy val localPart: Parser[String] =
		normalEmailCh ~ rep(rep(normalEmailCh) ~ opt("." ~ normalEmailCh)) ^^ {
			case head ~ list => head + list.foldLeft("") {
				case (z, ls ~ opt) => z + ls.mkString("") + opt.map { case "." ~ ch => "." + ch }
			}
		}
	lazy val ipSub: Parser[String] = """\d""".r | """[1-9]\d""".r | """1\d\d""".r | """2[0-4]\d""".r | """25[0-5]""".r
	lazy val ip: Parser[String] = ipSub ~ "." ~ ipSub ~ "." ~ ipSub ~ "." ~ ipSub ^^ {
		case i1 ~ "." ~ i2 ~ "." ~ i3 ~ "." ~ i4 => List(i1, i2, i3, i4).mkString(".")
	}

	lazy val domainPart: Parser[String] = (
		"[" ~ ip ~ "]" ^^ { case "[" ~ ip ~ "]" => "[" + ip + "]" }
		| """[A-Z0-9.-]+\.[A-Z]{2,}""".r)

	lazy val email: Parser[String] = localPart ~ "@" ~ domainPart ^^
		{ case loc ~ "@" ~ dom => loc + "@" + dom }

	lazy val url: Parser[URL] = anyButTab >> { s: String =>
		try success(new URL(s))
		catch { case m: MalformedURLException => failure("malformed url for image source") }
	}
}

case class Author(id: Int, name: String, legName: String, lastName: String,
	pseudo: String, birthPlace: String, birthDate: Date, deathDate: Date, img: URL, lang: Int,
	noteID: Int) {
	override val toString: String = id + name + legName + lastName + pseudo + birthPlace + birthDate + deathDate + img + lang + noteID + "\n"
}
trait AuthorParser extends ParserUtils {
	lazy val id: Parser[String] = intgr
	//apparemtn dans name il y a des exceptions: Gordon Cooper (1927 - 2004)
	//un parser de nom pour les noms, legal name, et last name et pseudo
	lazy val authName: Parser[String] = name
	lazy val authLegName: Parser[String] = name
	lazy val authLastName: Parser[String] = name
	lazy val pseudo: Parser[String] = name | intgr
	lazy val birthPlace: Parser[String] = placeAddress
	lazy val birthDate: Parser[Date] = date
	lazy val deathDate: Parser[Date] = date
	lazy val imgUrl: Parser[URL] = url
	lazy val lang: Parser[String] = intgr
	lazy val noteID: Parser[String] = intgr

	lazy val blabla = "oiwfnq" ~> "oinfoewqif" ~> "oifqwneinfe"
	def asr[T](t: Parser[T]): Parser[T] = spaces ~> t <~ (spaces ~> tab) //aSR veut dire add surrounding rule
	lazy val authorParser: Parser[Author] =
		asr(id) ~ asr(authName) ~ asr(authLegName) ~ asr(authLastName) ~
			asr(pseudo) ~ asr(birthPlace) ~ asr(birthDate) ~ asr(deathDate) ~
			asr(email) ~ asr(imgUrl) ~ asr(lang) ~ asr(noteID) ^^ {
				case id ~ n1 ~ n2 ~ n3 ~ ps ~ bp ~ bd ~ dd ~ em ~ img ~ lng ~ nid =>
					Author(id.toInt, n1, n2, n3, ps, bp, bd, dd, img, lng.toInt, nid.toInt)
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