#!/bin/sh
#set -e		# exit on error?
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

# careful with spaces in variable assignments.
# first in /usr/ports make index, then can make search key="game" cat="games" or something.
# Too many <object> tags causes a massive load delay.
# a missing ` will cause insane errors which include indicating an entirely wrong location of the error!
# pkg-plist might be the beginning of the file name, there may be more than one depending if something like server vs client, such as xpilot-ng-server

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Get a definite list of games in /usr/ports/games
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# [ -z "$pd" ] && pd=/usr/ports
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
# --- Parse file to fill-in data
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
game=""
executables=""
pkg=""
type=""
subtype=""
help=""
supplemental=""
if [ -f "./Data/$portname.txt" ]; then
game=`cat ./Data/$portname.txt | sed -n '/[<GAME>\s\S]*<\/GAME>/p'`
pkg=`cat ./Data/$portname.txt | sed  -n '/[<PKG>\s\S]*<\/PKG>/p'`
type=`cat ./Data/$portname.txt | sed  -n '/[<TYPE>\s\S]*<\/TYPE>/p'`
subtype=`cat ./Data/$portname.txt | sed  -n '/[<SUBTYPE>\s\S]*<\/SUBTYPE>/p'`
help=`cat ./Data/$portname.txt |sed  -n '/[<HELP>\s\S]*<\/HELP>/p'` 
fi

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# --- Build table rows
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

echo "<tr>" >> /var/tmp/tablerows.html

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# --- Game name
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if [ -f "./Data/$portname.txt" ]; then
echo "<td class=\"column0\">"$game"</td>" >> /var/tmp/tablerows.html
else
echo -n "<td class=\"column0\">" >> /var/tmp/tablerows.html
echo -n "No ./Data<br>" >> /var/tmp/tablerows.html
echo "</td>" >> /var/tmp/tablerows.html
fi
game=""

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# --- Port name
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo -n "<td class=\"column1\">">> /var/tmp/tablerows.html
echo $portname >> /var/tmp/tablerows.html ; echo "$path"
echo "</td>">> /var/tmp/tablerows.html

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# --- Executables
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo -n "<td class=\"column2\">">> /var/tmp/tablerows.html
if [ -f /var/tmp/temp_parsedfiles ]; then
rm /var/tmp/temp_parsedfiles
fi
if [ -f /var/tmp/manpages ]; then
rm /var/tmp/manpages
fi
if [ -f "$path/pkg-plist" ]; then
cat $path/pkg-plist | cut -w -f 2 | sed -e 's|\%||g' >> /var/tmp/temp_parsedfiles
cat /var/tmp/temp_parsedfiles | grep bin/ | sed -e 's|\%||g' -e 's|^[^bin/]*||g' -e 's|bin/||g' >> /var/tmp/temp_execfiles
for executable in `cat /var/tmp/temp_execfiles`
do
echo $executable | sed -e 's:-:\&#8209\;:g' >> /var/tmp/tablerows.html

# Desktop entry data will be better if it can be parsed for non-redundant information or other reasons.
# at least one game (alephone) seems to have overlaps between its game, scenarios, and game-data parts.

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~      
# Grab data from .desktop entry if it exists.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~      
desktop_file=""
verified_desktop_file=""
desktop_file=`grep -R -l Exec\=$executable /usr/local/share/applications/* `

[ ! -z "$desktop_file" ] && verified_desktop_file=`grep -l Exec\=$executable $desktop_file`
[ ! -z "$verified_desktop_file" ] && supplemental=`cat $verified_desktop_file`

done
rm /var/tmp/temp_execfiles
else
make -C $path -V PLIST_FILES | tr "[:space:]" "\n" >> /var/tmp/temp_parsedfiles
cat /var/tmp/temp_parsedfiles | grep bin/ | sed -e 's|^[^bin/]*||g' -e 's|bin/||g' >> /var/tmp/temp_execfiles
for executable in `cat /var/tmp/temp_execfiles`
do
echo $executable | sed -e 's:-:\&#8209\;:g' >> /var/tmp/tablerows.html
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Grab data from .desktop entry if it exists.
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
desktop_file=""
verified_desktop_file=""
desktop_file=`grep -R -l Exec\=$executable /usr/local/share/applications/* `

[ ! -z "$desktop_file" ] && verified_desktop_file=`grep -l Exec\=$executable $desktop_file`
[ ! -z "$verified_desktop_file" ] && supplemental=`cat $verified_desktop_file`

