@echo off
SET GAME_NAME=factory_game
SET DIST_DIR=dist
SET LOVE_FILES_DIR=dlls

echo Deleting old distribution zip to prevent duplicates...
del /F /Q %DIST_DIR%\%GAME_NAME%.zip 2>nul

echo Creating distribution directory: %DIST_DIR%
if not exist %DIST_DIR% mkdir %DIST_DIR%

echo.
echo Creating %GAME_NAME%.love file...
echo This will package: main.lua, conf.lua, and the audio/, fonts/, scripts/, and sprites/ folders.
powershell -Command "Remove-Item -Path '%DIST_DIR%\%GAME_NAME%.love' -ErrorAction SilentlyContinue; Compress-Archive -Path main.lua, conf.lua, audio, fonts, scripts, sprites -DestinationPath '%DIST_DIR%\%GAME_NAME%.zip' -Force; Rename-Item -Path '%DIST_DIR%\%GAME_NAME%.zip' -NewName '%GAME_NAME%.love'"

if %errorlevel% neq 0 (
    echo ERROR: Failed to create the .love file. Halting.
    exit /b %errorlevel%
)
echo .love file created successfully.

echo.
echo Creating %GAME_NAME%.exe...
copy /b /Y %LOVE_FILES_DIR%\love.exe+%DIST_DIR%\%GAME_NAME%.love %DIST_DIR%\%GAME_NAME%.exe

if %errorlevel% neq 0 (
    echo ERROR: Failed to create the .exe file.
    echo Make sure love.exe is present in the '%LOVE_FILES_DIR%' directory.
    exit /b %errorlevel%
)
echo .exe created successfully.

echo.
echo Copying required DLLs and license from %LOVE_FILES_DIR% to %DIST_DIR%...
copy /Y %LOVE_FILES_DIR%\*.dll %DIST_DIR% > nul
copy /Y %LOVE_FILES_DIR%\license.txt %DIST_DIR% > nul
echo Files copied.

echo.
echo Zipping final distribution package...
powershell -Command "Compress-Archive -Path %DIST_DIR%\* -DestinationPath '%GAME_NAME%.zip' -Force"
move /Y %GAME_NAME%.zip %DIST_DIR% > nul

echo.
echo --- BUILD COMPLETE ---
echo Your distributable game is in the '%DIST_DIR%' folder.
echo The final shareable package is: %DIST_DIR%\%GAME_NAME%.zip
