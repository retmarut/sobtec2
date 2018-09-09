#!/bin/bash 

# Split a document into signatures to be able to print theme on A4
# to render pages as A5 2-up both sides.
# That makes 4 pages per sheet of A4

# The size of the signature is 32 pages equalling 8 sheets 
# of A4 paper each for DIY-folding and binding
#
SIGSIZE=32

if [ -z "$1" ]; then 
	echo "Please specify the booktitle as first argument to this script."
	exit 
fi

BOOK=$1

#Determine the amount of pages the PDF holds
PAGESIZE=$(pdfinfo $BOOK|grep Pages|cut -b 15-|xargs)

NUMOFSIGS=$(($PAGESIZE/$SIGSIZE + 1))

SIGCOUNT=1
BOOK=$(basename $1)

#Split the book in signature page sets ready for printing
mkdir signatures.d
for ((s=1,e=$SIGSIZE; e<=$NUMOFSIGS*SIGSIZE; s+=$SIGSIZE,e+=$SIGSIZE,SIGCOUNT+=1)); do
	echo "Splitting off Pages [" $s "-" $e "] as signature $SIGCOUNT"
	end=$e
	if (( $e>$PAGESIZE )) ; then
		end="end"
	fi
	
	#split off pages for signature
	pdftk A=${BOOK} cat A$s-$end output signatures.d/${BOOK%.*}-sig$SIGCOUNT.pdf

	#transform the part into a 8-leaf double-sided signature
	pdfbook signatures.d/${BOOK%.*}-sig$SIGCOUNT.pdf
	rm signatures.d/${BOOK%.*}-sig$SIGCOUNT.pdf

	#print result with double-side long-edge and in landscape
	echo ""
	echo "Suggested printing command"
	echo lp -o sides=two-sided-long-edge -o landscape ${BOOK%.*}-sig$SIGCOUNT-book.pdf
	echo ""
	echo "*******************************************************************************"
done
