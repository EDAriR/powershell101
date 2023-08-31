# 取得今天日期字串，格式為 yyyyMMdd
$todayDate = Get-Date -Format "yyyyMMdd"

# 路徑1，D:\work_space\
$path1 = "D:\work_space\"

# 路徑2，D:\work_space2\
$path2 = "D:\work_space2\"

# 路徑3，D:\work_space3\
$path3 = "D:\work_space3\"

# 檢查路徑1底下的檔案，刪除日期大於今天的檔案
Get-ChildItem -Path $path1 -Filter "okta_g_*.csv" | ForEach-Object {
    $fileName = $_.Name
    $fileDate = [datetime]::ParseExact($fileName -replace "okta_g_(\d{8}).csv", '$1', $null)
    
    if ($fileDate -lt $todayDate) {
        Remove-Item $_.FullName
        Write-Host "Deleted file: $($file.FullName)"
    }
}

# 複製路徑2底下的 okta_g.csv 到路徑1 和 路徑3，並命名為 okta_g_{今天日期字串}.csv
Copy-Item -Path "$path2\okta_g.csv" -Destination "$path1\okta_g_$todayDate.csv"
Copy-Item -Path "$path2\okta_g.csv" -Destination "$path3\okta_g_$todayDate.csv"
