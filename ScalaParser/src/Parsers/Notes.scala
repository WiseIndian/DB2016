package Parsers

trait Notes extends ParserUtils {
	lazy val note: Parser[Note] =
		asrCSV(intParser) ~ (oSpc ~> anyButNull <~ oSpc) ^^ {
			case id ~ txt => Note(id, txt)
		}
}

case class Note(id: Integer, txt: String)