#!/bin/bash
#pandoc --csl=/home/maxigas/research/chicago-author-date.csl --bibliography=/home/maxigas/research/bib.bib -s -t revealjs slides.md -V theme=blood -o index.html
pandoc --standalone --to revealjs \
	--css="./custom.css" \
	--variable theme=moon \
	--output index.html \
	slides.md
