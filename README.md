# LineageOS 23.2 (Android 16) per Mediacom SmartPad iyo 10 (M-SP1DY)

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
| `boot_magisk.img`, `boot_originale.img` | cartella `strumenti\` (solo per il root, opzioni 3-4) |

Da scaricare a parte, nella cartella `strumenti\`:

- `adb.exe`, `fastboot.exe` e i file `.dll` da
  [SDK Platform-Tools for Windows](https://developer.android.com/tools/releases/platform-tools)
- `Magisk-v30.7.apk` da [github.com/topjohnwu/Magisk](https://github.com/topjohnwu/Magisk/releases)
  (solo per il root)

Poi doppio clic su `Mediacom_LineageOS23.bat`.

SHA-256 del file `.img.gz`:
`4F925A25BE147109FDA486AB58BBA443710328A898B3D636A9B57D9AE4F60C7A`

## Ringraziamenti

LineageOS, TrebleDroid / phhusson, chi ha compilato e condiviso la GSI
LineageOS 23.2 a64 su XDA, topjohnwu (Magisk), Google (adb e fastboot).
