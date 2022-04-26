# FreeBSD Games Directory
## Synopsis
This idea is a collection of screenshots, animated gifs of play, sample configurations for varying levels of performance, along with descriptions, all for the games available via the FreeBSD ports system.

### Preliminary concept, form
- An html interface will permit fairly easy sort functions in a table and provide access to other features via web browser.
- Added links to places to obtain additional files for use with games or game engines.
- Mechanism for translations of the html content.  Should game descriptions get translations?

### Sundry formats - ideas
- Reasonable screenshot size/res: 1280x1024?  * except if lacking detail a larger screen size may provide.
- Initial description pulled directly from port pkg-descr file.
- Comment from Makefile as short description.
- Executables list from pkg-plist.
- How shall the Directory specific contents be organized?  Seperate directories with portname?
- Verbose description unique to the directory, maybe include external links there?
- tags, categories, other sort labels
- more

### Community involvement
Once this has a framework, at least a few games with their table items, other FreeBSD users are welcome to add.

### Use (at present)
First obtain the content of this repo by your preferred method, then simply, as root for /var/tmp access: ./games_directory_top.html
#### What happens
The ports_games_rows.sh shellscript will create a hierarchy of directories: ./Images/animation ./Images/screenshot and an empty directory for each port that does not yet have its own directory, so ./Images/animation/0ad and ./Images/screenshot/0ad for example.
It will process any existing ./Data/$portname.txt files for the game name, pkg name, type, subtype, and supplemental values. Those whose data file is missing or does not exisit will have a generation/contribute message inserted in the game name field. Once these tasks are complete, it will then generate the middle portion of the html file and then concatenate the three together: 
- games_directory_top.html, 
- /var/tmp/tablerows.html, and 
- games_directory_bottom.html.

View the resulting table with your web browser of choice.  

###### Testing done via firefox, other browser functionality unknown but attempt to use standards while expecting newer versions of browsers would be used.
