# 設定 OKTA API 端點
$apiEndpoint = "https://your-okta-api-endpoint.com/api/v1/users"

# 設定 OKTA API 的授權憑證，例如使用 API Key 或 Bearer Token
$headers = @{
    "Authorization" = "Bearer your-api-key-or-token"
}

# 設定三個月前的日期
$threeMonthsAgo = (Get-Date).AddMonths(-3)

# 讀取 CSV 檔案
$userData = Import-Csv -Path "user_data.csv"

# 儲存符合條件的 user_id
$matchedUserIds = @()

# 呼叫 API 確認 Last Login 時間是否為空或三個月前
foreach ($user in $userData) {
    $userId = $user.user_id

    try {
        $response = Invoke-RestMethod -Uri "$apiEndpoint/$userId" -Headers $headers -Method Get

        # 取得 Last Login 時間
        $lastLoginTime = [DateTime]::Parse($response.lastLogin)

        # 比較 Last Login 時間是否為空或三個月前
        if ([string]::IsNullOrEmpty($response.lastLogin) -or $lastLoginTime -lt $threeMonthsAgo) {
            $matchedUserIds += $userId
        }
    }
    catch {
        Write-Host "呼叫 API 時發生錯誤：$($_.Exception.Message)"
    }
}

# 列出符合條件的 user_id
Write-Host "符合條件的 user_id："
$matchedUserIds
