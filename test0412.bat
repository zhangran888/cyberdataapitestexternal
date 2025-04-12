@echo off
@REM author:zhangran
@REM describe:整合jmx文件，生成报告
chcp 65001
setlocal enabledelayedexpansion

:: 设置 JMeter 的 bin 目录
set JMETER_HOME=..\jmeter-5.4.1
set PATH=%JMETER_HOME%\bin;%PATH%

:: 打印 JMeter 的路径
echo JMeter Home: %JMETER_HOME%
echo JMeter Executable Path: "%JMETER_HOME%\bin\jmeter"

:: 动态传入的参数
set "server_ip=%~1"
set "server_port=%~2"
set "userName=%~3"
set "userPWD=%~4"
set "server_http=%~5"

:: 直接在 userPWD 上拼接 ==
set "userPWD=!userPWD!=="

:: 打印参数以检查
echo Server IP: %server_ip%
echo Port: %server_port%
echo User Name: %userName%
echo User Password: %userPWD%
echo User server_http: %server_http%

:: 检查是否传入了所有参数
if "%server_ip%"=="" (
    echo Error: server_ip parameter is missing.
    exit /b
)
if "%server_port%"=="" (
    echo Error: server_port parameter is missing.
    exit /b
)
if "%userName%"=="" (
    echo Error: userName parameter is missing.
    exit /b
)
if "%userPWD%"=="" (
    echo Error: userPWD parameter is missing.
    exit /b
)
if "%server_http%"=="" (
    echo Error: server_http parameter is missing.
    exit /b
)

:: 定义结果文件和报告目录的路径
set "result_file=.\combined_results.jmx"
set "report_dir=.\combined_report"

:: 删除旧的结果文件和报告目录
if exist "%result_file%" del "%result_file%"
if exist "%report_dir%" rmdir /s /q "%report_dir%"

:: 递归搜索并执行所有 .jmx 文件
for /r %%f in (*.jmx) do (
    echo Found: "%%f"

    :: 执行 JMeter 脚本前替换文件内容
    echo Replacing parameters in "%%f"
    call :replaceArgumentValue "%%f" "server_ip" "%server_ip%" "%server_port%" "%server_http%"
    if errorlevel 1 (
        echo Error replacing server_ip in "%%f"
        exit /b
    )

    echo Replacing parameters in "%%f"
    call :replaceArgumentValue "%%f" "server_port" "%server_port%" "%server_port%" "%server_http%"
    if errorlevel 1 (
        echo Error replacing server_port in "%%f"
        exit /b
    )

    call :replaceArgumentValue "%%f" "userName" "%userName%" "%server_port%" "%server_http%"
    if errorlevel 1 (
        echo Error replacing userName in "%%f"
        exit /b
    )

    call :replaceArgumentValue "%%f" "userPWD" "%userPWD%" "%server_port%" "%server_http%"
    if errorlevel 1 (
        echo Error replacing userPWD in "%%f"
        exit /b
    )
    call :replaceArgumentValue "%%f" "server_http" "%server_http%" "%server_port%" "%server_http%"
    if errorlevel 1 (
        echo Error replacing server_http in "%%f"
        exit /b
    )

    echo Parameters replaced successfully in "%%f"

    :: 执行 JMeter 脚本
    echo Running JMeter script: "%%f"
    call "%JMETER_HOME%\bin\jmeter" -n -t "%%f" -l "%result_file%"
    if errorlevel 1 (
        echo Error running JMeter script: "%%f"
        exit /b
    )
)

:: 生成统一的 HTML 报告
echo Generating combined report...
call "%JMETER_HOME%\bin\jmeter" -g "%result_file%" -o "%report_dir%"

if errorlevel 1 (
    echo Error generating report.
    exit /b
)

echo All JMeter scripts executed and combined report generated successfully.
pause
exit /b

:replaceArgumentValue
:: %1 = 文件名, %2 = 参数名, %3 = 新的值, %4 = 端口值, %5 = http 值
setlocal enabledelayedexpansion
set "inputFile=%~1"
set "paramName=%~2"
set "newValue=%~3"
set "portValue=%~4"
set "httpValue=%~5"

:: 调用 PowerShell 脚本进行替换
echo Replacing %paramName% in "%inputFile%" with new value "!newValue!" and port "!portValue!" and httpValue "!httpValue!"
powershell -NoProfile -ExecutionPolicy Bypass -File "zd0412.ps1" -inputFile "%inputFile%" -paramName "%paramName%" -newValue "!newValue!" -portValue "!portValue!" -httpValue "!httpValue!"

:: 检查替换是否成功
if errorlevel 1 (
    echo Error: PowerShell replacement failed for %paramName% in "%inputFile%"
    exit /b 1
)

echo Successfully replaced %paramName% with "!newValue!" in "%inputFile%"
endlocal
exit /b