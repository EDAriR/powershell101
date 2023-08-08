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

# 如果回應中有結果
if ($response.Count -gt 0) {
    # 逐一處理每個符合條件的使用者
    foreach ($user in $response) {
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
} else {
    Write-Host "No users found."
}
