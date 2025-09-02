# This script is called by the main update script to perform final cleanup
# It takes the path of the old folder as a parameter

param (
    [string]$OldFolder
)

Write-Host "Tập lệnh dọn dẹp đang chạy..."

# Wait a moment to ensure the old script has exited
Start-Sleep -Seconds 2

# Remove the old project folder
Write-Host "Đang xóa thư mục cũ: $OldFolder"
Remove-Item -Path $OldFolder -Recurse -Force

# Clean up the downloaded zip file from the parent directory
Write-Host "Đang xóa tệp zip..."
Remove-Item "..\latest-release.zip"

Write-Host "Đã hoàn tất dọn dẹp!"

# You can add more cleanup or finalization steps here if needed
