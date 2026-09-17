@echo off
chcp 65001 >nul
setlocal
rem ============================================================
rem  music-zhuanhuan launcher for Windows (web UI / CLI)
rem
rem    double-click this file    start the web UI, opens http://127.0.0.1:8686
rem    run.bat web               same; also accepts --port 9000 / --no-browser
rem    run.bat FILE             CLI mode, e.g. run.bat song.ncm -o out --format flac
rem
rem  Keep every "rem" line ASCII-only. cmd parses batch comments too, and
rem  non-ASCII text (or a stray angle bracket / pipe) there makes it emit
rem  bogus "not recognized as an internal or external command" errors.
rem  All user-facing messages below are Chinese and safe inside echo.
rem ============================================================
cd /d "%~dp0"

rem keep the console window open when launched by double-click (no args)
if "%~1"=="" (set "PAUSE_AT_END=1") else (set "PAUSE_AT_END=")

rem first run: create the virtualenv and install dependencies
if not exist ".venv\Scripts\python.exe" (
  echo [music-zhuanhuan] 首次运行：创建虚拟环境并安装依赖，请稍候...
  where py >nul 2>nul && (py -3 -m venv .venv) || (python -m venv .venv)
  if not exist ".venv\Scripts\python.exe" (
    echo.
    echo [music-zhuanhuan] 创建虚拟环境失败：未找到可用的 Python。
    echo 请先安装 Python 3.10+，安装时勾选 Add Python to PATH，然后重新双击本文件。
    pause
    exit /b 1
  )
  ".venv\Scripts\pip" install -q --upgrade pip
  ".venv\Scripts\pip" install -q -r requirements.txt
  if errorlevel 1 (
    echo.
    echo [music-zhuanhuan] 依赖安装失败：请检查网络连接后重新双击本文件。
    pause
    exit /b 1
  )
)

rem no args (double-click) or "web" subcommand: web UI. anything else: CLI
if "%~1"=="" goto web
if /i "%~1"=="web" goto web
goto cli

:web
rem cmd's "shift" does NOT modify the whole argument string, so strip the leading
rem otherwise it gets passed to server.py and argparse exits with an error.
set "WEBARGS=%*"
if /i "%~1"=="web" set "WEBARGS=%WEBARGS:~3%"
echo [music-zhuanhuan] 正在启动网页版，浏览器将自动打开 http://127.0.0.1:8686 ...
echo [music-zhuanhuan] 转换期间请不要关闭本窗口；关闭窗口即停止服务。
echo.
".venv\Scripts\python" web\server.py %WEBARGS%
set "RC=%ERRORLEVEL%"
echo.
echo [music-zhuanhuan] 网页版已停止。
if defined PAUSE_AT_END pause
exit /b %RC%

:cli
".venv\Scripts\python" unlocker.py %*
set "RC=%ERRORLEVEL%"
if defined PAUSE_AT_END (
  echo.
  pause
)
exit /b %RC%
