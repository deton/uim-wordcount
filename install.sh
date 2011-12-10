#!/bin/sh
scmdir=$(pkg-config --variable=uim_scmdir uim)
pixmapsdir=$(pkg-config --variable=uim_datadir uim)/pixmaps
cp wordcount.scm "$scmdir"
cp pixmaps/wordcount.png pixmaps/wordcount_dark_background.png "$pixmapsdir"
cp pixmaps/wordcount.svg pixmaps/wordcount_dark_background.svg "$pixmapsdir"
uim-module-manager --register wordcount
