#!/bin/bash

echo "#--------------------------- Script start ------------------------------------#"
echo "#--->                                                                     <---#"
echo "#--------------------------- Script start ------------------------------------#"

#cd /var/www/repos/apt/debian 
cd /opt/lampp/htdocs/repos/apt 

#JESSIE_LIST=`eval sudo reprepro -C main -A armhf --list-format="${package}\n" list jessie`
echo ""
echo "Scr_MSG: Repo content before -->"
echo ""
LIST=`sudo reprepro -C main -A armhf --list-format='''${package}\n''' list jessie`

JESSIE_LIST1=$"${LIST}"

echo  "${JESSIE_LIST1}"

echo ""

if [ "${1}" == "-d" ]; then
	echo ""
	echo "Scr_MSG: Will clean repo"
	echo ""
	sudo reprepro -C main -A armhf remove jessie ${JESSIE_LIST1}
fi
echo ""

sudo reprepro -C main -A armhf includedeb jessie /home/mib/Development/hm3-beta2/arm-linux-socfpga-4.1.22-ltsi-rt-gnueabifh-kernel//*.deb
sudo reprepro export jessie

JESSIE_LIST2=$"${LIST}"
echo ""
echo "Scr_MSG: Repo content After: -->"
echo ""
echo  "${JESSIE_LIST2}"
echo ""
echo "#--------------------------- Script end --------------------------------------#"
echo "#--->                                                                     <---#"
echo "#--------------------------- Script end --------------------------------------#"



# 
# --list-format format
# 	Set  the  output  format  of  list,  listmatched and listfilter commands.  The format is similar to dpkg-query's --showformat: fields are specified as ${fieldname} or
# 	${fieldname;length}.  Zero length or no length means unlimited.  Positive numbers mean fill with spaces right, negative fill with spaces left.
# 
# 	\n, \r, \t, \0 are new-line, carriage-return, tabulator and zero-byte.  Backslash (\) can be used to escape every non-letter-or-digit.
# 
# 	The special field names $identifier, $architecture, $component, $type, $codename denote where the package was found.
# 
# 	The special field names $source and $sourceversion denote the source and source version a package belongs to.  (i.e.  ${$source} will either be the same as  ${source}
# 	(without a possible version in parentheses at the end) or the same as ${package}.
# 
# 	The  special  field  names $basename, $filekey and $fullfilename denote the first package file part of this entry (i.e. usually the .deb, .udeb or .dsc file) as base‐
# 	name, as filekey (filename relative to the outdir) and the full filename with outdir prepended (i.e. as relative or absolute as your outdir (or basedir if you did not
# 	set outdir) is).
# 
# 	When --list-format is not given or NONE, then the default is equivalent to
# 	${$identifier} ${package} ${version}\n.
# 
# 	Escaping  digits  or  letters  not  in above list, using dollars not escaped outside specified constructs, or any field names not listed as special and not consisting
# 	entirely out of letters, digits and minus signs have undefined behaviour and might change meaning without any further notice.
# 
# 	If you give this option on the command line, don't forget that $ is also interpreted by your shell.  So you have to properly escape it.  For example  by  putting  the
# 	whole argument to --list-format in single quotes.
# 
