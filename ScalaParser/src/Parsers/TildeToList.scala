package Parsers

import scala.util.parsing.combinator.RegexParsers;

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