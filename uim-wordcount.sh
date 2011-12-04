#!/bin/sh
scmfile=$(readlink -f $(dirname $0)/uim-wordcount.scm)
if [ ! -t 0 ]; then	# data from stdin
	# XXX: bytes count may change after converting to utf-8
	nkf -w | uim-sh $scmfile
else
	for f
	do
		if [ -f $f ]; then
			# XXX: bytes count may change after converting to utf-8
			nkf -w $f | uim-sh $scmfile
		fi
	done
fi
