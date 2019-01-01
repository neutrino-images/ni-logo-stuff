#!/bin/sh

###############################################################################
#
# NI Senderlogo-Updater von fred_feuerstein [NI-Team]
#
# => dies ist das Startskript, sowie das Logo-Basispaket. 
#    Die eigentlichen Updates, Symlinks, Änderungen werden online 
#    nachgeladen und installiert.
#
# Ziel:
# Mit dem Updater kann ein Logo-Paket auf der Box (intern/extern)
# installiert und upgedatet werden.
# Dazu ist eine Internetverbindung erforderlich.
# Welche Logos hinzugekommen sind, könnt ihr im NI-Forum 
# www.neutrino-images.de sehen.
# Dort ist auch zusätzlich bei Bedarf ein Radio-Senderlogo-Paket zu finden.
#
#
###############################################################################

# Parameter
#############

# Update-URL für Download-Archiv
# url="https://www.neutrino-images.de/channellogos/"
# url="http://fredfeuerstein.bplaced.net/"
url="http://logoupdater.showpalast.com/"

# Aufrufvariante für Download, WGET oder CURL bitte auswählen
command="WGET"  # oder "CURL"

# Archiv-Name
archive="ni_zusatzlogos.zip"


# ab hier keine Änderungen mehr nötig
#####################################

workdir=${archive%%.*}
camurl="http://127.0.0.1/tmp/$workdir/intro.jpg"
repeat=""
string="PICTURE=intro,|JPG$repeat|$camurl"

cleanup() {
	rm -rf /tmp/$workdir /tmp/$archive /tmp/logo.txt
}

cleanup

echo $archive >> /tmp/logo.txt
echo $command >> /tmp/logo.txt
echo $url >> /tmp/logo.txt

if [ $command = "WGET" ]; then
  cd /tmp && wget -q $url$archive
 else
  cd /tmp && curl -ks $url$archive --output $archive
fi 


if [ -e $archive ]; then
	mkdir $workdir
	cd $workdir

	unzip /tmp/$archive >/dev/null

  if [ -e /tmp/$workdir/version.txt ]; then
    vinfo=$(cat /tmp/$workdir/version.txt)
  else
    vinfo="0.2x"
  fi

  msgbox popup="Logo-Updater wird gestartet ..." icon="/tmp/$workdir/logo.png" title="NI Logo-Updater $vinfo ($command)" timeout=02


  if [ -e /bin/tuxwetter ]; then
      /bin/tuxwetter "$string" >/dev/null &
      sleep 5
      killall tuxwetter >/dev/null
  fi

  if [ -e /tmp/$workdir/changelog.txt ]; then
    CHANGEDATETEMP=$(cat /tmp/$workdir/changelog.txt)
    CHANGEDATE1=`echo "$CHANGEDATETEMP" | grep Datenstand `
    CHANGEDATE=`echo ${CHANGEDATE1:26:10}`
    echo " "  >> /tmp/$workdir/info.txt
    echo "Datenstand des Updates: ~B"$CHANGEDATE"~S "  >> /tmp/$workdir/info.txt
  else
    CHANGEDATE="unbekannt"
  fi

	if [ -e info.txt ]; then
		msgbox msg=/tmp/$workdir/info.txt size=20 icon="/tmp/$workdir/logo.png" title="NI Logo-Updater $vinfo" select="OK,CANCEL" default=1 >/dev/null
		case $? in
		1)
			#Logo-Updater ausfuehren
			test -e updates && chmod 755 updates && ./updates
			if [ -e /tmp/$workdir/time.txt ]; then
					sek=$(cat /tmp/$workdir/time.txt)
				else
					sek="0 Sekunden"
			fi
			echo "- "$(date +"%H.%M.%S")" Uhr - Logo-Updater beendet. (Gesamtlaufzeit: "$sek")"
			;;
		*)
			#Abbruch
			if [ -e /tmp/$workdir/time.txt ]; then
					sek=$(cat /tmp/$workdir/time.txt)
				else
					sek="0 Sekunden"
			fi
			echo "- "$(date +"%H.%M.%S")" Uhr - Logo-Updater abgebrochen. (Gesamtlaufzeit: "$sek")"
			;;
		esac
	fi
else
	echo "- "$(date +"%H.%M.%S")" Uhr - Fehler beim Download von $archive"
fi

cleanup
