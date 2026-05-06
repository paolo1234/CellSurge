# 🎮 Mobile Survivor Game — Piano di Sviluppo Professionale

Un gioco stile **Vampire Survivors / Survivor.io / Cell Survivor** per mobile, sviluppato in Godot 4.
Obiettivo: gioco professionale, scalabile, con monetizzazione efficace e meccaniche che creano dipendenza.

---

## 🎯 Concept e Game Loop

### Concept Core
- **Genere:** Auto-shooter Top-Down Survivor
- **Piattaforma:** Mobile (Android + iOS)
- **Orientamento:** Portrait (1080×1920)
- **Sessione ideale:** 15–25 minuti per run
- **Setting:** Ambientazione biologica/cellulare stile Cell Survivor (cell → virus → mutazioni)

### The Addictive Loop (Il Segreto del Successo)
```
Avvia run → Sopravvivi → Level up + scegli upgrade → Muori/Vinci
     ↓               ↓                              ↓
"Una ancora"    Soddisfazione                  Progressione meta
                  dopaminica                 (sblocchi permanenti)
```

**Pillars of Addiction:**
1. **Satisfying feedback** — ogni kill visivo e sonoro appagante
2. **Power spikes** — senti di diventare più forte ogni 2 minuti
3. **Choice illusion** — upgrade casuali ma sempre utili
4. **"One more run"** — morti veloci, restart istantaneo
5. **Meta-progression** — ogni partita sblocca qualcosa di permanente

---

## 🏗️ Architettura Tecnica

### Struttura Scene
```
res://
├── autoloads/
│   ├── GameManager.gd        # Stato globale, statistiche, run corrente
│   ├── SaveManager.gd        # Salvataggio/caricamento persistente
│   ├── MonetizationManager.gd # IAP, Ads (AdMob)
│   ├── AudioManager.gd       # Pool audio, SFX, musica
│   └── EventBus.gd           # Signal bus globale (decoupling)
│
├── scenes/
│   ├── ui/
│   │   ├── MainMenu.tscn
│   │   ├── CharacterSelect.tscn
│   │   ├── LevelUpScreen.tscn
│   │   ├── GameOver.tscn
│   │   ├── PauseMenu.tscn
│   │   └── HUD.tscn
│   ├── gameplay/
│   │   ├── World.tscn          # Scena principale gameplay
│   │   ├── Player.tscn
│   │   ├── EnemyBase.tscn
│   │   └── projectiles/
│   └── fx/
│       ├── BloodSplat.tscn
│       ├── LevelUpEffect.tscn
│       └── ExpOrb.tscn
│
├── scripts/
│   ├── player/
│   │   ├── Player.gd
│   │   ├── PlayerStats.gd
│   │   └── weapons/
│   │       ├── WeaponBase.gd
│   │       ├── Projectile.gd
│   │       └── [WeaponX].gd
│   ├── enemies/
│   │   ├── EnemyBase.gd
│   │   ├── EnemySpawner.gd
│   │   └── [EnemyType].gd
│   ├── systems/
│   │   ├── ObjectPool.gd     # Pool per performance mobile
│   │   ├── UpgradeSystem.gd
│   │   ├── WaveManager.gd
│   │   └── ProgressionSystem.gd
│   └── data/
│       ├── WeaponData.gd     # Resource con dati armi
│       ├── EnemyData.gd
│       └── UpgradeData.gd
└── resources/
    ├── weapons/
    ├── enemies/
    └── upgrades/
```

### Sistemi Chiave

#### 1. Object Pool (CRITICO per Mobile)
Nessun `instantiate()` a runtime. Tutti i proiettili, nemici e FX vengono da pool pre-allocati.

#### 2. Stats System (Data-Driven)
Ogni stat è un valore modificabile da upgrade, armi e livelli:
```gdscript
class_name PlayerStats
var max_health: float
var move_speed: float
var damage_mult: float
var attack_speed_mult: float
var area_mult: float
var exp_gain_mult: float
var pickup_radius: float
```

#### 3. Upgrade System
- Al level-up: 3 upgrade casuali (pesati) tra quelli disponibili
- Upgrade hanno tier: Comune, Raro, Epico
- Synergies: certi combo sbloccano potenziamenti speciali

#### 4. Wave Manager
Escalation progressiva:
- Minuto 0-5: tutorial soft, nemici lenti
- Minuto 5-15: rampa veloce, boss al minuto 10
- Minuto 15-20: endgame caotico
- Minuto 20+: solo per i "hard" — mob infiniti

---

## 🎮 Contenuto di Lancio (MVP)

### Personaggi (3)
| # | Nome | Arma Iniziale | Passivo |
|---|------|---------------|---------|
| 1 | Cellula (free) | Nucleo Pulse | +20% HP |
| 2 | Fagocita (sblocco) | Tentacoli | +15% velocità |
| 3 | Anticorpo (IAP) | Scudo + proiettili | +30% difesa |

