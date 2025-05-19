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

## Installing
Installation should be quite simple. 
- Install [Godot 4.4-stable](https://godotengine.org/download/archive/4.4-stable/).
- Install [Blender 3.6 LTS](https://www.blender.org/download/lts/3-6/). This will allow you to import the .blend files I use for my models and animations.
- Open the project in the engine. I'll probably complain about not finding Blender.
- Add the filepath to the Blender executable to the box Godot just jumpscared you with.
- If, for some reason, Godot just doesn't say anything and the project loads incorrectly, go to `Editor Settings > Filesystem > Import > Blender` and add the path to the executable.

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
| $`{\color{green}100\%}`$ | [Day/Night Cycle](#daynight-cycle) | Day/Night cycles with custom durations and custom dusk and dawn times | Completed & Fully Functional |
| $`{\color{greenyellow}85\%}`$ | [Movement](#movement-system) | Normalized analog movement + running + rolling. | Base movement + sprinting done. Needs polishing |
| $`{\color{yellow}60\%}`$ | [Animation](#animation-system) | State driven, signal-bound unified API for Player and NPCs | Basic logic implemented and quite reliable. Needs a lot of polishing and more granularity/control options |
| $`{\color{orange}46\%}`$ | [NPCs](#scheduled-npc-interaction-system) | [Rain World](https://store.steampowered.com/app/312520/Rain_World/) inspired naturalistic behaviour | Messy, bad code, average performance, somehow kinda working |
| $`{\color{orangered}33\%}`$ | [**Combat**](#combat-system) | My weird custom combat system, with directional attacks | 4-stance system implemented, test animations working, hiboxes and damage working. NPCs still don't attaack and behave really simplistically. No nuance. Heavy polishing needed.
| $`{\color{red}0.000001\%}`$ | [Story](#story) | Souls-like vague indirect weird narrative thing | Lol. There's nothing here. I thought of some stuff, but making the game work is the current priority |
| $`{\color{red}0.0\%}`$ | [SFX/OST](#sfxost) | Medieval + light bit crushed/electronic elements | <sub>_wind sounds... cobwebs... a skeleton on the corner... waiting_</sub> |

<sub>_**Feature**: Currently in active development. Other features are also in-development, but focus is on this one_</sub><br/>
<sub>_PS: Percentage values are arbitrary and merely ment to give an idea on how much/little progress has been made)_<br/><br/></sub>

<details>
<summary>A further detailing of the main features and mechanics of Synchronicity</summary>

### Animation System
> Section In-progress

### Combat System
> Section In-progress

### Day/Night Cycle
> Section In-progress

### Movement System
> Section In-progress

### Scheduled NPC Interaction System
> Section In-progress

### SFX/OST
> Section In-progress

### Story
> Section In-progress

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
