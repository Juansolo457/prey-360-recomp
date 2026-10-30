# Extract your own Prey disc image into port/assets (the game partition, about
# 4.3 GB: default.xex, Base/Paks, Base/Stream, Base/video). Never committed. The ISO is only read.
#   pwsh -NoProfile -File tools/extract.ps1 -Iso 'D:\path\to\prey.iso'
[CmdletBinding()]
param([Parameter(Mandatory)][string]$Iso)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$assets = Join-Path $root 'port\assets'
New-Item -ItemType Directory -Force $assets | Out-Null
python -I (Join-Path $PSScriptRoot 'xdvdfs.py') $Iso extract $assets
if ($LASTEXITCODE) { throw 'Extraction failed.' }
python -I (Join-Path $PSScriptRoot 'xexinfo.py') (Join-Path $assets 'default.xex')
"default.xex SHA-256 " + (Get-FileHash (Join-Path $assets 'default.xex') -Algorithm SHA256).Hash.ToLowerInvariant()
