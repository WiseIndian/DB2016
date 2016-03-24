package main.scala
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

trait PrintUtils {
	def printToFile(f: java.io.File)(op: java.io.PrintWriter => Unit) {
		val p = new java.io.PrintWriter(f)
		try { op(p) } finally { p.close() }
	}
}

object MainObj extends AuthorParser with PrintUtils {
	def main(args: Array[String]): Unit = {

		println(parseAll(email, "blabla@email.com"))
		println(parseAll(email, "nqowinefoqinwef@goiwqngoinre.com.fowqiefonwq"))
		println(parseAll(placeAddress, "qoiwnefoiwqnef qwef qwqfwoeni, qowienfiowqnfe, qwoienfoiewqnofnweq, qwoienfoiwqneoifnwqe, wqoinefoinwqofinwqoefnwqefqnwe, wqe"))
		println(parseAll(placeAddress, "qoiwnefoiwqnef, qwoienfoiwqneoifnwqe, wqoinefoinwqofinwqoefnwqefqnwe,"))
		println(parseAll(id, "123421"))
		println(parseAll(authName, "john doe, oqiwneoinw"))
		println(parseAll(pseudo, "qowiefoihwqoeifh oiwqefoihqw"))
		println(parseAll(pseudo, "120394091230949012"))
		println(parseAll(birthPlace, "ofwqineofinwqofiqnwef, qowinefoinwqfoinwqfeo, oiwqneofinwqeoifn     wefiowqnefoinwqeoinfwq,             qwoinefiowqne    ,     qowinefoinwq, qoinfew"))
		println(parseAll(birthDate, "1994-09-29"))
		println(parseAll(deathDate, "1934-09-27"))
		println(parseAll(imgUrl, "http://www.img.qwefinqwoinfe.com"))
		println(parseAll(lang, "123049123094"))
		println(parseAll(noteID, "123409213"))

		val s = "12342134\tJohn Doe\tJohn\tDoe\t1234\tWashington, Usa\t1987-01-01\t1989-02-02\tblabla@email.com\thttp://bolloss.com\t12308\t19"
		println(parseAll(authorParser, s))

		val authorPath = "/home/simonlbc/workspace/DB/CSV/authors.csv"
		val f = new java.io.File(authorPath)
		val in: InputStream = new FileInputStream(f)
		val sc: Scanner = new Scanner(in)
		val outFile = new File("/home/simonlbc/workspace/DB/DB2016/outputAuthor.txt")
		printToFile(outFile) {
			p =>

				while (sc.hasNext()) {
					val parsOut = parseAll(authorParser, sc.nextLine())
					p.println(parsOut)
					println(parsOut)
				}

		}
	}
}

trait MyRegexUtils {
	val alpha = """[a-zA-Z]""".r
	val alphaWord = """[a-zA-Z]+""".r
	val Null = "\\N"
	val intgr = """\d+""".r
	val year = """\d{4}""".r
	val day20 = """[0-2]\d""".r
	val day30 = """3[01]""".r
	val month0 = """0\d""".r
	val month1 = """1[0-2]""".r
	val anyButTab = """[^\t]+""".r
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
	import main.scala.TildeToList
	//TODO rajouter les nulls
	//TODO checker que j'ai bien ajouté space a la fin et au debut des parsers
	override val skipWhitespace = false

	lazy val nameSep: Parser[String] = (
		rep(" ") ~ "," ~ rep(" ") ^^ { _ => ", " }
		||| "." ~ rep(" ") ^^ { _ => ". " }
		||| rep1(" ") ^^ { _ => " " })

	lazy val name: Parser[String] = (
		rep1(alphaWord ~ nameSep) ~ alphaWord ~ opt(".") ^^ {
			case ls ~ aw ~ dotOpt => ls.map { tilde => tilde._1 + tilde._2 }.mkString + aw + dotOpt.getOrElse("")
		}
		||| alphaWord ~ opt(".") ^^ { case w ~ dotOpt => w + dotOpt.getOrElse("") }

		| failure("unexpected character in name part"))

	lazy val subSep: Parser[String] = (
		(rep(" ") ~> "-") <~ rep(" ")
		||| rep1(" ") ^^ { _ => " " })

	lazy val addrSub: Parser[String] = alphaWord ~ rep(subSep ~ alphaWord) ^^ {
		case head ~ ls => head + ls.foldLeft("") { case (s, sep ~ w) => s + sep + w }
	} | failure("addrSub failed")

	lazy val addrAtom: Parser[String] = ((rep(" ") ~> ",") <~ rep(" ")) ~ addrSub ^^ {
		case "," ~ sub => "," + sub
	} | failure("addrAtom failed")
	lazy val placeAddress: Parser[String] = (addrSub <~ rep(" ")) ~ rep(addrAtom) ^^ {
		case headSub ~ lsSubs => headSub + lsSubs.mkString
	} | failure("placeAddress failed")

	lazy val day: Parser[String] = day20 ||| day30 ||| failure("day format invalid")
	lazy val month: Parser[String] = month0 ||| month1 | failure("month format invalid")

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


case class Author(id: Int, name: String, legName: Option[String], lastName: Option[String],
		pseudo: Option[String], birthPlace: Option[String], birthDate: Option[Date], deathDate: Option[Date], img: Option[URL], lang: Option[Int],
		noteID: Option[Int]) {

	override val toString: String = id + name + legName + lastName + pseudo + birthPlace + birthDate + deathDate + img + lang + noteID + "\n"
}
trait AuthorParser extends ParserUtils {

	//TODO déplacer addNullRule et asr dans ParserUtils une fois que ça marchera
	def addNullRule[T](p: Parser[T]): Parser[Option[T]] =
		p ^^ { Some(_) } ||| "\\N" ^^ { _ => None }

	lazy val id: Parser[String] = intgr
	//apparemtn dans name il y a des exceptions: Gordon Cooper (1927 - 2004)
	//un parser de nom pour les noms, legal name, et last name et pseudo
	lazy val authName: Parser[String] = name
	lazy val authLegName: Parser[Option[String]] = addNullRule(name)
	lazy val authLastName: Parser[Option[String]] = addNullRule(name)
	lazy val pseudo: Parser[Option[String]] = addNullRule(name ||| intgr)
	lazy val birthPlace: Parser[Option[String]] = addNullRule(placeAddress)
	lazy val birthDate: Parser[Option[Date]] = addNullRule(date)
	lazy val deathDate: Parser[Option[Date]] = addNullRule(date)
	lazy val imgUrl: Parser[Option[URL]] = addNullRule(url)
	lazy val lang: Parser[Option[String]] = addNullRule(intgr)
	lazy val noteID: Parser[Option[String]] = addNullRule(intgr)

	def asr[T](t: Parser[T]): Parser[T] = rep(" ") ~> t <~ rep(" ") <~ "\t" //aSR veut dire add surrounding rule

	lazy val authorParser: Parser[Author] =
		asr(id) ~ asr(authName) ~ asr(authLegName) ~ asr(authLastName) ~
			asr(pseudo) ~ asr(birthPlace) ~ asr(birthDate) ~ asr(deathDate) ~
			asr(addNullRule(email)) ~ asr(imgUrl) ~ asr(lang) ~ (rep(" ") ~> (noteID <~ rep(" "))) ^^ {
				case id ~ n1 ~ n2 ~ n3 ~ ps ~ bp ~ bd ~ dd ~ em ~ img ~ lng ~ nid =>
					Author(id.toInt, n1, n2, n3, ps, bp, bd, dd, img, lng.map(_.toInt), nid.map(_.toInt))
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