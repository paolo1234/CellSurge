# CellSurge - Tracciamento Sviluppo OpenCode

## PROMPT 

-CONTINUA LO SVILUPPO DEL GIOCO su GODOT basandoti su questo file OPENCODE, TASKS e implementation_plan (e GDD se necessario)

- Ricordati sempre di aggiornare lo stato del file OPENCODE.md in modo che anche se chiudo l'agente sai sempre da dove riprendere.

- RICORDATI IL MODELLO NON PRENDE IMMAGINI IN INPUT QUINDI EVITA SCREENSHOT 

## Ultimo aggiornamento: 2026-05-06

## STATO ATTUALE: FASE 1 COMPLETATA ✅

### Cosa funziona:
- ✅ Core gameplay: player, nemici, spawning, wave system
- ✅ Arma base: NucleusPulse con object pool
- ✅ Level Up: 3 upgrade cards, pausa, selezione
- ✅ UI HUD coerente con DESIGN_UI.md (bioluminescenza)
  - XP bar pill-shape top-wide ciano (#00FFFF)
  - Header: LV (ciano) / Timer (bianco, grande) / ☠ Kills
  - Inventario mutazioni (bottom-left, 3x2, 32×32)
  - Low HP vignette rossa pulsante (<20%)
  - Damage pop-ups #FFAC1C, 0.4s, scale+fade
  - Level Up flash bianco 0.1s
- ✅ HP Ring (Node2D _draw) attorno al player in world-space
- ✅ Virtual Joystick floating (appare al tocco, scompare al rilascio)
- ✅ MainMenu con tema bioluminescenza (ciano, dark bg)
- ✅ GameOver con palette coerente
- ✅ LevelUp cards con bordi ciano hover
- ✅ GDD.md completo
- ✅ TASKS.md con 6 fasi di sviluppo

### Prossimi step (FASE 2):
- [ ] Nuove armi (Enzyme Stream, Antibody Orbit, Cytokine Wave)
- [ ] Virus zigzag behavior
- [ ] Fungo slow effect
- [ ] Più mutazioni passive nell'UpgradeSystem
- [ ] Sistema rarity con drop rates

### File principali modificati in questa sessione:
- `scripts/ui/HUD.gd` — Riscritto: UI programmatica, palette bioluminescenza
- `scenes/ui/HUD.tscn` — Ridotto a CanvasLayer minimale
- `scripts/ui/HPRing.gd` — NUOVO: anello HP con _draw(), verde→rosso
- `scripts/ui/VirtualJoystick.gd` — Floating joystick behavior
- `scenes/ui/VirtualJoystick.tscn` — Touch area bottom-wide
- `scripts/ui/MainMenu.gd` — Palette bioluminescenza, icone emoji
- `scripts/ui/GameOverScreen.gd` — Palette bioluminescenza, icone stats
- `scripts/ui/LevelUpScreen.gd` — Palette bioluminescenza, bordi ciano
- `scripts/systems/World.gd` — HPRing setup, damage popup fix
- `GDD.md` — Game Design Document completo
- `TASKS.md` — Task board 6 fasi
