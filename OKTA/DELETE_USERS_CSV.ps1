# 讀取原始的 user.csv 檔案
$userData = Import-Csv -Path "user.csv"

# 根據符合條件的 user_id 刪除對應的資料
$usersNew = $userData | Where-Object { $matchedUserIds -notcontains $_.user_id }

# 存儲新的 users_new.csv 檔案
$usersNew | Export-Csv -Path "users_new.csv" -NoTypeInformation
