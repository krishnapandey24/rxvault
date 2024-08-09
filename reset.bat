@echo off

REM Clean the Flutter project
flutter clean

REM Get dependencies
flutter pub get

REM Run flutter_launcher_icons to update app icons
dart run flutter_launcher_icons

REM Create native splash screens
dart run flutter_native_splash:create

echo Flutter project has been reset and updated.
pause
