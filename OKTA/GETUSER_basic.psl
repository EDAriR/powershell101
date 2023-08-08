
# 設定 API 端點和使用者 ID
$apiEndpoint = "https://your-okta-api-endpoint.com/api/v1/users"
$userId = "user-id-or-username"

# 設定 OKTA API 的授權憑證，例如使用 API Key 或 Bearer Token
$headers = @{
    "Authorization" = "Bearer your-api-key-or-token"
}

# 呼叫 API
try {
    $response = Invoke-RestMethod -Uri "$apiEndpoint/$userId" -Headers $headers -Method Get

    # 處理 API 回應資料
    $userDetails = $response | ConvertTo-Json
    Write-Host "使用者詳細資料："
    Write-Host $userDetails
}
catch {
    Write-Host "呼叫 API 時發生錯誤：$($_.Exception.Message)"
}
