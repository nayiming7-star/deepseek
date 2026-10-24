<#
    dsh-boot-two-act · 安装脚本
    把 vendor/ 下两个插件装进 desktop profile，并在两者之间挂上衔接补丁。

    用法：
      powershell -ExecutionPolicy Bypass -File install.ps1
      powershell -ExecutionPolicy Bypass -File install.ps1 -CheckOnly
#>
param(
  [string]$DshHome = '',
  [string]$ProfileName = 'desktop',
  [switch]$CheckOnly
)

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$utf8 = New-Object System.Text.UTF8Encoding($false)
$nl = [Environment]::NewLine

function Say($m) { Write-Host $m }
function Fail($m) { Write-Host "失败：$m" -ForegroundColor Red; exit 2 }

if ([string]::IsNullOrWhiteSpace($DshHome)) {
  if ($env:DSH_HOME) { $DshHome = $env:DSH_HOME } else { $DshHome = Join-Path $env:USERPROFILE '.dsh' }
}
if (-not (Test-Path $DshHome)) { Fail "找不到 DSH 目录：$DshHome" }

$profileDir = Join-Path (Join-Path $DshHome 'profiles') $ProfileName
if (-not (Test-Path $profileDir)) {
  $known = @()
  $root = Join-Path $DshHome 'profiles'
  if (Test-Path $root) { $known = Get-ChildItem $root -Directory | Select-Object -ExpandProperty Name }
  Fail "没有 profile '$ProfileName'。现有：$($known -join ', ')"
}

$pluginsDir = Join-Path $DshHome 'plugins'
$nmDir = Join-Path $profileDir 'node_modules'
$patchFile = Join-Path $profileDir 'cordis.patch.yml'

Say "DSH      : $DshHome"
Say "profile  : $profileDir"
Say "仓库     : $here"
Say ''

$jobs = @(
  @{ Name = 'dsh-startup-screen'; Src = Join-Path $here 'vendor\dsh-startup-screen'; Id = 'dsh-startup-screen' },
  @{ Name = 'boot-splash';        Src = Join-Path $here 'vendor\boot-splash';        Id = 'boot-splash' }
)

foreach ($j in $jobs) { if (-not (Test-Path $j.Src)) { Fail "缺少 $($j.Src)" } }

if ($CheckOnly) {
  foreach ($j in $jobs) { Say "[dry-run] 会复制 $($j.Src) -> $(Join-Path $pluginsDir $j.Name)" }
  Say "[dry-run] 会建联接 $nmDir\<name> -> $pluginsDir\<name>"
  Say "[dry-run] 会往 $patchFile 追加两条 insert（若不存在）"
  exit 0
}

# 1) 复制插件本体
New-Item -ItemType Directory -Force -Path $pluginsDir | Out-Null
foreach ($j in $jobs) {
  $dst = Join-Path $pluginsDir $j.Name
  if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
  Copy-Item $j.Src $dst -Recurse -Force
  Say "已复制  $($j.Name)"
}

# 2) 建目录联接
New-Item -ItemType Directory -Force -Path $nmDir | Out-Null
foreach ($j in $jobs) {
  $link = Join-Path $nmDir $j.Name
  if (Test-Path $link) { cmd /c rmdir "$link" | Out-Null }
  New-Item -ItemType Junction -Path $link -Target (Join-Path $pluginsDir $j.Name) -Force | Out-Null
  Say "已联接  $($j.Name)"
}

# 3) 追加 patch 行
if (-not (Test-Path $patchFile)) { Set-Content -Path $patchFile -Value '' -NoNewline -Encoding ascii }
$bak = "$patchFile.bak-$(Get-Date -Format yyyyMMdd-HHmmss)"
Copy-Item $patchFile $bak -Force
Say "已备份  $bak"

$raw = [System.IO.File]::ReadAllText($patchFile, $utf8)
$eol = if ($raw.Contains("`r`n")) { "`r`n" } else { "`n" }
$added = @()
foreach ($j in $jobs) {
  if ($raw -match [regex]::Escape($j.Id)) { continue }
  $block = '- insert:' + $eol + '    - id: ' + $j.Id + $eol + '      name: ' + $j.Name + $eol
  if ($raw.Length -gt 0 -and -not $raw.EndsWith("`n")) { $raw += $eol }
  $raw += $block
  $added += $j.Id
}
[System.IO.File]::WriteAllText($patchFile, $raw, $utf8)
if ($added.Count -gt 0) { Say "已追加  $($added -join ', ')" } else { Say "配置里已有这两条，跳过" }

Say ''
Say '装好了。现在完全退出 DeepSeek Harness（窗口 + 托盘），再重新打开。'
Say '开机顺序：黑幕 → 五步授权 → 揭幕 → 全屏短片 → 溶解进聊天。'
Say ''
Say "卸载：powershell -ExecutionPolicy Bypass -File $(Join-Path $here 'uninstall.ps1')"
