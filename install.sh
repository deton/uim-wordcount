#!/bin/sh
scmdir=$(pkg-config --variable=uim_scmdir uim)
pixmapsdir=$(pkg-config --variable=uim_datadir uim)/pixmaps
cp wordcount.scm "$scmdir"
cp wordcount.png wordcount_dark_background.png "$pixmapsdir"
cp wordcount.svg wordcount_dark_background.svg "$pixmapsdir"
uim-module-manager --register wordcount
