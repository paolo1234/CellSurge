# 🧬 Design Spec: Cell Surge - Main HUD

## 📱 Wireframe (Modalità Portrait)
```text
+-----------------------------------------+
| [██████████████████████████░░░░░░]      |  <-- XP Bar (Top Edge)
|  LV 19          05:15          ☠ 453    |  <-- Header Info
|                                         |
|                                         |
|                                         |
|                                         |
|                                         |
|                                         |
|                 ╭───╮                   |
|                 │ ✧ │                   |  <-- Player Cell (Centro)
|                 ╰───╯                   |  <-- HP Ring (Attorno al Player)
|                                         |
|                                         |
|                                         |
|                                         |
|                                         |
|                                         |
|  [🔬] [🧬] [🦠]                         |  <-- Inventario (Mutazioni attive)
|  [🧪] [  ] [  ]            ( ⭕ )       |  <-- Joystick Dinamico
+-----------------------------------------+
🎨 Palette Colori (Bioluminescenza)
Sfondo UI Globale: Nessuno o gradiente leggerissimo (Nero #000000 con Opacità 40% in alto a sfumare fino allo 0% al centro).

XP Bar (Aminoacidi): Ciano Fluorescente #00FFFF con leggero bagliore.

Salute (HP Ring):

High HP: Verde Acido #39FF14

Low HP (<25%): Rosso Scarlatto #FF2400 (Pulsante)

Testo Base: Bianco Ghiaccio #F0F8FF

Testo Danni (Nemici): Giallo/Arancio #FFAC1C

🧩 Specifiche degli Elementi
1. Header (Parte Superiore)
XP Bar: Deve essere ancorata al bordo superiore dello schermo (Top Wide). Altezza: 6-8 pixel. Non squadrata: usa bordi arrotondati (Pill shape).

Contenitore Testi: Sotto la XP Bar. Margini laterali di almeno 16px per evitare i bordi curvi del telefono.

Livello (Sinistra): Font Bold. Testo "LV" piccolo, numero "19" più grande. Colore: Ciano o Giallo.

Timer (Centro): L'elemento di testo più grande dell'header. Font Monospace o Sans-Serif bold (es. Roboto o Montserrat).

Kills (Destra): Usa un'icona SVG di un virus o teschio invece della parola "Kills" per risparmiare spazio.

2. Area Giocatore (Centro)
HP Ring (Anello Salute): Un indicatore di progresso circolare (TextureProgressBar in modalità Radial/Clockwise).

Comportamento: Segue costantemente le coordinate X e Y del Player. Raggio leggermente più grande della sprite del giocatore, così non copre le animazioni della cellula. Spessore dell'anello: 3-4 pixel.

3. Footer (Parte Inferiore)
Inventario Mutazioni (In basso a sinistra): Griglia 3x2 o 6x1 di piccoli quadrati. Devono essere semitrasparenti (Alpha 0.3) quando vuoti. Quando un'arma viene acquisita, mostra l'icona a colori pieni con un leggero bordo luminoso. Dimensione: piccola e non invasiva (es. 32x32 px).

Joystick Virtuale (In basso a destra / Ovunque al tocco):

Base: Cerchio grigio semitrasparente (Opacità 20%).

Knob (Levetta): Cerchio più piccolo, bianco semitrasparente (Opacità 50%).

Comportamento: Scompare quando non si tocca lo schermo (Floating Joystick).

💥 Effetti e Feedback (Juiciness)
Level Up Flash: Quando la XP bar si riempie, l'intera barra diventa bianca per 0.1 secondi prima di aprire il menu.

Damage Pop-ups: Numeri che appaiono proprio sopra il nemico colpito. Durata: 0.4 secondi. Devono muoversi verso l'alto ed espandersi leggermente, per poi svanire (Fade out).

Low HP Warning: Se la salute scende sotto il 20%, i bordi dello schermo (Vignette) lampeggiano lentamente di rosso.