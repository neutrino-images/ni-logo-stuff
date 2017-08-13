#!/bin/bash

debug=1

warning() {
	test $debug = 0 && return
	echo -e "\033[40;0;33mWARNING:\033[0m ${provider##*/} line $line: $@"
}

case $# in
	2)
		provider=$1
		logodir=$2
	;;
	*)
		echo "Usage: ${0##*/} <provider file> <ng logodir>"
		exit 1
	;;
esac

test -f $provider	|| { echo "Provider file $provider does not exist, exiting..." ;	exit 1 ; }
test -d $logodir	|| { echo "Logodir $logodir does not exist, exiting..." ;		exit 1 ; }

line=0
while read content # from $provider
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
	link=$2

	# some annoying console-spam to help us to keep the database as clean as possible
	if [ -z "$chid" -o -z "$link" ]
	then
		warning "syntax error"
		continue
	elif [ "$chid" = "$link" ]
	then
		warning "linkname $link same as channelid $chid"
		continue
	elif [ ! -f "$logodir/$chid.png" ]
	then
		warning "logo $chid.png not found"
		continue
	elif [ -L "$logodir/$chid.png" ]
	then
		warning "logo $chid.png is a symlink"
		#continue
	elif [ -L "$logodir/$link.png" ]
	then
		warning "link $link.png already exist as a symlink"
		continue
	elif [ -f "$logodir/$link.png" ]
	then
		warning "link $link.png already exist as a regular file"
		continue
	fi

	# all tests passed. lets symlink it.
	#echo "linking $chid.png -> $link.png"
	ln -s "$chid.png" "$logodir/$link.png"
done < $provider
