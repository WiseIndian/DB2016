package Parsers

import scala.util.parsing.combinator.RegexParsers
import java.text.SimpleDateFormat
import java.time.LocalDate
import java.time.Year
import java.time.YearMonth
import java.time.temporal.Temporal
import java.time.format.DateTimeFormatter
import java.time.format.DateTimeParseException
import java.net.URL
import java.text.ParseException
import java.net.MalformedURLException

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
	
}

trait ParserUtils extends TildeToListMethods with MyRegexUtils with RegexParsers {
	override val skipWhitespace = false

	def asr[G, T, H](l: Parser[G], t: Parser[T], r: Parser[H]): Parser[T] =
		(l ~> t) <~ r //aSR veut dire add surrounding rule

	def asrSpaces[T](p: Parser[T]): Parser[T] = asr(oSpc, p, oSpc)
	def tildeToStr[T <: _ ~ String](t: T)(implicit ttl: TildeToList[T]): String =
		tildeToList(t).mkString
	val oSpc: Parser[String] = rep(" ") ^^ { case ls =>  if (ls.size > 0) " " else "" } // optional space
	val cSpc = " +".r ^^ { _ => " " }
	/*this subset of the grammar of name separators, included in nameSep can be used 
	 * as name terminator too, thus the definition of the subset.
	 */
	lazy val nameSepSubset: Parser[String] = (
		"."
		||| ("." <~ oSpc) ~ "," ^^ { _ => ". ," })

	lazy val nameSep: Parser[String] = (
		nameSepSubset
		||| ","
		||| "-"
		||| "'")

	lazy val nameChar = isocodePart ||| """\p{IsLatin}""".r
	lazy val nameSub = rep1(nameChar) ^^ { _.mkString }

	lazy val termPart: Parser[String] =
		opt(nameSepSubset) ^^ { _.getOrElse("") }

	lazy val nameOptInfo: Parser[String] =
		"(" ~> latinWord ~ opt(".") <~ ")" ^^ { case lat ~ opt => lat + opt.getOrElse("") }

	def toSingle(s: String): String = 	
		if (s.matches{" +".r.toString}) return " " 
		else s
	
	lazy val name: Parser[String] =
		(nameSub ~ oSpc ~ opt(nameOptInfo) ~ oSpc ~ opt(nameSep) ~ oSpc ~ name ^^ {
			case sub ~ oSpc ~ optInf ~ oSpc2 ~ sep ~ oSpc3 ~ tail => sub + oSpc + optInf.getOrElse("") + oSpc2 + sep.getOrElse("") + oSpc3 + tail
		} 
		||| nameSub ~ oSpc ~ opt(nameOptInfo) ~ oSpc ~ termPart ^^ {
				case sub ~ oSpc  ~ optInf ~ oSpc2 ~ t => sub + oSpc + optInf.getOrElse("") + oSpc2 + t
			}
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