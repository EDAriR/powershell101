# 設定 OKTA API 相關參數
$apiBaseUrl = "https://your-okta-api-base-url.com/api/v1"
$apiToken = "your-okta-api-token"

# 設定查詢參數
$currentTime = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
$threeMonthsAgo = (Get-Date).AddMonths(-3).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
$searchQuery = "status eq 'STAGED' and (lastLogin lt '$currentTime' and activated lt '$threeMonthsAgo')"

# 設定 API 請求標頭
$headers = @{
    "Authorization" = "SSWS $apiToken"
    "Content-Type" = "application/json"
}

# 發送 API 請求進行搜尋
$url = "$apiBaseUrl/users?q=$searchQuery"
$response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get

# 儲存符合條件的使用者 ID 到陣列
$matchedUserIds = @()
foreach ($user in $response) {
    $matchedUserIds += $user.id
    Write-Host "User ID: $($user.id)"
    Write-Host "User Profile:"
    Write-Host "   First Name: $($user.profile.firstName)"
    Write-Host "   Last Name: $($user.profile.lastName)"
    Write-Host "   Email: $($user.profile.email)"
    Write-Host "   Department: $($user.profile.department)"
    Write-Host "   Last Login: $($user.lastLogin)"
    Write-Host "   Activated: $($user.activated)"
    Write-Host "-----------------------------"
}

# 載入 user.csv 檔案
$usersData = Import-Csv -Path "user.csv"

# 比較符合條件的使用者 ID 和 user.csv 中的 ID，找出差異
$usersToDelete = Compare-Object -ReferenceObject $usersData.user_id -DifferenceObject $matchedUserIds | Where-Object { $_.SideIndicator -eq "<=" }

# 從 user.csv 移除符合條件的使用者資料
foreach ($userToDelete in $usersToDelete) {
    $usersData = $usersData | Where-Object { $_.user_id -ne $userToDelete.InputObject }
}

# 儲存新的 users_new.csv 檔案
$usersData | Export-Csv -Path "users_new.csv" -NoTypeInformation
