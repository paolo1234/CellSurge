# ✅ CELL SURGE — Task Board Completo

Ogni task ha: `ID`, stato, priorità, dipendenze e note tecniche.

**Legenda stato:**
- `[ ]` Da fare
- `[/]` In corso
- `[x]` Completato
- `[!]` Bloccato

**Legenda priorità:** 🔴 Critico | 🟠 Alto | 🟡 Medio | 🟢 Basso

---

## FASE 1 — Prototipo Core Giocabile

### P1 — Setup Progetto
- `[x]` **T001** 🔴 Crea cartella progetto `Progetti/CellSurge`
- `[x]` **T002** 🔴 Crea `project.godot` con configurazione mobile (1080×1920, portrait)
- `[ ]` **T003** 🔴 Crea struttura cartelle: `autoloads/`, `scenes/`, `scripts/`, `resources/`, `assets/`
- `[ ]` **T004** 🔴 Crea placeholder icon.svg
- `[ ]` **T005** 🟠 Inizializza git repo con `.gitignore` Godot

### P2 — Autoloads Core
- `[ ]` **T010** 🔴 Crea `EventBus.gd` con tutti i signal globali
- `[ ]` **T011** 🔴 Crea `GameManager.gd` — stato run, timer, score
- `[ ]` **T012** 🔴 Crea `SaveManager.gd` — save/load JSON locale
- `[ ]` **T013** 🟠 Crea `AudioManager.gd` — pool SFX, musica

### P3 — Player
- `[ ]` **T020** 🔴 Crea `Player.tscn` (CharacterBody2D + CollisionShape2D + Sprite2D)
- `[ ]` **T021** 🔴 Crea `Player.gd` — movimento 8 direzioni, velocità
- `[ ]` **T022** 🔴 Crea `PlayerStats.gd` — tutte le statistiche, modificatori
- `[ ]` **T023** 🔴 Crea sistema HP: danno ricevuto, morte, invincibilità temporanea
- `[ ]` **T024** 🟠 Visual: hit flash (rosso), screen shake leggero su danno ricevuto
- `[ ]` **T025** 🟡 Joystick virtuale mobile (bottom-left)

### P4 — Prima Arma: Nucleo Pulse
- `[ ]` **T030** 🔴 Crea `WeaponBase.gd` — classe base per tutte le armi
- `[ ]` **T031** 🔴 Crea `NucleusPulse.gd` — proiettili radiali auto
- `[ ]` **T032** 🔴 Crea `Projectile.tscn` + `Projectile.gd` — base proiettile
- `[ ]` **T033** 🔴 Crea `ObjectPool.gd` — pool generico per qualsiasi nodo
- `[ ]` **T034** 🟠 Proiettile: collisione con nemici, danno, distruzione/repool

### P5 — Nemici Base
- `[ ]` **T040** 🔴 Crea `EnemyBase.tscn` + `EnemyBase.gd`
- `[ ]` **T041** 🔴 Crea `Batterio.gd` — chase player, morte drop EXP
- `[ ]` **T042** 🔴 Crea `EnemySpawner.gd` — spawn da bordi schermo, wave config
- `[ ]` **T043** 🟠 Crea `Virus.gd` (fast enemy)
- `[ ]` **T044** 🟠 Crea `Fungo.gd` (tank enemy)
- `[ ]` **T045** 🟡 Visual: hit flash su nemici, death effect (particelle)

### P6 — EXP e Level Up
- `[ ]` **T050** 🔴 Crea `ExpOrb.tscn` + `ExpOrb.gd` — drop, vola verso player nel raggio
- `[ ]` **T051** 🔴 Crea sistema EXP in `GameManager` — curva livelli, event on level up
- `[ ]` **T052** 🔴 Crea `UpgradeSystem.gd` — pool upgrade, peso rarità, selezione 3 casuali
- `[ ]` **T053** 🔴 Crea `LevelUpScreen.tscn` — UI 3 card upgrade, pausa gioco
- `[ ]` **T054** 🟠 Crea dati upgrade (almeno 10 upgrade) — stat boost base

### P7 — HUD e UI Base
- `[ ]` **T060** 🔴 Crea `HUD.tscn` — HP bar, EXP bar, timer, level
- `[ ]` **T061** 🟠 HP bar animata (tween quando cambia)
- `[ ]` **T062** 🟠 Timer di gioco visibile (MM:SS)
- `[ ]` **T063** 🟡 Kill counter, danno totale (stat display)

