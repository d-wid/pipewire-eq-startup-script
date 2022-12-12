# Pipewire EQ Startup Script
Simple-ish script which starts an equaliser (or whatever sound effects are available) under pipewire and connects it to real output device(s) as well as a virtual device used to relay applications' sound to it.

While There are apps like qjackctl, Helvum or Catia which can be used instead I like the idea of being able to stick with Pavucontrol without needing to use extra applications or download something from outside my distribution's default repository for this particular task.

Pulseeffects is perhaps the better solution for my personal needs, but right now my system doesn't play well with it when using Pipewire for audio, it seems.

Depends on:
- Jackd (or whatever part of JACK provides jack_connect and jack_lsp)
- either calfjackhost or lsp-plugins (or whatever equivalent you use)
- Pipewire (I've personally tested it on Pipewire 0.3.19)

## Download
Two variants have been uploaded with the only difference being whether it's setup for:
- [calfjackhost](https://github.com/d-wid/pipewire-eq-startup-script/blob/main/start-calf.sh), or
- [for one of the lsp-plugins](https://github.com/d-wid/pipewire-eq-startup-script/blob/main/start-lspeq.sh)

## Changelog
- 2021-11-29: Prevents a second instance of EQ software from starting. Useful for me because my sound card often disconnects when I start the script for some reason as now I simply need to click on the script again after my sound card reappears to try to connect it to the already-started EQ, without extra windows appearing.
- 2021-09-04: Added pw-cli's new way of creating virtual device as default while commenting out the old way. Thanks [@thulle](https://github.com/thulle)!
- 2021-08-14: Added a new version for those using lsp-plugins-jack downloaded from https://sourceforge.net/projects/lsp-plug()ns/files/lsp-plugins/
- 2021-06-25: For some reason my output device doesn't immediately appear to the Calf host when I start the script after login, so I've modified the script to wait for that as well before connecting all the ports.

## How to Use
- Create and save a preset in calfjackhost or the LSP EQ plugin you want to use. Edit the values in the LSP plugin by double clicking on them, and in the Calf plugins by middle clicking the wheels.
- Edit the script to correspond with your setup. There should be at most 7 to 9 lines that need changing (see examples below/pay attention to the lines in the script itself that is commented as needing some changes) in addition to a couple at the top for those who use the new version meant for the binaries provided [here](https://sourceforge.net/projects/lsp-plugins/files/lsp-plugins). To list JACK ports one can use:

      pw-jack jack_lsp

- Don't forget to edit the line where calfjackhost or the lsp-plugins EQ is actually run so they correspond to your preset(s)
- Run the script when you want to use EQ (or make it run right after every login). Logging out and back in or restarting Pipewire **NOT** required if you want to use EQ again after quitting it.
- Use e.g. Pavucontrol to make apps output sound through $NODENAME as specified in the script (defaults to "EQ")
- If the sound card disconnects, simply run the script again after the sound card reappears to try to connect it to the already-started EQ. Extra windows of the EQ won't appear now unless you close the one already running.

## Examples
![Calf](https://github.com/d-wid/pipewire-eq-startup-script/blob/main/calf.png)
![lsp-plugins](https://github.com/d-wid/pipewire-eq-startup-script/blob/main/lsp.png)

p.s. lsp-pluins has actually got a 32-band EQ as well if you need that many bands:

    lsp-plugins-para-equalizer-x32-stereo

Unfortunately you don't have nearly as much flexibility if you use the Calf Equaliser plugins, but it's possible to just stack a few of them together as shown in the example above. Being far from an audio playback expert I asked around [here](https://www.reddit.com/r/oratory1990/comments/nnazlb/does_splitting_an_eq_preset_into_a_series_of/) and it seems to be fine.

## The Script (Calf version)



    #!/bin/sh
    CALFFIRSTIN1="Calf Studio Gear:Equalizer 12 Band In #1"		#Edit as needed.
    CALFFIRSTIN2="Calf Studio Gear:Equalizer 12 Band In #2"		#Edit as needed.
    
    CALFLASTOUT1="Calf Studio Gear:Equalizer 12 Band Out #1"	#Edit as needed.
    CALFLASTOUT2="Calf Studio Gear:Equalizer 12 Band Out #2"	#Edit as needed.
    
    ACTUALOUTPUTHARDWARE1="K3:playback_FL"				#Edit as needed.
    ACTUALOUTPUTHARDWARE2="K3:playback_FR"				#Edit as needed.
    
    #These probably need not be changed, though feel free to make changes anyway.
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
    
    #2 Start Calf unless it's already running
    if (pw-jack jack_lsp | grep -q "$CALFLASTOUT2"); then
    	echo "nothing to be done."
    else
    	calfjackhost eq12:preset-1 &
    	#lsp-plugins-para-equalizer-x16-stereo -c /tmp/preset.cfg &
    fi
    
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
    
## The Script
### (version for lsp-plugins-jack downloaded from https://sourceforge.net/projects/lsp-plugins/files/lsp-plugins)
#### Doesn't work with the newest version (It probably broke at version 1.2.0) unless changes to LD_PRELOAD and the executable location are also made

    #!/bin/sh

    LSP_FOLDER=/tmp/lsp-plugins-jack-1.1.30-Linux-x86_64	#Change to extracted folder containing README.txt, LICENSE.txt, CHANGELOG.txt, and usr
    VERSION=1.1.30						#Change to the version you're using

    #Load library first
    LD_PRELOAD=$LSP_FOLDER/usr/local/lib/lsp-plugins/lsp-plugins-r3d-glx.so:$LSP_FOLDER/usr/local/lib/lsp-plugins/lsp-plugins-jack-core-$VERSION.so
    export LD_PRELOAD

    #Actual LSP load script starts

    #!/bin/sh
    CALFFIRSTIN1="para_equalizer_x16_stereo:in_l"		#Edit as needed.
    CALFFIRSTIN2="para_equalizer_x16_stereo:in_r"		#Edit as needed.

    CALFLASTOUT1="para_equalizer_x16_stereo:out_l"		#Edit as needed.
    CALFLASTOUT2="para_equalizer_x16_stereo:out_r"		#Edit as needed.

    ACTUALOUTPUTHARDWARE1="K3:playback_FL"			#Edit as needed.
    ACTUALOUTPUTHARDWARE2="K3:playback_FR"			#Edit as needed.

    #These probably need not be changed, though feel free to make changes anyway.
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
    
    #2 Start EQ unless it's already running (obviously you want to change the preset names/config files)
    if (pw-jack jack_lsp | grep -q "$CALFLASTOUT2"); then
    	echo "nothing to be done."
    else
    	#calfjackhost eq8:preset-a ! eq12:preset1 !  eq8:preset2 &
    	$LSP_FOLDER/usr/local/bin/lsp-plugins-para-equalizer-x16-stereo -c /tmp/config.cfg &
    fi

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

