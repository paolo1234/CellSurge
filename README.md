# 🧬 Cell Surge

**Engine:** Godot 4.6.2 | **Genere:** Mobile Auto-Shooter / Survivor  
**Piattaforma:** iOS & Android (Portrait) | **Viewport:** 1080 × 1920  
**Durata run:** ~20 minuti

> **Un gioco survivor-shooter ambientato all'interno del corpo umano.**  
> Controlli una **cellula immunitaria** che deve sopravvivere a ondate crescenti di patogeni (batteri, virus, funghi).

## 🎮 Gameplay

- **Auto-shooter** — la cellula spara automaticamente ai nemici
- **Ondate infinite** — patogeni sempre più numerosi e resistenti
- **Potenziamenti** — migliora la cellula tra un'ondata e l'altra
- **20 minuti di sopravvivenza** — obiettivo: resistere fino alla fine

## 📁 Struttura

| Percorso | Contenuto |
|---|---|
| `scenes/ui/` | Menu principale, HUD, schermate di gioco |
| `scenes/gameplay/` | Scene di gioco (mondo, nemici, player) |
| `scripts/player/` | Logica del giocatore (movimento, attacco, health) |
| `scripts/enemies/` | Comportamento nemici (AI, ondate, tipi) |
| `scripts/systems/` | Sistemi: wave manager, upgrade, spawn |
| `scripts/ui/` | Elementi UI (barra vita, punteggio, menu) |
| `assets/` | Grafica e sprite |
| `audio/` | Effetti sonori e musica |
| `autoloads/` | Script globali (GameManager, AudioManager) |
| `addons/` | Plugin Godot aggiuntivi |

## 📚 Documentazione inclusa

- **GDD.md** — Game Design Document completo (concept, meccaniche, progressione)
- **DESIGN_UI.md** — Specifiche di design dell'interfaccia utente
- **TASKS.md** — Lista task di sviluppo
- **OPENCODE.md** — Configurazione per sviluppo AI-assisted
- **implementation_plan.md** — Piano di implementazione dettagliato

## 🚀 Build

1. Apri in Godot Engine 4.6.2
2. Scena principale: `res://scenes/ui/MainMenu.tscn`
3. Esporta per Android/iOS dal menu **Progetto > Esporta**

## 🤖 AI-Assisted

Sviluppato con approccio **VibeCoding** (AI-assisted). I file di configurazione per agenti AI (`.opencode`, ecc.) sono inclusi per facilitare lo sviluppo collaborativo con AI.

## 📋 Stato

🔨 **In sviluppo attivo** — nuove meccaniche in arrivo.
