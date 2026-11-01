# LineageOS 23.2 (Android 16) per Mediacom SmartPad iyo 10 (M-SP1DY)

> **Build NON ufficiale**: non e' prodotta ne' supportata dal progetto LineageOS.

ROM e script di installazione che sostituiscono l'Android 11 Go originale del
**Mediacom SmartPad iyo 10, modello M-SP1DY** (Allwinner A133, PowerVR GE8300,
2 GB RAM) con LineageOS 23.2 gia' sistemata per questo tablet (schermo,
rotazione, Bluetooth, prestazioni). Le istruzioni complete sono in
[LEGGIMI.txt](LEGGIMI.txt).

> Solo per M-SP1DY (build "1DY"). L'installazione cancella tutti i dati.
> Tutto a proprio rischio.

## Cosa scaricare

Dalla pagina **Releases** di questo repository:

| File | Dove metterlo |
|---|---|
| `lineage-23.2-20260620-a64-bvN_mediacom.img.gz` | cartella `rom\` |

Da scaricare a parte, nella cartella `strumenti\`:

- `adb.exe`, `fastboot.exe` e i file `.dll` da
  [SDK Platform-Tools for Windows](https://developer.android.com/tools/releases/platform-tools)
- `Magisk-v30.7.apk` da [github.com/topjohnwu/Magisk](https://github.com/topjohnwu/Magisk/releases)
  (solo per il root)

**Root (opzioni 3-4):** le immagini `boot_originale.img` e `boot_magisk.img`
NON sono incluse, perche' contengono il kernel del produttore. Si ricavano dal
firmware originale Mediacom 1DY (partizione `boot`, estraibile con
imgRePacker) e si patchano con l'app Magisk. Lo script controlla l'SHA-256
delle immagini di riferimento: con immagini di un firmware diverso si ferma
senza scrivere nulla. Per installare Android 16 il root non serve.

Poi doppio clic su `Mediacom_LineageOS23.bat`.

SHA-256 del file `.img.gz`:
`4F925A25BE147109FDA486AB58BBA443710328A898B3D636A9B57D9AE4F60C7A`

## Sorgenti

- GSI di partenza: lineage-23.2-20260620-a64-bvN, build di LineageOS 23.2
  per architettura a64 condivisa su XDA
- [LineageOS](https://github.com/LineageOS), [TrebleDroid](https://github.com/TrebleDroid)
- Le modifiche fatte per questo tablet sono descritte in LEGGIMI.txt
  (sezione DETTAGLI TECNICI). La ROM contiene solo la partizione `system`:
  kernel e driver restano quelli del tablet.

## Ringraziamenti

LineageOS, TrebleDroid / phhusson, chi ha compilato e condiviso la GSI
LineageOS 23.2 a64 su XDA, topjohnwu (Magisk), Google (adb e fastboot).
