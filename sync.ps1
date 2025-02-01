function Sync-Push {
	param (
		[Parameter(Mandatory=$true)]
		[ValidateScript({
			if (-not ($_ | Test-Path -PathType Container)) {
				throw "Directory does not exist."
			}
			return $true
		})]
		[String]$Dir,
		[Parameter(Mandatory=$true)]
		[String]$RemoteDir,
		[String]$FilterPath = (Join-Path $PSScriptRoot "syncfilter.txt"),
		[String]$RclonePath = "rclone",
		[switch]$DryRun
	)


	if (-not (Join-Path $Dir "world" | Test-Path -PathType Container)) {
		$choices = @(
			[System.Management.Automation.Host.ChoiceDescription]::new("&Yes", "Proceed with the operation.")
			[System.Management.Automation.Host.ChoiceDescription]::new("&No", "Cancel the operation.")
		)
		$decision = $Host.UI.PromptForChoice("WARNING", "Directory '$((Resolve-Path $Dir).Path)' does not contain a 'world' folder. It is likely you have selected the wrong directory to push. Proceed?", $choices, 1)
		if ($decision -eq 1) { return }
	}

	$syncArgs = @($Dir, $RemoteDir, "--verbose")
	$syncFilterPath = [System.IO.Path]::Combine($Dir, $FilterPath)
	if ($syncFilterPath | Test-Path -PathType Leaf) {
		$syncArgs += "--filter-from", $syncFilterPath
	}
	if ($DryRun) {
		$syncArgs += "--dry-run"
	}
	& $RclonePath sync @syncArgs
}

function Sync-Pull {
	param (
		[Parameter(Mandatory=$true)]
		[String]$Dir,
		[Parameter(Mandatory=$true)]
		[String]$RemoteDir,
		[String]$FilterPath = (Join-Path $PSScriptRoot "syncfilter.txt"),
		[String]$RclonePath = "rclone",
		[switch]$DryRun
	)

	$syncArgs = @($RemoteDir, $Dir, "--verbose", "--filter-from", "-")
	if ($DryRun) {
		$syncArgs += "--dry-run"
	}
	$syncFilterPath = [System.IO.Path]::Combine($RemoteDir, $FilterPath)
	& $RclonePath cat $syncFilterPath | rclone sync @syncArgs
}

function Get-HostLock {
	param (
		[Parameter(Mandatory=$true)]
		[String]$RemoteDir,
		[String]$RclonePath = "rclone"
	)

	$hostLockPath = $RemoteDir.TrimEnd("/") + "/host.lock"
	return & $RclonePath cat $hostLockPath
}

function Set-HostLock {
	param (
		[Parameter(Mandatory=$true)]
		[String]$RemoteDir,
		[Parameter(Mandatory=$true)]
		[String]$HostName,
		[Parameter(Mandatory=$true)]
		[String]$HostAddress,
		[switch]$DryRun,
		[String]$RclonePath = "rclone"
	)

	$hostLockPath = $RemoteDir.TrimEnd("/") + "/host.lock"
	$rcatArgs = @($hostLockPath, "--verbose")
	if ($DryRun) {
		$rcatArgs += "--dry-run"
	}
	$HostName, $HostAddress | & $RclonePath rcat @rcatArgs
}

function Remove-HostLock {
	param (
		[Parameter(Mandatory=$true)]
		[String]$RemoteDir,
		[switch]$DryRun,
		[String]$RclonePath = "rclone"
	)

	$hostLockPath = $RemoteDir.TrimEnd("/") + "/host.lock"
	$deletefileArgs = @($hostLockPath, "--verbose")
	if ($DryRun) {
		$deletefileArgs += "--dry-run"
	}
	& $RclonePath deletefile @deletefileArgs
}
