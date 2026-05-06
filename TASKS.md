# 🧬 CELL SURGE — Task Board

## Legenda
- `[ ]` Da fare
- `[/]` In corso
- `[x]` Completato

---

## FASE 1: UI & Foundation ✅
- [x] Architettura base (EventBus, GameManager, SaveManager, AudioManager)
- [x] Player con movimento e stats
- [x] Sistema nemici (EnemyBase, EnemySpawner, WaveManager)
- [x] Arma base (NucleusPulse + ObjectPool)
- [x] Sistema Level Up (UpgradeSystem + LevelUpScreen)
- [x] HUD coerente con DESIGN_UI.md (bioluminescenza)
- [x] HP Ring attorno al player (world-space)
- [x] XP Bar pill-shape top-wide ciano
- [x] Header: LV / Timer / ☠ Kills
- [x] Inventario mutazioni (bottom-left, 32×32)
- [x] Low HP Vignette (rosso pulsante <20%)
- [x] Virtual Joystick floating (appare al tocco, scompare al rilascio)
- [x] Damage Pop-ups (#FFAC1C, 0.4s, scale + fade)
- [x] Level Up flash bianco 0.1s
- [x] MainMenu bioluminescenza
- [x] GameOver bioluminescenza
- [x] LevelUp cards bioluminescenza

---

## FASE 2: Core Gameplay Polish
- [ ] Nuova arma: Enzyme Stream (spara verso nemico più vicino)
- [ ] Nuova arma: Antibody Orbit (sfere orbitanti)
- [ ] Nuova arma: Cytokine Wave (onda d'urto AoE)
- [ ] Bilanciamento spawn nemici per minuto
- [ ] Virus: comportamento zigzag
- [ ] Fungo: rallenta il player al contatto
- [ ] Sistema evoluzione armi (Lv5 → forma evoluta)
- [ ] Mutazioni passive (Thick Membrane, ATP Boost, Mitosis, ecc.)
- [ ] Più upgrade nell'UpgradeSystem (almeno 15 opzioni)
- [ ] Sistema rarity con drop rate (common 60%, rare 30%, epic 10%)

---

## FASE 3: Meta-Progression & Menus
- [ ] Main Menu: bottone Upgrades funzionante
- [ ] Shop Meta-Upgrades (spendi Gold per upgrade permanenti)
- [ ] UI Shop con lista upgrade, livello attuale, costo, pulsante acquisto
- [ ] Character Select screen
- [ ] Sblocco personaggi (Macrofago, Linfocita T, Plasmacellula, NK)
- [ ] Ogni personaggio con stats e passive uniche
- [ ] Settings menu (volume SFX, Music, Vibrazione)
- [ ] Daily Login system (reward crescenti, 7 giorni)
- [ ] Stats screen (best time, best kills, total runs)

---

## FASE 4: Content & Boss
- [ ] Boss: Super Cellula (min 10) — area denial, spawn mini-nemici
- [ ] Boss: Prione (min 20) — boss finale, pattern multipli
- [ ] Boss HP bar dedicata (in cima allo schermo)
- [ ] Nuovi nemici: Parassita (invisibile periodicamente)
- [ ] Nuovi nemici: Cellula Infetta (esplode alla morte)
- [ ] Chest/cassa bonus (spawn periodico sulla mappa)
- [ ] Power-up temporanei (bomba, magnete globale, invincibilità)
- [ ] Bilanciamento end-game (minuti 15-20)

---

## FASE 5: Polish & Effects
- [ ] Particle system: morte nemico (esplosione verde)
- [ ] Particle system: raccolta XP (trail ciano)
- [ ] Particle system: level up (esplosione oro)
- [ ] Particle system: proiettili (trail luminoso)
- [ ] Screen shake migliorato (differenziato per evento)
- [ ] Animazione entrata/uscita per LevelUp e GameOver
- [ ] Suoni SFX per tutti gli eventi (sparo, hit, pickup, level up, morte)
- [ ] BGM gameplay (loop ambient biologico)
- [ ] BGM menu (loop calmo)
- [ ] Haptic feedback (vibrazione) per hit e level up
- [ ] Background procedurale (pattern cellulare che si muove)

---

## FASE 6: Monetizzazione & Release
- [ ] Sistema Ads (Rewarded: doppio gold, resurrezione)
- [ ] Remove Ads IAP
- [ ] Gem packs IAP
- [ ] Starter Pack IAP
- [ ] Store listing (icon, screenshots, descrizione)
- [ ] Performance profiling su device reali
- [ ] Export Android APK/AAB
- [ ] Export iOS
- [ ] Beta testing (TestFlight / Google Play Beta)
- [ ] Launch
