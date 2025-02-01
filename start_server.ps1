. (Join-Path $PSScriptRoot "sync.ps1")
$config = Import-PowerShellDataFile $(Join-Path $PSScriptRoot "config.psd1")

$Dir = [System.IO.Path]::Combine($PSScriptRoot, $config.LocalDir)

if (Get-HostLock $config.RemoteDir -RclonePath $config.RclonePath) {
	Write-Host "Host lock found in remote directory. Aborting startup."
	return
}
Write-Host "Creating host lock..."
Set-HostLock $config.RemoteDir $config.HostName $config.HostAddress -RclonePath $config.RclonePath

Write-Host "Pulling files..."
Sync-Pull $Dir $config.RemoteDir -RclonePath $config.RclonePath

Write-Host "Starting server..."
Invoke-Expression $config.StartServerCommand

Write-Host "Pushing files..."
Sync-Push $Dir $config.RemoteDir -RclonePath $config.RclonePath

Write-Host "Removing host lock..."
Remove-HostLock $config.RemoteDir -RclonePath $config.RclonePath
