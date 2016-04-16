#!/bin/sh

debug=1

warning() {
	test $debug = 0 && return
	echo -e "\033[40;0;33mWARNING:\033[0m ${delete_db##*/} line $line: $@"
}

delete_db="delete.db"

test -f $delete_db	|| { echo "Delete database does not exist, exiting..." ;	exit 0 ; }

remove="rm"
if [ "$1" == "git" ]; then
	remove="git rm"
fi

line=0
while read content # from $delete_db
do
	line=$((line+1))		# count lines

	case "${content:0:1}" in
		"#"|";") continue ;;	# ignore commented lines
	esac

	content=${content%%#*}		# strip trailing comments
	content=$(echo $content)	# cleanup from spaces

	test -n "$content" || continue	# an empty line

	eval _content='$content'
	set -- $_content
	chid=$1

	# some annoying console-spam to help us to keep the database as clean as possible
	if [ -z "$chid" ]
	then
		warning "syntax error"
		continue
	elif [ ! -e "logos/$chid.png" ]
	then
		warning "file logos/$chid.png not exist"
		continue
	fi

	# all tests passed. lets delete it.
	echo "deleting $chid.png"
	$remove -f "logos/$chid.png"
done < $delete_db
