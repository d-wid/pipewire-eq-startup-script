#!/bin/sh
CALFFIRSTIN1="Calf Studio Gear:Equalizer 12 Band In #1"		#Edit as needed.
CALFFIRSTIN2="Calf Studio Gear:Equalizer 12 Band In #2"		#Edit as needed.

CALFLASTOUT1="Calf Studio Gear:Equalizer 12 Band Out #1"	#Edit as needed.
CALFLASTOUT2="Calf Studio Gear:Equalizer 12 Band Out #2"	#Edit as needed.

ACTUALOUTPUTHARDWARE1="K3:playback_FL"				#Edit as needed.
ACTUALOUTPUTHARDWARE2="K3:playback_FR"				#Edit as needed.

#These probably need not be changed, though feel free to anyway.
NODENAME=EQ #Name of virtual device
PWLINKORJACKCONNECT="pw-jack jack_connect" #Replacing "pw-jack jack_connect" with "pw-link" may be possible for Pipewire 0.3.26 and above
CHECKEDPORT=$CALFFIRSTIN2
CHECKEDPORT2=$ACTUALOUTPUTHARDWARE2

VIRTUALMONITOR1="$NODENAME:monitor_FL"
VIRTUALMONITOR2="$NODENAME:monitor_FR"

#1 Create virtual device unless it"s already there.
if (pw-jack jack_lsp | grep -q "$NODENAME"); then
    echo "nothing to be done."
else
	pw-cli create-node adapter { factory.name=support.null-audio-sink node.name="$NODENAME" media.class=Audio/Sink object.linger=1 audio.position=[ FL FR ] }	#COMMENT OUT if Pipewire is older than 0.3.25, and uncomment the line below
#	pw-cli create-node adapter { factory.name=support.null-audio-sink node.name="$NODENAME" media.class=Audio/Sink object.linger=1 audio.position=FL,FR }		#UNCOMMENT IF you comment out the above. Only for Pipewire UP TO 0.3.25
fi

#2 Start EQ (obviously you want to change the preset names/config files)
calfjackhost eq12:preset-1 &
#lsp-plugins-para-equalizer-x16-stereo -c /tmp/preset.cfg &

#3 Wait for Calf Jack ports to appear.
while ! (pw-jack jack_lsp | grep -q "$CHECKEDPORT") > /dev/null
do
	sleep 0.1
done

#3.5 Wait for/Make sure of presence of Output Device ports
while ! (pw-jack jack_lsp | grep -q "$CHECKEDPORT2") > /dev/null
do
	sleep 0.1
done

#4 Connect Jack ports.
($PWLINKORJACKCONNECT "$ACTUALOUTPUTHARDWARE1" "$CALFLASTOUT1" ;
$PWLINKORJACKCONNECT "$ACTUALOUTPUTHARDWARE2" "$CALFLASTOUT2" ;
$PWLINKORJACKCONNECT "$VIRTUALMONITOR1" "$CALFFIRSTIN1" ;
$PWLINKORJACKCONNECT "$VIRTUALMONITOR2" "$CALFFIRSTIN2" )&

#5 Please make all apps output sound through $NODENAME in e.g. Pavucontrol :)
