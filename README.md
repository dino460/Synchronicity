![Synchronicity](https://github.com/dino460/Synchronicity/blob/godot-remake/synchronicity-title-tmp.png)

---

<div align="center">

  **A Souls-like Top-down Adventure Game**

</div>

<div align="center">

  [Installation](#installing)&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;[Features](#features)&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;[Configurations](#configurations)&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;[Contributing](#contributing)&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;[Links](#links)&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;[Licensing](#licensing)

  [![Godot Engine](https://img.shields.io/badge/Godot%204.4--stable-%23FFFFFF.svg?logo=godot-engine)](#)
  [![GitHub last commit](https://img.shields.io/github/last-commit/dino460/Synchronicity)](#)
</div>

---

Synchronicity is a top down pixelated open world-ish adventure game I'm developing by myself on my spare time. It's a blend of procedural and hand-crafted elements, with a deep NPC simulation (akin to [Rain World](https://store.steampowered.com/app/312520/Rain_World/)), souls-like adventure aspects, a deep and innovative combat system, and a sprinkle of narrative ideas revolving around the psychological idea of "Synchronicity."

> Synchronicity is a concept introduced by analytical psychologist Carl Jung to describe events that coincide in time and appear meaningfully related, yet lack a discoverable causal connection.[1] Jung held this was a healthy function of the mind, that can become harmful within psychosis.
<sup>[wikipedia](https://en.wikipedia.org/wiki/Synchronicity)</sup>

## Installation
Installation should be quite simple.
- Install [Godot 4.4-stable](https://godotengine.org/download/archive/4.4-stable/).
- Install [Blender 5.0](https://www.blender.org/download/releases/5-0/). _This will allow you to import the .blend files I use for my models and animations._
- Open the project in the engine. It'll probably complain about not finding Blender.
- Add the **filepath** to the _Blender executable_ to the box Godot just jumpscared you with.
- If, for some reason, Godot just doesn't say anything and the project loads incorrectly, go to `Editor Settings > Filesystem > Import > Blender` and add the path to the executable.
- If, for any reason, the imports break and the game doesn't work, simply delete the `.blend.import` files located in `res://assets/`.

Now everything should be working properly!

## Features
<!--
For now, the game is quite barebones and totally in an Alpha state of affairs. In the future, I may add a section explaining each one more carefully, since some can get complicated. For now, these are the main features and their implementation state:
- [x] **Basic movement**: The player character moves around using WASD or the Left Analog Stick on a controller (and it runs with SHIFT, quite neat). Still needs a bit of polishing. $`[{\color{lightgreen}85\%}]`$
- [ ] **Directional Combat**: My weird custom combat system has some parts somewhat implemented. Migration from the old FromSoft-like combat is still being done. Currently nothing works, but the back-end has methods, signals and tie-ins with the animation system. $`[{\color{red}12\%}]`$
- [ ] **Animation System**: Similar to the combat system, it's half-done, and is easily breakable. $`[{\color{orange}33\%}]`$
- [X] **Day Cycle**: Day cycles with custom durations and custom dusk and dawn times. $`[{\color{green}100\%}]`$
- [ ] **NPC System**: A complex mess of weights and checks and arbitrary math that I'll one day explain in a section of its own. It's actually half-working half-well. Still missing interaction between NPCs, combat and doing stuff other than moving around. But the moving around is quite neat and works real nice. $`[{\color{yellow}46\%}]`$
- [ ] **Story**: Lol. There's nothing here. I thought of some stuff, but programming, art and animations are currently consuming most of my time. One day... one day... $`[{\color{red}0.000001\%}]`$
-->

For now, the game is quite barebones and totally in an Alpha state of affairs. Below is a table summarizing the current main features and their development progress:
| Completeness | Feature | Description | Progress/State |
| :---: | --- | --- | --- |
| 100% 🟢 | [Day/Night Cycle](#daynight-cycle) | Day/Night cycles with custom durations and custom dusk and dawn times | Completed & Fully Functional. |
| 85% 🟢 | [Movement](#movement-system) | Normalized analog movement + running + rolling. | Base movement + sprinting done. Needs polishing. |
| 65% 🟡 | [Animation](#animation-system) | State driven, signal-bound unified API for Player and NPCs | Basic logic implemented and quite reliable. Needs a lot of polishing and more granularity/control options. |
| 40% 🟠 | [NPCs](#scheduled-npc-interaction-system) | [Rain World](https://store.steampowered.com/app/312520/Rain_World/) inspired naturalistic behaviour | Messy, bad code, average performance, somehow kinda working. Currently on a big rework of this whole system. |
| 35% 🔴 | [**Combat**](#combat-system) | My weird custom combat system, with directional attacks | 4-stance system implemented, test animations working, hiboxes and damage working. NPCs attack, but behave really simplistically. No nuance. Heavy polishing needed. Currently on a big rework of the NPC system.
| 0.000001% 🔴 | [Story](#story) | Souls-like vague indirect weird narrative thing | Lol. There's nothing here. I thought of some stuff, but making the game work is the current priority. |
| 0.0% 🔴 | [SFX/OST](#sfxost) | Medieval + light bit crushed/electronic elements | <sub>_wind sounds... cobwebs... a skeleton in the corner... waiting_</sub> |

<sub>_**Feature**: Currently in active development. Other features are also in-development, but focus is on this one_</sub><br/>
<sub>_PS: Percentage values are arbitrary and merely ment to give an idea on how much/little progress has been made)_<br/><br/></sub>

<details>
<summary>A further detailing of the main features and mechanics of Synchronicity</summary>

### Animation System
> Section is a Work In progress

Synchornicity's animation system is heavily based on Godot's signal system. All NPC's and the Player Character make use of this simple system to connect the state-driven logic implemented internally by each class (npc.gd and player.gd) to the receiving methods in the AnimationHandler class. These methods then make the necessary checks for animation cancelling and call the AnimationPlayer, which will play the given animation.

For base animations, such as idle, walk and run, they are implemented globally, while combat animations are handled independently with a weapon-system. This system, further detailed in the [Combat System](#combat-system) section, provides the correct animations for each weapon, along with the combo sequences and other important details about the used weapon.

### Combat System
> Section is a Work In-progress

Custom system that provides four diferent attak directions: up, down, left, and right. These are used to simulate a somewhat real-life-like sword-fighting experience.

### Day/Night Cycle
A simple system for defining an absolute time for a full day to last (such as 10 minutes), which is translated to the in-game simulated 24 hour time. Also provides the capability of defining custom sunrise and sunset times (for custom day/night ratios).

### Movement System
> Section is a Work In-progress

Currently the player has simple 3D top down movement with two speeds and a directional combat system. In the future, I plan on adding different dashes and perhaps some other different, but simple, movement abilities.

### Scheduled NPC Interaction System
> Section is a Work In-progress

The SNIS, as I call it, is a organic and dynamic system for simulating interactions between NPCs and their surroundings. The idea is to give them life-like behaviour with as much simplicity as possible and the possibility of constant simulation, meaning, NPCs won't stop acting and despawn when off-screen. This is a system heavily inspired by how the ecosystem in Rain World works.

Currently, SNIS is at it's infancy and in heavy prototyping/reworking phases. Constant changes are made, and I'm remaking it from the ground up frequently. For now, NPCs simply respond to attacks, try to find you if you go out of sight, and move between Home, Work and any Points Of Interest added to them. It's simplistic, janky, overly-engineered, and I'm already working on a 3rd iteration, so nothing here is final.

It's "zero" iteration was a [Rust based Dijkstra algorithm for pathfinding in a randomly generated maze](https://github.com/dino460/scheduled-npc-interaction-system) I made for fun (and studying Rust). It was through that experiment I started thinking about what I wanted for SNIS.

### SFX/OST
> Section is a Work In-(glacial)-progress

### Story
> Section is a Work In-(very, very, **_very_** slow)-progress

</details>

## Configurations

> Still in construction.
There are some neat configurations you can do in-engine while editing the game.
I'll explain them on a later date.

## Contributing

You can leave Issues and Pull-Requests. I'll keep an eye on both and carfully revise everything submited.

Though be aware that I'm slow, so both may stay open for a while.

### Contributors
<a href = "https://github.com/madushadhanushka/simple-sqlite/graphs/contributors">
  <img src = "https://contrib.rocks/image?repo=dino460/Synchronicity"/>
</a>


## Links

Some usefull/important links:

[![Instagram](https://img.shields.io/badge/Instagram-%23E4405F.svg?logo=Instagram&logoColor=white)](https://www.instagram.com/the_dino460/)
[![Reddit](https://img.shields.io/badge/Reddit-FF4500?logo=reddit&logoColor=white)](https://www.reddit.com/user/dino460)
[![Discord](https://img.shields.io/badge/Discord-%235865F2.svg?&logo=discord&logoColor=white)](https://discordapp.com/users/dino460)
[![GitHub](https://img.shields.io/github/followers/dino460?label=follow&style=social)](https://github.com/dino460)

[![Sychronicity](https://github-readme-stats.vercel.app/api/pin/?username=dino460&repo=Synchronicity&theme=dark)](https://github.com/dino460/Synchronicity)

#### [Issue tracker](https://github.com/dino460/Synchronicity/issues)

## Licensing

This program is distributed under ~~three different~~ one license~~s~~:
1. Source code and official releases/binaries are distributed under the [End-User License Agreement for Synchronicity (EULA)](https://github.com/dino460/Synchronicity/blob/godot-remake/EULA.txt). Please keep in mind that Godot related modules/libraries in the source code and/or releases/binaries are distributed under the [MIT License as defined by the Godot Engine](https://godotengine.org/license/). Third-party software bundled with the Godot distribution may follow different licenses not compatible with Godot's MIT License. For those, refer to [this file](https://github.com/dino460/Synchronicity/blob/godot-remake/GODOT_COPYRIGHT.txt).
2. ~~Steam releases will one day happen. When that happens, they will folow Steam's Subscriber Agreement. For now, I'mfocusing on other stuff.~~
3. ~~Itch.io releases will one day happen. When that happens, they will folow their own license. For now, this repo is all I have.~~
