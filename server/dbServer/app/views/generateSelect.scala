object Generator {
  //for generating deliv 3 queries options
  def generateOptions(lastQueryIndex: Char, delivNb: Int) {
    (0 to (lastQueryIndex - 'a')).foreach {
       x => 
        println(s"""<option value="${('a' + x).toChar}${delivNb}"> """ + 
                   s"""query ${('a' +  x).toChar} - Deliverable ${delivNb}""") 
    }
  }

  generateOptions('g', 2) 
  println()
  generateOptions('o', 3)
}
