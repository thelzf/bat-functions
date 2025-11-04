@echo off
:: Thelzf Bat - Menu de Ferramentas do Windows (com verificação e decodificação robusta)
:: Salve como windows_toolbox_menu.bat e execute (clique direito → Executar como administrador para algumas ações)

title Thelzf Bat
cls

:: Base64 de: https://github.com/thelzf/bat-functions
set "OBF=aHR0cHM6Ly9naXRodWIuY29tL3RoZWx6Zi9iYXQtZnVuY3Rpb25z"

set "SUB="

:: 1) Tentar decodificar via PowerShell
for /f "delims=" %%S in ('powershell -NoProfile -Command "try { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('%OBF%')) } catch { Write-Error 'PS decode failed'; exit 1 }" 2^>nul') do set "SUB=%%S"

:: 2) Se falhar, tentar via certutil
if "%SUB%"=="" (
    set "B64=%TEMP%\b64_obf.txt"
    set "OUT=%TEMP%\b64_out.txt"
    >"%B64%" echo %OBF%
    certutil -decode "%B64%" "%OUT%" >nul 2>&1
    if exist "%OUT%" (
        setlocal enabledelayedexpansion
        set "LINE="
        for /f "usebackq delims=" %%L in ("%OUT%") do (
            if defined LINE (
                set "LINE=!LINE!%%L"
            ) else (
                set "LINE=%%L"
            )
        )
        endlocal & set "SUB=%LINE%"
        del "%B64%" >nul 2>&1
        del "%OUT%" >nul 2>&1
    )
)

set "EXPECTED=https://github.com/thelzf/bat-functions"

if "%SUB%"=="" (
    echo.
    echo ERRO: Falha ao decodificar o subtítulo via PowerShell ou certutil.
    echo Motivos possíveis:
    echo  - PowerShell bloqueado por política.
    echo  - Certutil ausente ou sem permissões.
    echo  - Problemas de escrita no diretório TEMP.
    echo.
    echo Depuração:
    echo OBF: %OBF%
    echo ESPERADO: %EXPECTED%
    echo.
    echo Teste PowerShell com: powershell -NoProfile -Command "Write-Output 'hello'"
    echo Teste certutil com: certutil -?
    echo.
    echo O script será encerrado. Pressione qualquer tecla para sair...
    pause >nul
    exit /b 1
)

if /i not "%SUB%"=="%EXPECTED%" (
    echo.
    echo ERRO: Verificação do subtítulo falhou.
    echo Esperado: %EXPECTED%
    echo Encontrado: %SUB%
    echo.
    echo O script será bloqueado para evitar modificações acidentais.
    attrib +r "%~f0" >nul 2>&1
    echo %date% %time% - Falha de verificação: esperado %EXPECTED% encontrado %SUB%>>"%~dp0verification_fail.log"
    echo Log salvo em: "%~dp0verification_fail.log"
    echo Pressione qualquer tecla para sair...
    pause >nul
    exit /b 1
)

echo ===============================
echo Thelzf Bat
echo -------------------------------
echo Subtítulo: %SUB%
echo ===============================
echo.

:menu
cls
echo ===============================
echo 🧰 Menu de Ferramentas do Windows
echo ===============================
echo 1. Limpar arquivos temporários (pasta Temp)
echo 2. Abrir programas (Chrome, Explorador, Word, Excel, PowerPoint)
echo 3. Desligar o computador
echo 4. Troll: Criar 10.000 pastas na área de trabalho (CONFIRMAÇÃO)
echo 5. Alternar ícones da área de trabalho (mostrar/ocultar)
echo 6. Outras utilidades (Prompt, reiniciar Explorer)
echo 0. Sair
echo ===============================
set /p escolha=Escolha uma opção:
if "%escolha%"=="1" goto limpar_temp
if "%escolha%"=="2" goto abrir_programas
if "%escolha%"=="3" goto desligar_pc
if "%escolha%"=="4" goto troll_pastas
if "%escolha%"=="5" goto alternar_icones
if "%escolha%"=="6" goto outras_utils
if "%escolha%"=="0" goto fim
echo Opção inválida. Pressione qualquer tecla para tentar novamente...
pause >nul
goto menu

