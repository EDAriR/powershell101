@echo off

REM 取得今天日期字串，格式為 yyyyMMdd
for /f "delims=" %%a in ('powershell -command "Get-Date -Format 'yyyyMMdd'"') do set "todayDate=%%a"

REM 路徑1，D:\work_space\
set "path1=D:\work_space\"

REM 路徑2，D:\work_space2\
set "path2=D:\work_space2\"

REM 路徑3，D:\work_space3\
set "path3=D:\work_space3\"

REM 檢查路徑1底下的檔案，刪除日期大於今天的檔案
for %%f in ("%path1%\okta_g_*.csv") do (
    set "fileName=%%~nxf"
    set "fileDate=%%~nf"
    set "fileDate=!fileDate:~8,8!"

    if !fileDate! lss %todayDate% (
        echo Deleted file: %%f
        del "%%f"
    )
)

REM 複製路徑2底下的 okta_g.csv 到路徑1 和 路徑3，並命名為 okta_g_{今天日期字串}.csv
copy "%path2%\okta_g.csv" "%path1%\okta_g_%todayDate%.csv"
copy "%path2%\okta_g.csv" "%path3%\okta_g_%todayDate%.csv"