### P8 — Game Over e Restart
- `[ ]` **T070** 🔴 Crea `GameOver.tscn` — statistiche run, pulsante riprova
- `[ ]` **T071** 🔴 Restart run (reload scena world)
- `[ ]` **T072** 🟠 Animazione death player (dissolvenza / esplosione)
- `[ ]` **T073** 🟡 Victory screen (sopravvissuto 20 minuti)

### P9 — World e Camera
- `[ ]` **T080** 🔴 Crea `World.tscn` — scena principale gameplay
- `[ ]` **T081** 🔴 Camera 2D che segue il player smooth
- `[ ]` **T082** 🟠 Mappa infinita (background tile che si ripete)
- `[ ]` **T083** 🟡 Boundaries: spawner nemici da bordi camera, non bordi mondo

---

## FASE 2 — Content Layer

### C1 — Armi (completare tutte 8)
- `[ ]` **T100** 🟠 `Lash.gd` — whip melee ad arco
- `[ ]` **T101** 🟠 `CellSplit.gd` — piercing shot
- `[ ]` **T102** 🟡 `Toxin.gd` — area DOT
- `[ ]` **T103** 🟡 `Membrane.gd` — scudi orbitanti
- `[ ]` **T104** 🟡 `LaserRay.gd` — laser direzionale
- `[ ]` **T105** 🟡 `Vortex.gd` — pull + danno
- `[ ]` **T106** 🟡 `Antibody.gd` — homing missile
- `[ ]` **T107** 🟡 Slot sistema armi (max 4 armi contemporanee)

### C2 — Nemici (completare tutti)
- `[ ]` **T110** 🟠 `Parassita.gd` — ranged, mantieni distanza
- `[ ]` **T111** 🟠 `Spora.gd` — esplode alla morte
- `[ ]` **T112** 🟡 `Batteriofago.gd` — spawn in swarm x15
- `[ ]` **T113** 🔴 `SuperCellula.gd` — boss minuto 10
- `[ ]` **T114** 🔴 `Prione.gd` — boss finale minuto 20, 3 fasi

### C3 — Wave Manager
- `[ ]` **T120** 🔴 `WaveManager.gd` — schedule spawn per minuto
- `[ ]` **T121** 🟠 Escalation densità nemici per minuto
- `[ ]` **T122** 🟠 Trigger boss a minuto 10 e 20
- `[ ]` **T123** 🟡 Elite nemici random dopo minuto 5

### C4 — Upgrade System Completo
- `[ ]` **T130** 🟠 Tutti 30+ upgrade implementati
- `[ ]` **T131** 🟠 Weapon upgrade (level up armi in game)
- `[ ]` **T132** 🟡 Passive items (prerequisiti evoluzioni)
- `[ ]` **T133** 🟡 Weapon evolutions (4 evoluzioni)

### C5 — Mappe
- `[ ]` **T140** 🟠 Mappa "Petri Dish" — sfondo colorato, aperta
- `[ ]` **T141** 🟡 Mappa "Corpo Umano" — corridoi, più difficile

---

## FASE 3 — Meta-Progression

### M1 — Personaggi
- `[ ]` **T200** 🟠 Sistema selezione personaggio (CharacterSelect.tscn)
- `[ ]` **T201** 🟠 Leuco (default)
- `[ ]` **T202** 🟡 Fagos (500 oro)
- `[ ]` **T203** 🟡 Anticorpo (2000 oro)
- `[ ]` **T204** 🟡 Mitosi (5000 oro)

### M2 — Valuta e Save
- `[ ]` **T210** 🔴 Sistema oro: guadagno fine run, salvataggio
- `[ ]` **T211** 🔴 SaveManager completo: personaggi, oro, meta-upgrade
- `[ ]` **T212** 🟠 Meta-upgrade tree (almeno 10 upgrade permanenti)
- `[ ]` **T213** 🟠 UI Meta-upgrade (MainMenu → Upgrades)

### M3 — Daily Retention
- `[ ]` **T220** 🟡 Daily login reward (7 giorni loop)
- `[ ]` **T221** 🟡 Daily challenge (run con regole speciali)
- `[ ]` **T222** 🟢 Achievements system
- `[ ]` **T223** 🟢 Leaderboard locale (best run stat)

---

## FASE 4 — UI/UX e Feel

