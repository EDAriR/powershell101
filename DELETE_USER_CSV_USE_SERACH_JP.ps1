DELETE_USER_CSV_USE_SERACH.ps1# OKTA API の関連パラメータを設定します
$apiBaseUrl = "https://your-okta-api-base-url.com/api/v1"
$apiToken = "your-okta-api-token"

# 検索条件を設定します
$currentTime = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
$threeMonthsAgo = (Get-Date).AddMonths(-3).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
$searchQuery = "status eq 'STAGED' and (lastLogin lt '$currentTime' and activated lt '$threeMonthsAgo')"

# API リクエストのヘッダーを設定します
$headers = @{
    "Authorization" = "SSWS $apiToken"
    "Content-Type" = "application/json"
}

# API リクエストを送信して検索を実行します
$url = "$apiBaseUrl/users?q=$searchQuery"
$response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get

# 条件に一致するユーザーの ID を配列に保存します
$matchedUserIds = @()
foreach ($user in $response) {
    $matchedUserIds += $user.id
    Write-Host "ユーザー ID: $($user.id)"
    Write-Host "ユーザープロファイル:"
    Write-Host "   名前: $($user.profile.firstName)"
    Write-Host "   苗字: $($user.profile.lastName)"
    Write-Host "   メール: $($user.profile.email)"
    Write-Host "   部門: $($user.profile.department)"
    Write-Host "   最終ログイン: $($user.lastLogin)"
    Write-Host "   アクティベート日時: $($user.activated)"
    Write-Host "-----------------------------"
}

# user.csv ファイルを読み込みます
$usersData = Import-Csv -Path "user.csv"

# 条件に一致するユーザーの ID と user.csv の ID を比較し、差異を見つけます
$usersToDelete = Compare-Object -ReferenceObject $usersData.user_id -DifferenceObject $matchedUserIds | Where-Object { $_.SideIndicator -eq "<=" }

# user.csv から条件に一致するユーザーのデータを削除します
foreach ($userToDelete in $usersToDelete) {
    $usersData = $usersData | Where-Object { $_.user_id -ne $userToDelete.InputObject }
}

# 新しい users_new.csv ファイルに結果を保存します
$usersData | Export-Csv -Path "users_new.csv" -NoTypeInformation
