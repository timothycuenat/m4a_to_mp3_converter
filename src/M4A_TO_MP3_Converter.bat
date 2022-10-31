@echo off
REM TIMOTHY CUENAT | 25.10.2022
SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

set currentDirectory=%CD%
set ffmpegBaseUrl=https://www.gyan.dev/ffmpeg/builds
set ffmpegLastReleaseZip=ffmpeg-release-essentials.zip
set ffmpegLastReleaseUrl=%ffmpegBaseUrl%/%ffmpegLastReleaseZip%
set ffmpegFilter=ffmpeg*
set sourceFilesExtensionFfmpegFilter=*.m4a

echo=  __  __ _  _     _      _____ ___     __  __ ____ _____     ____                          _            
echo= ^|  \/  ^| ^|^| ^|   / \    ^|_   _/ _ \   ^|  \/  ^|  _ \___ /    / ___^|___  _ ____   _____ _ __^| ^|_ ___ _ __ 
echo= ^| ^|\/^| ^| ^|^| ^|_ / _ \     ^| ^|^| ^| ^| ^|  ^| ^|\/^| ^| ^|_) ^|^|_ \   ^| ^|   / _ \^| '_ \ \ / / _ \ '__^| __/ _ \ '__^|
echo= ^| ^|  ^| ^|__   _/ ___ \    ^| ^|^| ^|_^| ^|  ^| ^|  ^| ^|  __/___) ^|  ^| ^|__^| (_) ^| ^| ^| \ V /  __/ ^|  ^| ^|^|  __/ ^|   
echo= ^|_^|  ^|_^|  ^|_^|/_/   \_\   ^|_^| \___/   ^|_^|  ^|_^|_^|  ^|____/    \____\___/^|_^| ^|_^|\_/ \___^|_^|   \__\___^|_^|   
echo=--------------------------------------------------------------------------------------------------------
echo= Timothy Cuenat - 25.10.2022                                                                                                     

call :downloadOrProcess
pause >NUL 
goto :eof

:downloadOrProcess
call :searchDirectory %ffmpegFilter%,ffmpegFolder REM Check if FFMPEG already downloaded or download it
set ffmpegApp=%currentDirectory%\%ffmpegFolder%\bin\ffmpeg.exe
if exist "%ffmpegApp%" (
	call :convertProcess %sourceFilesExtensionFfmpegFilter% "%ffmpegApp%"
) else (
	call :downloadFfmpeg
	call :downloadOrProcess
)
EXIT /B 0

:searchDirectory
FOR /F "tokens=*" %%F IN ('"dir /b %~1 2>nul"') DO (
	IF NOT "%%F" == "" (
		set folder=%%F
		set %~2=!folder!
	)
)
EXIT /B 0

:downloadFfmpeg
echo Downloading FFMPEG
curl -# -L -O %ffmpegLastReleaseUrl%
if exist %ffmpegLastReleaseZip% (
	echo=Download COMPLETE
	echo=Unzipping FFMPEG .zip
	tar -xf %ffmpegLastReleaseZip%
	echo=Removing FFMPEG .zip
	del -q %ffmpegLastReleaseZip%
) else (
	echo=Download failed
)
EXIT /B 0

:convertAllFilesWithFilterInCurrentFolder
REM For each file that have the filter in current folder
FOR /F "tokens=*" %%F IN ('"dir /b %~1 2>nul"') DO (
	IF NOT "%%F" == "" (
		call :convertFile "%%F" %2 %3
		echo=
	)
)
EXIT /B 0

:convertProcess
REM Going through all folders and subfolders and converting each file
echo=Converting process started ! (Converting all files %sourceFilesExtensionFfmpegFilter% in all subfolders)
echo=
call :convertAllFilesWithFilterInCurrentFolder %~1 %~2 %cd% REM Convert files from current directory before making subfolders
FOR /F "tokens=*" %%D IN ('"dir /ad /b /s 2>nul"') DO (
	IF NOT "%%D" == "" (
		cd "%%D"
		call :convertAllFilesWithFilterInCurrentFolder %~1 %2 "%%D"
	)
)
cd %currentDirectory%
call :deleteFfmpeg
echo=--------------------------
echo=^| Convert process FINISH ^|
echo=--------------------------
EXIT /B 0

:convertFile
echo= - %~3\%~1
set fileName=%~1
set fileName=%fileName:~0,-4%
%2 -i %1 -c:a libmp3lame -q:a 8 "%fileName%.mp3" -hide_banner -loglevel error -stats -n
EXIT /B 0

:deleteFfmpeg
echo=Deleting FFMPEG
cd %currentDirectory%
rmdir /s /q "%currentDirectory%\%ffmpegFolder%"
EXIT /B 0