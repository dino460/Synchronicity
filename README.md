![Synchronicity](https://github.com/dino460/Synchronicity/blob/godot-remake/synchronicity-title-tmp.png)

---

<div align="center">
  
  **A Souls-like Top-down Adventure Game**
  
</div>

<div align="center">
  
  [Installation](#installing)&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;[Features](#features)&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;[Configurations](#configs)&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;[Contributing](#contrib)&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;[Links](#links)&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;[Licensing](#licensing)

  [![Godot Engine](https://img.shields.io/badge/Godot%204.4--stable-%23FFFFFF.svg?logo=godot-engine)](#)
  [![GitHub last commit](https://img.shields.io/github/last-commit/dino460/Synchronicity)](#)
</div>

---

Synchronicity is a top down pixelated open world-ish adventure game I'm developing by myself on my spare time. It's a blend of procedural and hand-crafted elements, with a deep NPC simulation (akin to [Rain World](https://store.steampowered.com/app/312520/Rain_World/)), souls-like adventure aspects, a deep and innovative combat system, and a sprinkle of narrative ideas revolving around the psychological idea of "Synchronicity."

> Synchronicity is a concept introduced by analytical psychologist Carl Jung to describe events that coincide in time and appear meaningfully related, yet lack a discoverable causal connection.[1] Jung held this was a healthy function of the mind, that can become harmful within psychosis.
<sup>[link](https://en.wikipedia.org/wiki/Synchronicity)</sup>

<a name="installing"/>

## Installing / Getting started
Installation should be quite simple. Just install [Godot 4.3-stable](https://godotengine.org/download/archive/). After that, install [Blender 3.6 LTS](https://www.blender.org/download/lts/3-6/). This will allow you to import the .blend files I use for my models and animations.

With Godot and Blender installed, open the project in the engine. I'll probably complain about not finding Blender. Just add the filepath to the Blender executable to the box Godot just jumpscared you with. If, for some reason, Godot just doesn't say anything and the project loads incorrectly, go to `Editor Settings > Filesystem > Import > Blender` and add the path to the executable.

Now everything should be working properly!

<a name="features"/>

## Features

For now, the game is quite barebones and totally in an Alpha state of affairs. In the future, I may add a section explaining each one more carefully, since some can get complicated. For now, these are the main features and their implementation state:
- [x] **Basic movement**: The player character moves around using WASD or the Left Analog Stick on a controller (and it runs with SHIFT, quite neat). Still needs a bit of polishing. $`[{\color{lightgreen}85\%}]`$
- [ ] **Directional Combat**: My weird custom combat system has some parts somewhat implemented. Migration from the old FromSoft-like combat is still being done. Currently nothing works, but the back-end has methods, signals and tie-ins with the animation system. $`[{\color{red}12\%}]`$
- [ ] **Animation System**: Similar to the combat system, it's half-done, and is easily breakable. $`[{\color{orange}33\%}]`$
- [X] **Day Cycle**: Day cycles with custom durations and custom dusk and dawn times. $`[{\color{green}100\%}]`$
- [ ] **NPC System**: A complex mess of weights and checks and arbitrary math that I'll one day explain in a section of its own. It's actually half-working half-well. Still missing interaction between NPCs, combat and doing stuff other than moving around. But the moving around is quite neat and works real nice. $`[{\color{yellow}46\%}]`$
- [ ] **Story**: Lol. There's nothing here. I thought of some stuff, but programming, art and animations are currently consuming most of my time. One day... one day... $`[{\color{red}0.000001\%}]`$

<sub>*PS: Percentage values are arbitrary and merely ment to give an idea on how much/little progress has been made)*</sub>

<a name="configs"/>

## Configuration

> Still in construction.
There are some neat configurations you can do in-engine while editing the game.
I'll explain them on a later date.

<a name="contrib"/>

## Contributing

Either leave an issue (really appreciate it) or do a Pull Request. The latter will almost definitely stay gathering dust for a while, as I test and review everything carefully (and I'm slow). The former will 100% help me keep track of bugs and problems I'll be continuously keeping an eye on while developing.

<a name="links"/>

## Links

Some usefull/important links:

- Repository: https://github.com/dino460/Synchronicity
- Issue tracker: https://github.com/dino460/Synchronicity/issues
- Related projects:
  - SNIS: https://github.com/dino460/scheduled-npc-interaction-system
  	- Legacy A* modification I was developing in Rust to serve as the pathfinding for the game. In the end, it didn't prove itself quite what I wanted or needed, but it helped me understand a little better how pathfinding works.

<a name="licensing"/>

## Licensing

This program is distributed under ~~three different~~ one license~~s~~:
1. Source code and official releases/binaries are distributed under the [End-User License Agreement for Synchronicity (EULA)](https://github.com/dino460/Synchronicity/blob/godot-remake/EULA.txt). Please keep in mind that Godot related modules/libraries in the source code and/or releases/binaries are distributed under the [MIT License as defined by the Godot Engine](https://godotengine.org/license/). Third-party software bundled with the Godot distribution may follow different licenses not compatible with Godot's MIT License. For those, refer to [this file](https://github.com/dino460/Synchronicity/blob/godot-remake/GODOT_COPYRIGHT.txt).
2. ~~Steam releases will one day happen. When that happens, they will folow Steam's Subscriber Agreement. For now, I'mfocusing on other stuff.~~
3. ~~Itch.io releases will one day happen. When that happens, they will folow their own license. For now, this repo is all I have.~~
