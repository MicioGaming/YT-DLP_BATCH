@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

:: Load configuration
call :LoadConfig

:: Initialize statistics
call :InitStats

:: Check required files
if not exist yt-dlp.exe (
  echo %MSG_NO_YTDLP%
  echo %MSG_DOWNLOAD_YTDLP%
  echo ============by MICHU============
  pause
  exit /b
)

if not exist ffmpeg.exe (
  echo %MSG_NO_FFMPEG%
  echo %MSG_DOWNLOAD_FFMPEG%
  echo ============by MICHU============
  pause
  exit /b
)

:MAIN_START
call :SetTheme
cls
call :ShowProgress 0
goto PLATFORM_MENU

:LoadConfig
:: Default configuration (English)
set LANG=EN
set COLOR_SCHEME=0C
set DOWNLOAD_THUMBNAILS=N
set DEFAULT_FOLDER=Downloaded
set THEME=DARK
set NOTIFICATIONS=Y
set AUTO_TAG=N

:: Load from config file if exists
if exist config.ini (
    for /f "tokens=1,2 delims==" %%a in (config.ini) do (
        if "%%a"=="LANG" set LANG=%%b
        if "%%a"=="COLOR_SCHEME" set COLOR_SCHEME=%%b
        if "%%a"=="DOWNLOAD_THUMBNAILS" set DOWNLOAD_THUMBNAILS=%%b
        if "%%a"=="DEFAULT_FOLDER" set DEFAULT_FOLDER=%%b
        if "%%a"=="THEME" set THEME=%%b
        if "%%a"=="NOTIFICATIONS" set NOTIFICATIONS=%%b
        if "%%a"=="AUTO_TAG" set AUTO_TAG=%%b
    )
)

:: Set language strings
call :SetLanguageStrings
goto :eof

:SetTheme
if "%THEME%"=="DARK" (
    if "%COLOR_SCHEME%"=="0A" color 0A
    if "%COLOR_SCHEME%"=="0B" color 0B
    if "%COLOR_SCHEME%"=="0C" color 0C
    if "%COLOR_SCHEME%"=="0D" color 0D
    if "%COLOR_SCHEME%"=="0E" color 0E
    if "%COLOR_SCHEME%"=="0F" color 0F
) else (
    if "%COLOR_SCHEME%"=="0A" color F0
    if "%COLOR_SCHEME%"=="0B" color F1
    if "%COLOR_SCHEME%"=="0C" color F4
    if "%COLOR_SCHEME%"=="0D" color F5
    if "%COLOR_SCHEME%"=="0E" color F6
    if "%COLOR_SCHEME%"=="0F" color F7
)
goto :eof

:InitStats
if not exist stats.txt (
    echo TOTAL_DOWNLOADS=0 > stats.txt
    echo TOTAL_SIZE_MB=0 >> stats.txt
    echo TOTAL_TIME_SECONDS=0 >> stats.txt
    echo VIDEO_COUNT=0 >> stats.txt
    echo AUDIO_COUNT=0 >> stats.txt
    echo LAST_DOWNLOAD= >> stats.txt
)

:: Load stats
for /f "tokens=1,2 delims==" %%a in (stats.txt) do (
    if "%%a"=="TOTAL_DOWNLOADS" set TOTAL_DOWNLOADS=%%b
    if "%%a"=="TOTAL_SIZE_MB" set TOTAL_SIZE_MB=%%b
    if "%%a"=="TOTAL_TIME_SECONDS" set TOTAL_TIME_SECONDS=%%b
    if "%%a"=="VIDEO_COUNT" set VIDEO_COUNT=%%b
    if "%%a"=="AUDIO_COUNT" set AUDIO_COUNT=%%b
    if "%%a"=="LAST_DOWNLOAD" set LAST_DOWNLOAD=%%b
)
goto :eof

:UpdateStats
set type=%1
set /a TOTAL_DOWNLOADS+=1

if "%type%"=="video" (
    set /a VIDEO_COUNT+=1
) else (
    set /a AUDIO_COUNT+=1
)

:: Get current date/time
for /f "tokens=2 delims==" %%I in ('wmic OS Get localdatetime /value') do set "dt=%%I"
set "LAST_DOWNLOAD=%dt:~0,4%-%dt:~4,2%-%dt:~6,2% %dt:~8,2%:%dt:~10,2%"

:: Save stats
(
echo TOTAL_DOWNLOADS=%TOTAL_DOWNLOADS%
echo TOTAL_SIZE_MB=%TOTAL_SIZE_MB%
echo TOTAL_TIME_SECONDS=%TOTAL_TIME_SECONDS%
echo VIDEO_COUNT=%VIDEO_COUNT%
echo AUDIO_COUNT=%AUDIO_COUNT%
echo LAST_DOWNLOAD=%LAST_DOWNLOAD%
) > stats.txt
goto :eof

:LogDownload
set url=%1
set filename=%2
set platform=%3
set type=%4

