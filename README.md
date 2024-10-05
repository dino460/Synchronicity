![Logo of the project](https://github.com/dino460/Synchronicity/blob/godot-remake/synchronicity-title-tmp.png)
# Synchronicity
> A Souls-like Top-down Adventure Game

This is a silly little game I'm developing by myself on my free time. It'll blend some elements of procedural and hand-crafted elements, with a realistic NPC ecosystem simulation (akin to Rain World), with souls-like adventure tropes like dodge roll and a deep combat system, and a sprinkle of narrative ideas revolving around the psychological idea of "Synchornicity."

> Synchronicity is a concept introduced by analytical psychologist Carl Jung to describe events that coincide in time and appear meaningfully related, yet lack a discoverable causal connection.[1] Jung held this was a healthy function of the mind, that can become harmful within psychosis.
![Wikipedia link](https://en.wikipedia.org/wiki/Synchronicity)

## Installing / Getting started

Installation should be quite simple. Just install ![Godot 4.3-stable](https://godotengine.org/download/archive/). After that, install ![Blender 3.6 LTS](https://www.blender.org/download/lts/3-6/). This will allow you to import the .blend files I use for my models and animations.

With Godot and Blender installed, open the project in the engine. I'll probably complain about not finding Blender. Just add the filepath to the Blender executable to the box Godot just jumpscared you with. If, for some reason, Godot just doesn't say anything and the project loads incorrectly, go to `Editor Settings > Filesystem > Import > Blender` and add the path to the executable.

Now everything should be working properly!

## Features

For now, the game is quite barebones and totally in an Alpha state of affairs. In the future, I may add a section explaining each one more carefully, since some can get complicated. For now, these are the main features and their implementation state:
- [x] **Basic movement**: The player character does move around using WASD or the Left Analog Stick on a controller (and it runs with SHIFT). $`[{\color{lightgreen}85\%}]`$
- [ ] **Directional Combat**: My weird custom combat system has some parts somewhat implemented. Migration from the old FromSoft-like combat is still being done. Currently nothing works, but the back-end has methods, signals and tie-ins with the animation system. $`[{\color{red}12\%}]`$
- [ ] **Animation System**: Similar to the combat system, it's half-done, and is easily breakable. $`[{\color{orange}33\%}]`$
- [X] **Day Cycle**: Day cycles with custom durations and custom dusk and dawn times. $`[{\color{green}100\%}]`$
- [ ] **NPC System**: A complex mess of weights and checks and arbitrary math that I'll one day explain in a section of its own. It's actually half-working half-well. Still missing interaction between NPCs, combat and doing stuff other than moving around. But the moving around is quite neat and works real nice. $`[{\color{yellow}46\%}]`$
- [ ] **Story**: Lol. There's nothing here. I thought of some stuff, but programming, art and animations is consuming most of my time currently. One day... one day... $`[{\color{red}0.000001\%}]`$

*PS: Percentage values are arbitrary and merely ment to give and idea on how much/little progress has been made)*

## Configuration

> Still in construction.
There are some neat configurations you can do in-engine while editing the game.
I'll explain them on a later date.

## Contributing

For now just do whatever pleases you, though I recommend leaving and Issue or forking. Since I'm quite limited on time, I may take a while to address any pull-requests. I'll try my best to keep an eye on any contributions, though.

## Links

Some usefull/important links:

- Repository: https://github.com/dino460/Synchronicity
- Issue tracker: https://github.com/dino460/Synchronicity/issues
- Related projects:
  - SNIS: https://github.com/dino460/scheduled-npc-interaction-system
  	- Legacy A* modification I was developing in Rust to serve as the pathfinding for the game. in the end, it didn't prove itself quite what I wanted or needed, but it helped me understand a little better how pathfinding works.

## Licensing

All rights reserved. That said, you may clone, run, compile, play with, modify and fork this code. Do whatever you please, just don't sell anything I make without my consent.

The intention behind having this open repo is so that people can have their hands on shaping my game through testing and more informed feedback, and also to allow those that cannot buy it (when I eventually start distributing it) to still play it.

I'm still working on a proper license, similar to how ![Aseprite](https://github.com/aseprite/aseprite) does theirs.

I'm trusting you, bro.
