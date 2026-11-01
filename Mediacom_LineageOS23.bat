@echo off
setlocal
cd /d "%~dp0"
title Mediacom SmartPad iyo 10 - LineageOS 23.2 (Android 16)

rem ==================================================================
rem  Mediacom SmartPad iyo 10 (M-SP1DY) - installazione di
rem  LineageOS 23.2 Mediacom (Android 16), gia' sistemata e ottimizzata.
rem  Leggi LEGGIMI.txt prima di usare questo file.
rem ==================================================================

set "TOOLS=%~dp0strumenti"
set "ROMDIR=%~dp0rom"
set "LOGDIR=%~dp0log"
set "ROMNAME=lineage-23.2-20260620-a64-bvN_mediacom"
set "ROMSIZE=1880514560"
set "ROMSHA=BC3201DECDAF12B6CAA6DA28ADC9322CCE953D3D40BB9A139C94D2BE25AA623F"
set "VBM=%TOOLS%\vbmeta_disabled.img"
set "FPRINT=mediacom/1DY/1DY"
set "BOOTORIG=%TOOLS%\boot_originale.img"
set "BOOTORIGSHA=E99650E0943BFEBCB5D907E25115A2165F9AE33224AC1B6F46E1A09495718C21"
set "BOOTMAGISK=%TOOLS%\boot_magisk.img"
set "BOOTMAGISKSHA=7D16EFB5D40696943274A87ED10357B0B8FBCA2DFAE1DA792DF709A90A71723B"
set "MAGISKAPK=%TOOLS%\Magisk-v30.7.apk"
set "KERNELID=#26 SMP PREEMPT Thu Jul 15 18:23:55 CST 2021"
set "PATH=%TOOLS%;%PATH%"
if not exist "%LOGDIR%" mkdir "%LOGDIR%"

where adb >nul 2>&1
if errorlevel 1 goto manca_adb
where fastboot >nul 2>&1
if errorlevel 1 goto manca_adb
goto menu

:manca_adb
echo [ERRORE] Non trovo adb.exe e fastboot.exe.
echo Scarica "SDK Platform-Tools for Windows" da
echo   https://developer.android.com/tools/releases/platform-tools
echo e copia adb.exe, fastboot.exe e le .dll nella cartella "strumenti".
pause
exit /b 1

rem ==================================================================
:menu
cls
echo ==================================================================
echo   Mediacom SmartPad iyo 10 (M-SP1DY)
echo   LineageOS 23.2 Mediacom - Android 16
echo ==================================================================
echo.
echo   1  Controlla il collegamento del tablet
echo   2  INSTALLA LineageOS 23.2               (CANCELLA TUTTI I DATI)
echo   3  ROOT con Magisk                (facoltativo, A TUO RISCHIO)
echo   4  Togli il root, rimette il boot originale
echo   0  Esci
echo.
echo   Prima di iniziare leggi LEGGIMI.txt
echo.
choice /c 12340 /n /m "Scegli un numero: "
if errorlevel 5 exit /b 0
if errorlevel 4 goto togli_root
if errorlevel 3 goto root
if errorlevel 2 goto installa
goto controlla

:fine_menu
echo.
pause
goto menu

