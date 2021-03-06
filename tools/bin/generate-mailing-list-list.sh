#!/bin/sh

# Generate web pages that can be used for monitoring and editing mailing lists
#
# The reason for the need for this script is that it is somewhat cumbersome
# to click through the Tigris site to examine that all mailing lists are
# set correctly and to remember what they are supposed to be set to.

dir=generated
test -d $dir || mkdir $dir

EDIT=$dir/edit.html
VIEW=$dir/view.html
SUBSCRIBERS=$dir/subs.html

files="$EDIT $VIEW $SUBSCRIBERS"
# First the projects directly under argouml
# Then the projects under seeds
# Last, all other projects
projects="argouml \
    argouml-andromda \
    argouml-classfile \
    argouml-cpp \
    argouml-csharp \
    argouml-de \
    argouml-downloads \
    argouml-en-gb \
    argouml-es \
    argouml-fr \
    argouml-gen \
    argouml-i18n-zh \
    argouml-idl \
    argouml-mdr \
    argouml-nb \
    argouml-php \
    argouml-pt \
    argouml-pt-br \
    argouml-python \
    argouml-ru \
    argouml-ruby \
    argouml-sql \
    argouml-stats \
    argoumlinstaller \
    seeds \
    argopdf \
    argoprint \
    argouml-actionscript3 \
    argouml-ada \
    argouml-atl \
    argouml-ca \
    argouml-delphi \
    argouml-emf \
    argouml-hi \
    argouml-it \
    argouml-ja \
    argouml-java \
    argouml-javascript \
    argouml-pattern-wizard \
    argouml-python \
    argouml-ro \
    argouml-sequence \
    argouml-sv \
    argouml-zh-cn \
    argouml-zh-tw \
    \
    argouml-ar \
"


lists="dev cvs issues users commits announce"

for f in $files
do
    echo "<!-- This file was generated by the script $Id$ -->" > $f
    echo '<HTML>' >> $f
    echo '<HEAD><TITLE>Mailing list administration for the ArgoUML projects</TITLE></HEAD>' >> $f
    echo '<BODY>' >> $f
    echo '<a name="top"></a>' >> $f
done

# First we generate the index
for f in $files
do
    for proj in $projects
    do
        echo "$proj: " >> $f
        for listname in $lists
	do
            echo "<a href=\"#$proj-$listname\">$listname</a>" >> $f
        done
        echo "<br>" >> $f
    done

    echo "<hr>" >> $f
done

# The delay is increased once per list. For every lap we write several
# lists in different files so each file will bigger delays...
delay=10000
delayincr=1000

# Here is a function for one list.
# The arguments are:
# 1 - the servlet and arguments
# 2 - the project
# 3 - the listname
function onelist() {
    echo "<a href=\"http://$2.tigris.org/nonav/servlets/$1\" target=\"frame-$2-$3$4\">Refetch</a>"
    echo "<a href=\"http://$2.tigris.org/servlets/MailingListEdit?list=$3\" target=\"_blank\">Open Edit</a>"
    echo "<a href=\"http://$2.tigris.org/servlets/SummarizeList?list=$3\" target=\"_blank\">Open View</a>"
    for subscribersalt in Subscribers Digest+Subscribers Moderators Allowed+Posters
    do
        echo "<a href=\"http://$2.tigris.org/servlets/MailingListMembers?list=$3&group=$subscribersalt\" target=\"_blank\">Open $subscribersalt</a>"
    done

    echo "<br>"
    echo "<IFRAME name=\"frame-$2-$3$4\" width=\"800\" height=\"600\"></IFRAME>"
    echo "<script>"
    echo "setTimeout(\"document.frames('frame-$2-$3$4').location.href='http://$2.tigris.org/nonav/servlets/$1'\", $delay)"
    echo "</script>"
    echo "<br>"
    delay=`expr $delay + $delayincr`

}


for listname in $lists
do
    for f in $files
    do
	echo '<h1>' >> $f
        echo "$listname" >> $f
	echo '</h1>' >> $f
    done

    for proj in $projects
    do
        for f in $files
	do
	    echo '<DIV class="h2"><h2>' >> $f
            echo "<a name=\"$proj-$listname\">$listname in the project $proj</a>" >> $f
	    echo '</h2>' >> $f
            echo "<a href=\"#top\">Top</a> " >> $f
        done

	case $listname in
	announce)
	    echo '<p>Announce list Moderated.</p>' >> $EDIT
	    for f in $files
	    do
	        echo '<p>The announce mailing list is just present in the main project.</p>' >> $f
	    done
	    ;;
        cvs)
	    for f in $files
	    do
	        echo '<p>' >> $f
	        echo 'The cvs mailing lists are to be removed' >> $f
		echo 'autumn 2007' >> $f
	        echo 'unless in new projects where they are empty.' >> $f
	        echo '</p>' >> $f
	    done
	    ;;
        dev|users)
	    echo '<p>' >> $EDIT
	    echo 'Description: Emphasize in the description on the purpose:' >> $EDIT
	    echo 'this project.' >> $EDIT
	    echo '</p>' >> $EDIT
	    ;;
        esac

	echo '<p>' >> $EDIT
	echo "<nobr>Owner: owner@$proj.tigris.org,</nobr>" >> $EDIT
        case $listname in
        commits)
	    echo "<nobr>Prefix: none,</nobr>" >> $EDIT
	    ;;
        *)
	    echo "<nobr>Prefix: [$proj-$listname],</nobr>" >> $EDIT
	    ;;
	esac
	echo '<nobr>Trailer: checked,</nobr>' >> $EDIT
	echo '<nobr>Private: not checked,</nobr> and' >> $EDIT
	case $listname in
        announce|cvs)
	    echo '<nobr>Type: moderated.</nobr>' >> $EDIT
	    ;;
	*)
	    echo '<nobr>Type: discuss.</nobr>' >> $EDIT
	    ;;
	esac
	echo '</p>' >> $EDIT

	onelist MailingListEdit?list=$listname $proj $listname >> $EDIT
	onelist SummarizeList?list=$listname $proj $listname >> $VIEW

	for subscribersalt in Subscribers Digest+Subscribers Moderators Allowed+Posters
	do
	    echo '<DIV class="h3"><h3>' >> $SUBSCRIBERS
            echo "$subscribersalt for $listname in the project $proj" >> $SUBSCRIBERS
	    echo '</h3>' >> $SUBSCRIBERS

	    onelist "MailingListMembers?list=$listname&group=$subscribersalt" $proj $listname $subscribersalt >> $SUBSCRIBERS

	    echo '</DIV>' >> $SUBSCRIBERS
        done

        for f in $files
	do
	    echo '</DIV>' >> $f
        done
    done
done

for f in $files
do
    echo '</BODY></HTML>' >> $f
done