:: Get current date/time
for /f "tokens=2 delims==" %%I in ('wmic OS Get localdatetime /value') do set "dt=%%I"
set "datetime=%dt:~0,4%-%dt:~4,2%-%dt:~6,2% %dt:~8,2%:%dt:~10,2%"

:: Add to history
echo %datetime% ^| %platform% ^| %type% ^| %filename% ^| %url% >> download_history.txt
goto :eof

:ShowNotification
if "%NOTIFICATIONS%"=="Y" (
    echo [%time%] %~1
    :: Windows notification using powershell
    powershell -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('%~1', 'MICHU Downloader', 'OK', 'Information')" 2>nul
    :: Fallback beep sound
    echo 
)
goto :eof

:TagMP3
set "filepath=%~1"
set "title=%~2"
set "artist=%~3"

if "%AUTO_TAG%"=="Y" (
    if exist "%filepath%" (
        :: Extract title from filename if not provided
        if "%title%"=="Unknown Title" (
            for %%f in ("%filepath%") do set "title=%%~nf"
        )
        
        :: Use ffmpeg to add metadata tags (suppress output)
        ffmpeg -i "%filepath%" -metadata title="%title%" -metadata artist="%artist%" -c copy "%filepath%.tagged.mp3" >nul 2>&1
        if exist "%filepath%.tagged.mp3" (
            del "%filepath%" >nul 2>&1
            move "%filepath%.tagged.mp3" "%filepath%" >nul 2>&1
        )
    )
)
goto :eof

:SetLanguageStrings
if "%LANG%"=="PL" (
    set MSG_PLATFORM_MENU=Z CZEGO CHCESZ POBRAC?
    set MSG_YOUTUBE=YouTube
    set MSG_TIKTOK=TikTok
    set MSG_FACEBOOK=Facebook ^(rolki^)
    set MSG_INSTAGRAM=Instagram ^(rolki i zdjecia^)
    set MSG_SOUNDCLOUD=SoundCloud
    set MSG_TWITTER=Twitter
    set MSG_CDA=CDA
    set MSG_EXIT=Wyjscie
    set MSG_AUTHORS=Autorzy
    set MSG_SETTINGS=Ustawienia
    set MSG_STATISTICS=Statystyki
    set MSG_HISTORY=Historia
    set MSG_INVALID_CHOICE=Nieprawidlowy wybor, sprobuj ponownie.
    set MSG_PLATFORM_NUMBER=Podaj swoj wybor: 
    set MSG_NO_YTDLP=Nie znaleziono yt-dlp.exe! Wrzuc plik do katalogu skryptu.
    set MSG_DOWNLOAD_YTDLP=Mozesz go pobrac: https://github.com/yt-dlp/yt-dlp/releases/download/2025.07.21/yt-dlp.exe
    set MSG_NO_FFMPEG=Nie znaleziono ffmpeg.exe! Wrzuc plik do katalogu skryptu.
    set MSG_DOWNLOAD_FFMPEG=Mozesz go pobrac: https://www.gyan.dev/ffmpeg/builds/ffmpeg-git-full.7z
    set MSG_YOUTUBE_MENU=YouTube Downloader
    set MSG_VIDEO=Video ^(mp4^)
    set MSG_AUDIO=Audio ^(mp3^)
    set MSG_PLAYLIST=Playlist
    set MSG_BACK=Powrot do wyboru platformy
    set MSG_ENTER_URL=Podaj URL: 
    set MSG_FOLDER_PATH=Podaj sciezke zapisu ^(puste = %DEFAULT_FOLDER%^): 
    set MSG_DOWNLOAD_COMPLETE=Pobieranie zakonczone!
    set MSG_QUALITY_MENU=Wybierz jakosc:
    set MSG_BEST_QUALITY=Najlepsza
    set MSG_SETTINGS_MENU=USTAWIENIA
    set MSG_LANGUAGE=Jezyk
    set MSG_COLOR_SCHEME_SETTING=Schemat kolorow
    set MSG_THUMBNAILS=Pobieranie miniaturek
    set MSG_DEFAULT_FOLDER_SETTING=Domyslny folder
    set MSG_SAVE_SETTINGS=Zapisz ustawienia
    set MSG_CURRENT=Aktualnie
    set MSG_THEME=Motyw
    set MSG_NOTIFICATIONS=Powiadomienia
    set MSG_AUTO_TAG=Auto-tagowanie MP3
    set MSG_TOTAL_DOWNLOADS=Lacznie pobran
    set MSG_VIDEO_COUNT=Wideo
    set MSG_AUDIO_COUNT=Audio
    set MSG_LAST_DOWNLOAD=Ostatnie pobieranie
    set MSG_CLEAR_HISTORY=Wyczysc historie
    set MSG_STATS_MENU=STATYSTYKI
    set MSG_HISTORY_MENU=HISTORIA POBIERAN
) else (
    set MSG_PLATFORM_MENU=WHAT DO YOU WANT TO DOWNLOAD FROM?
    set MSG_YOUTUBE=YouTube
    set MSG_TIKTOK=TikTok
    set MSG_FACEBOOK=Facebook ^(reels^)
    set MSG_INSTAGRAM=Instagram ^(reels and photos^)
    set MSG_SOUNDCLOUD=SoundCloud
    set MSG_TWITTER=Twitter
    set MSG_CDA=CDA
    set MSG_EXIT=Exit
    set MSG_AUTHORS=Authors
    set MSG_SETTINGS=Settings
    set MSG_STATISTICS=Statistics
    set MSG_HISTORY=History
    set MSG_INVALID_CHOICE=Invalid choice, please try again.
    set MSG_PLATFORM_NUMBER=Enter your choice: 
    set MSG_NO_YTDLP=yt-dlp.exe not found! Put the file in the script directory.
    set MSG_DOWNLOAD_YTDLP=You can download it: https://github.com/yt-dlp/yt-dlp/releases/download/2025.07.21/yt-dlp.exe
    set MSG_NO_FFMPEG=ffmpeg.exe not found! Put the file in the script directory.
    set MSG_DOWNLOAD_FFMPEG=You can download it: https://www.gyan.dev/ffmpeg/builds/ffmpeg-git-full.7z
    set MSG_YOUTUBE_MENU=YouTube Downloader
    set MSG_VIDEO=Video ^(mp4^)
    set MSG_AUDIO=Audio ^(mp3^)
    set MSG_PLAYLIST=Playlist
    set MSG_BACK=Back to platform selection
    set MSG_ENTER_URL=Enter URL: 
    set MSG_FOLDER_PATH=Enter save path ^(empty = %DEFAULT_FOLDER%^): 
    set MSG_DOWNLOAD_COMPLETE=Download completed!
    set MSG_QUALITY_MENU=Select quality:
    set MSG_BEST_QUALITY=Best
    set MSG_SETTINGS_MENU=SETTINGS
    set MSG_LANGUAGE=Language
    set MSG_COLOR_SCHEME_SETTING=Color Scheme
    set MSG_THUMBNAILS=Download Thumbnails
    set MSG_DEFAULT_FOLDER_SETTING=Default Folder
    set MSG_SAVE_SETTINGS=Save Settings
    set MSG_CURRENT=Current
    set MSG_THEME=Theme
    set MSG_NOTIFICATIONS=Notifications
    set MSG_AUTO_TAG=Auto-tag MP3
    set MSG_TOTAL_DOWNLOADS=Total Downloads
    set MSG_VIDEO_COUNT=Videos
    set MSG_AUDIO_COUNT=Audio
    set MSG_LAST_DOWNLOAD=Last Download
    set MSG_CLEAR_HISTORY=Clear History
    set MSG_STATS_MENU=STATISTICS
    set MSG_HISTORY_MENU=DOWNLOAD HISTORY
)
goto :eof

