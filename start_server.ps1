. (Join-Path $PSScriptRoot "sync.ps1")
$config = Import-PowerShellDataFile $(Join-Path $PSScriptRoot "config.psd1")

$Dir = [System.IO.Path]::Combine($PSScriptRoot, $config.LocalDir)

if (Get-HostLock $config.RemoteDir -rclonePath $config.rclonePath) {
	Write-Host "Host lock found in remote directory. Aborting startup."
	return
}
Write-Host "Creating host lock..."
Set-HostLock $config.RemoteDir $config.HostName $config.HostAddress -rclonePath $config.rclonePath

Write-Host "Pulling files..."
Sync-Pull $Dir $config.RemoteDir -rclonePath $config.rclonePath

Write-Host "Starting server..."
$command = $config.StartServerCommand.Split(" ")
& $command[0] $command[1..($command.Count - 1)]

Write-Host "Pushing files..."
Sync-Push $Dir $config.RemoteDir -rclonePath $config.rclonePath

Write-Host "Removing host lock..."
Remove-HostLock $config.RemoteDir -rclonePath $config.rclonePath
