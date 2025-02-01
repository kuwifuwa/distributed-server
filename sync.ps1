function Sync-Push {
    param (
        [Parameter(Mandatory)]
        [ValidateScript({
            if (-not ($_ | Test-Path -PathType Container)) {
                throw "Directory does not exist."
            }
            return $true
        })]
        [String]$Dir,
        [Parameter(Mandatory)]
        [String]$RemoteDir,
        [String]$FilterPath = (Join-Path $PSScriptRoot "syncfilter.txt"),
        [String]$RclonePath = "rclone",
        [switch]$DryRun
    )

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
        [Parameter(Mandatory)]
        [String]$Dir,
        [Parameter(Mandatory)]
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
        [Parameter(Mandatory)]
        [String]$RemoteDir,
        [String]$RclonePath = "rclone"
    )

    $hostLockPath = $RemoteDir.TrimEnd("/") + "/distributed-server/host.lock"
    return & $RclonePath cat $hostLockPath
}

function Set-HostLock {
    param (
        [Parameter(Mandatory)]
        [String]$RemoteDir,
        [Parameter(Mandatory)]
        [String]$HostName,
        [Parameter(Mandatory)]
        [String]$HostAddress,
        [switch]$DryRun,
        [String]$RclonePath = "rclone"
    )

    $hostLockPath = $RemoteDir.TrimEnd("/") + "/distributed-server/host.lock"
    $rcatArgs = @($hostLockPath, "--verbose")
    if ($DryRun) {
        $rcatArgs += "--dry-run"
    }
    $HostName, $HostAddress | & $RclonePath rcat @rcatArgs
}

function Remove-HostLock {
    param (
        [Parameter(Mandatory)]
        [String]$RemoteDir,
        [switch]$DryRun,
        [String]$RclonePath = "rclone"
    )

    $hostLockPath = $RemoteDir.TrimEnd("/") + "/distributed-server/host.lock"
    $deletefileArgs = @($hostLockPath, "--verbose")
    if ($DryRun) {
        $deletefileArgs += "--dry-run"
    }
    & $RclonePath deletefile @deletefileArgs
}
