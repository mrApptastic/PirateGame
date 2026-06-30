# ⚓ Pirate's Plunder - Curse of the Ghost Ship ☠️

A swashbuckling 2D pirate platformer built with Godot 4.5!

## 🎮 Controls

| Action | Key |
|--------|-----|
| Move | A/D or Arrow Keys |
| Jump | Space / W / Up Arrow |
| Double Jump | Jump while airborne |
| Wall Jump | Jump while sliding on wall |
| Attack (Sword) | J or Left Mouse Button |
| Dash | K or Shift |
| Interact | E |
| Pause | Escape |

## 🏴‍☠️ Features

### Player Mechanics
- **Double Jump** - Leap again in mid-air for extra height
- **Wall Slide & Wall Jump** - Cling to walls and leap off them
- **Dash** - Burst forward with invincibility frames
- **Sword Attack** - Slash enemies with your cutlass
- **Coyote Time** - Forgiving jump timing at ledge edges
- **Jump Buffering** - Press jump slightly early and still leap
- **Variable Jump Height** - Tap for short hop, hold for full jump
- **Combo System** - Chain enemy kills for bonus score multipliers

### Enemies
- **Skeleton Pirates** 💀 - Patrol, chase, and attack with swords
- **Crabs** 🦀 - Scuttle sideways, hide in shell for defense, then charge
- **Ghost Pirates** 👻 - Float through walls, teleport behind you, fade in/out
- **Seagulls** 🐦 - Fly overhead and dive-bomb when you're below

### Collectibles & Items
- **Gold Coins** 🪙 - Scattered everywhere, attracted to nearby player
- **Treasure Chests** 📦 - Contains gold, health, or treasure map pieces
- **Rum Bottles** 🍶 - Restores health
- **Treasure Map Pieces** 🗺️ - Collect all 3 to unlock secrets

### Environment & Hazards
- **Cannons** 💣 - Fire cannonballs at regular intervals with warning flash
- **Water Hazards** 🌊 - Damages over time with splash effects
- **Spike Traps** ⚔️ - Extend and retract on timers
- **Rope Swings** 🪢 - Grab and swing across gaps
- **Moving Platforms** - Ship deck segments that travel between waypoints
- **Kill Zone** - Fall too far and meet Davy Jones

### Visual Polish
- **Parallax Background** - Multi-layer ocean sky with moon and clouds
- **Particle Effects** - Dash trails, sword sparks, jump dust, coin sparkles
- **Dynamic Lighting** - Lanterns and ghost glows illuminate the night
- **Screen Shake** - Impact feedback on hits
- **Pirate Decorations** - Flags, barrels, crates, anchors, ship masts, crow's nests

### Game Systems
- **Health System** - 5 hearts with invincibility frames on hit
- **Lives System** - 3 lives before game over
- **Score System** - Points from enemies, gold, combos, and level completion
- **Combo Counter** - Chain kills for increasing multipliers
- **Achievement System** - Unlock feats like "First Blood", "Combo Master", "Gold Hoarder"
- **Pause Menu** - Escape to pause/unpause

### UI
- **Main Menu** - Animated title screen with pirate theme
- **HUD** - Health hearts, gold counter, score, combo display, map progress
- **Game Over Screen** - Final stats display with retry option
- **Victory Screen** - Level completion celebration with fireworks

## 🗂️ Project Structure

```
├── scripts/
│   ├── game_manager.gd      # Global game state, scoring, achievements
│   ├── pirate_player.gd     # Player with all movement mechanics
│   ├── skeleton_pirate.gd   # Skeleton enemy AI
│   ├── crab_enemy.gd        # Crab enemy AI
│   ├── ghost_pirate.gd      # Ghost enemy AI
│   ├── seagull_enemy.gd     # Diving seagull enemy
│   ├── gold_coin.gd         # Coin collectible with magnet effect
│   ├── treasure_chest.gd    # Interactive treasure chest
│   ├── rum_bottle.gd        # Health pickup
│   ├── cannon.gd            # Cannon hazard
│   ├── cannonball.gd        # Cannonball projectile
│   ├── water_hazard.gd      # Water damage zone
│   ├── spike_trap.gd        # Timed spike hazard
│   ├── rope_swing.gd        # Swinging rope mechanic
│   ├── moving_platform.gd   # Waypoint-based platform
│   ├── level_end.gd         # Level completion trigger
│   ├── parallax_ocean.gd    # Background parallax controller
│   ├── hud.gd               # HUD display logic
│   ├── main_menu.gd         # Title screen
│   ├── game_over.gd         # Game over screen
│   └── victory_screen.gd    # Level victory screen
├── scenes/
│   ├── game.tscn             # Main game level
│   ├── main_menu.tscn        # Title screen
│   ├── pirate_player.tscn    # Player character scene
│   ├── enemies/              # Enemy scenes
│   ├── collectibles/         # Pickup scenes
│   ├── environment/          # Hazard & prop scenes
│   ├── effects/              # Particle effect scenes
│   └── ui/                   # UI screen scenes
└── assets/                   # Sprites and textures
```

## 🚀 Getting Started

1. Open the project in Godot 4.5+
2. Press F5 or click Play to start
3. Navigate the pirate-themed levels, defeat enemies, collect treasure!

## 🎯 Tips

- Use **wall jumps** to reach high platforms
- **Dash** through enemy attacks with invincibility
- Kill enemies quickly to build **combos** for bonus points
- Look for **treasure chests** on hard-to-reach platforms
- Collect all **map pieces** to prove you're a true pirate captain
- **Crabs** can't be hurt while hiding in their shell - wait for them to charge!
- **Ghost pirates** will teleport - keep moving!

---

*Arr, may the wind be at yer back, matey! ⚓*