### U1 — Schermate
- `[ ]` **T300** 🟠 `MainMenu.tscn` — logo, play, personaggi, upgrade, settings
- `[ ]` **T301** 🟠 `Settings.tscn` — volume, vibrazione, lingua
- `[ ]` **T302** 🟡 Animazioni transizione schermate (fade, slide)
- `[ ]` **T303** 🟡 Splash screen (logo + studio)

### U2 — Juice e Game Feel
- `[ ]` **T310** 🟠 Screen shake modulabile (leggero su hit, forte su boss)
- `[ ]` **T311** 🟠 Numero danno pop (floating text)
- `[ ]` **T312** 🟠 Particelle kill per ogni tipo nemico
- `[ ]` **T313** 🟠 Level up: freeze frame 0.5s + flash schermo
- `[ ]` **T314** 🟡 Critico: testo "CRIT!" + suono speciale
- `[ ]` **T315** 🟡 Camera zoom out leggero con molti nemici

### U3 — Audio
- `[ ]` **T320** 🟠 SFX: shoot, kill, hit subito, level up, game over
- `[ ]` **T321** 🟠 BGM: musica gameplay energica
- `[ ]` **T322** 🟡 Boss music (traccia separata)
- `[ ]` **T323** 🟡 Haptics (vibrazione leggera su kill / danno ricevuto)

---

## FASE 5 — Monetizzazione

### Mo1 — AdMob
- `[ ]` **T400** 🟠 Integra plugin AdMob Android/iOS
- `[ ]` **T401** 🟠 Interstitial ad (game over, ogni 2 run)
- `[ ]` **T402** 🟠 Rewarded ad (revive, +1 upgrade choice)
- `[ ]` **T403** 🟡 Banner ad (main menu)
- `[ ]` **T404** 🔴 "Remove Ads" IAP — disabilita banner + interstitial

### Mo2 — IAP
- `[ ]` **T410** 🔴 Integra GodotGooglePlayBilling plugin (Android)
- `[ ]` **T411** 🟠 IAP: Starter Pack, Gold packs, Gems packs
- `[ ]` **T412** 🟠 Season Pass (mensile)
- `[ ]` **T413** 🟡 Receipt validation (server-side se possibile)

### Mo3 — Analytics
- `[ ]` **T420** 🟡 Firebase Analytics — eventi: run_start, run_end, level_up, ad_watched
- `[ ]` **T421** 🟡 Crash reporting (Firebase Crashlytics)

---

## FASE 6 — Polish e Release

### R1 — Ottimizzazione Mobile
- `[ ]` **T500** 🔴 Profiling FPS su device fisico Android
- `[ ]` **T501** 🔴 Object pool tutti i nodi frequenti
- `[ ]` **T502** 🟠 LOD: riduzione logica per nemici fuori camera
- `[ ]` **T503** 🟠 Riduzione draw calls (atlasing sprites)
- `[ ]` **T504** 🟡 Memory profiling (niente leak)

### R2 — QA e Test
- `[ ]` **T510** 🔴 Balance: curva difficoltà vs divertimento
- `[ ]` **T511** 🟠 Balance: costo upgrade vs guadagno oro
- `[ ]` **T512** 🟠 Test su almeno 3 dispositivi Android diversi
- `[ ]` **T513** 🟡 Test iOS (simulator + device)
- `[ ]` **T514** 🟡 Beta test (5-10 utenti reali)

### R3 — Store
- `[ ]` **T520** 🟠 Screenshots e video promo per store
- `[ ]` **T521** 🟠 Descrizione Google Play (EN + IT)
- `[ ]` **T522** 🟠 Privacy Policy + GDPR compliance
- `[ ]` **T523** 🔴 Build APK release + firma
- `[ ]` **T524** 🔴 Upload Google Play (test interno → closed beta → open)
- `[ ]` **T525** 🟡 Apple App Store (richiede Mac + Developer account)

---

## BACKLOG / Future

- `[ ]` **B001** 🟢 Co-op 2 giocatori online
- `[ ]` **B002** 🟢 Boss Rush mode
- `[ ]` **B003** 🟢 Stagioni mensili (nuovo personaggio + skin ogni mese)
- `[ ]` **B004** 🟢 Leaderboard globale (online)
- `[ ]` **B005** 🟢 Ascension mode (infinito post-20min)
- `[ ]` **B006** 🟢 Localizzazione (IT, EN, ES, PT, KO, JA)

---

**Totale task:** ~120 task  
**Task Fase 1 (MVP giocabile):** ~45 task  
**Stima Fase 1:** 2–3 settimane (sviluppo attivo con AI)
