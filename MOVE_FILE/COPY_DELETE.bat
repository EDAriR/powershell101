@echo off

REM 現在の日付を取得し、/ を削除してyyyyMMdd形式に整形
set "todayDate=%DATE:/=%"

REM パス1の処理
for %%I in (D:\work_space\okta_g_*.csv) do (
    set "fileName=%%~nxI"
    set "fileDate=!fileName:okta_g_=!"
    set "fileDate=!fileDate:.csv=!"

    REM 日付が今日より過去の場合、ファイルを削除
    if !fileDate! lss %todayDate% (
        del "%%I"
        echo %%I を削除しました。
    )
)

REM パス2からファイルをコピー
copy "D:\work_space2\okta_g.csv" "D:\work_space\okta_g_%todayDate%.csv"
echo D:\work_space2\okta_g.csv を D:\work_space\ にコピーしました。

REM パス2からファイルをコピー（別のディレクトリ）
copy "D:\work_space2\okta_g.csv" "D:\work_space3\okta_g_%todayDate%.csv"
echo D:\work_space2\okta_g.csv を D:\work_space3\ にコピーしました。