rem ==================================================================
rem  1 - CONTROLLO COLLEGAMENTO
rem ==================================================================
:controlla
cls
set "LOG=%LOGDIR%\1_controllo_log.txt"
echo [%date% %time%] Controllo collegamento > "%LOG%"
echo === Dispositivi visti da adb ===
adb devices -l > "%TEMP%\mc_adb.txt" 2>&1
type "%TEMP%\mc_adb.txt"
type "%TEMP%\mc_adb.txt" >> "%LOG%"
echo === Dispositivi visti da fastboot ===
fastboot devices > "%TEMP%\mc_fbd.txt" 2>&1
type "%TEMP%\mc_fbd.txt"
type "%TEMP%\mc_fbd.txt" >> "%LOG%"
echo.
findstr /c:"unauthorized" "%TEMP%\mc_adb.txt" >nul
if not errorlevel 1 (
  echo Il tablet e' collegato ma NON autorizzato: sul tablet accetta
  echo "Consentire debug USB?" e spunta "Consenti sempre da questo computer".
  goto fine_menu
)
adb get-state >nul 2>&1
if errorlevel 1 goto ctrl_fastboot
echo Il tablet e' collegato con adb. Sistema installato:
<nul adb shell getprop ro.vendor.build.fingerprint > "%TEMP%\mc_fp.txt" 2>&1
<nul adb shell getprop ro.build.display.id >> "%TEMP%\mc_fp.txt" 2>&1
<nul adb shell getprop ro.build.version.release > "%TEMP%\mc_rel.txt" 2>&1
type "%TEMP%\mc_fp.txt"
type "%TEMP%\mc_fp.txt" >> "%LOG%"
type "%TEMP%\mc_rel.txt" >> "%LOG%"
echo.
findstr /c:"%FPRINT%" "%TEMP%\mc_fp.txt" >nul
if errorlevel 1 (
  echo ATTENZIONE: questo NON sembra un Mediacom SmartPad iyo 10 M-SP1DY.
  echo Non usare questo pacchetto su altri modelli.
  goto fine_menu
)
echo OK: e' un Mediacom SmartPad iyo 10 M-SP1DY.
findstr /x /c:"16" "%TEMP%\mc_rel.txt" >nul && ( echo LineageOS 23.2 - Android 16 gia' installata. Facoltativo: opzione 3 per il root. & goto fine_menu )
echo Prossimo passo: opzione 2.
goto fine_menu

:ctrl_fastboot
findstr /c:"fastboot" "%TEMP%\mc_fbd.txt" >nul
if errorlevel 1 (
  echo Il tablet NON e' visto dal PC. Controlla:
  echo  - che sia acceso e collegato con un cavo USB DATI
  echo  - che il Debug USB sia attivo, vedi LEGGIMI.txt
  echo  - i driver USB, vedi LEGGIMI.txt
  goto fine_menu
)
echo Il tablet e' in modalita' fastboot:
fastboot getvar product > "%TEMP%\mc_fb.txt" 2>&1
fastboot getvar is-userspace >> "%TEMP%\mc_fb.txt" 2>&1
fastboot getvar unlocked >> "%TEMP%\mc_fb.txt" 2>&1
fastboot getvar current-slot >> "%TEMP%\mc_fb.txt" 2>&1
findstr /b /c:"product:" /c:"is-userspace:" /c:"unlocked:" /c:"current-slot:" "%TEMP%\mc_fb.txt"
type "%TEMP%\mc_fb.txt" >> "%LOG%"
goto fine_menu

rem ==================================================================
rem  2 - INSTALLAZIONE
rem ==================================================================
:installa
cls
set "LOG=%LOGDIR%\2_installa_log.txt"
echo [%date% %time%] Installazione LineageOS 23.2 Mediacom > "%LOG%"
set "ROMGZ=%ROMDIR%\%ROMNAME%.img.gz"
set "ROMIMG=%ROMDIR%\%ROMNAME%.img"
echo ==================================================================
echo  INSTALLAZIONE LineageOS 23.2 Mediacom - Android 16
echo  ATTENZIONE: cancella TUTTO il contenuto del tablet:
echo  foto, video, app, account. Salva prima quello che ti serve.
echo ==================================================================
echo.
echo === 1/6 Preparo la ROM sul PC ===
if exist "%ROMIMG%" goto rom_verifica
if not exist "%ROMGZ%" (
  echo [STOP] Nella cartella "rom" manca il file %ROMNAME%.img.gz
  echo Vedi LEGGIMI.txt.
  echo STOP: manca la rom >> "%LOG%"
  goto fine_menu
)
echo Decompressione, qualche minuto. Servono circa 2 GB liberi...
powershell -NoProfile -Command "$i=[IO.File]::OpenRead($env:ROMGZ); $o=[IO.File]::Create($env:ROMIMG); $g=New-Object IO.Compression.GZipStream($i,[IO.Compression.CompressionMode]::Decompress); $g.CopyTo($o); $g.Close(); $o.Close(); $i.Close()" <nul >> "%LOG%" 2>&1
:rom_verifica
echo Verifico la ROM, circa un minuto...
powershell -NoProfile -Command "$f=Get-Item -LiteralPath $env:ROMIMG; $h=(Get-FileHash -LiteralPath $env:ROMIMG -Algorithm SHA256).Hash; Write-Output ('ROM: '+$f.Length+' byte, SHA256 '+$h); if ($f.Length -eq [int64]$env:ROMSIZE -and $h -eq $env:ROMSHA) { exit 0 } else { exit 1 }" <nul >> "%LOG%" 2>&1
if errorlevel 1 (
  echo [STOP] Il file della ROM e' danneggiato o incompleto: lo cancello.
  echo Controlla lo spazio libero e riprova l'opzione 2.
  del "%ROMIMG%" >nul 2>&1
  echo STOP: rom non valida >> "%LOG%"
  goto fine_menu
)
echo ROM OK.

echo.
echo === 2/6 Porto il tablet in modalita' fastboot ===
fastboot devices 2>nul | find "fastboot" >nul
if not errorlevel 1 goto inst_fastboot
adb get-state >nul 2>&1
if errorlevel 1 (
  echo [STOP] Il tablet non e' collegato o il Debug USB non e' autorizzato.
  echo Usa prima l'opzione 1.
  echo STOP: adb non vede il tablet >> "%LOG%"
  goto fine_menu
)
<nul adb shell getprop ro.vendor.build.fingerprint > "%TEMP%\mc_fp.txt" 2>&1
type "%TEMP%\mc_fp.txt" >> "%LOG%"
findstr /c:"%FPRINT%" "%TEMP%\mc_fp.txt" >nul
if errorlevel 1 (
  echo [STOP] Questo non e' un Mediacom SmartPad iyo 10 M-SP1DY. Mi fermo.
  echo STOP: modello diverso >> "%LOG%"
  goto fine_menu
)
adb reboot fastboot
echo Attendo il tablet in modalita' fastboot, fino a 2 minuti...
call :attendi_fastboot
if errorlevel 1 (
  echo [STOP] Il tablet non risulta in fastboot. Se lo schermo mostra
  echo "fastbootd" il problema sono i driver: vedi LEGGIMI.txt
  echo STOP: fastboot non visto >> "%LOG%"
  goto fine_menu
)

:inst_fastboot
echo.
echo === 3/6 Controlli di sicurezza ===
fastboot getvar product > "%TEMP%\mc_fb.txt" 2>&1
fastboot getvar is-userspace >> "%TEMP%\mc_fb.txt" 2>&1
fastboot getvar unlocked >> "%TEMP%\mc_fb.txt" 2>&1
fastboot getvar current-slot >> "%TEMP%\mc_fb.txt" 2>&1
fastboot getvar partition-size:product_a >> "%TEMP%\mc_fb.txt" 2>&1
type "%TEMP%\mc_fb.txt" >> "%LOG%"
findstr /b /c:"product:" /c:"is-userspace:" /c:"unlocked:" /c:"current-slot:" "%TEMP%\mc_fb.txt"
findstr /c:"product: 1DY" "%TEMP%\mc_fb.txt" >nul || ( echo [STOP] Il modello non e' 1DY. Mi fermo. & echo STOP: product >> "%LOG%" & goto fine_menu )
findstr /c:"is-userspace: yes" "%TEMP%\mc_fb.txt" >nul || ( echo [STOP] Il tablet e' nel fastboot sbagliato: serve fastbootd. Riavvia il tablet normalmente e riprova. & echo STOP: non fastbootd >> "%LOG%" & goto fine_menu )
findstr /c:"unlocked: yes" "%TEMP%\mc_fb.txt" >nul || ( echo [STOP] Il bootloader e' BLOCCATO: va sbloccato prima, vedi LEGGIMI.txt & echo STOP: bootloader bloccato >> "%LOG%" & goto fine_menu )
findstr /c:"current-slot: a" "%TEMP%\mc_fb.txt" >nul || ( echo [STOP] Lo slot attivo non e' "a": situazione non prevista, mi fermo. & echo STOP: slot non a >> "%LOG%" & goto fine_menu )
set "DELPROD=0"
findstr /c:"partition-size:product_a: 0x" "%TEMP%\mc_fb.txt" >nul && set "DELPROD=1"
echo Controlli OK.

echo.
echo ==================================================================
echo  Sto per scrivere sul tablet, SOLO nello slot "a":
echo   1. eliminare la partizione product_a, per fare spazio
echo   2. scrivere LineageOS 23.2 nella partizione system_a, circa 3 minuti
echo   3. disattivare le verifiche in vbmeta_a e vbmeta_system_a
echo  Poi il tablet va nel recovery per cancellare i dati.
echo  Il sistema attuale verra' sostituito.
echo ==================================================================
set "OK="
set /p OK=Scrivi SI e premi Invio per procedere:
if /i not "%OK%"=="SI" ( echo Annullato, non ho scritto nulla. & echo Annullato >> "%LOG%" & goto fine_menu )

echo.
echo === 4/6 Elimino product_a ===
if "%DELPROD%"=="0" ( echo product_a e' gia' stata eliminata. & goto inst_flash )
fastboot delete-logical-partition product_a >> "%LOG%" 2>&1
if errorlevel 1 ( echo [ERRORE] Non riesco a eliminare product_a. Il tablet non e' stato modificato. & echo ERRORE delete product_a >> "%LOG%" & goto fine_menu )
:inst_flash
echo === 5/6 Scrivo LineageOS 23.2, circa 3 minuti: NON scollegare ===
echo  Il messaggio "Invalid sparse file format" e' normale.
fastboot flash system_a "%ROMIMG%" >> "%LOG%" 2>&1
if errorlevel 1 ( echo [ERRORE] Scrittura fallita. NON spegnere il tablet e ripeti l'opzione 2. & echo ERRORE flash system_a >> "%LOG%" & goto fine_menu )
fastboot --disable-verity --disable-verification flash vbmeta_a "%VBM%" >> "%LOG%" 2>&1
if errorlevel 1 ( echo [ERRORE] Scrittura di vbmeta_a fallita. NON spegnere il tablet e ripeti l'opzione 2. & echo ERRORE vbmeta_a >> "%LOG%" & goto fine_menu )
fastboot --disable-verity --disable-verification flash vbmeta_system_a "%VBM%" >> "%LOG%" 2>&1
if errorlevel 1 ( echo [ERRORE] Scrittura di vbmeta_system_a fallita. NON spegnere il tablet e ripeti l'opzione 2. & echo ERRORE vbmeta_system_a >> "%LOG%" & goto fine_menu )
echo Scrittura completata.

echo.
echo === 6/6 Cancellazione dati dal recovery ===
echo  Il fastboot di questo tablet non sa cancellare i dati:
echo  si fa dal recovery originale. Riavvio nel recovery...
fastboot reboot recovery >> "%LOG%" 2>&1
echo [%date% %time%] Scrittura completata, riavvio nel recovery >> "%LOG%"
echo.
echo ==================================================================
echo  ORA SUL TABLET, nel menu del recovery:
echo    tasti VOLUME = spostarsi      tasto POWER = confermare
echo    se vedi solo "Nessun comando": tieni premuto POWER e
echo    premi una volta VOLUME SU, poi lascia i tasti.
echo.
echo   1. scegli  "Wipe data/factory reset"
echo   2. conferma con  "Yes" oppure "Factory data reset"
echo   3. alla fine scegli  "Reboot system now"
echo.
echo  Il primo avvio dura 5-10 minuti: e' normale. Completa la
echo  configurazione iniziale (lingua, Wi-Fi...). Non serve altro:
echo  rotazione, Impostazioni, ottimizzazioni e sfondo HD li sistema
echo  la ROM da sola. Nella prima mezz'ora il tablet compila le app
echo  e puo' essere un po' lento: poi diventa piu' veloce.
echo.
echo  Facoltativo: opzione 3 per il root con Magisk.
echo ==================================================================
goto fine_menu

rem ==================================================================
rem  3 - ROOT CON MAGISK (facoltativo, a rischio dell'utente)
rem ==================================================================
:root
cls
set "LOG=%LOGDIR%\3_root_log.txt"
echo [%date% %time%] Root con Magisk > "%LOG%"
echo ==================================================================
echo  ROOT CON MAGISK - FACOLTATIVO, A TUO RISCHIO
echo.
echo  Scrive nella partizione boot del tablet un'immagine modificata
echo  con Magisk 30.7. E' fatta SOLO per il Mediacom SmartPad iyo 10
echo  M-SP1DY con il firmware originale 1DY: su altri tablet o altri
echo  firmware il tablet potrebbe non avviarsi piu'. Lo script controlla
echo  modello e kernel e si ferma se non corrispondono.
echo  Serve LineageOS 23.2 avviata con il Debug USB attivo.
echo  Per tornare indietro: opzione 4 del menu.
echo ==================================================================
set "CHK=%BOOTMAGISK%"
set "CHKSHA=%BOOTMAGISKSHA%"
call :verifica_file
if errorlevel 1 goto fine_menu
call :verifica_lineage
if errorlevel 1 goto fine_menu
call :verifica_kernel
if errorlevel 1 goto fine_menu
echo.
set "OK="
set /p OK=Scrivi SI per installare il root a tuo rischio:
if /i not "%OK%"=="SI" ( echo Annullato, non ho scritto nulla. & echo Annullato >> "%LOG%" & goto fine_menu )
call :vai_fastboot
if errorlevel 1 goto fine_menu
echo Scrivo il boot con Magisk...
fastboot flash boot_a "%BOOTMAGISK%" >> "%LOG%" 2>&1
if errorlevel 1 ( echo [ERRORE] Scrittura del boot fallita. NON spegnere il tablet: usa l'opzione 4 per rimettere il boot originale. & echo ERRORE flash boot >> "%LOG%" & goto fine_menu )
fastboot reboot >> "%LOG%" 2>&1
echo Riavvio, 1-2 minuti...
call :attendi_avvio
if exist "%MAGISKAPK%" ( echo Installo l'app Magisk... & adb install -r "%MAGISKAPK%" >> "%LOG%" 2>&1 )
<nul adb shell magisk -v > "%TEMP%\mc_mgk.txt" 2>&1
type "%TEMP%\mc_mgk.txt" >> "%LOG%"
findstr /c:"MAGISK" "%TEMP%\mc_mgk.txt" >nul && ( echo Root attivo: Magisk funziona. ) || ( echo ATTENZIONE: non riesco a confermare Magisk, controlla il log. )
echo [%date% %time%] Fine >> "%LOG%"
echo.
echo  Apri l'app Magisk sul tablet: se chiede una configurazione
echo  aggiuntiva accetta, il tablet si riavvia una volta.
echo  Le app che chiedono il root mostreranno una richiesta di Magisk.
goto fine_menu

rem ==================================================================
rem  4 - TOGLI IL ROOT (rimette il boot originale)
rem ==================================================================
:togli_root
cls
set "LOG=%LOGDIR%\4_togli_root_log.txt"
echo [%date% %time%] Tolgo il root > "%LOG%"
set "CHK=%BOOTORIG%"
set "CHKSHA=%BOOTORIGSHA%"
call :verifica_file
if errorlevel 1 goto fine_menu
fastboot devices 2>nul | find "fastboot" >nul
if not errorlevel 1 goto tr_conferma
call :verifica_lineage
if errorlevel 1 goto fine_menu
:tr_conferma
echo ==================================================================
echo  Rimetto il boot ORIGINALE del firmware Mediacom 1DY: il root
echo  di Magisk sparisce, LineageOS e i tuoi dati restano.
echo ==================================================================
set "OK="
set /p OK=Scrivi SI e premi Invio per procedere:
if /i not "%OK%"=="SI" ( echo Annullato, non ho scritto nulla. & echo Annullato >> "%LOG%" & goto fine_menu )
call :vai_fastboot
if errorlevel 1 goto fine_menu
fastboot flash boot_a "%BOOTORIG%" >> "%LOG%" 2>&1
if errorlevel 1 ( echo [ERRORE] Scrittura del boot fallita. NON spegnere il tablet e riprova l'opzione 4. & echo ERRORE flash boot >> "%LOG%" & goto fine_menu )
fastboot reboot >> "%LOG%" 2>&1
echo [%date% %time%] Boot originale scritto >> "%LOG%"
echo Fatto: boot originale rimesso, il tablet si riavvia senza root.
goto fine_menu

rem ==================================================================
rem  SUBROUTINE
rem ==================================================================
:verifica_file
if not exist "%CHK%" ( echo [STOP] Manca un file nella cartella strumenti, vedi LEGGIMI.txt & echo STOP: manca file >> "%LOG%" & exit /b 1 )
powershell -NoProfile -Command "if ((Get-FileHash -LiteralPath $env:CHK -Algorithm SHA256).Hash -eq $env:CHKSHA) { exit 0 } else { exit 1 }" <nul
if errorlevel 1 ( echo [STOP] Un file della cartella strumenti e' danneggiato: non lo uso. & echo STOP: sha errato >> "%LOG%" & exit /b 1 )
exit /b 0

:verifica_kernel
<nul adb shell cat /proc/version > "%TEMP%\mc_kv.txt" 2>&1
type "%TEMP%\mc_kv.txt" >> "%LOG%"
findstr /c:"%KERNELID%" "%TEMP%\mc_kv.txt" >nul
if errorlevel 1 ( echo [STOP] Il kernel del tablet non e' quello originale 1DY del 15/07/2021: il boot non e' adatto, mi fermo. & echo STOP: kernel diverso >> "%LOG%" & exit /b 1 )
echo Kernel originale 1DY riconosciuto.
exit /b 0

:vai_fastboot
fastboot devices 2>nul | find "fastboot" >nul
if not errorlevel 1 goto vf_controlli
adb reboot fastboot
echo Attendo il tablet in modalita' fastboot...
call :attendi_fastboot
if errorlevel 1 ( echo [STOP] Il tablet non risulta in fastboot, vedi LEGGIMI.txt & echo STOP: fastboot non visto >> "%LOG%" & exit /b 1 )
:vf_controlli
fastboot getvar product > "%TEMP%\mc_fb.txt" 2>&1
fastboot getvar is-userspace >> "%TEMP%\mc_fb.txt" 2>&1
fastboot getvar unlocked >> "%TEMP%\mc_fb.txt" 2>&1
fastboot getvar current-slot >> "%TEMP%\mc_fb.txt" 2>&1
type "%TEMP%\mc_fb.txt" >> "%LOG%"
findstr /c:"product: 1DY" "%TEMP%\mc_fb.txt" >nul || ( echo [STOP] Il modello non e' 1DY. Mi fermo. & echo STOP: product >> "%LOG%" & exit /b 1 )
findstr /c:"is-userspace: yes" "%TEMP%\mc_fb.txt" >nul || ( echo [STOP] Il tablet e' nel fastboot sbagliato: serve fastbootd. & echo STOP: non fastbootd >> "%LOG%" & exit /b 1 )
findstr /c:"unlocked: yes" "%TEMP%\mc_fb.txt" >nul || ( echo [STOP] Il bootloader e' BLOCCATO. & echo STOP: bootloader bloccato >> "%LOG%" & exit /b 1 )
findstr /c:"current-slot: a" "%TEMP%\mc_fb.txt" >nul || ( echo [STOP] Lo slot attivo non e' "a", mi fermo. & echo STOP: slot non a >> "%LOG%" & exit /b 1 )
exit /b 0

:verifica_lineage
adb get-state >nul 2>&1
if errorlevel 1 (
  echo [STOP] adb non vede il tablet: deve essere acceso, sbloccato,
  echo collegato e con il Debug USB attivo. Usa l'opzione 1.
  echo STOP: adb non vede il tablet >> "%LOG%"
  exit /b 1
)
<nul adb shell getprop ro.vendor.build.fingerprint > "%TEMP%\mc_fp.txt" 2>&1
<nul adb shell getprop ro.build.version.release > "%TEMP%\mc_rel.txt" 2>&1
type "%TEMP%\mc_fp.txt" >> "%LOG%"
type "%TEMP%\mc_rel.txt" >> "%LOG%"
findstr /c:"%FPRINT%" "%TEMP%\mc_fp.txt" >nul || ( echo [STOP] Questo non e' un Mediacom SmartPad iyo 10 M-SP1DY. & echo STOP: modello diverso >> "%LOG%" & exit /b 1 )
findstr /x /c:"16" "%TEMP%\mc_rel.txt" >nul || ( echo [STOP] Sul tablet non c'e' LineageOS 23.2: usa prima l'opzione 2. & echo STOP: lineage 23.2 assente >> "%LOG%" & exit /b 1 )
exit /b 0

:attendi_fastboot
set /a N=0
:af_loop
fastboot devices 2>nul | find "fastboot" >nul
if not errorlevel 1 exit /b 0
set /a N+=1
if %N% GEQ 40 exit /b 1
ping -n 4 127.0.0.1 >nul
goto af_loop

:attendi_avvio
ping -n 31 127.0.0.1 >nul
adb wait-for-device
set /a N=0
:aa_loop
<nul adb shell getprop sys.boot_completed 2>nul | find "1" >nul
if not errorlevel 1 ( ping -n 11 127.0.0.1 >nul & exit /b 0 )
set /a N+=1
if %N% GEQ 60 exit /b 1
ping -n 6 127.0.0.1 >nul
goto aa_loop
