@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

title 英雄无敌7.5MOD更新中文文件安装工具
color 0A

echo ========================================
echo     英雄无敌7.5MOD更新中文文件安装工具
echo ========================================
echo.

:: 4. 首先检查批处理文件所在目录的源文件夹（提前检查）
set "SourceFolder=%~dp0Might & Magic Heroes VII"

if not exist "%SourceFolder%\" (
    echo 错误：未找到源文件夹！
    echo 请确保批处理文件同级目录下存在 "Might & Magic Heroes VII" 文件夹
    echo 当前目录：%~dp0
    echo.
    pause
    exit /b 1
)

echo 中文源文件存在："%SourceFolder%"
echo.

:: 1. 通过注册表获取文档文件夹路径
set "MyGamesPath="
echo 正在查询文档文件夹位置...

:: 方法1：查询注册表获取文档文件夹路径
set "docpath="
for /f "tokens=2*" %%i in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Personal 2^>nul') do (
    set "docpath=%%j"
)

if defined docpath (
    :: 替换环境变量
    call set "docpath=%%docpath%%"
    
    :: 检查是否包含"My Games"文件夹
    set "MyGamesPath=!docpath!\My Games"
    
    if not exist "!MyGamesPath!\" (
        echo 警告：注册表路径未找到My Games文件夹：!MyGamesPath!
        set "MyGamesPath="
    )
)

:: 方法2：如果注册表方法失败，尝试常见路径
if not defined MyGamesPath (
    echo 正在尝试常见路径...
    
    set "paths[0]=%USERPROFILE%\Documents\My Games"
    set "paths[1]=%USERPROFILE%\我的文档\My Games"
    set "paths[2]=%PUBLIC%\Documents\My Games"
    set "paths[3]=%OneDrive%\Documents\My Games"
    set "paths[4]=%OneDrive%\我的文档\My Games"
    
    for /l %%i in (0,1,4) do (
        if not defined MyGamesPath (
            set "testpath=!paths[%%i]!"
            call :CheckPath "!testpath!" MyGamesPath
        )
    )
)

:: 方法3：如果还没找到，让用户手动输入
if not defined MyGamesPath (
    echo.
    echo 无法自动找到My Games文件夹！
    echo.
    echo 请手动输入您的My Games文件夹完整路径：
    echo 例如：D:\我的文档\My Games 或 C:\Users\用户名\Documents\My Games
    echo.
    set /p "MyGamesPath=请输入："
    
    :: 移除可能的引号
    set "MyGamesPath=!MyGamesPath:"=!"
    
    if not exist "!MyGamesPath!\" (
        echo.
        echo 错误：输入的路径不存在！
        echo 请检查路径是否正确。
        pause
        exit /b 1
    )
)

echo.
echo 使用My Games文件夹：%MyGamesPath%
echo.

:: 2. 检查目标文件夹是否存在（使用引号避免特殊字符问题）
set "TargetFolderPart1=%MyGamesPath%\Might & Magic Heroes VII"
set "TargetFolder=%TargetFolderPart1%\MMH7Game\Localization\Content\INT"

if not exist "%TargetFolder%\" (
    echo 错误：未找到目标文件夹！
    echo.
    echo 请先安装英雄无敌7.5MOD！
    echo.
    echo 确保路径存在：
    echo %TargetFolder%
    echo.
    pause
    exit /b 1
)

echo 正在检查并清理过期的旧中文文件...
echo.

:: 3. 删除三个目标文件夹（使用引号避免特殊字符问题）
set "BasePath=%MyGamesPath%\Might & Magic Heroes VII"
set "Folder1=%BasePath%\MMH7Game\Localization\Content\CHN"
set "Folder2=%BasePath%\MMH7Game\Localization\General\CHN"
set "Folder3=%BasePath%\MMH7Game\Localization\Maps\CHN"

set "DeletedCount=0"

:: 使用延迟变量和引号处理路径
if exist "!Folder1!\" (
    echo 正在删除：!Folder1!
    rd /s /q "!Folder1!" 2>nul
    if not exist "!Folder1!\" (
        echo    ✓ 删除成功
        set /a DeletedCount+=1
    ) else (
        echo    ✗ 删除失败
    )
) else (
    echo 文件夹不存在：!Folder1!
)

if exist "!Folder2!\" (
    echo 正在删除：!Folder2!
    rd /s /q "!Folder2!" 2>nul
    if not exist "!Folder2!\" (
        echo    ✓ 删除成功
        set /a DeletedCount+=1
    ) else (
        echo    ✗ 删除失败
    )
) else (
    echo 文件夹不存在：!Folder2!
)

if exist "!Folder3!\" (
    echo 正在删除：!Folder3!
    rd /s /q "!Folder3!" 2>nul
    if not exist "!Folder3!\" (
        echo    ✓ 删除成功
        set /a DeletedCount+=1
    ) else (
        echo    ✗ 删除失败
    )
) else (
    echo 文件夹不存在：!Folder3!
)

echo.
echo 已成功删除 %DeletedCount% 个文件夹
echo.

echo 正在复制新文件...
echo 从："%SourceFolder%"
echo 到："%MyGamesPath%"
echo.

:: 使用robocopy（Windows Vista及以上）或xcopy
echo 正在复制文件，请稍候...

:: 首先确保目标父目录存在
if not exist "%BasePath%\" mkdir "%BasePath%"

robocopy "%SourceFolder%" "%BasePath%" /E /COPY:DAT /R:3 /W:5 /NP /NFL /NDL 1>nul

if errorlevel 8 (
    echo 错误：文件复制失败！
    echo 请检查文件夹权限或磁盘空间
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================
echo     更新安装中文文件完成！
echo ========================================
echo.
echo 操作已完成，请按任意键退出...
pause
goto :eof

:: 检查路径存在的子程序
:CheckPath
setlocal enabledelayedexpansion
set "check_path=%~1"
call set "check_path=%%check_path%%"
if exist "!check_path!\" (
    endlocal
    set "%~2=%~1"
    exit /b 0
) else (
    endlocal
    exit /b 1
)