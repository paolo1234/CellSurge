# 📖 CELL SURGE — Game Design Document (GDD)
**Versione:** 1.0  
**Data:** Maggio 2026  
**Engine:** Godot 4.6.2  
**Piattaforma:** Android / iOS (Mobile Portrait)  
**Genere:** Auto-Shooter Top-Down Survivor  

---

## 1. VISIONE DEL GIOCO

### 1.1 Elevator Pitch
> Cell Surge è un auto-shooter survivor per mobile ambientato dentro il corpo umano. Il giocatore controlla una cellula che deve sopravvivere a ondate infinite di patogeni, evolversi raccogliendo potenziamenti e diventare sempre più potente. Ogni run dura 20 minuti, ogni morte è una lezione, ogni upgrade è una scelta strategica.

### 1.2 Pillars Design
| Pillar | Descrizione |
|--------|-------------|
| **Accessibilità** | Una mano, un dito. No tutorial lungo. Si capisce in 10 secondi. |
| **Depth** | 8 armi, 30+ upgrade, synergies nascoste. Ore per masterizzare. |
| **Progression** | Ogni run lascia qualcosa. Mai sprecare tempo. |
| **Juice** | Ogni kill è soddisfacente. Il feedback audio/visivo è esagerato. |
| **Social** | Leaderboard, record personali, screenshot share. |

### 1.3 Target Audience
- Età: 16–35 anni
- Casual gamer che cerca sessioni da 15-30 min
- Fan di Vampire Survivors, Survivor.io, Archero
- Mercato: Globale (testi in inglese, UI intuitiva)

---

## 2. MECCANICHE DI GIOCO

### 2.1 Controlli
**Mobile:**  
- **Joystick virtuale** (sinistro, bottom-left) → movimento del personaggio
- Il giocatore muove solo il personaggio — le armi sparano in automatico verso il nemico più vicino
- **Tap su power-up** a terra per raccoglierli (o auto-pickup nel raggio)

**PC/Testing:**
- WASD → movimento
- Mouse click → selezione upgrade

### 2.2 Gameplay Loop Core

```
START RUN
    │
    ▼
MUOVI il personaggio per evitare i nemici
    │
    ▼
UCCIDI i nemici → drop ORB EXP
    │
    ▼
RACCOGLI le orb → riempi la barra EXP
    │
    ▼
LEVEL UP → pausa gioco → scegli 1 di 3 upgrade casuali
    │
    ▼
SOPRAVVIVI 20 minuti → Win Screen
    │ (o muori prima)
    ▼
GAME OVER → statistiche → ottieni ORO in base a performance
    │
    ▼
SPENDI ORO in meta-upgrade permanenti
    │
    └──────────────────────────────────────► START NUOVA RUN
```

### 2.3 Statistiche Personaggio

```gdscript
max_health:        100.0   # HP massimi
move_speed:        200.0   # pixel/secondo
damage_mult:       1.0     # moltiplicatore danno globale
attack_speed_mult: 1.0     # moltiplicatore velocità attacco
area_mult:         1.0     # moltiplicatore area/range armi
duration_mult:     1.0     # durata effetti
exp_gain_mult:     1.0     # EXP guadagnata
pickup_radius:     80.0    # raggio auto-pickup orb EXP
luck:              0.0     # probabilità drop migliori / upgrade rari
crit_chance:       0.0     # probabilità critico
crit_mult:         1.5     # moltiplicatore danno critico
armor:             0.0     # riduzione danno flat
regen:             0.0     # HP/secondo rigenerazione
```

### 2.4 Sistema Armi

#### Come funzionano
- Ogni personaggio parte con **1 arma**
- Si possono avere fino a **4 armi contemporaneamente**
- Le armi si evolvono (2 livelli: base → potenziato → evolved)
- L'evolved si sblocca con un'arma + il relativo passive item

#### Tabella Armi

