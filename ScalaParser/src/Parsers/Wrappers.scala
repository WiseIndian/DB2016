package Parsers
import java.net.URL

object Wrappers {
	sealed trait CSVAble {
		def toCSV: String
	}

	case class Author(id: Int, name: String, legName: Option[String], lastName: Option[String],
			pseudo: Option[String], birthPlace: Option[String], birthDate: Option[MyTemporal],
			deathDate: Option[MyTemporal], email: Option[String], img: Option[URL], lang: Option[Int],
			noteID: Option[Int]) extends CSVAble {
		override val toString: String = id + name + legName + lastName +
			pseudo + birthPlace + birthDate + deathDate + email + img + lang + noteID + "\n"

		override val toCSV: String =
			id + "\t" + name + "\t" + legName.getOrElse("\\N") + "\t" +
				lastName.getOrElse("\\N") + "\t" + pseudo.getOrElse("\\N") + "\t" +
				birthPlace.getOrElse("\\N") + "\t" + birthDate.map(_.toString).getOrElse("\\N") + "\t" +
				deathDate.map { _.toString }.getOrElse("\\N") + "\t" + email.getOrElse("\\N") + "\t" +
				img.getOrElse("\\N") + "\t" + lang.getOrElse("\\N") + "\t" + lang.getOrElse("\\N") + "\t" +
				noteID.getOrElse("\\N")
	}
}