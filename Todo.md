# Todo #
Installieren von Citrix Receiver 13.3
Danach die Zertfikate kopieren und umbiegen. Außerdem müssen noch die Kundenspezifischen Zertifikate kopiert werden.
 ``mv /opt/Citrix/ICAClient/keystore/cacerts/* /usr/share/ca-certificates/mozilla/`` im Anschluss einen Symlink bauen ``sudo ln -s /usr/share/ca-certificates/mozilla /opt/Citrix/ICAClient/keystore/cacerts``
Zum Schluss alles hashen und gut. ``sudo c_rehash /opt/Citrix/ICAClient/keystore/cacerts``

Um die IT4S Anwendungen zum laufen zu bekommen muss das entsprechende Archiv nach '/opt/' kopiert werden und dort entpackt werden ``tar -xf IT4S_XXXXXX.tar``. zusätzlich ist das Paket qt5-default zu installieren ``sudo apt-get install qt5-default``

Nun legen wir die Datei ``.xsession`` an. 
'#!/bin/bash
/opt/IT4S/StartPage.sh &
xfwm4'

## Zeitserver ##
Um den Zeitserver anzupassen ist nur notwendig unter ``/etc/systemd/timesyncd.conf`` die Zeile ``Servers= 172.16.0.1`` eintragen.

## Bootsplash ##
Installieren von fbi ``sudo apt-get install fbi``.

## USB ##
Das Paket ``sudo apt-get install udisks-glue`` installieren damit USB - Sticks erkannt werden. Zusätzlich sind noch die Pakete ``sudo apt-get install exfat-fuse ntfs-3g`` zu installieren um NTFS und EXFAT - Partition zu unterstützen.
https://github.com/osmc/osmc/blob/master/package/diskmount-osmc/files/lib/systemd/system/udisks-glue.service

## Autocompletion ##
Um unter Debian auf dem Terminal eine autovervollständigung zu bekommen sind folgende pakete zu installieren ``sudo apt-get install bash-completion apt-utils``.

## Keybindings ##
Um Shortcuts zu erstellen muss das Paket ``sudo apt-get install xbindkeys`` installiert werden. 
Dann im Home - Verzeichnis die Datei ``.xbindkeysrc``. Dort muss dann der Inhalt 
"/opt/IT4S/ConfigPage.sh"
shift+control+c

