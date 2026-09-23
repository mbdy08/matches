@echo off
cd /d "%~dp0"
chcp 65001 > nul

echo ======================================================
echo [1/3] جاري فحص وتشفير جميع روابط المباريات...
echo ======================================================

powershell -NoProfile -ExecutionPolicy Bypass -Command "$key = 'TheLawyerDaughter'; $kBytes = [System.Text.Encoding]::UTF8.GetBytes($key); $file = 'matches.json'; if (-not (Test-Path $file)) { Write-Host 'Error: matches.json not found!' -ForegroundColor Red; exit }; $content = Get-Content -Path $file -Raw -Encoding UTF8; $json = $content | ConvertFrom-Json; $arr = @($json); foreach ($m in $arr) { if ($m.streamUrl -and $m.streamUrl.StartsWith('http')) { $uBytes = [System.Text.Encoding]::UTF8.GetBytes($m.streamUrl); $encBytes = New-Object byte[] $uBytes.Length; for ($i = 0; $i -lt $uBytes.Length; $i++) { $encBytes[$i] = $uBytes[$i] -bxor $kBytes[$i %% $kBytes.Length] }; $m.streamUrl = 'ENC_' + [Convert]::ToBase64String($encBytes); Write-Host ('[+] تم تشفير مباراة: ' + $m.homeTeam + ' vs ' + $m.awayTeam) -ForegroundColor Green; } }; $json | ConvertTo-Json -Depth 5 | Set-Content -Path $file -Encoding UTF8; Write-Host '[✓] اكتمل تشفير كافة الروابط بنجاح!' -ForegroundColor Green;"

echo.
echo ======================================================
echo [2/3] جاري رفع التحديث المشفر إلى GitHub...
echo ======================================================
git add matches.json
git commit -m "Auto Encrypt Matches"
git push origin main

echo.
echo ======================================================
echo [3/3] تم كل شيء بنجاح! الروابط مشفرة والملف مرفوع.
echo ======================================================
pause