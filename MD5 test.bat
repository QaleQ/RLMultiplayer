@echo off
cls
echo -----------------------------------------------------------------
echo -  NOTE: If you're a mapper and have custom texture files that  -
echo -you've manually added, this script might overwrite those files.-
echo -----------------------------------------------------------------
echo -    (However, you won't be able to play online with other      -
echo -       players that don't have those same files as you.)       -
echo -----------------------------------------------------------------
echo.
echo.
echo Press any key to run script...
@pause >nul
cls
setlocal enableextensions && setlocal enabledelayedexpansion
cls
set regvar=HKCU HKCU\Wow6432Node HKLM HKLM\Wow6432Node
for %%a in (%regvar%) do (
  for /f "tokens=1,2*" %%x in ('reg query %%a\Software\Valve\Steam 2^> nul') do (
    if "%%x" equ "SteamPath" (
      set "steampath1=%%z"
      goto checkforlibraryfolders
    )
  )
)
echo Steam not found.. sorry!
goto exitapp

:checkforlibraryfolders
set counter=1
for /f skip^=4^ usebackq^ tokens^=4^ delims^=^" %%a in ("%steampath1%\steamapps\libraryfolders.vdf") do (
  set /a counter+=1
  set "steampath!counter!=%%a"
)

:findrlloop
if %counter% gtr 0 (
  if exist "!steampath%counter%!\steamapps\common\rocketleague\binaries\Win32\rocketleague.exe" goto rlfound
  set /a counter-=1
  goto findrlloop
)
echo Rocket League not found.. sorry!
goto exitapp

:rlfound
set rlpath=!steampath%counter%!\steamapps\common\rocketleague
set rlpath=%rlpath:\\=\%
set cookedpath=%rlpath%\TAGame\CookedPCConsole
set wspath=!steampath%counter%!\steamapps\workshop\content\252950
set wspath=%wspath:\\=\%
set bmpath=%rlpath%\binaries\Win32\bakkesmod
mkdir "%bmpath%" >nul 2>&1
setlocal disabledelayedexpansion

:wstcheck
<nul set /p="Looking for Workshop Texture files.................. "

echo EditorLandscapeResources.upk > "%bmpath%\txtlist.id.tmp"
echo EditorMaterials.upk >> "%bmpath%\txtlist.id.tmp"
echo EditorMeshes.upk >> "%bmpath%\txtlist.id.tmp"
echo EditorResources.upk >> "%bmpath%\txtlist.id.tmp"
echo Engine_MI_Shaders.upk >> "%bmpath%\txtlist.id.tmp"
echo EngineBuildings.upk >> "%bmpath%\txtlist.id.tmp"
echo EngineDebugMaterials.upk >> "%bmpath%\txtlist.id.tmp"
echo EngineMaterials.upk >> "%bmpath%\txtlist.id.tmp"
echo EngineResources.upk >> "%bmpath%\txtlist.id.tmp"
echo EngineVolumetrics.upk >> "%bmpath%\txtlist.id.tmp"
echo MapTemplateIndex.upk >> "%bmpath%\txtlist.id.tmp"
echo MapTemplates.upk >> "%bmpath%\txtlist.id.tmp"
echo mods.upk >> "%bmpath%\txtlist.id.tmp"
echo NodeBuddies.upk >> "%bmpath%\txtlist.id.tmp"

for /f "usebackq" %%a in ("%bmpath%\txtlist.id.tmp") do (
  if not exist "%cookedpath%\%%a" ( echo Workshop Textures missing! && goto wstdl )
)

echo OK!
<nul set /p="Checking if Workshop Texture files are up to date... "

echo 560333dc989c762a98b191b8739746bb > "%bmpath%\textures.id"
echo c441e48051c69860391864f8692f5f3a >> "%bmpath%\textures.id"
echo 1850b79e98c318afe996ff6e7babac8f >> "%bmpath%\textures.id"
echo 1c33a45c2593b0e1a24da77364b21e3a >> "%bmpath%\textures.id"
echo c3c3915f6003d0563487a5870f5fdaf8 >> "%bmpath%\textures.id"
echo 5a29f5df27b83c1a5e6e7090e203743c >> "%bmpath%\textures.id"
echo 8a56921d4047d90d91ce8297d9dfd5ca >> "%bmpath%\textures.id"
echo 34d45741e009b48b85cfbd8da72ec3d3 >> "%bmpath%\textures.id"
echo 4699e8608b8d582fab3fae94cbc6c6f1 >> "%bmpath%\textures.id"
echo 8b2f19aa5d9f6fdd368386ac94972eab >> "%bmpath%\textures.id"
echo 32b1f64638b3ad245b479c2780a2a96f >> "%bmpath%\textures.id"
echo 8a81cd1c8370bc97bdc451544878940c >> "%bmpath%\textures.id"
echo 6d24ccc3f5fc1c5021d5ddf24a25adb8 >> "%bmpath%\textures.id"
echo 5e8038788967bff3360e8a2b289a43e8 >> "%bmpath%\textures.id"

if exist "%bmpath%\textures.id.tmp" del "%bmpath%\textures.id.tmp"
setlocal enabledelayedexpansion
for /f "usebackq" %%a in ("%bmpath%\txtlist.id.tmp") do (
  set counter=0
  for /f %%i in ('certutil -hashfile "%cookedpath%\%%a" md5') do (
    if !counter! equ 1 echo %%i >> "%bmpath%\textures.id.tmp"
    set /a counter+=1
  )
)
setlocal disabledelayedexpansion

