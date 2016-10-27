package com.thoughtworks.DDF.Language

object Preclude {
  def square[Info[_], Repr[_]](implicit lang: Lang[Info, Repr]): Repr[Double => Double] = lang.W_(lang.multD)

  def square_[Info[_], Repr[_]](r: Repr[Double])(implicit lang: Lang[Info, Repr]): Repr[Double] =
    lang.app(square(lang))(r)

  def sumList[Info[_], Repr[_]](implicit lang: Lang[Info, Repr]): Repr[List[Double] => Double] = {
    val nLang = NextLang(lang, lang.listInfo(lang.doubleInfo))
    nLang.collapse(sumList_[nLang.info, nLang.repr](nLang.in)(nLang))
  }

  def sumList_[Info[_], Repr[_]](li: Repr[List[Double]])(implicit lang: Lang[Info, Repr]) = {
    import lang._
    foldLeft___(plusD)(litD(0))(li)
  }

  def dot__[Info[_], Repr[_]](l: Repr[List[Double]])(r: Repr[List[Double]])(implicit lang: Lang[Info, Repr]):
  Repr[Double] = {
    import lang._
    sumList_(listMap__(uncurry_(multD))(listZip__(l)(r)))
  }

  def dot_[Info[_], Repr[_]](l: Repr[List[Double]])(implicit lang: Lang[Info, Repr]): Repr[List[Double] => Double] = {
    val nLang = NextLang(lang, lang.listInfo(lang.doubleInfo))
    nLang.collapse(dot__[nLang.info, nLang.repr](nLang.rconv(l))(nLang.in)(nLang))
  }

  def dot[Info[_], Repr[_]](implicit lang: Lang[Info, Repr]): Repr[List[Double] => List[Double] => Double] = {
    val nLang = NextLang(lang, lang.listInfo(lang.doubleInfo))
    nLang.collapse(dot_[nLang.info, nLang.repr](nLang.in)(nLang))
  }

  def divAvg_[Info[_], Repr[_]](ld: Repr[List[Double]])(implicit lang: Lang[Info, Repr]): Repr[List[Double]] = {
    import lang._
    listMap__(C__(divD)(sumList_(ld)))(ld)
  }

  def divAvg[Info[_], Repr[_]](implicit lang: Lang[Info, Repr]): Repr[List[Double] => List[Double]] = {
    val nLang = NextLang(lang, lang.listInfo(lang.doubleInfo))
    nLang.collapse(divAvg_[nLang.info, nLang.repr](nLang.in)(nLang))
  }

  def softMax_[Info[_], Repr[_]](ld: Repr[List[Double]])(implicit lang: Lang[Info, Repr]): Repr[List[Double]] = {
    import lang._
    divAvg_(listMap__(expD)(ld))
  }

  def softMax[Info[_], Repr[_]](implicit lang: Lang[Info, Repr]): Repr[List[Double] => List[Double]] = {
    val nLang = NextLang(lang, lang.listInfo(lang.doubleInfo))
    nLang.collapse(softMax_[nLang.info, nLang.repr](nLang.in)(nLang))
  }

  def max__[Info[_], Repr[_]](l: Repr[Double])(r: Repr[Double])(implicit lang: Lang[Info, Repr]): Repr[Double] = {
    import lang._
    ite___(ltD__(l)(r))(r)(l)
  }

  def max_[Info[_], Repr[_]](l: Repr[Double])(implicit lang: Lang[Info, Repr]): Repr[Double => Double] = {
    val nLang = NextLang(lang, lang.doubleInfo)
    nLang.collapse(max__[nLang.info, nLang.repr](nLang.rconv(l))(nLang.in)(nLang))
  }

  def max[Info[_], Repr[_]](implicit lang: Lang[Info, Repr]): Repr[Double => Double => Double] = {
    val nLang = NextLang(lang, lang.doubleInfo)
    nLang.collapse(max_[nLang.info, nLang.repr](nLang.in)(nLang))
  }

  def relu_[Info[_], Repr[_]](d: Repr[Double])(implicit lang: Lang[Info, Repr]): Repr[Double] = {
    import lang._
    max__(litD(0))(d)
  }

  def relu[Info[_], Repr[_]](implicit lang: Lang[Info, Repr]): Repr[Double => Double] = {
    val nLang = NextLang(lang, lang.doubleInfo)
    nLang.collapse(relu_[nLang.info, nLang.repr](nLang.in)(nLang))
  }
}