done
if [ -f /var/tmp/temp_execfiles ]; then
rm /var/tmp/temp_execfiles
fi
fi
cat /var/tmp/temp_parsedfiles | grep man[1-9]/ | sed -e 's|\%||g' -e 's|share/||g' -e 's/man\/man/man/g' -e 's/[0-9]\.gz//' -e 's/\.//g' >> /var/tmp/manpages

echo "</td>">> /var/tmp/tablerows.html

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# --- Pkg name
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo "<td class=\"column3\">"$pkg"</td>" >> /var/tmp/tablerows.html
pkg=""

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# --- Type
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo "<td class=\"column4\">"$type"</td>" >> /var/tmp/tablerows.html
type=""

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# --- Sub-type(s)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo "<td class=\"column5\">"$subtype"</td>" >> /var/tmp/tablerows.html
subtype=""

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# --- Makefile comment (combined with long descr + virtual category)
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo "<td class=\"column6\">" >> /var/tmp/tablerows.html
[ -z "$temp" ] && temp=`make -C $path -V COMMENT`
if [ ! -z "$temp" ]
then
echo $temp >> /var/tmp/tablerows.html
echo "<hr class=\"break\">" >> /var/tmp/tablerows.html
temp=""
fi

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# --- Long Description
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
maintainer=`make -C $path -V MAINTAINER`
if [ "$maintainer" = "ports@FreeBSD.org" ] ; then 
echo "<span class=\"maint\">Maintainer needed <a onclick="on\(\)">(info)</a></span><br>" >> /var/tmp/tablerows.html
fi

if [ -f "$path/pkg-descr" ]; then
cat $path/pkg-descr| sed -e 's:<:\&lt\;:g' -e 's:>:\&gt\;:g'  -e 's:\ :\&nbsp\;:g' -e 's:^-:\<br\>-:' -e 's:^*:\<br\>*:' -e 's:^$:\<br\>:' >> /var/tmp/tablerows.html
else
echo "---pkg-descr missing---" >> /var/tmp/tablerows.html
fi

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# --- Virtual categories
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
[ -z "$vcat" ] && vcat=`make -C $path -V CATEGORIES |sed -e 's/games//g' -e 's/^ //' -e 's/ /, /g'`
if [ ! -z "$vcat" ]
then
echo "<hr class=\"break\">" >> /var/tmp/tablerows.html
echo "<span class=\"virtcat\">Virtual Categories: "$vcat"</span>" >> /var/tmp/tablerows.html
echo >> /var/tmp/tablerows.html
vcat=""
fi
echo "</td>" >> /var/tmp/tablerows.html

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# --- Help Output
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo "<td class=\"column7\">" >> /var/tmp/tablerows.html
if [ -f /var/tmp/manpages ]; then 
cat /var/tmp/manpages >> /var/tmp/tablerows.html
echo >> /var/tmp/tablerows.html
fi
if [ -f "./Data/Help/$portname.txt" ]; then
cat ./Data/Help/$portname.txt| sed -e 's:<:\&lt\;:g' -e 's:>:\&gt\;:g'  -e 's:\ :\&nbsp\;:g' -e 's:^-:\<br\>-:' -e 's:^*:\<br\>*:' -e 's:^$:\<br\>:' >> /var/tmp/tablerows.html
echo "</td>" >> /var/tmp/tablerows.html
else
echo $help >> /var/tmp/tablerows.html
echo "</td>" >> /var/tmp/tablerows.html
fi
help=""

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# --- Supplemental Information
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo "<td class=\"column8\">"$supplemental"</td>" >> /var/tmp/tablerows.html
supplemental=""

# Lazy load is nice but distracting. loading="lazy" beside alt="altname" and such.
# --- Screenshot
echo "<td class=\"column9\"><img id=\"screenshot\" src=\"screenshots/$portname.png\" onerror=\"this.onerror=null; this.src='drawing.svg';\" name=\"screenshot/$portname.png\" alt=\"screenshot/$portname.png\" /></td>" >> /var/tmp/tablerows.html


# --- Animation
echo "<td class=\"column10\"><img id=\"animation\" src=\"screenshots/$portname_anim.gif\" onerror=\"this.onerror=null; this.src='drawing.svg';\" name=\"animation/$portname.png\" alt=\"animation/$portname.png\" /></td>" >> /var/tmp/tablerows.html

echo "</tr>">> /var/tmp/tablerows.html
done

echo; echo; echo "Table data generation complete."

sleep 1

echo "Generating final html file concatenating 3 parts."

sleep 2

cat ./games_directory_top.html /var/tmp/tablerows.html ./games_directory_bottom.html > games_directory.html
