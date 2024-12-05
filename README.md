# Godot 4.3
# Third and First Person Parkour Character Controller
**By Anand Egan**

## Overview:

This is a Parkour Character Controller designed utilizing a CharacterBody3D node.

### Features include:
- Swapping between first and third person mode
- **Basic movement:**
  + Walking
  + Sprinting
  + Crouching
  + Jumping
  + Falling
  + Looking around by moving the camera
- **Advanced movement:**
  + Sliding with dynamic movement based on slopes
  + Climbing
  + Wall running
  + Wall hopping
- **Abilities:**
  + Bullet Time
  + Dodge/Dash
  + Dive
- Somewhat animated dummy player model
- Ability to be used in any scene so long as there are collisions set up within said scene.

## Controls:
### Basic Movement:
- **Forward** - W
- **Left** - A
- **Backward** - S
- **Right** - D
- **Jump** - Space
- **Crouch** - C
- **Move Camera** - Move Mouse
### Abilities:
- **Triple Jump** - Space (in air)
- **Sliding** - Hold Crouch (C) while sprinting, gain speed by going down slopes
- **Dive** - Z (in air)
- **Climbing** - Face directly and hug a wall while in the air and hit Space
- **Wall Run** - Physically hug a wall on the side in the air and hit Space
- **Wall Hop** - While Wall Running, press Space

## Credits/Sources:
- DISCLAIMER: I have been working on this project for months, and there are likely several sources/credits that I forgot about.
- Fundamental Movement, Camera, and State Machine - Followed along and modified code from “The Godot FPS Project” tutorial on YouTube by StayAtHomeDev (Up to Episode 17 - State Machine Falling)
- Sliding mechanic - Took the concept of Sliding like in Apex Legends | Godot tutorial #4 by PerfectioNH and changed it up
- Wallrun and Wallhop mechanic - Followed along and modified code from Godot FPS Tutorial - Part 7 - Wallrunning by Skyvastern and tweaked it
- Shaders from Godot Shaders
  + Slow down time ripple effect
  + Speed lines effect