| # | Nome | Tipo | Danno Base | Cadenza | Lvl Max | Description |
|---|------|------|-----------|---------|---------|-------------|
| 1 | Nucleo Pulse | Proiettile radiale | 15 | 1.5s | 5 | Spara N proiettili in cerchio |
| 2 | Lash | Whip melee | 30 | 1.2s | 5 | Colpo ad arco frontale |
| 3 | Cell Split | Piercing | 20 | 2.0s | 5 | Proiettile che trafigge i nemici |
| 4 | Toxin | DOT area | 5/tick | 3.0s | 5 | Nuvola veleno persistente |
| 5 | Membrane | Orbitante | 25 | — | 5 | Scudi che ruotano intorno al player |
| 6 | Laser Ray | Direzionale | 50 | 2.5s | 5 | Laser verso il nemico più vicino |
| 7 | Vortex | Pull + danno | 10/tick | — | 5 | Campo che attira e danneggia |
| 8 | Antibody | Homing | 35 | 2.0s | 5 | Proiettile che segue il nemico |

#### Evoluzioni (con passive abbinate)
| Arma | Passive | Evolved | Bonus |
|------|---------|---------|-------|
| Nucleo Pulse | Energy Core | Nova Burst | Esplosione + knockback |
| Lash | Blade Edge | Razor Whip | Bleeding DOT |
| Toxin | Poison Flask | Plague Cloud | Area x3, contagio |
| Laser Ray | Lens | Death Ray | Atraversa muri, piercing |

### 2.5 Sistema Upgrade

#### Categorie
1. **Weapon Upgrade** — potenzia un'arma posseduta (livello +1)
2. **Stat Upgrade** — aumenta una statistica del personaggio
3. **Passive Item** — aggiunge un oggetto passivo (necessario per evoluzioni)
4. **Special** — effetti unici, sbloccano meccaniche

#### Peso Rarità
| Rarità | Colore | Probabilità base |
|--------|--------|-----------------|
| Comune | Grigio | 70% |
| Raro | Blu | 25% |
| Epico | Viola | 5% → modificato da `luck` |

#### Lista Upgrade (30+)

**Stat Upgrades:**
- +Max Health (x3 livelli)
- +Regen (x3)
- +Move Speed (x3)
- +Damage (x3)
- +Attack Speed (x3)
- +Area (x3)
- +EXP Gain (x2)
- +Pickup Radius (x2)
- +Armor (x2)
- +Crit Chance (x2)
- +Luck (x2)

**Passive Items:**
- Energy Core → evolve Nucleo Pulse
- Blade Edge → evolve Lash
- Poison Flask → evolve Toxin
- Lens → evolve Laser Ray
- Iron Shell → +Armor +Health
- Stimulant → +Speed +Attack Speed
- Magnet → +Pickup Radius ×2

### 2.6 Nemici

#### Comportamenti
| Tipo | Nome | HP | Danno | Velocità | Comportamento |
|------|------|----|----|-------|--------------|
| Basic | Batterio | 30 | 10 | 80 | Chase player |
| Fast | Virus | 15 | 8 | 160 | Flank player |
| Tank | Fungo | 200 | 20 | 40 | Push through |
| Ranged | Parassita | 40 | 15 | 60 | Mantieni distanza, spara |
| Exploder | Spora | 25 | 40 area | 100 | Esplode alla morte |
| Swarm | Batteriofago | 8 | 5 | 120 | Arriva in gruppo x15 |

#### Boss
| Minuto | Nome | HP | Meccanica Speciale |
|--------|------|----|--------------------|
| 10 | Super-Cellula | 5000 | Spawn add + carica |
| 20 | Il Prione | 15000 | 3 fasi, meccaniche uniche |

### 2.7 Wave System