### Armi (8)
1. **Nucleo Pulse** — proiettili circolari auto
2. **Tentacoli** — whip che colpisce vicino
3. **Divisione Cellulare** — split shot
4. **Tossina** — area damage nel tempo (DOT)
5. **Membrana** — scudo orbitante
6. **Mitosi Laser** — raggio direzionale verso il nemico più vicino
7. **Endocitosi** — aspira i nemici vicini
8. **Anticorpo** — proiettile che segue il nemico

### Nemici (6 tipi base + 2 boss)
- Batterio Basic, Virus Fast, Fungo Tank, Parassita Ranged, Spora Esplosiva, Batterio Gigante
- Boss minuto 10: Superba Cellula
- Boss finale minuto 20: Il Prione

### Mappe (2)
- Petri Dish (aperta, colorata, tutorial)
- Corpo Umano (corridoi, più difficile)

---

## 💰 Monetizzazione (La Parte Importante)

### Strategia: Free-to-Play con IAP soft + Ads rewarded

#### Ads
| Tipo | Quando | Frequenza |
|------|--------|-----------|
| Interstitial | Game Over | 1 ogni 2 partite |
| Rewarded | +1 scelta upgrade / continua dopo morte | Volontario |
| Banner | Main Menu | Sempre (discreto) |

#### IAP
| Prodotto | Prezzo | Cosa dà |
|---------|--------|---------|
| Remove Ads | €2,99 | Niente più interstitial/banner |
| Starter Pack | €1,99 | Personaggio + 1000 oro + 7 giorni premium |
| Oro x500 | €0,99 | Valuta premium |
| Oro x2500 | €3,99 | |
| Season Pass | €4,99/mese | Daily reward premium, +20% oro |

#### Valuta e Progressione
- **Oro** (earned in-game, purchasable): upgrade permanenti, sblocchi personaggi
- **Gemme** (premium): acquisti esclusivi, continua dopo morte illimitata
- **Meta-upgrade tree**: potenziamenti permanenti acquistabili con oro

#### Daily Retention
- Login giornaliero: oro scalabile (7gg loop)
- Daily challenge: run con regole speciali → ricompensa garantita
- Weekly boss: evento speciale con leaderboard

---

## 🔄 Fasi di Sviluppo

### Fase 1 — Prototipo Core (2-3 settimane)
- [ ] Player movement + camera
- [ ] 1 arma (Nucleo Pulse) auto-attack
- [ ] EnemySpawner + 2 nemici base
- [ ] Object Pool system
- [ ] Experience + Level Up (3 scelte)
- [ ] HUD: HP bar, EXP bar, timer
- [ ] Game Over / Restart

### Fase 2 — Content Layer (2-3 settimane)
- [ ] Tutte 8 le armi
- [ ] Tutti 6 i nemici + 2 boss
- [ ] Upgrade System completo con 20+ upgrade
- [ ] Wave Manager con escalation
- [ ] SaveManager (salvataggio locale)
- [ ] 2 mappe

### Fase 3 — Meta-progression (1-2 settimane)
- [ ] 3 personaggi
- [ ] Albero upgrade permanenti
- [ ] Valuta oro
- [ ] Sblocchi

### Fase 4 — UI/UX + Feel (1-2 settimane)
- [ ] Main Menu, Character Select
- [ ] Level Up screen animata
- [ ] Juice: screen shake, hit flash, particelle
- [ ] Sound FX + Musica
- [ ] UI/UX mobile touch-friendly

### Fase 5 — Monetizzazione (1 settimana)
- [ ] AdMob (Android) + App Tracking (iOS)
- [ ] IAP setup
- [ ] Rewarded ads integrazione
- [ ] Analytics (Firebase)

### Fase 6 — Polish + Ottimizzazione (1 settimana)
- [ ] Performance profiling su mobile
- [ ] LOD system per nemici lontani
- [ ] Riduzione draw calls
- [ ] Test su dispositivi fisici

---

## ⚠️ Domande Aperte (user review)

> [!IMPORTANT]
> **1. Nome del gioco?** Hai un concept di nome/brand o procediamo con un placeholder tipo "Cell Surge"?

> [!IMPORTANT]
> **2. Hai già un progetto Godot aperto?** Oppure creo tutto da zero in una nuova cartella?

> [!IMPORTANT]
> **3. Assets:** Preferisci che usi placeholder geometrici (cerchi colorati) per partire subito, oppure vuoi uno stile grafico specifico (pixel art, vettoriale, cartoon)?

> [!IMPORTANT]
> **4. Lingua target:** Solo italiano o internazionale (inglese) per il mercato globale?

> [!CAUTION]
> **5. Monetizzazione:** Hai un account Google Play / Apple Developer? L'integrazione AdMob richiede credenziali. Possiamo procedere senza per adesso e aggiungere dopo.

---

## 🚀 Prossimo Passo

Con la tua approvazione, inizio dalla **Fase 1**: creo il progetto Godot con l'architettura completa, player movement, prima arma e sistema di enemy spawning con object pool.
