$TxtPath = "Insert Path Here"
$File = Import-Csv $TxtPath
$Computers = $File.Computers

function StopService($Service, $Status)
{
    if($Status -eq 'Running')
    {
        Stop-Service -Name "$Service"
        $Status = (Get-Service -Name "$Service").status
        if(($Status -eq 'Running') -OR ($Status -eq 'Starting'))
        {
            Write-Error "Stopping service did not stop service"
        }
    }
}

function StartService($Service, $Status)
{
    if($Status -eq 'Stopped')
    {
        Start-Service -Name "$Service"
        $Status = (Get-Service -Name "$Service").status
        
        if(($Status -eq 'Stopped') -OR ($Status -eq 'Stopping'))
        {
            Write-Error "Starting service did not run service"
        }
    }
}

foreach($Computer in $Computers)
{
    Enter-PSSession -ComputerName $Computer
    $Service = "wuauserv"
    $Status = (Get-Service -Name "$Service").status
    StopService $Service $Status
    $Service = "bits"
    $Status = (Get-Service -Name "$Service").status
    StopService $Service $Status
    Remove-Item -Path C:\Windows\SoftwareDistribution -recurse
    $Service = "wuauserv"
    $Status = (Get-Service -Name "$Service").status
    StartService $Service $Status
    $Service = "bits"
    $Status = (Get-Service -Name "$Service").status
    StartService $Service $Status
    Exit-PSSession
}