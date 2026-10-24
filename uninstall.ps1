<#
    dsh-boot-two-act · 卸载脚本
    摘掉两条 patch 行和两个目录联接；plugins/ 下的目录默认保留。
#>
param(
  [string]$DshHome = '',
  [string]$ProfileName = 'desktop',
  [switch]$Purge
)

$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding($false)

if ([string]::IsNullOrWhiteSpace($DshHome)) {
  if ($env:DSH_HOME) { $DshHome = $env:DSH_HOME } else { $DshHome = Join-Path $env:USERPROFILE '.dsh' }
}
$profileDir = Join-Path (Join-Path $DshHome 'profiles') $ProfileName
if (-not (Test-Path $profileDir)) { Write-Host "没有 profile '$ProfileName'"; exit 2 }

$nmDir = Join-Path $profileDir 'node_modules'
$patchFile = Join-Path $profileDir 'cordis.patch.yml'
$ids = @('dsh-startup-screen', 'boot-splash')

foreach ($id in $ids) {
  $link = Join-Path $nmDir $id
  if (Test-Path $link) { cmd /c rmdir "$link" | Out-Null; Write-Host "已断开 $id" }
}

if (Test-Path $patchFile) {
  Copy-Item $patchFile "$patchFile.bak-$(Get-Date -Format yyyyMMdd-HHmmss)" -Force
  $raw = [System.IO.File]::ReadAllText($patchFile, $utf8)
  $eol = if ($raw.Contains("`r`n")) { "`r`n" } else { "`n" }
  $lines = New-Object System.Collections.Generic.List[string]
  $raw -split "`r?`n" | ForEach-Object { $lines.Add($_) }
  $removed = 0
  for ($i = $lines.Count - 1; $i -ge 0; $i--) {
    foreach ($id in $ids) {
      if ($lines[$i] -match ('^\s*-\s*id:\s*' + [regex]::Escape($id) + '\s*$')) {
        $start = $i
        if ($start -ge 1 -and $lines[$start - 1].Trim() -eq '- insert:') { $start-- }
        $end = $i
        while ($end + 1 -lt $lines.Count -and $lines[$end + 1] -match '^\s+name:') { $end++ }
        $lines.RemoveRange($start, $end - $start + 1)
        $removed++
      }
    }
  }
  $out = ($lines -join $eol)
  [System.IO.File]::WriteAllText($patchFile, $out, $utf8)
  Write-Host "已摘掉 $removed 条配置"
}

if ($Purge) {
  foreach ($id in $ids) {
    $p = Join-Path (Join-Path $DshHome 'plugins') $id
    if (Test-Path $p) { Remove-Item $p -Recurse -Force; Write-Host "已删除 $p" }
  }
}

Write-Host '完成。完全退出并重开 DeepSeek Harness 生效。'
