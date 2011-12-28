#!/bin/sh
srcdir=$(dirname $0)
scmdir=$(pkg-config --variable=uim_scmdir uim)
pixmapsdir=$(pkg-config --variable=uim_datadir uim)/pixmaps
cp "$srcdir/wordcount.scm" "$scmdir"
cp "$srcdir/pixmaps/wordcount.png" "$srcdir/pixmaps/wordcount_dark_background.png" "$pixmapsdir"
cp "$srcdir/pixmaps/wordcount.svg" "$srcdir/pixmaps/wordcount_dark_background.svg" "$pixmapsdir"
uim-module-manager --register wordcount
