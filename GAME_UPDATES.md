# Dwarf Platformer - Implementerede Features

## Nyligt Tilføjet

### 1. Animations System ✓
- **Walk/Run Animation** - 4 frames løbe-animation når dværgen bevæger sig
- **Jump Animation** - Spring animation når dværgen hopper op
- **Fall Animation** - Fald animation når dværgen falder ned
- **Sprite Flipping** - Dværgen vender ansigtet mod bevægelsesretningen
- Smooth animation transitions baseret på velocity og floor status

### 2. Level Goal System ✓
- **Exit/Flag** - Grøn exit zone ved slutningen af niveauet
- **Win Condition** - Når spilleren rører exit, genstartes niveauet efter 2 sekunder
- **Visual Feedback** - Exit lyser grønt når spilleren vinder
- Console besked med final score

### 3. Collectibles System ✓
- **Coins** - 5 coins placeret rundt i niveauet
- **Score Tracking** - Score gemmes i dwarf.gd
- **Collection Detection** - Coins forsvinder når indsamlet
- **UI Display** - "Coins: X" vises i øverste venstre hjørne

### 4. Kamera Forbedringer ✓
- **Kamera Grænser** - Kameraet kan ikke vise ud over niveauet
- Limits sat til: left=-150, top=-100, right=300, bottom=150
- Position smoothing aktiveret for smooth følgning

## Fil Struktur

```
scenes/
  ├── dwarf.tscn      - Opdateret med Run, Jump, Fall animationer
  ├── game.tscn       - Hovedscene med coins, exit, UI og kamera limits
  ├── exit.tscn       - Exit zone (Area2D med collision)
  ├── coin.tscn       - Collectable coin (Area2D)
  └── ui.tscn         - Score display (CanvasLayer)

scripts/
  ├── game.gd         - Koordinerer UI og level completion
  ├── exit.gd         - Håndterer exit collision og signal
  ├── coin.gd         - Håndterer coin collection
  └── ui.gd           - Opdaterer score label

dwarf.gd              - Opdateret med animation logic og score tracking
```

## Sådan Spiller Du

1. Kør projektet i Godot
2. Brug **Piltaster/WASD** til at bevæge dig
3. Tryk **Mellemrum** for at hoppe
4. Saml alle **5 coins** i niveauet
5. Nå **exit zonen** (grøn flag) for at fuldføre niveau

## Næste Skridt (Forslag)

- [ ] Tilføj lyd effekter (jump, coin collection, win)
- [ ] Opret Level 2 med højere sværhedsgrad
- [ ] Implementer enemies/hazards
- [ ] Tilføj particle effects (dust, coin sparkle)
- [ ] Opret main menu
- [ ] Tilføj background/parallax layers
- [ ] Implementer lives/health system
- [ ] Tilføj checkpoints for længere niveauer
