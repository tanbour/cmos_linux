cp -f liblist_6T.tcl liblist_6T.csh
cp -f liblist_7d5T.tcl liblist_7d5T.csh
sed -i 's/ "/ = "/g' liblist_6T.csh
sed -i 's/ "/ = "/g' liblist_7d5T.csh

