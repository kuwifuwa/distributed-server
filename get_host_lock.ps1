param (
	[switch]$Delete
)

. (Join-Path $PSScriptRoot "sync.ps1")
$config = Import-PowerShellDataFile $(Join-Path $PSScriptRoot "config.psd1")

Write-Host "Getting host lock file..."
$hostLock = Get-HostLock $config.RemoteDir -rclonePath $config.rclonePath

if ($hostLock) {
	Write-Output $hostLock
} else {
	Write-Host "Couldn't find a host lock file or it was empty. It seems there is currently no host."
}

if ($Delete) {
	Write-Host "Deleting host lock file..."
	Remove-HostLock $config.RemoteDir -rclonePath $config.rclonePath
}