```
Minuto 0–2:   Solo Batteri Base, low density
Minuto 2–5:   + Virus Fast, densità media
Minuto 5–8:   + Funghi Tank, elite random
Minuto 8–10:  Rampa intensità, niente boss minuto
Minuto 10:    ⚠️ BOSS: Super-Cellula
Minuto 10–15: Mix 4 tipi nemici, alta densità
Minuto 15–18: + Spora Esplosiva + Batteriofago
Minuto 18–20: ENDGAME — tutti i tipi, max density
Minuto 20:    ⚠️ BOSS FINALE: Il Prione
Minuto 20+:   Infinito, solo "Hard Core" sopravvive
```

### 2.8 Sistema EXP e Livelli

Curva EXP crescente:
```
Livello 1→2:   20 EXP
Livello 2→3:   30 EXP
...
Livello N→N+1: 20 + (N-1) * 10 EXP
```

Max livello per run: 50 (teorico)
Al level up: gioco pausato, scelta tra 3 upgrade (pesi rarità)

---

## 3. PROGRESSIONE META

### 3.1 Valute
| Valuta | Come si guadagna | Come si spende |
|--------|-----------------|---------------|
| **Oro** | Fine run (base + bonus) | Meta-upgrade, unlock personaggi |
| **Gemme** | IAP, eventi daily | Continua dopo morte, skin, gemma → oro |
| **Cristalli** | Completare achievment | Sblocco armi speciali |

### 3.2 Oro Guadagnato per Run
```
Base:          100 oro
+10 per minuto sopravvissuto
+5 per ogni livello raggiunto
+50 se ucciso boss minuto 10
+100 se completata run (20 min)
Moltiplicatore: x1.5 con Premium/Season Pass
```

### 3.3 Meta-Upgrade Tree (Albero Potenziamenti Permanenti)

**Sezione Offesa:**
- +5% danno globale (max x10, costo 200/500/1000...)
- +5% velocità attacco (max x5)
- +10% area armi (max x5)

**Sezione Difesa:**
- +10% HP max (max x10)
- +1 HP/s regen (max x5)
- +5% armor (max x5)

**Sezione Fortuna:**
- +5% EXP guadagnata (max x10)
- +1% luck (max x5)
- +10% pickup radius (max x5)

**Sezione Speciale:**
- Inizia ogni run con 1 upgrade extra (costo 5000)
- Sblocca slot arma extra (costo 3000)
- "Blessed Start" — primo upgrade sempre Epico (costo 2000)

### 3.4 Personaggi Giocabili

| # | Nome | Arma Iniziale | Passivo Unico | Sblocco |
|---|------|--------------|--------------|---------|
| 1 | **Leuco** (leucocita) | Nucleo Pulse | +20% HP max | Default |
| 2 | **Fagos** (fagocita) | Lash | +20% velocità | 500 oro |
| 3 | **Anticorpo** | Antibody | Inizia con 2 armi | 2000 oro |
| 4 | **Mitosi** | Cell Split | +1 proiettile sempre | 5000 oro / IAP |

---

## 4. RETENTION E MONETIZZAZIONE

### 4.1 Daily Retention Loop
```
GIORNO 1:  Tutorial + onboarding → regalo 200 oro
GIORNO 2:  Sblocca primo meta-upgrade → video reward disponibile
GIORNO 7:  Login settimanale → 500 oro + skin esclusiva
GIORNO 30: "Core Player" badge → gemme gratis
```

**Daily Login Calendar (7 giorni loop):**
- Giorno 1: 50 oro
- Giorno 2: 1 gemma
- Giorno 3: 100 oro
- Giorno 4: 2 gemme
- Giorno 5: 150 oro
- Giorno 6: 3 gemme
- Giorno 7: 500 oro + skin

### 4.2 Ads

| Tipo | Trigger | Frequenza | Skip |
|------|---------|-----------|------|
| Interstitial | Game Over | 1 ogni 2 partite | Dopo 5s |
| Rewarded | "Revive" button / "+1 scelta upgrade" | Volontario | No skip |
| Banner | Main Menu (solo free) | Sempre | No |

**Remove Ads (€2.99):** rimuove interstitial e banner. Rewarded sempre disponibili.

