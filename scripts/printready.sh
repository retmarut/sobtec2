#!/bin/bash

###############################################################################
# This script transforms the available markdown (*.md) files 
# to TeX creating a printshop-ready book. This is complementary
# to the gitbooks.sh script output which renders the documents
# with a digital book-reading experience.
#
# On a Debian-based Linux system (ubuntu) you will need to install
# the following pacakges to succesfully progress to TeX and pdf
# renderings of the collective work:
#
# * pandoc
# * texlive-extra-utils (for texliveonfly)
# * texlive-latex-extra and texlive-fonts-extra (for doclicense LaTeX package)
# * evince (optional, this is the PDF viewer for the preview to work)
#
# N.B.: Please have about 2+ GB diskspace available to install 
# all the related software
#
# For LaTeX you might consider installing some optional packages 
# related to various languages to get all the chapters, TOC, and other default
# headings render to langues-specific output:
# texlive-lang-european (include dutch among other languages)
# texlive-lang-french
# texlive-lang-spanish
# etc. ...

###############################################################################
# Render a book for a certain language.
# "renderbook" transforms the markdowns to TeX by means of pandoc.
# After that TeX output is collated to a book through 'book.tex'
#
# param1: lang-dir name (defaults to or(iginal))
# param2: language (default to english)
# Changing the params will have an impact on the chapter, TOC and other
# parts of the documents which are automatically rendered but change name
# depending on the language you want.
#
function renderbook {
	DIR=../${1:-or}/content
	LANGUAGE=${2:-english}

	if [ ! -d "$DIR" ]; then
		exit
	fi

	pushd $DIR

	#Generate docs as separate latex section documents for inclusion later on
	prepareParts

	#Some pandoc-results need mangling for section titles, tables and headings...
	manglePandocResults

	#Generate full book in PDF format including title, TOC, etc.
	texliveonfly "\def\languagename{$LANGUAGE} \input{book.tex}"

	#Testing
	if [ -x "$(command -v evince)" ]; then
		evince book.pdf
	fi

	#Output book with front and back covers for the web
	printWeb $1

	#Move resulting book to target location
	DEST=../../releases/print/sobtec2-$LANGUAGE.pdf
	mv book.pdf $DEST
	echo "Another sobtec book was made print-ready!"
	ls $DEST

	#clean-up pandoc and tex build blurbs.
	rm -rf tex.d *.log *.out *.toc *.aux *.synctex.gz

	popd
}

#Transform the markdown files into TeX-format for further processing
function prepareParts {
	mkdir -p tex.d 
	for file in *.md ; do
		pandoc -f markdown_mmd -t latex $file -o tex.d/$(basename $file .md).tex
	done
}

#Introduce some corrections to the Pandoc -> LaTeX output for further processing  
function manglePandocResults {
	#Note: Running through pandoc longtable layout 
	#results in columns only 5% wide #fixing it to 15%
	sed -i -e 's/0.05/0.15/g' tex.d/03algos.tex
	#Put fontsize of table to tiny to fit A5-page
	sed -i '/begin{longtable}/ i \\\\begin{dummy}\n\\tiny' tex.d/03algos.tex
	sed -i '/end{longtable}/ a \\\\end{dummy}' tex.d/03algos.tex

	#Insert linebreak after every ':' in section heading of tex.d-parts
	#that's a '\\'
	sed -i '0,/: /s//:\\\\/' tex.d/01preface.tex
	sed -i '0,/: /s//:\\\\/' tex.d/01prefacio.tex
	sed -i '0,/: /s//:\\\\/' tex.d/02intro.tex
}

function printWeb {
	#cut out the first page of the book to replace it with 
	#the language-dependent pre-rendered frontcover
	pdftk book.pdf cat 2-end output preweb.pdf

	#compress the front and back images slightly
	convert ../../contrib/gfx/covers/front-${1^^}-600dpi.png \
		-geometry x90% front.pdf
	convert ../../contrib/gfx/covers/back-${1^^}-600dpi.png \
		-geometry x90% back.pdf

	pdftk front.pdf \
		preweb.pdf \
		back.pdf \
		cat output web.pdf

	mv web.pdf \
		../../releases/web/sobtech2-${1^^}-with-covers-web-150dpi-2018-09-10-v2.pdf
	
	#cleaning up
	rm preweb.pdf front.pdf back.pdf
}

#################################################
renderbook nl dutch
#renderbook en english
#renderbook es spanish
#renderbook fr french
#renderbook it italian
