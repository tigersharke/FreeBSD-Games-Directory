#!/bin/sh
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Reset files to start fresh
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if [ -f "/var/tmp/gamelist_directory" ]; then
rm /var/tmp/gamelist_directory
fi
if [ -f "/var/tmp/tablerows.html" ]; then
rm /var/tmp/tablerows.html
fi
if [ -f "/var/tmp/temp_execfiles" ]; then
rm /var/tmp/temp_execfiles
fi
if [ -f "./games_directory.html" ]; then
rm ./games_directory.html
fi

# first in /usr/ports make index, then can make search key="game" cat="games" or something.
# Too many <object> tags causes a massive load delay.
# a missing ` will cause insane errors which include indicating an entirely wrong location of the error!
# pkg-plist might be the beginning of the file name, there may be more than one depending if something like server vs client, such as xpilot-ng-server

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Get a definite list of games in /usr/ports/games
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ls -l /usr/ports/games/*/distinfo | cut -w -f 9 | sed -e 's:/distinfo::' > /var/tmp/gamelist_directory
 

for path in `cat /var/tmp/gamelist_directory`
do
portname=`echo -n $path | sed -e 's:/usr/ports/games/::1'` 

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Setup Image directories
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#dir=./Images/animation/$portname
#if [ -d "$dir" ] && files=$(ls -qAH -- "$dir") && [ -z "$files" ]; then
#  printf '%s\n' "$dir is an empty directory"
#else
#if [ -d "$dir" ]; then
# printf '%s\n' "$dir already exists"
# echo $portname >> ./animskip.txt
#else
# mkdir $dir
#fi
#fi

##rm /var/tmp/cleaned_blacklist 2>/dev/null
##grep -v \# ~/Symbolic_Links/13amd64-blacklist | sort -d -u >> /var/tmp/cleaned_blacklist
##
##diff $1 /var/tmp/cleaned_blacklist | grep \< |sed  -e 's/^<\ //g' -e 's/---//g' -e '1d' > ~/$1-deblack
##
##echo $1-deblack

#dir=./Images/screenshot/$portname
#if [ -d "$dir" ] && files=$(ls -qAH -- "$dir") && [ -z "$files" ]; then
#  printf '%s\n' "$dir is an empty directory"
#else
#if [ -d "$dir" ]; then
# printf '%s\n' "$dir already exists"
# echo $portname >> ./shotskip.txt
#else
# mkdir $dir
#fi
#fi

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# --- Parse file to fill-in single line data
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if [ -f "./Data/$portname.txt" ]; then
game=`cat ./Data/$portname.txt | grep \<GAME\> | sed -e 's:<GAME>::' -e 's:<\/GAME>::'`
pkg=`cat ./Data/$portname.txt | grep \<PKG\> | sed -e 's:<PKG>::' -e 's:<\/PKG>::'`
type=`cat ./Data/$portname.txt | grep \<TYPE\> | sed -e 's:<TYPE>::' -e 's:<\/TYPE>::'`
subtype=`cat ./Data/$portname.txt | grep \<SUBTYPE\> | sed -e 's:<SUBTYPE>::' -e 's:<\/SUBTYPE>::'`
supplemental=`cat ./Data/$portname.txt | grep \<SUPPLEMENTAL\> | sed -e 's:<SUPPLEMENTAL>::' -e 's:<\/SUPPLEMENTAL>::'`
else
game=""
pkg=""
type=""
subtype=""
supplemental=""
fi

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
cat $path/pkg-plist | cut -w -f 2 | sed -e 's:^[^bin/]*::' |grep bin/ >> /var/tmp/temp_execfiles
for executable in `cat /var/tmp/temp_execfiles`
do
echo $executable | sed -e 's:bin/::g' -e 's:-:\&#8209\;:g' >> /var/tmp/tablerows.html
done
rm /var/tmp/temp_execfiles
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
echo "<td>"$type"</td>" >> /var/tmp/tablerows.html

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# --- Sub-type(s)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo "<td>"$subtype"</td>" >> /var/tmp/tablerows.html

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# --- Makefile comment
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo "<td>" >> /var/tmp/tablerows.html
cat $path/Makefile | grep COMMENT= | sed -e 's:COMMENT=\t::1' -e 's:COMMENT= ::1' >> /var/tmp/tablerows.html
echo "</td>" >> /var/tmp/tablerows.html

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# --- Long Description
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo "<td>" >> /var/tmp/tablerows.html
if [ -f "$path/pkg-descr" ]; then
#cat $path/pkg-descr |sed -e 's:\ :\&nbsp\;:' -e 's:* :\<br\>*\&nbsp\;:' -e 's:^- :\<br\>-\&nbsp\;:' -e 's:^$:\<br\>:' -e 's:\<br\> \<br\>:\<br\>:' -e 's:^ ::' -e 's:WWW\: :\<br\> WWW\:\&nbsp\;:g' >> /var/tmp/tablerows.html
cat $path/pkg-descr| sed -e 's:<:\&lt\;:g' -e 's:>:\&gt\;:g'  -e 's:\ :\&nbsp\;:g' -e 's:^-:\<br\>-:' -e 's:^*:\<br\>*:' -e 's:^$:\<br\>:' >> /var/tmp/tablerows.html
else
echo "pkg-descr missing" >> /var/tmp/tablerows.html
fi
echo "</td>" >> /var/tmp/tablerows.html

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# --- Help Output
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo "<td>" >> /var/tmp/tablerows.html
if [ -f "./Data/Help/$portname.txt" ]; then
cat ./Data/Help/$portname.txt| sed -e 's:<:\&lt\;:g' -e 's:>:\&gt\;:g'  -e 's:\ :\&nbsp\;:g' -e 's:^-:\<br\>-:' -e 's:^*:\<br\>*:' -e 's:^$:\<br\>:' >> /var/tmp/tablerows.html
echo "</td>" >> /var/tmp/tablerows.html
else
echo "</td>" >> /var/tmp/tablerows.html
fi

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
