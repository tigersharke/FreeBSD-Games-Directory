#!/bin/sh
rm /var/tmp/gamelist_directory
rm /var/tmp/tablerows.html
ls -l /usr/ports/games/*/distinfo | cut -w -f 9 | sed -e "s:/distinfo::1" >> /var/tmp/gamelist_directory
 
# This document.write trick is a magic container that helps it be included!
echo "document.write(\`" >> /var/tmp/tablerows.html

for path in `cat /var/tmp/gamelist_directory`
do
echo "<tr>" >> /var/tmp/tablerows.html

# --- Game name
echo -n "<td>">> /var/tmp/tablerows.html
echo "</td>">> /var/tmp/tablerows.html

# --- Port name
echo -n "<td>">> /var/tmp/tablerows.html
echo -n $path | sed -e "s:Makefile::1" -e  "s:/usr/ports/games/::1" >> /var/tmp/tablerows.html ; echo "$path"
echo "</td>">> /var/tmp/tablerows.html

# --- Executables
echo -n "<td>">> /var/tmp/tablerows.html
for executable in `cat $path/pkg-plist | cut -w -f 2 | grep ^bin/`
do
echo $executable| sed -e "s:bin/::1" >> /var/tmp/tablerows.html
done
echo "</td>">> /var/tmp/tablerows.html

# --- Pkg name
echo -n "<td>">> /var/tmp/tablerows.html
echo "</td>" >> /var/tmp/tablerows.html

# --- Type
echo -n "<td>">> /var/tmp/tablerows.html
echo "</td>" >> /var/tmp/tablerows.html

# --- Sub-type(s)
echo -n "<td>">> /var/tmp/tablerows.html
echo "</td>" >> /var/tmp/tablerows.html

# --- Makefile comment
echo -n "<td>">> /var/tmp/tablerows.html
echo "</td>" >> /var/tmp/tablerows.html

# --- Long Description
echo -n "<td>">> /var/tmp/tablerows.html
echo -n "<object type=\"text/plain\" data=\"$path/pkg-descr\"/>" >> /var/tmp/tablerows.html
echo "</td>" >> /var/tmp/tablerows.html

# --- Supplemental Information
echo -n "<td>">> /var/tmp/tablerows.html
echo "</td>">> /var/tmp/tablerows.html

# --- Screenshot
echo "<td><img id=\"imgProd1\" src=\"someimage.gif\" onerror=\"this.onerror=null; this.src='drawing.svg';\" /></td>" >> /var/tmp/tablerows.html

# --- Animation
echo -n "<td>">> /var/tmp/tablerows.html
echo "</td>">> /var/tmp/tablerows.html

echo "</tr>">> /var/tmp/tablerows.html
done
# This is the magic container that helps it be included!
echo "\`);" >> /var/tmp/tablerows.html

cp /var/tmp/tablerows.html ./tablerows.js
echo; echo; echo "Task complete."
