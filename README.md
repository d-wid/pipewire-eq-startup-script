# pipewire-eq-startup-script
Simple-ish script which starts an equaliser (or whatever sound effects are available) under pipewire and connect real output device(s) as well as a virtual device which relays applications' sound to it. Two variants have been uploaded with the only difference being whether it's setup [for calfjackhost](https://github.com/d-wid/pipewire-eq-startup-script/blob/main/start-calf.sh) or [for one of the lsp-plugins](https://github.com/d-wid/pipewire-eq-startup-script/blob/main/start-lspeq.sh).

While There are apps like qjackctl, Helvum or Catia which can be used instead I like the idea of being able to stick with Pavucontrol and not needing to use extra applications and not needing to download something from outside my distro's default repository for this particular task.

Depends on:
- Jackd (or whatever part of JACK provides jack_connect and jack_lsp)
- either calfjackhost or lsp-plugins (or whatever equivalent you use)
- Pipewire

## How to use
- Create and save a preset in calfjackhost or the LSP EQ plugin you want to use. Edit the values in the LSP plugin by double clicking on them, and in the Calf plugins by middle clicking the wheels.
- Edit the script to correspond with your setup. There should be 6 or 7 lines that need changing (see examples below). To list JACK ports one can use:

    pw-jack jack_lsp

- Don't forget to edit the line where calfjackhost or the lsp-plugins EQ is actually run so they correspond to your preset(s)
- Run the script when you want to use EQ (or make it run right after every login)
- Use e.g. Pavucontrol to make apps output sound through $NODENAME as specified in the script (defaults to "EQ")

## Examples
![Calf](https://github.com/d-wid/pipewire-eq-startup-script/blob/main/calf.png)
![lsp-plugins](https://github.com/d-wid/pipewire-eq-startup-script/blob/main/lsp.png)

p.s. lsp-pluins has actually got a 32-band EQ as well if you need that many bands:

    lsp-plugins-para-equalizer-x32-stereo

Unfortunately you don't have nearly as much flexibility with the Calf Equaliser plugins, but it's possible to just stack a few of them together as shown in the example above. Being far from an audio playback expert I asked around [here](https://old.reddit.com/r/oratory1990/comments/nnazlb/does_splitting_an_eq_preset_into_a_series_of/) and it seems to be fine.