:limpar_temp
cls
echo *** Limpar Arquivos Temporários ***
echo Esta opção apagará os arquivos dentro da pasta TEMP: %TEMP%
set /p confirm=Tem certeza? Digite SIM para confirmar:
if /i not "%confirm%"=="SIM" (
    echo Operação cancelada. Voltando ao menu...
    timeout /t 2 >nul
    goto menu
)
echo Apagando arquivos temporários...
del /q /f "%TEMP%\*" 2>nul
for /d %%D in ("%TEMP%\*") do rd /s /q "%%D" 2>nul
echo Concluído.
pause >nul
goto menu

:abrir_programas
cls
echo *** Abrir Programas ***
echo 1. Google Chrome
echo 2. Explorador de Arquivos
echo 3. Microsoft Word
echo 4. Microsoft Excel
echo 5. Microsoft PowerPoint
echo 6. Abrir todos os acima
echo 0. Voltar
set /p p=Escolha:
if "%p%"=="1" start "" chrome.exe & goto aberto
if "%p%"=="2" start "" explorer.exe & goto aberto
if "%p%"=="3" start "" winword.exe & goto aberto
if "%p%"=="4" start "" excel.exe & goto aberto
if "%p%"=="5" start "" powerpnt.exe & goto aberto
if "%p%"=="6" start "" chrome.exe & start "" explorer.exe & start "" winword.exe & start "" excel.exe & start "" powerpnt.exe & goto aberto
if "%p%"=="0" goto menu
echo Erro: não foi possível abrir o programa. Verifique se está instalado.
pause >nul
goto abrir_programas

:aberto
echo Programa(s) iniciado(s). Voltando ao menu...
timeout /t 1 >nul
goto menu

:desligar_pc
cls
echo *** Desligar Computador ***
echo Isso desligará o computador.
set /p confirm=Digite DESLIGAR para confirmar:
if /i not "%confirm%"=="DESLIGAR" (
    echo Cancelado. Voltando ao menu...
    timeout /t 2 >nul
    goto menu
)
echo Desligando em 10 segundos... Pressione Ctrl+C para cancelar.
shutdown /s /t 10
goto menu

:troll_pastas
cls
echo *** Troll: Criar Pastas na Área de Trabalho ***
echo AVISO: Isso criará muitas pastas e pode deixar o sistema lento.
set /p confirm=Digite CRIAR para confirmar:
if /i not "%confirm%"=="CRIAR" (
    echo Cancelado. Voltando ao menu...
    timeout /t 2 >nul
    goto menu
)
set "DESKTOP=%USERPROFILE%\Desktop"
echo Quantas pastas deseja criar? (padrão: 10000)
set /p qtd=Quantidade:
if "%qtd%"=="" set qtd=10000
echo Criando %qtd% pastas em %DESKTOP% ...
for /l %%i in (1,1,%qtd%) do (
    md "%DESKTOP%\troll_%%i" 2>nul
)
echo Concluído: %qtd% pastas criadas.
pause >nul
goto menu

:alternar_icones
cls
echo *** Alternar Ícones da Área de Trabalho ***
echo Isso vai mostrar ou ocultar os ícones. O Explorer será reiniciado.
set /p confirm=Digite ALTERAR para confirmar:
if /i not "%confirm%"=="ALTERAR" (
    echo Cancelado. Voltando ao menu...
    timeout /t 2 >nul
    goto menu
)
echo Lendo configuração atual...
for /f "tokens=2*" %%A in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideIcons 2^>nul') do set cur=%%B
if "%cur%"=="0x1" (
    echo Ícones ocultos → mostrando (valor 0)
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideIcons /t REG_DWORD /d 0 /f >nul 2>&1
) else (
    echo Ícones visíveis → ocultando (valor 1)
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideIcons /t REG_DWORD /d 1 /f >nul 2>&1
)
echo Reiniciando o Explorer...
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe
echo Concluído.
pause >nul
goto menu

:outras_utils
cls
echo *** Outras Utilidades ***
echo 1. Abrir Prompt de Comando
echo 2. Reiniciar o Explorer
echo 0. Voltar
set /p o=Escolha:
if "%o%"=="1" start cmd.exe & goto menu
if "%o%"=="2" (
    echo Reiniciando Explorer...
    taskkill /f /im explorer.exe >nul 2>&1
    start explorer.exe
    echo Concluído.
    pause >nul
    goto menu
)
echo Opção inválida. Voltando ao menu...
timeout /t 1 >nul
goto menu

:fim
echo Até mais!
exit /b 0
