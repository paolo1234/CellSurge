# 🧬 CELL SURGE — Game Design Document (GDD)

**Genere:** Mobile Auto-Shooter / Survivor  
**Engine:** Godot 4.6.2  
**Piattaforma:** iOS & Android (Portrait)  
**Viewport:** 1080 × 1920  
**Durata Run:** 20 minuti  

---

## 1. Concept & Vision

Cell Surge è un gioco mobile survivor-shooter ambientato all'interno del corpo umano.  
Il giocatore controlla una **cellula immunitaria** che deve sopravvivere a ondate crescenti di patogeni (batteri, virus, funghi) per 20 minuti.

**Core Fantasy:** Essere una cellula del sistema immunitario che difende il corpo da un'infezione.

**Riferimenti:** Vampire Survivors, Brotato, Archero — adattato al formato mobile portrait con joystick virtuale.

---

## 2. Core Loop

```
[ Muoviti & Schiva ] → [ Auto-Attacca ] → [ Raccogli XP ] → [ Level Up → Scegli Mutazione ] → [ Ripeti ]
                                                                        ↓
                                                              [ Muori / Sopravvivi 20 min ]
                                                                        ↓
                                                              [ Guadagna Gold → Meta-Upgrade ]
```

### 2.1 Gameplay Loop (In-Run)
1. La cellula **si muove** con il joystick virtuale
2. Le armi **attaccano automaticamente** (auto-fire)
3. I nemici uccisi lasciano **orbs di esperienza** (aminoacidi)
4. Accumulando XP → **Level Up** → scelta tra 3 mutazioni random
5. Le mutazioni potenziano armi, stats o aggiungono nuove abilità
6. Ogni minuto la difficoltà aumenta (più nemici, più veloci, più HP)
7. **Boss** a minuto 10 e 20
8. Sopravvivere 20 minuti = **Vittoria**

### 2.2 Meta Loop (Tra le Run)
1. Alla fine di ogni run → guadagni **Gold**
2. Gold speso in **Meta-Upgrade** permanenti (HP, Velocità, Danno, ecc.)
3. Sblocco di nuovi **personaggi** (cellule diverse con abilità uniche)
4. Progressione graduale: ogni run rende il giocatore leggermente più forte

---

## 3. Personaggi (Cellule)

| ID | Nome | HP Base | Velocità | Abilità Passiva | Stato |
|---|---|---|---|---|---|
| `leuco` | Leucocita | 100 | 200 | Nessuna (base) | ✅ Implementato |
| `macro` | Macrofago | 150 | 160 | +20% pickup radius | 🔲 TODO |
| `linfo_t` | Linfocita T | 80 | 220 | +15% crit chance | 🔲 TODO |
| `plasma` | Plasmacellula | 70 | 180 | +1 proiettile base | 🔲 TODO |
| `nk` | Natural Killer | 90 | 200 | +25% danno ai boss | 🔲 TODO |

---

## 4. Nemici (Patogeni)

### 4.1 Nemici Base

| ID | Nome | HP | Velocità | Danno | XP | Comportamento |
|---|---|---|---|---|---|---|
| `batterio` | Batterio | 30 | 80 | 10 | 5 | Insegue diretto |
| `virus` | Virus | 20 | 120 | 8 | 4 | Veloce, zigzag |
| `fungo` | Fungo | 60 | 50 | 15 | 8 | Lento, tankoso |

### 4.2 Boss

| ID | Nome | HP | Minuto | Meccanica |
|---|---|---|---|---|
| `super_cellula` | Super Cellula | 2000 | 10:00 | Spawna mini-nemici, area denial |
| `prione` | Prione | 5000 | 20:00 | Boss finale, pattern multipli |

---

## 5. Armi & Mutazioni

### 5.1 Armi (Auto-fire)

| ID | Nome | Tipo | Base Dmg | Fire Rate | Descrizione |
|---|---|---|---|---|---|
| `nucleus_pulse` | Nucleus Pulse | Radiale | 15 | 0.8/s | Spara proiettili in cerchio |
| `enzyme_stream` | Enzyme Stream | Direzionale | 12 | 1.2/s | Spara verso il nemico più vicino |
| `antibody_orbit` | Antibody Orbit | Orbitale | 8 | Passivo | Sfere che orbitano il player |
| `cytokine_wave` | Cytokine Wave | Area | 20 | 0.5/s | Onda d'urto circolare |
| `membrane_shield` | Membrane Shield | Difensiva | 5 | 0.3/s | Scudo che blocca proiettili e danneggia |
| `phagocyte_burst` | Phagocyte Burst | Esplosiva | 25 | 0.4/s | Esplosione a contatto |

### 5.2 Upgrade per Arma (5 livelli)

Ogni arma ha 5 livelli di potenziamento:
- **Lv 2-3:** Aumenta danno, velocità di fuoco
- **Lv 4:** Aggiunge proiettili o area
- **Lv 5:** Effetto speciale unico