fc "%bmpath%\textures.id.tmp" "%bmpath%\textures.id" >nul 2>&1
if %errorlevel% equ 0 ( echo OK! && goto bmcheck ) else ( echo FAILED! && goto wstdl )



:wstdl
echo.
echo One or more texture files missing or mismatched, downloading... (44,4 MB)
echo Downloading...
powershell -command "(New-Object Net.WebClient).DownloadFile('https://dl.dropboxusercontent.com/s/4mi9nnjrhl01lnm/Workshop-textures.zip', '%bmpath%\Workshop-textures-mpmod.zip')"
echo Extracting...
powershell.exe -command "$ProgressPreference='SilentlyContinue'; Expand-Archive -Path '%bmpath%\Workshop-textures-mpmod.zip' -DestinationPath '%cookedpath%' -Force"
echo Done! && echo.
goto bmcheck




:bmcheck
set bmlaunch=1
<nul set /p="Looking for BakkesMod............................... "
tasklist /FI "IMAGENAME eq bakkesmod*" 2>nul | find /I "bakkesmod">nul
if "%ERRORLEVEL%"=="0" ( echo OK! && set bmlaunch=0 && goto checksymlinks )
if not exist "%bmpath%\bakkesmod.dll" goto bmnotfound
if not exist "%bmpath%\BakkesMod.exe" goto bmelsewhere
echo OK!
goto bmstart



:bmnotfound
echo Could not detect BakkesMod, downloading... (5,21 MB)
if not exist "%bmpath%\BakkesModInjector-mpmod.zip" (
  powershell -Command "(New-Object Net.WebClient).DownloadFile('https://bakkesmod.com/static/BakkesModInjector.zip', '%bmpath%\BakkesModInjector-mpmod.zip')"
)
echo Extracting...
powershell.exe -command "$ProgressPreference='SilentlyContinue'; Expand-Archive -Path '%bmpath%\BakkesModInjector-mpmod.zip' -DestinationPath '%bmpath%' -Force"
echo Done!.. && echo.
echo BakkesMod is automatically set to run when Windows start.
echo If you prefer to launch if manually, BakkesMod.exe is located in %bmpath% && echo.
echo Remember to confirm any update prompts you might get when BakkesMod starts! && echo.
goto bmstart



:bmelsewhere
set bmlaunch=0
echo OK!* && echo.
echo *You have manually installed BakkesMod on your system prior to running this script.
echo Remember that BakkesMod has to be running for certain features to function correctly. && echo.
echo Please start BakkesMod to proceed. && echo.
goto bmstart



:bmstart
<nul set /p="Waiting for BakkesMod to start...................... "
if %bmlaunch% equ 1 start /MIN "" "%bmpath%\BakkesMod.exe"


:bmtestloop
tasklist /FI "IMAGENAME eq bakkesmod*" 2>nul | find /I "bakkesmod">nul
if "%ERRORLEVEL%"=="0" (
  echo OK!
  ) else (
  timeout 3 >nul 2>&1
  goto bmtestloop )
goto checksymlinks




:checksymlinks
set forcelinks=0

dir /b "%cookedpath%\custommaps" > "%bmpath%\addedmaps.id.tmp"
if exist "%bmpath%\addedmaps.id" (
  setlocal enabledelayedexpansion
  <nul set /p="Verifying that all maps have links.................. "
  fc "%bmpath%\addedmaps.id.tmp" "%bmpath%\addedmaps.id" >nul 2>&1
  if !errorlevel! equ 0 (
    setlocal disabledelayedexpansion
    echo OK!
  )
  if !errorlevel! equ 1 (
    setlocal disabledelayedexpansion
    echo OK!** && echo.
    set deletedlinks=1
    set forcelinks=1
  )
)
copy "%bmpath%\addedmaps.id.tmp" "%bmpath%\addedmaps.id" >nul 2>&1

<nul set /p="Looking for new workshop maps....................... "
dir /b "%wspath%" > "%bmpath%\maps.id.tmp"
fc "%bmpath%\maps.id.tmp" "%bmpath%\maps.id" >nul 2>&1
if %errorlevel% equ 0 (
 echo OK!***
 set nonewmaps=1
 if %forcelinks% equ 1 goto makelinks
 goto enditall
) else (
 echo OK!
 <nul set /p="New maps detected! Making links..................... "
 copy "%bmpath%\maps.id.tmp" "%bmpath%\maps.id" >nul 2>&1
 goto makelinks
)
goto enditall



:makelinks
mkdir "%cookedpath%\custommaps" >nul 2>&1
for /R "%wspath%" %%f in (*.udk) do ( mklink /H "%cookedpath%\custommaps\%%~nf.upk" "%%f" >nul 2>&1 )
dir /b "%cookedpath%\custommaps" > "%bmpath%\addedmaps.id"
echo OK!
goto enditall



:rlnotfound
echo.
echo ERROR!* && echo.
echo *No rocket league installation could be found... sorry!
goto exitapp



:enditall
if defined deletedlinks (
  echo.
  echo **Looks like you've deleted some links manually. They have been added back.
)
if defined nonewmaps (
 echo.
 echo ***No new maps detected. If you've recently subscribed to a new workshop map, make 
 echo sure to check in Steam that it's fully downloaded before running this script again.
)

echo.
echo DONE! && echo.
echo Note: You need to run this script again to add any new maps you subscribe to!
goto exitapp



:exitapp
echo.
echo Press any button to close this window.
@pause >nul
del "%bmpath%\textures.id.tmp"
del "%bmpath%\txtlist.id.tmp"
del "%bmpath%\addedmaps.id.tmp"
del "%bmpath%\maps.id.tmp"

rem made by QaleQ