#!/bin/sh
rm /var/tmp/gamelist_directory
rm /var/tmp/tablerows.html
rm /var/tmp/temp_execfiles
if [ -f "./games_directory.html" ]; then
rm ./games_directory.html
fi

# Too many <object> tags causes a massive load delay.

# pkg-plist might be the beginning of the file name, there may be more than one depending if something like server vs client, such as xpilot-ng-server

ls -l /usr/ports/games/*/distinfo | cut -w -f 9 | sed -e "s:/distinfo::1" >> /var/tmp/gamelist_directory
 

for path in `cat /var/tmp/gamelist_directory`
do
portname=`echo -n $path | sed -e "s:Makefile::1" -e  "s:/usr/ports/games/::1"` 

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Setup Image directories
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
dir=./Images/animation/$portname
if [ -d "$dir" ] && files=$(ls -qAH -- "$dir") && [ -z "$files" ]; then
  printf '%s\n' "$dir is an empty directory"
else
if [ -d "$dir" ]; then
 printf '%s\n' "$dir already exists"
else
 mkdir $dir
fi
fi

dir=./Images/screenshot/$portname
if [ -d "$dir" ] && files=$(ls -qAH -- "$dir") && [ -z "$files" ]; then
  printf '%s\n' "$dir is an empty directory"
else
if [ -d "$dir" ]; then
 printf '%s\n' "$dir already exists"
else
 mkdir $dir
fi
fi

#if [ -d "$dir" ] && files=$(ls -qAH -- "$dir") && [ -z "$files" ]; then
#  printf '%s\n' "$dir is an empty directory"
#else
#  printf >&2 '%s\n' "$dir is not empty, or is not a directory" \
#                    "or is not readable or searchable in which case" \
#                    "you should have seen an error message from ls above."
#fi
#

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# --- Fill in data
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
game=`cat ./Data/$portname.txt | grep game= | sed -e 's:game=\t::1' -e 's:game= ::1' -e 's:game=::1'`
pkg=`cat ./Data/$portname.txt | grep pkg= | sed -e 's:pkg=\t::1' -e 's:pkg= ::1' -e 's:pkg=::1'`
maintype=`cat ./Data/$portname.txt | grep maintype= | sed -e 's:maintype=\t::1' -e 's:maintype= ::1' -e 's:maintype=::1'`
subtype=`cat ./Data/$portname.txt | grep subtype= | sed -e 's:subtype=\t::1' -e 's:subtype= ::1' -e 's:subtype=::1'`
supplemental=`cat ./Data/$portname.txt | grep supplemental= | sed -e 's:supplemental=\t::1' -e 's:supplemental= ::1' -e 's:supplemental=::1'`

echo "<tr>" >> /var/tmp/tablerows.html

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# --- Game name
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if [ -f "./Data/$portname.txt" ]; then
echo "<td>"$game"</td>" >> /var/tmp/tablerows.html
else
echo -n "<td>" >> /var/tmp/tablerows.html
echo -n "Missing, please create<br>" >> /var/tmp/tablerows.html
echo -n "./Data/"$portname".txt<br>" >> /var/tmp/tablerows.html
echo -n "and submit to project." >> /var/tmp/tablerows.html
echo "</td>" >> /var/tmp/tablerows.html
fi

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# --- Port name
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo -n "<td>">> /var/tmp/tablerows.html
echo $portname >> /var/tmp/tablerows.html ; echo "$path"
echo "</td>">> /var/tmp/tablerows.html

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# --- Executables
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo -n "<td>">> /var/tmp/tablerows.html

if [ -f "$path/pkg-plist" ]; then
rm /var/tmp/temp_execfiles
cat $path/pkg-plist | cut -w -f 2 | sed -e 's:^[^bin/]*::' |grep bin/ >> /var/tmp/temp_execfiles
for executable in `cat /var/tmp/temp_execfiles`
do
echo $executable | sed -e "s:bin/::g" >> /var/tmp/tablerows.html
done
else echo "(Makefile)"  >> /var/tmp/tablerows.html
fi
#else
#cat $path/Makefile | grep -e ^PLIST_FILES=(.*\n)*' | tr "[:space:]" "\n" | grep bin/ | sed -e "s:PLIST_FILES=::1" -e "s:{PORTNAME}:portname:1" >> /var/tmp/temp_execfiles
#cat $path/Makefile | grep ^PLIST_FILES= '.*Untracked files(.*\n)*' | tr "[:space:]" "\n" | grep bin/ | sed -e "s:PLIST_FILES=::1" -e "s:{PORTNAME}:portname:1" >> /var/tmp/temp_execfiles
#cat $path/Makefile | grep ^PLIST_FILES= | tr "[:space:]" "\n" | grep bin/ | sed -e "s:PLIST_FILES=::1" -e "s:{PORTNAME}:portname:1" >> /var/tmp/temp_execfiles
#for executable in `cat /var/tmp/temp_execfiles`
#do
#echo $executable | sed -e "s:bin/::g" >> /var/tmp/tablerows.html
#if (executable=\$portname) 
#then 
#echo $portname >> /var/tmp/tablerows.html
#else 
#echo $executable | sed -e "s:bin/::g" >> /var/tmp/tablerows.html
#fi
#done
#fi
echo "</td>">> /var/tmp/tablerows.html

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# --- Pkg name
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo "<td>"$pkg"</td>" >> /var/tmp/tablerows.html

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# --- Type
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo "<td>"$maintype"</td>" >> /var/tmp/tablerows.html

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# --- Sub-type(s)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo "<td>"$subtype"</td>" >> /var/tmp/tablerows.html

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# --- Makefile comment
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo "<td>"`cat $path/Makefile | grep COMMENT= | sed -e 's:COMMENT=\t::1' -e 's:COMMENT= ::1'`"</td>" >> /var/tmp/tablerows.html

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# --- Long Description
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo "<td>"`cat $path/pkg-descr | sed -e 's:* :\<br\>*\&nbsp\;:' -e 's:^- :\<br\>-\&nbsp\;:' -e 's:^$:\<br\>:' -e 's:\<br\> \<br\>:\<br\>:' -e 's:^ ::'`"</td>" >> /var/tmp/tablerows.html

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# --- Supplemental Information
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo "<td>"$supplemental"</td>" >> /var/tmp/tablerows.html

# Lazy load is nice but distracting. loading="lazy" beside alt="altname" and such.
# --- Screenshot
echo "<td><img id=\"screenshot\" src=\"screenshots/$portname.png\" onerror=\"this.onerror=null; this.src='drawing.svg';\" name=\"screenshot/$portname.png\" alt=\"screenshot/$portname.png\" /></td>" >> /var/tmp/tablerows.html


# --- Animation
echo "<td><img id=\"animation\" src=\"screenshots/$portname_anim.gif\" onerror=\"this.onerror=null; this.src='drawing.svg';\" name=\"animation/$portname.png\" alt=\"animation/$portname.png\" /></td>" >> /var/tmp/tablerows.html

echo "</tr>">> /var/tmp/tablerows.html
done

echo; echo; echo "Table data generation complete."

sleep 1

echo "Generating final html file concatenating 3 parts."

sleep 3

cat games_directory_top.html /var/tmp/tablerows.html games_directory_bottom.html > games_directory.html
