param (
    [Parameter(Mandatory)]
    [ValidateSet("push", "pull")]
    [String]$Operation
)

. (Join-Path $PSScriptRoot "lib.ps1")
$config = Import-PowerShellDataFile $(Join-Path $PSScriptRoot "config.psd1")

$Dir = [System.IO.Path]::Combine($PSScriptRoot, $config.LocalDir)

switch ($Operation) {
    "push" {
        Write-Host "Pushing files..."
        Sync-Push $Dir $config.RemoteDir -RclonePath $config.RclonePath
    }
    "pull" {
        Write-Host "Pulling files..."
        Sync-Pull $Dir $config.RemoteDir -RclonePath $config.RclonePath
    }
    default {
        Write-Host "Invalid operation."
    }
}
