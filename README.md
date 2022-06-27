# FreeBSD Games Directory
## Synopsis
This idea is a collection of screenshots, animated gifs of play, sample configurations for varying levels of performance, along with descriptions, all for the games available via the FreeBSD ports system. 

### Present concept
- An html interface will permit fairly easy sort functions in a table and provide access to other features via web browser.
- Added links to places to obtain additional files for use with games or game engines.
- Mechanism for translations of the html content.  How can game descriptions get translations?
- Preferred zero or very limited dependencies aside from a web browser or html/css viewer/parser application.

### Ideas
- Reasonable screenshot png, size/res: 1280x1024?  * except if lacking detail a larger screen size may provide.
- Initial description pulled directly from port pkg-descr file.
- Comment from Makefile as short description.
- Executables list from pkg-plist.
- How shall the Directory specific contents be organized?  Seperate directories with portname?
- Verbose description unique to the directory, maybe include external links there?
- tags, categories, other sort labels
- I suspect the pkg name and port name and game name may sometimes differ, but if they do not, the ones that always guaranteed the same can be merged
- At present, supplemental field (former "verbose description") is being filled with the .desktop file content
- Add a way to include games not yet in the ports tree, likely by way of a complete file, possibly override if added to FreeBSD ports?
- Method to check whether any item has new info added so as to skip if already included in the Directory
- Provide html/css output file regardless, but eventually transition to using mysql database for maintaining 
- Once database enabled, keep rudimentary info parsing methods to allow easiest dependency-free community contributions
- Makefile acting upon this github repo, distinfo, etc. Option to include database dependencies 
- more

### Community involvement
Welcome BSDNow listeners! (https://www.bsdnow.tv/457)

Although the primary intent is to provide the directory for FreeBSD ports, the method of constructing this resource can be used to add games not yet in the FreeBSD ports tree, probably with some small adjustments. A large portion has been constructed but it is far from complete and may not all be in its final form. I am not an expert with shell scripting or sed or awk, or many other things relating to parsing text files but I do the best I can. I may not be satisfied with the results at any given moment, though imperfect may remain until I figure out something more.  My local copy is frequently revised and often less perfect than the more recent commit, and regressions occur often when I do update. 

I welcome comments and involvement though I am quite new to attempting this here on github. If I need to make adjustments to improve involvement of other FreeBSD contributors, I can do so when I know what I need to change.

Email: contactme_on_github@incogneato.co 

### Use (at present)
First obtain the content of this repo by your preferred method, then simply: ./ports_games_rows.sh

If /var/tmp access is denied, you may need to adjust your fstab accordingly.

https://forums.FreeBSD.org/threads/correct-way-of-securing-tmp-and-var-tmp-in-freebsd.30864/post-171745
#### What happens
The shell script iterates through the ports tree games directory to obtain the bulk of the information. A recent improvement will add the content of any existing .desktop files into their respective rows, although this is not done with much finesse. It will process any existing ./Data/$portname.txt files for the game name, pkg name, type, subtype, and supplemental values. The 'help output' is captured from the commandline manually and seperate from the script and is added as a txt file which the shell script parses and includes.
The ports_games_rows.sh shellscript will create a hierarchy of directories: ./Images/animation ./Images/screenshot and an empty directory for each port that does not yet have its own directory, so ./Images/animation/0ad and ./Images/screenshot/0ad for example. As there are really neither screenshots nor animations, these lines are nullified in the script (commented out) at present.
 Once all these tasks are complete, it will then generate the middle portion of the html file and then concatenate the three together: 
- games_directory_top.html, 
- /var/tmp/tablerows.html, and 
- games_directory_bottom.html.

##### View the resulting table with your web browser of choice.  

###### Testing done via firefox, other browser functionality unknown but attempt to use standards while expecting newer versions of browsers would be used.
