#!/bin/bash

set -e

curdir="$(pwd)"
cd
homedir="$(pwd)"
localdir="$homedir"/.piratepack/firefox-mods

numprofile="$(ls .mozilla/firefox/*.default 2>> /dev/null | wc -l)"
if [ "$numprofile" -lt "1" ]
then
    if [ ! -d ".mozilla" ]
    then
	mkdir .mozilla
    fi
    
    if [ ! -d ".mozilla/firefox" ]
    then
	chmod u+rwx ".mozilla"
	mkdir ".mozilla/firefox"
    fi

    chmod u+rwx ".mozilla/firefox"
    uuid="$(uuidgen)"
    profileuuid="${uuid:0:8}"
    cd ".mozilla/firefox"
    mkdir "$profileuuid".default

    if [ ! -f profiles.ini ]
    then
	echo "[General]" >> profiles.ini
        echo "StartWithLastProfile=1" >> profiles.ini
	echo "" >> profiles.ini
    fi
    
    if [ -f profiles.ini ]
    then
	profilenum="0"
	while read line
	do
            if [[ "$line" == *"[Profile"*"]"* ]]
            then
		profilenum=$(($profilenum + 1))
            fi
	done <profiles.ini
	
	echo "[Profile""$profilenum""]" >> profiles.ini
	echo "Name=default" >> profiles.ini
	echo "IsRelative=1" >> profiles.ini
	echo "Path=""$profileuuid"".default" >> profiles.ini
	echo "Default=1" >> profiles.ini
	echo "" >> profiles.ini
    fi

    cd

else
    cd .mozilla/firefox
    if [ -f profiles.ini ]
    then
        hasdefault="0"
        while read line
	do
            if [[ "$line" == *"Default=1"* ]]
            then
		hasdefault="1"
                break
            fi
	done <profiles.ini

	if [[ "$hasdefault" == "0" ]]
	then
	    sed '$d' < profiles.ini > profiles.ini.tmp ; mv profiles.ini.tmp profiles.ini
	    echo "Default=1" >> profiles.ini
            echo "" >> profiles.ini
	fi
    fi
    cd
fi

profiledir=""

while read -r line
do
    profiledir="$homedir"/"$line"
    break
done < <(find ".mozilla/firefox/"*".default" -maxdepth 0)


if [[ "$profiledir" != "" ]]
then 
    cd "$profiledir"

    version="4"
    versioncmd="$(firefox -version)"

    if [[ "$versioncmd" == *"Firefox 3"* ]]
    then
	version="3"
    fi

    if [ ! -d extensions ]
    then
	mkdir extensions
    fi
    chmod u+rwx extensions
    cd extensions
    extdir="$(pwd)"
    if [[ "$version" != "3" ]] 
    then
	if [ ! -d staged ]
	then
	    mkdir staged
	fi
	chmod u+rwx staged
    fi
    cd "$curdir"
    find *.xpi | while read line; do
	linelen=${#line}
        linelensub=$(($linelen - 4))
	if [ ! -f "$extdir"/"$line" ] && [ ! -d "$extdir"/"${line:0:$linelensub}" ]
	then
	    if [ ! -f "$extdir"/staged/"${line:0:$linelensub}.xpi" ] && [ ! -d "$extdir"/staged/"${line:0:$linelensub}" ] 
	    then
		if [ -d "${line:0:$linelensub}" ]
		then
		    if [[ "$version" == "3" ]]
		    then
			unzip "$line" -d "$extdir"/"${line:0:$linelensub}"
			echo "$extdir"/"${line:0:$linelensub}" >> "$localdir"/.installed
		    else
			unzip "$line" -d "$extdir"/staged/"${line:0:$linelensub}"
			echo "$extdir"/"${line:0:$linelensub}" >> "$localdir"/.installed
			echo "$extdir"/staged/"${line:0:$linelensub}" >> "$localdir"/.installed
		    fi
		else
		    if [[ "$version" == "3" ]]
                    then
			unzip "$line" -d "$extdir"/"${line:0:$linelensub}"
			echo "$extdir"/"${line:0:$linelensub}" >> "$localdir"/.installed
                    else
			cp "$line" "$extdir"/staged
			echo "$extdir"/"$line" >> "$localdir"/.installed
			echo "$extdir"/staged/"$line" >> "$localdir"/.installed
		    fi
		fi
		if [[ "$version" != "3" ]]
		then
		    cp "${line:0:$linelensub}".json "$extdir"/staged
		    echo "$extdir"/staged/"${line:0:$linelensub}".json >> "$localdir"/.installed
		fi
	    fi
	fi
    done

    cd "$curdir"
    if [ -d "{d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}-mods/profile/{d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}" ]
    then
	if [ ! -d "$profiledir"/"{d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}" ]
	then
            cp -r "{d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}-mods/profile/{d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}" "$profiledir"
            echo "$profiledir"/"{d10d0bf8-f5b5-c8b4-a8b2-2b9879e08c5d}" >> "$localdir"/.installed
	fi
    fi

fi