### 5.3 Mutazioni Passive

| ID | Nome | Rarità | Effetto |
|---|---|---|---|
| `thick_membrane` | Thick Membrane | Common | +15 HP max |
| `atp_boost` | ATP Boost | Common | +8% velocità |
| `mitosis` | Mitosis | Rare | +1 proiettile a tutte le armi |
| `rapid_division` | Rapid Division | Rare | +15% attack speed |
| `evolution` | Evolution | Epic | +30% area effetto |
| `crispr` | CRISPR | Epic | +10% crit chance |

---

## 6. Progressione delle Wave (20 minuti)

| Minuto | Nemici | Spawn/Wave | Intervallo | Evento |
|---|---|---|---|---|
| 0-1 | Batterio | 2 | 2.0s | Inizio |
| 2-3 | Batterio, Virus | 3 | 1.8s | — |
| 4-7 | Batterio, Virus, Fungo | 4 | 1.5s | — |
| 8-9 | Tutti | 6 | 1.2s | Intensificazione |
| 10 | Tutti | 5 | 1.0s | 🔴 BOSS: Super Cellula |
| 11-13 | Tutti | 5 | 1.0s | Post-boss |
| 14-16 | Tutti | 7 | 0.9s | Late game |
| 17-19 | Tutti | 8 | 0.8s | Endgame rush |
| 20 | Tutti | 8 | 0.8s | 🔴 BOSS FINALE: Prione |

---

## 7. Meta-Progressione (Persistente)

### 7.1 Valuta
- **Gold:** Guadagnato ogni run (base 100 + tempo + livello + bonus vittoria)
- **Gems:** Valuta premium (acquistabile con IAP)

### 7.2 Meta-Upgrade (Gold)

| ID | Nome | Effetto per Livello | Max Lv | Costo Base |
|---|---|---|---|---|
| `hp_up` | Vitality | +10 HP | 20 | 100 |
| `speed_up` | Agility | +5 velocità | 15 | 80 |
| `damage_up` | Power | +5% danno | 20 | 120 |
| `exp_up` | Wisdom | +5% XP gain | 15 | 100 |
| `armor_up` | Fortitude | +2 armor | 10 | 150 |
| `regen_up` | Regeneration | +0.5 HP/s | 10 | 200 |
| `magnet_up` | Magnetism | +10 pickup radius | 10 | 80 |
| `luck_up` | Fortune | +5% luck | 10 | 150 |

---

## 8. Monetizzazione

### 8.1 In-App Purchases
- **Remove Ads:** €2.99 (una tantum)
- **Gem Packs:** €0.99 / €4.99 / €9.99
- **Starter Pack:** €1.99 (Gold + Gems + Personaggio bonus)

### 8.2 Rewarded Ads
- **Doppio Gold:** Guarda un ad per raddoppiare il gold della run
- **Resurrezione:** Guarda un ad per continuare la run dopo la morte (1x per run)
- **Cassa Gratuita:** Ogni 4 ore, guarda un ad per aprire una cassa bonus

### 8.3 Daily Login
- Bonus crescenti per login consecutivi (7 giorni → reset)
- Giorno 7: Personaggio o Gems bonus

---

## 9. UI/UX Specifications

→ Vedere **DESIGN_UI.md** per le specifiche dettagliate dell'HUD in-game.

### 9.1 Palette Bioluminescenza
- **Sfondo:** Nero profondo #000000 / #010103
- **Ciano Fluorescente:** #00FFFF (XP bar, accenti, bordi UI)
- **Verde Acido:** #39FF14 (HP alta, guarigione)
- **Rosso Scarlatto:** #FF2400 (HP bassa, danno)
- **Bianco Ghiaccio:** #F0F8FF (testo base)
- **Giallo/Arancio:** #FFAC1C (damage numbers, gold)

### 9.2 Screen Flow
```
MainMenu → World (Gameplay) → GameOver → MainMenu
              ↓                    ↑
          LevelUp (Pausa)    (Restart)
```

---

## 10. Audio

| Categoria | Descrizione |
|---|---|
| **BGM Gameplay** | Ambient elettronico, toni bassi biologici, build-up crescente |
| **BGM Menu** | Ambient calmo, toni misteriosi |
| **SFX Sparo** | Suono morbido, "whoosh" organico |
| **SFX Hit** | Impact breve, "squelch" |
| **SFX Level Up** | Chime ascendente luminoso |
| **SFX Pickup** | Tono breve positivo |
| **SFX Death** | Suono cupo, dissoluzione |

---

## 11. Requisiti Tecnici

- **Target FPS:** 60fps su dispositivi mid-range
- **Object Pooling:** Per proiettili, nemici, effetti
- **Rendering:** Mobile (Forward Mobile)
- **Texture Filter:** Nearest (pixel art style)
- **Min SDK:** iOS 14 / Android 8.0
