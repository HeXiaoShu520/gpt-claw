@echo off
cd /d "%~dp0"
call npm run start
if errorlevel 1 (
  echo.
  echo gpt-claw failed to start. See the error above.
  pause
)
