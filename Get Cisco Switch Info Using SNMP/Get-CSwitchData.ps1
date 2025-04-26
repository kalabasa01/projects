
function Get-CSwitchInfo{
[CmdletBinding()]
 param (
        $IPAddress,
        $Community,
        $InfoType
    )

    $Hostname = (Get-SnmpData -IP $IPAddress -OID ".1.3.6.1.2.1.1.5.0" -Community $Community -Version V2).Data

    switch ($InfoType){
        "DEVICE-INFO" {
            Write-Host ""
            [PSCustomObject]@{
                "IPAddress" = $IPAddress
                "Hostnaame" = $Hostname
                "OS" = (Get-SnmpData -IP $IPAddress -OID ".1.3.6.1.2.1.47.1.1.1.1.9.1001" -Community $Community -Version V2).Data
                "Model" = (Get-SnmpData -IP $IPAddress -OID ".1.3.6.1.2.1.47.1.1.1.1.2.1001" -Community $Community -Version V2).Data
                "Serial Number" = (Get-SnmpData -IP $IPAddress -OID ".1.3.6.1.2.1.47.1.1.1.1.11.1001" -Community $Community -Version V2).Data
            } | Format-List
            Write-Host ""
        }

        "INTERFACE-INFO" {
            Write-Host ""
            (Invoke-SnmpWalk -IP $IPAddress -OIDStart .1.3.6.1.2.1.2.2.1.1 -Community $Community).Data | ForEach {

                [PSCustomObject]@{
                    "Description" = (Get-SnmpData -IP $IPAddress -OID ".1.3.6.1.2.1.31.1.1.1.18.$_" -Community $Community -Version V2).Data
                    "Interface" = (Get-SnmpData -IP $IPAddress -OID ".1.3.6.1.2.1.2.2.1.2.$_" -Community $Community -Version V2).Data
                    "Speed" = (Get-SnmpData -IP $IPAddress -OID ".1.3.6.1.2.1.2.2.1.5.$_" -Community $Community -Version V2).Data
                 }

            } | Format-Table -AutoSize

            Write-Host ""
        }
    }
}


cls
Write-Host "Note: This script run through SNMP Module." -ForegroundColor Red
Write-Host "      'Install-Module -Name SNMP' to install." -ForegroundColor Red
Write-Host ""
$IPAddress = Read-Host "Host Address"
$Community = Read-Host "Community"
Write-Host ""
Write-Host "Please Select the Type of Info you want to show."
$InfoType = Read-Host "(INTERFACE-INFO, DEVICE-INFO)"

Get-CSwitchInfo -IPAddress $IPAddress -Community $Community -InfoType $InfoType