:ShowProgress
set /a progress=%1
set progressbar=
for /l %%i in (1,1,%progress%) do set progressbar=!progressbar!█
for /l %%i in (%progress%,1,20) do set progressbar=!progressbar!░
echo [!progressbar!] %progress%/20
goto :eof

:PLATFORM_MENU
cls
call :ShowProgress 5
echo ================================
echo      %MSG_PLATFORM_MENU%
echo ============by MICHU============
echo.
echo [1/Y] %MSG_YOUTUBE%
echo [2/T] %MSG_TIKTOK%
echo [3/F] %MSG_FACEBOOK%
echo [4/I] %MSG_INSTAGRAM%
echo [5/S] %MSG_SOUNDCLOUD%
echo [6/W] %MSG_TWITTER%
echo [7/C] %MSG_CDA%
echo [][][][][][][][][][][][][][]
echo [8/Q] %MSG_EXIT%
echo [9/A] %MSG_AUTHORS%
echo [0/R] %MSG_SETTINGS%
echo [*/X] %MSG_STATISTICS%
echo [#/H] %MSG_HISTORY%
echo.
echo %MSG_TOTAL_DOWNLOADS%: %TOTAL_DOWNLOADS% ^| %MSG_VIDEO_COUNT%: %VIDEO_COUNT% ^| %MSG_AUDIO_COUNT%: %AUDIO_COUNT%
echo.
set /p platform=%MSG_PLATFORM_NUMBER%

:: Quick shortcuts
if /i "%platform%"=="Q" goto END
if /i "%platform%"=="Y" set platform=1
if /i "%platform%"=="T" set platform=2
if /i "%platform%"=="F" set platform=3
if /i "%platform%"=="I" set platform=4
if /i "%platform%"=="S" set platform=5
if /i "%platform%"=="W" set platform=6
if /i "%platform%"=="C" set platform=7
if /i "%platform%"=="A" set platform=9
if /i "%platform%"=="R" set platform=0
if /i "%platform%"=="X" set platform=*
if /i "%platform%"=="H" set platform=#

if "%platform%"=="1" goto YOUTUBE_MENU
if "%platform%"=="2" goto TIKTOK_MENU
if "%platform%"=="3" goto FACEBOOK_MENU
if "%platform%"=="4" goto INSTAGRAM_MENU
if "%platform%"=="5" goto SOUNDCLOUD_MENU
if "%platform%"=="6" goto TWITTER_MENU
if "%platform%"=="7" goto CDA_MENU
if "%platform%"=="8" goto END
if "%platform%"=="9" goto AUTHOR
if "%platform%"=="0" goto SETTINGS_MENU
if "%platform%"=="*" goto STATISTICS_MENU
if "%platform%"=="#" goto HISTORY_MENU

echo %MSG_INVALID_CHOICE%
timeout /t 2 >nul
goto PLATFORM_MENU

:STATISTICS_MENU
cls
call :ShowProgress 10
echo ================================
echo        %MSG_STATS_MENU%
echo ============by MICHU============
echo.
echo %MSG_TOTAL_DOWNLOADS%: %TOTAL_DOWNLOADS%
echo %MSG_VIDEO_COUNT%: %VIDEO_COUNT%
echo %MSG_AUDIO_COUNT%: %AUDIO_COUNT%
echo %MSG_LAST_DOWNLOAD%: %LAST_DOWNLOAD%
echo.
if %TOTAL_DOWNLOADS% GTR 0 (
    set /a video_percent=VIDEO_COUNT*100/TOTAL_DOWNLOADS
    set /a audio_percent=AUDIO_COUNT*100/TOTAL_DOWNLOADS
    echo Video percentage: !video_percent!%%
    echo Audio percentage: !audio_percent!%%
)
echo.
echo Press any key to return...
pause >nul
goto PLATFORM_MENU

:HISTORY_MENU
cls
call :ShowProgress 10
echo ================================
echo      %MSG_HISTORY_MENU%
echo ============by MICHU============
echo.
if exist download_history.txt (
    echo Last 10 downloads:
    echo.
    powershell -Command "Get-Content download_history.txt | Select-Object -Last 10"
    echo.
    echo [1] %MSG_CLEAR_HISTORY%
    echo [2] %MSG_BACK%
    echo.
    set /p histchoice=Choice: 
    if "!histchoice!"=="1" (
        del download_history.txt 2>nul
        echo History cleared!
        timeout /t 2 >nul
    )
) else (
    echo No download history found.
    echo.
    echo Press any key to return...
    pause >nul
)
goto PLATFORM_MENU

:SETTINGS_MENU
cls
call :ShowProgress 10
echo ================================
echo        %MSG_SETTINGS_MENU%
echo ============by MICHU============
echo.
echo [1] %MSG_LANGUAGE% (%MSG_CURRENT%: %LANG%)
echo [2] %MSG_COLOR_SCHEME_SETTING% (%MSG_CURRENT%: %COLOR_SCHEME%)
echo [3] %MSG_THEME% (%MSG_CURRENT%: %THEME%)
echo [4] %MSG_THUMBNAILS% (%MSG_CURRENT%: %DOWNLOAD_THUMBNAILS%)
echo [5] %MSG_NOTIFICATIONS% (%MSG_CURRENT%: %NOTIFICATIONS%)
echo [6] %MSG_AUTO_TAG% (%MSG_CURRENT%: %AUTO_TAG%)
echo [7] %MSG_DEFAULT_FOLDER_SETTING% (%MSG_CURRENT%: %DEFAULT_FOLDER%)
echo [8] %MSG_SAVE_SETTINGS%
echo [9] %MSG_BACK%
echo.
set /p setting=%MSG_PLATFORM_NUMBER%

if "%setting%"=="1" goto CHANGE_LANGUAGE
if "%setting%"=="2" goto CHANGE_COLOR
if "%setting%"=="3" goto CHANGE_THEME
if "%setting%"=="4" goto CHANGE_THUMBNAILS
if "%setting%"=="5" goto CHANGE_NOTIFICATIONS
if "%setting%"=="6" goto CHANGE_AUTO_TAG
if "%setting%"=="7" goto CHANGE_FOLDER
if "%setting%"=="8" goto SAVE_CONFIG
if "%setting%"=="9" goto PLATFORM_MENU

echo %MSG_INVALID_CHOICE%
timeout /t 2 >nul
goto SETTINGS_MENU

:CHANGE_LANGUAGE
cls
echo Select Language / Wybierz jezyk:
echo [1] English
echo [2] Polski
echo.
set /p newlang=Choice/Wybor: 

if "%newlang%"=="1" set LANG=EN
if "%newlang%"=="2" set LANG=PL
call :SetLanguageStrings
goto SETTINGS_MENU

:CHANGE_COLOR
cls
echo Color schemes:
echo [1] Green (0A)
echo [2] Blue (0B)  
echo [3] Red (0C)
echo [4] Purple (0D)
echo [5] Yellow (0E)
echo [6] White (0F)
echo.
set /p newcolor=Choice: 

if "%newcolor%"=="1" set COLOR_SCHEME=0A
if "%newcolor%"=="2" set COLOR_SCHEME=0B
if "%newcolor%"=="3" set COLOR_SCHEME=0C
if "%newcolor%"=="4" set COLOR_SCHEME=0D
if "%newcolor%"=="5" set COLOR_SCHEME=0E
if "%newcolor%"=="6" set COLOR_SCHEME=0F
call :SetTheme
goto SETTINGS_MENU

:CHANGE_THEME
if "%THEME%"=="DARK" (
    set THEME=LIGHT
) else (
    set THEME=DARK
)
call :SetTheme
goto SETTINGS_MENU

:CHANGE_THUMBNAILS
if "%DOWNLOAD_THUMBNAILS%"=="Y" (
    set DOWNLOAD_THUMBNAILS=N
) else (
    set DOWNLOAD_THUMBNAILS=Y
)
goto SETTINGS_MENU

:CHANGE_NOTIFICATIONS
if "%NOTIFICATIONS%"=="Y" (
    set NOTIFICATIONS=N
) else (
    set NOTIFICATIONS=Y
)
goto SETTINGS_MENU

:CHANGE_AUTO_TAG
if "%AUTO_TAG%"=="Y" (
    set AUTO_TAG=N
) else (
    set AUTO_TAG=Y
)
goto SETTINGS_MENU

:CHANGE_FOLDER
cls
echo %MSG_CURRENT%: %DEFAULT_FOLDER%
echo.
set /p newfolder=New folder name: 
if not "%newfolder%"=="" set DEFAULT_FOLDER=%newfolder%
goto SETTINGS_MENU

:SAVE_CONFIG
(
echo LANG=%LANG%
echo COLOR_SCHEME=%COLOR_SCHEME%
echo THEME=%THEME%
echo DOWNLOAD_THUMBNAILS=%DOWNLOAD_THUMBNAILS%
echo NOTIFICATIONS=%NOTIFICATIONS%
echo AUTO_TAG=%AUTO_TAG%
echo DEFAULT_FOLDER=%DEFAULT_FOLDER%
) > config.ini
echo Configuration saved!
timeout /t 2 >nul
goto SETTINGS_MENU

:YOUTUBE_MENU
cls
call :ShowProgress 15
echo ================================
echo        %MSG_YOUTUBE_MENU%      
echo ============by MICHU============
echo.
echo %MSG_QUALITY_MENU%
echo [1/V] %MSG_VIDEO%
echo [2/A] %MSG_AUDIO%
echo [3/P] %MSG_PLAYLIST%
echo [4/B] %MSG_BACK%
echo.
set /p choice=%MSG_PLATFORM_NUMBER%

:: Quick shortcuts
if /i "%choice%"=="V" set choice=1
if /i "%choice%"=="A" set choice=2
if /i "%choice%"=="P" set choice=3
if /i "%choice%"=="B" set choice=4

if "%choice%"=="1" goto VIDEO
if "%choice%"=="2" goto AUDIO
if "%choice%"=="3" goto PLAYLIST
if "%choice%"=="4" goto PLATFORM_MENU

echo %MSG_INVALID_CHOICE%
timeout /t 2 >nul
goto YOUTUBE_MENU

:TIKTOK_MENU
cls
call :ShowProgress 18
set /p url=%MSG_ENTER_URL%
call :DownloadGeneric "%url%" "TikTok"
goto PLATFORM_MENU

:FACEBOOK_MENU
cls
call :ShowProgress 18
set /p url=%MSG_ENTER_URL%
call :DownloadGeneric "%url%" "Facebook"
goto PLATFORM_MENU

:INSTAGRAM_MENU
cls
call :ShowProgress 18
set /p url=%MSG_ENTER_URL%
call :DownloadGeneric "%url%" "Instagram"
goto PLATFORM_MENU

:SOUNDCLOUD_MENU
cls
call :ShowProgress 18
set /p url=%MSG_ENTER_URL%
call :DownloadSoundcloud "%url%" "SoundCloud"
goto PLATFORM_MENU

:TWITTER_MENU
cls
call :ShowProgress 18
set /p url=%MSG_ENTER_URL%
call :DownloadGeneric "%url%" "Twitter"
goto PLATFORM_MENU

:CDA_MENU
cls
call :ShowProgress 15
echo CDA Download:
echo %MSG_QUALITY_MENU%
echo [1] %MSG_VIDEO%
echo [2] %MSG_AUDIO%
echo [3] %MSG_PLAYLIST%
echo [4] %MSG_BACK%
echo.
set /p choice=%MSG_PLATFORM_NUMBER%

if "%choice%"=="1" (
    call :DownloadCDA video "CDA"
) else if "%choice%"=="2" (
    call :DownloadCDA audio "CDA"
) else if "%choice%"=="3" (
    call :DownloadCDAPlaylist "CDA"
) else if "%choice%"=="4" (
    goto PLATFORM_MENU
) else (
    echo %MSG_INVALID_CHOICE%
    timeout /t 2 >nul
    goto CDA_MENU
)
goto PLATFORM_MENU

:DownloadGeneric
set "url=%~1"
set "platform=%~2"
cls
call :ShowProgress 20
echo %MSG_QUALITY_MENU%
echo [1] %MSG_VIDEO%
echo [2] %MSG_AUDIO%
echo.
set /p choice=%MSG_PLATFORM_NUMBER%

set /p folder=%MSG_FOLDER_PATH%
if "%folder%"=="" (
    set "folder=%cd%\%DEFAULT_FOLDER%"
)

rem Create folder if it doesn't exist
if not exist "%folder%" (
    mkdir "%folder%"
)

:: Build thumbnail argument
set thumbnail_arg=
if "%DOWNLOAD_THUMBNAILS%"=="Y" (
    set thumbnail_arg=--write-thumbnail
)

set start_time=%time%

if "%choice%"=="1" (
    yt-dlp.exe -f "bestvideo+bestaudio/best" --merge-output-format mp4 %thumbnail_arg% -o "%folder%\%%(title)s.%%(ext)s" "%url%"
    call :UpdateStats video
    call :LogDownload "%url%" "%(title)s.mp4" "%platform%" "video"
) else if "%choice%"=="2" (
    yt-dlp.exe -f bestaudio -x --audio-format mp3 %thumbnail_arg% -o "%folder%\%%(title)s.%%(ext)s" "%url%"
    call :UpdateStats audio
    call :LogDownload "%url%" "%(title)s.mp3" "%platform%" "audio"
    :: Auto-tag MP3 if enabled
    if "%AUTO_TAG%"=="Y" (
        for %%f in ("%folder%\*.mp3") do (
            call :TagMP3 "%%f" "Unknown Title" "Unknown Artist"
        )
    )
) else (
    echo %MSG_INVALID_CHOICE%
    yt-dlp.exe -f "bestvideo+bestaudio/best" --merge-output-format mp4 %thumbnail_arg% -o "%folder%\%%(title)s.%%(ext)s" "%url%"
    call :UpdateStats video
    call :LogDownload "%url%" "%(title)s.mp4" "%platform%" "video"
)

echo.
echo %MSG_DOWNLOAD_COMPLETE%
call :ShowNotification "%MSG_DOWNLOAD_COMPLETE% - %platform%"
call :SetTheme
timeout /t 3 >nul
goto :eof

:DownloadSoundcloud
set "url=%~1"
set "platform=%~2"
cls
call :ShowProgress 20
set /p folder=%MSG_FOLDER_PATH%
if "%folder%"=="" (
    set "folder=%cd%\%DEFAULT_FOLDER%"
    if not exist "%folder%" mkdir "%folder%"
)

set thumbnail_arg=
if "%DOWNLOAD_THUMBNAILS%"=="Y" (
    set thumbnail_arg=--write-thumbnail --convert-thumbnails jpg
)

yt-dlp.exe -f bestaudio -x --audio-format mp3 %thumbnail_arg% -o "%folder%\%%(title)s.%%(ext)s" "%url%"
call :UpdateStats audio
call :LogDownload "%url%" "%(title)s.mp3" "%platform%" "audio"

:: Auto-tag MP3 if enabled - wait for file to be ready
timeout /t 1 >nul
if "%AUTO_TAG%"=="Y" (
    for %%f in ("%folder%\*.mp3") do (
        call :TagMP3 "%%f" "Auto-extracted" "Unknown Artist"
    )
)

echo.
echo %MSG_DOWNLOAD_COMPLETE%
call :ShowNotification "%MSG_DOWNLOAD_COMPLETE% - %platform%"
call :SetTheme
timeout /t 3 >nul
goto :eof

:DownloadCDA
set type=%1
set platform=%2
cls
call :ShowProgress 20
set /p url=%MSG_ENTER_URL%
set /p folder=%MSG_FOLDER_PATH%

if "%folder%"=="" (
    set folder=%cd%\%DEFAULT_FOLDER%
    if not exist "%folder%" mkdir "%folder%"
)

set thumbnail_arg=
if "%DOWNLOAD_THUMBNAILS%"=="Y" (
    set thumbnail_arg=--write-thumbnail --convert-thumbnails jpg
)

if "%type%"=="video" (
    set args=-f bestvideo+bestaudio --merge-output-format mp4 %thumbnail_arg%
    call :UpdateStats video
    call :LogDownload "%url%" "%(title)s.mp4" "%platform%" "video"
) else (
    set args=-f bestaudio -x --audio-format mp3 %thumbnail_arg%
    call :UpdateStats audio
    call :LogDownload "%url%" "%(title)s.mp3" "%platform%" "audio"
)

yt-dlp.exe %args% -o "%folder%\%%(title)s.%%(ext)s" "%url%"

:: Auto-tag MP3 if audio and enabled - wait for file to be ready
if "%type%"=="audio" (
    timeout /t 1 >nul
    if "%AUTO_TAG%"=="Y" (
        for %%f in ("%folder%\*.mp3") do (
            call :TagMP3 "%%f" "Auto-extracted" "Unknown Artist"
        )
    )
)

echo.
echo %MSG_DOWNLOAD_COMPLETE%
call :ShowNotification "%MSG_DOWNLOAD_COMPLETE% - %platform%"
call :SetTheme
timeout /t 3 >nul
goto :eof

:DownloadCDAPlaylist
set platform=%1
cls
call :ShowProgress 20
set /p url=%MSG_ENTER_URL%
set /p folder=%MSG_FOLDER_PATH%
if "%folder%"=="" (
    set "folder=%cd%\%DEFAULT_FOLDER%"
)
if not exist "%folder%" mkdir "%folder%"

set thumbnail_arg=
if "%DOWNLOAD_THUMBNAILS%"=="Y" (
    set thumbnail_arg=--write-thumbnail --convert-thumbnails jpg
)

yt-dlp.exe -f bestvideo+bestaudio --merge-output-format mp4 %thumbnail_arg% -o "%folder%\%%(playlist_index)s - %%(title)s.%%(ext)s" "%url%"
call :UpdateStats video
call :LogDownload "%url%" "Playlist" "%platform%" "playlist"

echo.
echo %MSG_DOWNLOAD_COMPLETE%
call :ShowNotification "%MSG_DOWNLOAD_COMPLETE% - %platform% Playlist"
call :SetTheme
timeout /t 3 >nul
goto :eof

:VIDEO
cls
call :ShowProgress 18
echo %MSG_QUALITY_MENU%
echo [1] %MSG_BEST_QUALITY% (bestvideo+bestaudio)
echo [2] 1080p
echo [3] 720p
echo [4] 480p
echo [5] 360p
echo.
set /p vquality=%MSG_PLATFORM_NUMBER%

set /p url=%MSG_ENTER_URL%
set /p folder=%MSG_FOLDER_PATH%
if "%folder%"=="" (
    set "folder=%cd%\%DEFAULT_FOLDER%"
    if not exist "%folder%" mkdir "%folder%"
)

set thumbnail_arg=
if "%DOWNLOAD_THUMBNAILS%"=="Y" (
    set thumbnail_arg=--write-thumbnail --convert-thumbnails jpg
)

if "%vquality%"=="1" (
    set args=-f bestvideo+bestaudio --merge-output-format mp4 %thumbnail_arg%
) else if "%vquality%"=="2" (
    set args=-f "bestvideo[height<=1080]+bestaudio" --merge-output-format mp4 %thumbnail_arg%
) else if "%vquality%"=="3" (
    set args=-f "bestvideo[height<=720]+bestaudio" --merge-output-format mp4 %thumbnail_arg%
) else if "%vquality%"=="4" (
    set args=-f "bestvideo[height<=480]+bestaudio" --merge-output-format mp4 %thumbnail_arg%
) else if "%vquality%"=="5" (
    set args=-f "bestvideo[height<=360]+bestaudio" --merge-output-format mp4 %thumbnail_arg%
) else (
    echo %MSG_INVALID_CHOICE%
    set args=-f bestvideo+bestaudio --merge-output-format mp4 %thumbnail_arg%
)

call :ShowProgress 20
yt-dlp.exe %args% -o "%folder%\%%(title)s.%%(ext)s" "%url%"
call :UpdateStats video
call :LogDownload "%url%" "%(title)s.mp4" "YouTube" "video"

echo.
echo %MSG_DOWNLOAD_COMPLETE%
call :ShowNotification "%MSG_DOWNLOAD_COMPLETE% - YouTube Video"
call :SetTheme
timeout /t 3 >nul
goto YOUTUBE_MENU

:AUDIO
cls
call :ShowProgress 18
echo %MSG_QUALITY_MENU%
echo [1] %MSG_BEST_QUALITY% (default)
echo [2] 320 kbps
echo [3] 192 kbps
echo [4] 128 kbps
echo.
set /p aquality=%MSG_PLATFORM_NUMBER%

set /p url=%MSG_ENTER_URL%
set /p folder=%MSG_FOLDER_PATH%
if "%folder%"=="" (
    set "folder=%cd%\%DEFAULT_FOLDER%"
    if not exist "%folder%" mkdir "%folder%"
)

set thumbnail_arg=
if "%DOWNLOAD_THUMBNAILS%"=="Y" (
    set thumbnail_arg=--write-thumbnail --convert-thumbnails jpg
)

if "%aquality%"=="1" (
    set args=-f bestaudio -x --audio-format mp3 %thumbnail_arg%
) else if "%aquality%"=="2" (
    set args=-f bestaudio -x --audio-format mp3 --audio-quality 0 %thumbnail_arg%
) else if "%aquality%"=="3" (
    set args=-f bestaudio -x --audio-format mp3 --audio-quality 5 %thumbnail_arg%
) else if "%aquality%"=="4" (
    set args=-f bestaudio -x --audio-format mp3 --audio-quality 9 %thumbnail_arg%
) else (
    echo %MSG_INVALID_CHOICE%
    set args=-f bestaudio -x --audio-format mp3 %thumbnail_arg%
)

call :ShowProgress 20
yt-dlp.exe %args% -o "%folder%\%%(title)s.%%(ext)s" "%url%"
call :UpdateStats audio
call :LogDownload "%url%" "%(title)s.mp3" "YouTube" "audio"

:: Auto-tag MP3 if enabled - wait for file to be ready
timeout /t 2 >nul
if "%AUTO_TAG%"=="Y" (
    for %%f in ("%folder%\*.mp3") do (
        call :TagMP3 "%%f" "Auto-extracted" "YouTube"
    )
)

echo.
echo %MSG_DOWNLOAD_COMPLETE%
call :ShowNotification "%MSG_DOWNLOAD_COMPLETE% - YouTube Audio"
call :SetTheme
timeout /t 3 >nul
goto YOUTUBE_MENU

:PLAYLIST
set /p url=%MSG_ENTER_URL%
cls
call :ShowProgress 18
echo %MSG_QUALITY_MENU%
echo [1] %MSG_BEST_QUALITY% (bestvideo+bestaudio)
echo [2] 1080p
echo [3] 720p
echo [4] 480p
echo [5] 360p
echo.
set /p vquality=%MSG_PLATFORM_NUMBER%

set /p folder=%MSG_FOLDER_PATH%
if "%folder%"=="" (
    set "folder=%cd%\%DEFAULT_FOLDER%"
    if not exist "%folder%" mkdir "%folder%"
)

set thumbnail_arg=
if "%DOWNLOAD_THUMBNAILS%"=="Y" (
    set thumbnail_arg=--write-thumbnail --convert-thumbnails jpg
)

if "%vquality%"=="1" (
    set args=-f bestvideo+bestaudio --merge-output-format mp4 %thumbnail_arg%
) else if "%vquality%"=="2" (
    set args=-f "bestvideo[height<=1080]+bestaudio" --merge-output-format mp4 %thumbnail_arg%
) else if "%vquality%"=="3" (
    set args=-f "bestvideo[height<=720]+bestaudio" --merge-output-format mp4 %thumbnail_arg%
) else if "%vquality%"=="4" (
    set args=-f "bestvideo[height<=480]+bestaudio" --merge-output-format mp4 %thumbnail_arg%
) else if "%vquality%"=="5" (
    set args=-f "bestvideo[height<=360]+bestaudio" --merge-output-format mp4 %thumbnail_arg%
) else (
    echo %MSG_INVALID_CHOICE%
    set args=-f bestvideo+bestaudio --merge-output-format mp4 %thumbnail_arg%
)

call :ShowProgress 20
yt-dlp.exe %args% -o "%folder%\%%(playlist_index)s - %%(title)s.%%(ext)s" "%url%"
call :UpdateStats video
call :LogDownload "%url%" "Playlist" "YouTube" "playlist"

echo.
echo %MSG_DOWNLOAD_COMPLETE%
call :ShowNotification "%MSG_DOWNLOAD_COMPLETE% - YouTube Playlist"
call :SetTheme
timeout /t 3 >nul
goto YOUTUBE_MENU

:AUTHOR
cls
call :ShowProgress 10
echo :██╗::::█████╗:██╗::::::::::::::::::::::::::::::::
echo ███║:::██╔══██╗██║:::::::Made with OpenAI:::::::::
echo ╚██║:::███████║██║:::::::claude.ai fixed::::::::::
echo :██║:::██╔══██║██║::::::::::::::::::::::::::::::::
echo :██║██╗██║::██║██║::::::::::::::::::::::::::::::::
echo :╚═╝╚═╝╚═╝::╚═╝╚═╝::::::::::::::::::::::::::::::::
echo :::::::::::::::made 24.07.2025::::::::::::::::::::
echo ██████╗::::███╗:::███╗██╗:██████╗██╗::██╗██╗:::██╗
echo ╚════██╗:::████╗:████║██║██╔════╝██║::██║██║:::██║
echo :█████╔╝:::██╔████╔██║██║██║:::::███████║██║:::██║
echo ██╔═══╝::::██║╚██╔╝██║██║██║:::::██╔══██║██║:::██║
echo ███████╗██╗██║:╚═╝:██║██║╚██████╗██║::██║╚██████╔╝
echo ╚══════╝╚═╝╚═╝:::::╚═╝╚═╝:╚═════╝╚═╝::╚═╝:╚═════╝:
echo.
echo Enhanced with: Multi-language, Statistics, History,
echo Dark/Light themes, Notifications, and MP3 Auto-tagging!
echo.
echo Total downloads so far: %TOTAL_DOWNLOADS%
timeout /t 5 >nul
goto PLATFORM_MENU

:END
cls
call :ShowProgress 20
echo.
echo Thanks for using MICHU's Enhanced Downloader!
echo Dziekuje za uzywanie MICHU Enhanced Downloader!
echo.
echo Final stats: %TOTAL_DOWNLOADS% downloads (%VIDEO_COUNT% videos, %AUDIO_COUNT% audio)
echo.
timeout /t 3 >nul
exit /b 0