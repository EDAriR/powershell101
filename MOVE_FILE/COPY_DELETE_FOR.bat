@echo off
REM 設定路徑一、路徑二、路徑三
set "Path1=D:\work_space1"
set "Path2=D:\work_space2"
set "Path3=D:\work_space3"

REM 設定今天日期字串 (yyyyMMdd)
set "todayDate=%DATE:/=%"

REM 設定上週日期字串 (yyyyMMdd)，値為今天日期減 7 天
set "lastWeekDate=%date:~0,4%%date:~4,2%%date:~6,2%"
set /a lastWeekDate=lastWeekDate-7

REM 迴圈處理路徑一，取出 okta_ 開頭且 .csv 結尾的檔案
for %%I in ("%Path1%\okta_*.csv") do (
    set "fileName=%%~nxI"
    set "fileDate=!fileName:okta_=!"
    set "fileDate=!fileDate:.csv=!"

    REM 判斷檔案中的日期 (yyyyMMdd) 是否小於上週日期字串
    if !fileDate! lss %lastWeekDate% (
        echo %%I 的日期為 !fileDate!，小於上週日期 %lastWeekDate%，將被刪除。
        del "%%I"
    )
)
