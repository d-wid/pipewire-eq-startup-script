#!/bin/sh
CALFFIRSTIN1="para_equalizer_x16_stereo:in_l"		#Edit as needed.
CALFFIRSTIN2="para_equalizer_x16_stereo:in_r"		#Edit as needed.

CALFLASTOUT1="para_equalizer_x16_stereo:out_l"	#Edit as needed.
CALFLASTOUT2="para_equalizer_x16_stereo:out_r"	#Edit as needed.

ACTUALOUTPUTHARDWARE1="K3:playback_FL"						#Edit as needed.
ACTUALOUTPUTHARDWARE2="K3:playback_FR"						#Edit as needed.

#These probably need not be changed, though feel free to anyway.
NODENAME=EQ #Name of virtual device
PWLINKORJACKCONNECT="pw-jack jack_connect" #Replacing "pw-jack jack_connect" with "pw-link" may be possible for Pipewire 0.3.26 and above
CHECKEDPORT=$CALFFIRSTIN2

VIRTUALMONITOR1="$NODENAME:monitor_FL"
VIRTUALMONITOR2="$NODENAME:monitor_FR"

#1 Create virtual device unless it"s already there.
if (pw-jack jack_lsp | grep -q "$NODENAME"); then
	echo "nothing to be done."
else
	pw-cli create-node adapter { factory.name=support.null-audio-sink node.name="$NODENAME" media.class=Audio/Sink object.linger=1 audio.position=FL,FR } 
fi

#2 Start EQ (obviously you want to change the preset names/config files)
#calfjackhost eq8:preset-a ! eq12:preset1 !  eq8:preset2 &
lsp-plugins-para-equalizer-x16-stereo -c /tmp/config.cfg &

#3 Wait for Calf Jack ports to appear.
while ! (pw-jack jack_lsp | grep -q "$CHECKEDPORT") > /dev/null
do
	sleep 0.1
done

#4 Connect Jack ports.
($PWLINKORJACKCONNECT "$ACTUALOUTPUTHARDWARE1" "$CALFLASTOUT1" ;
$PWLINKORJACKCONNECT "$ACTUALOUTPUTHARDWARE2" "$CALFLASTOUT2" ;
$PWLINKORJACKCONNECT "$VIRTUALMONITOR1" "$CALFFIRSTIN1" ;
$PWLINKORJACKCONNECT "$VIRTUALMONITOR2" "$CALFFIRSTIN2" )&

#5 Please make all apps output sound through $NODENAME in e.g. Pavucontrol :)
