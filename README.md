# Pipewire EQ Startup Script
Simple-ish script which starts an equaliser (or whatever sound effects are available) under pipewire and connects it to real output device(s) as well as a virtual device used to relay applications' sound to it.

While There are apps like qjackctl, Helvum or Catia which can be used instead I like the idea of being able to stick with Pavucontrol without needing to use extra applications or download something from outside my distribution's default repository for this particular task.

Pulseeffects is perhaps the better solution for my personal needs, but right now my system doesn't play well with it when using Pipewire for audio, it seems.

Depends on:
- Jackd (or whatever part of JACK provides jack_connect and jack_lsp)
- either calfjackhost or lsp-plugins (or whatever equivalent you use)
- Pipewire

## Download
Two variants have been uploaded with the only difference being whether it's setup for:
- [calfjackhost](https://github.com/d-wid/pipewire-eq-startup-script/blob/main/start-calf.sh), or
- [for one of the lsp-plugins](https://github.com/d-wid/pipewire-eq-startup-script/blob/main/start-lspeq.sh)

## Changelog
- 2021-06-25: For some reason my output device doesn't immediately appear to the Calf host when I start the script after login, so I've modified the script to wait for that as well before connecting all the ports.

## How to Use
- Create and save a preset in calfjackhost or the LSP EQ plugin you want to use. Edit the values in the LSP plugin by double clicking on them, and in the Calf plugins by middle clicking the wheels.
- Edit the script to correspond with your setup. There should be at most 6 or 7 lines that need changing (see examples below). To list JACK ports one can use:

    pw-jack jack_lsp

- Don't forget to edit the line where calfjackhost or the lsp-plugins EQ is actually run so they correspond to your preset(s)
- Run the script when you want to use EQ (or make it run right after every login). Logging out and back in or restarting Pipewire **NOT** required if you want to use EQ again after quitting it.
- Use e.g. Pavucontrol to make apps output sound through $NODENAME as specified in the script (defaults to "EQ")

## Examples
![Calf](https://github.com/d-wid/pipewire-eq-startup-script/blob/main/calf.png)
![lsp-plugins](https://github.com/d-wid/pipewire-eq-startup-script/blob/main/lsp.png)

p.s. lsp-pluins has actually got a 32-band EQ as well if you need that many bands:

    lsp-plugins-para-equalizer-x32-stereo

Unfortunately you don't have nearly as much flexibility with the Calf Equaliser plugins, but it's possible to just stack a few of them together as shown in the example above. Being far from an audio playback expert I asked around [here](https://www.reddit.com/r/oratory1990/comments/nnazlb/does_splitting_an_eq_preset_into_a_series_of/) and it seems to be fine.

## The Script (Calf version)



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
	    pw-cli create-node adapter { factory.name=support.null-audio-sink node.name="$NODENAME" media.class=Audio/Sink object.linger=1 audio.position=FL,FR } 
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