### 4.3 IAP Catalogue

| ID | Nome | Prezzo | Contenuto |
|----|------|--------|---------|
| `remove_ads` | Niente Più Pub | €2.99 | Nessun interstitial/banner |
| `starter_pack` | Starter Pack | €1.99 | Personaggio Anticorpo + 1000 oro + 5 gemme |
| `gold_500` | 500 Oro | €0.99 | 500 oro |
| `gold_2500` | 2500 Oro | €3.99 | 2500 oro (+bonus 500) |
| `gold_7000` | 7000 Oro | €9.99 | 7000 oro (+bonus 2000) |
| `gems_10` | 10 Gemme | €0.99 | 10 gemme |
| `gems_50` | 50 Gemme | €3.99 | 50 gemme |
| `season_pass` | Season Pass | €4.99/mese | +50% oro, daily reward premium, skin esclusiva |

### 4.4 Mechanic of "One More Run"
- **Instant respawn**: pulsante "Riprova" immediatamente disponibile
- **Death screen** mostra i progressi fatti (level raggiunto, nemici uccisi, armi usate)
- **"Così vicino!"** — se muori dopo il minuto 15, mostra "+X% per sopravvivere" con meta-upgrade suggerito
- **Revive**: 1x gratis per run (video ad), poi gemme

---

## 5. AUDIO E GRAFICA

### 5.1 Visual Style
- **Stile:** Vector/cartoon 2D, colori vivaci su sfondo scuro
- **Palette principale:** Viola scuro (sfondo) + Verde acido (player) + Rosso (nemici)
- **Effetti:** Screen shake moderato, hit flash, particle burst per ogni kill
- **UI:** Minimalista, grande font, alta leggibilità su mobile

### 5.2 Audio Design
- **Musica:** Sintetica, ritmo energico, intensità aumenta con i nemici
- **SFX Kill:** "Splat" soddisfacente, variazioni pitch per varietà
- **SFX Level Up:** Suono positivo, ascendente
- **SFX Hit Subito:** Impatto + flash rosso + screen shake lieve
- **Boss Music:** Traccia dedicata, si attiva quando appare il boss

### 5.3 Juice (Feedback Esagerato = Dipendenza)
- **Kill:** particelle colorate, orb EXP vola verso player, numero danno pop
- **Level Up:** freeze 0.5s + effetto luce su tutto lo schermo + musica
- **Critico:** testo "CRIT!" giallo + danno x2 visibile + suono speciale
- **Combo kill:** tanti nemici insieme → effetto cascata

---

## 6. ARCHITETTURA TECNICA

### 6.1 Autoload/Singleton

| Nome | Responsabilità |
|------|---------------|
| `EventBus` | Signal globali per decoupling totale |
| `GameManager` | Stato run corrente, statistiche, timer |
| `SaveManager` | JSON save/load, oro, meta, personaggi |
| `AudioManager` | Pool audio, volume, SFX/BGM |

### 6.2 Sistema Object Pool
Tutti i proiettili, EXP orb, particelle e nemici vengono da pool pre-allocati a inizio scena. Nessun `instantiate()` durante il gameplay = 60 FPS stabili su Android mid-range.

### 6.3 Performance Target
- **FPS target:** 60 FPS stabile
- **Nemici a schermo:** fino a 200 contemporaneamente
- **Proiettili a schermo:** fino a 100
- **Dispositivo target min:** Android con 2GB RAM, GPU Adreno 505

---

## 7. FEATURE ROADMAP POST-LAUNCH

| Release | Feature |
|---------|---------|
| **1.1** | + 2 nuovi personaggi, + 3 armi |
| **1.2** | Co-op 2 giocatori online |
| **1.3** | Boss Rush mode (solo boss, run breve) |
| **1.4** | Stagioni: ogni mese tema diverso |
| **2.0** | Endgame: "Ascension" tier — infinite scaling |

---

*Documento redatto per uso interno. Versione 1.0 — Maggio 2026.*
