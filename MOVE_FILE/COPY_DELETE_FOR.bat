@echo off
REM 設定路徑一、路徑二、路徑三
set "Path1=D:\work_space1"
set "Path2=D:\work_space2"
set "Path3=D:\work_space3"

REM 今日の日付文字列を設定 (yyyyMMdd)
set "todayDate=%DATE:/=%"

REM 今日から7日前の日付文字列を設定 (yyyyMMdd)
set "lastWeekDate=%date:~0,4%%date:~4,2%%date:~6,2%"
set /a lastWeekDate=lastWeekDate-7

REM ファイルの存在を判定する
if exist "%Path2%\flag.flg" (
    del "%Path2%\flag.flg"
    echo "delete flag.flg success。"
) else (
    echo 檔案不存在。
)

REM パス2をループ処理し、okta_ で始まり .csv で終わるファイルを取得する
for %%I in ("%Path2%\okta_*.csv") do (
    set "fileName=%%~nxI"
    set "fileDate=!fileName:okta_=!"
    set "fileDate=!fileDate:.csv=!"

    REM ファイル内の日付（yyyyMMdd形式）が先週の日付文字列より小さいかどうかを判定する
    if !fileDate! lss %lastWeekDate% (
        echo %%Iの日付は !fileDate! で、先週の日付よりも古いため、削除されます。
        del "%%I"
    )
)

echo true > %Path2%\flag.flg

