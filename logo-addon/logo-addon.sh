#!/bin/sh

###############################################################################
#
# Senderlogo-Updater 0.17 fred_feuerstein [NI-Team]
#
# Ziel:
# Mit dem Updater werden die neuen und/oder geänderten Senderlogos seit dem
# letzten NI Image Release (aktuell NI 3.2) ins Image geholt.
# Diese werden automatisch in das Logo-Verzeichnis:
# /share/tuxbox/neutrino/icons/logo kopiert bzw. vorhandene aktualisiert.
# Dazu ist eine Internetverbindung erforderlich.
# Welche Logos hinzugekommen sind, könnt ihr im NI-Forum sehen.
# Thread: Kleines Logopaket (Ergaenzung zum X.xx NI Image)
# Dort ist auch zusätzlich bei Bedarf ein Radio-Senderlogo-Paket zu finden.
#
# 
#
# Changelog:
# 0.17 = Auswahl ob Logos intern / extern (logo-hdd-dir) gespeichert werden
# 0.16 = Logo-Updater kann nun auch vor dem Start wieder beendet werden
# 0.15 = Anpassungen an Update-Skript
# 0.14 = Anpassungen an Update-Skript
# 0.13 = Anpassungen an Update-Skript
# 0.05 = Download-URL und Dateiname angepasst (NG -> NI)
# 0.04 = Marginale Ausgabe-Änderungen
# 0.03 = kleine Änderungen
# 0.02 = bisher konnten nur Logos upgedated werden, nun
#        koennen auch neue Symlinks angelegt werden.
# 0.01 = Startversion
#
###############################################################################

archive="ni_zusatzlogos.zip"
workdir=${archive%%.*}
echo $archive >> /tmp/logo.txt

vinfo="0.17"

cleanup() {
	rm -rf /tmp/$workdir /tmp/$archive
}

cleanup

cd /tmp && wget -q http://www.neutrino-images.de/channellogos/$archive

if [ -e $archive ]; then
	mkdir $workdir
	cd $workdir

	unzip /tmp/$archive >/dev/null

	if [ -e info.txt ]; then
		msgbox msg=/tmp/$workdir/info.txt icon="/tmp/$workdir/logo.png" title="Info zum Logo-Updater $vinfo" select="OK,CANCEL" default=1 >/dev/null
		case $? in
		1)
			#Logo-Updater ausfuehren
			test -e updates && chmod 755 updates && ./updates
			echo "- Logo-Updater beendet."
			;;
		*)
			#Abbruch
			echo "- Logo-Updater abgebrochen."
			;;
		esac
	fi
else
	echo "- Fehler beim Download von $archive"
fi

cleanup
