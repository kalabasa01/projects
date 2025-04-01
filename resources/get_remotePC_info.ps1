$host.UI.RawUI.WindowTitle = "wemotePC by Maw : Get PCs info remotely!"

$pshost = get-host
$pswindow = $pshost.ui.rawui
$newsize = $pswindow.buffersize
$newsize.height = 8980
$newsize.width = 75
$pswindow.buffersize = $newsize
$newsize = $pswindow.windowsize
$newsize.height = 50
$newsize.width = 75
$pswindow.windowsize = $newsize


function Get-PCinfo {

    Do {
        try {
            cls

            Write-Host ""
            Write-Host "          IF CONFUSE READ THE TXT FILE (READ ME DADDY PLEASE)"-ForegroundColor Red
            Write-Host ""


            $computerName = Read-Host -Prompt " Enter the Computer Host Name/IP Address"
            if (Test-Connection -ComputerName $computerName -Count 3 -Quiet){

                Write-Host ""
                $CUser = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $computerName -Property UserName
                ForEach ($CurrentUser in $CUser){

                    $UserName = $CurrentUser.UserName -Replace "OSS\\", ""
                    Write-Host " Current User        "-ForegroundColor green -NoNewLine
                    Write-Host ": $UserName"

                    if ($UserName -ne ""){
                        $ADUser = Get-ADUser -Filter "mailNickname -like '*$UserName*'" -properties *

                            ForEach ($ADUsers in $ADUser){
                            $cn = $ADUsers.CN
                            $mail = $ADUsers.mail
                            $created = $ADUsers.whenCreated
                            $pass_last_set = $ADUser.PasswordLastSet
                            $SID = $ADUser.SID
                            $Pass_Age = [int](((Get-Date) - ([DateTime]$pass_last_set)).TotalDays)

                            Write-Host " Email               " -ForeGroundColor Green -NoNewLine
                            Write-Host ": $mail"

                            $department = $ADUsers.DistinguishedName -Replace "CN=$cn,", ""
                            $ADOUnit = Get-ADOrganizationalUnit -Identity "$department" -Property *
                            ForEach ($ADOUnits in $ADOUnit){
                                $DName = $ADOUnits.CanonicalName -Replace "oss.com.ph/OSS/",""
                                Write-Host " Department          " -ForeGroundColor Green -NoNewLine
                                Write-Host ": $DName"
                            }
                            Write-Host " Created             " -ForeGroundColor Green -NoNewLine
                            Write-Host ": $created"
                            Write-Host " Password Last Set   " -ForeGroundColor Green -NoNewLine
                            Write-Host ": $pass_last_set"
                            Write-Host " Password Age        " -ForeGroundColor Green -NoNewLine
                            Write-Host ": $Pass_Age days"

                        }
                    }

                }

                
                Write-Host ""
                try {
                    $currentUser = (whoami).Split('\')[1]
                    $MonitorInfoCSV = Import-CSV -Path "C:\REMOTEPC\resources\MonitorDB.csv"

                    $Monitors = Get-WmiObject WmiMonitorID -Namespace root\wmi -ComputerName $computerName
                    Write-Host " Monitor................................................................."
                    ForEach ($Monitor in $Monitors) {
                       $ManufacturerName = [System.Text.Encoding]::ASCII.GetString($Monitor.UserFriendlyName)
                       $ServiceTag = [System.Text.Encoding]::ASCII.GetString($Monitor.SerialNumberID)
                       $year = $Monitor.YearOfManufacture

                       if ($year -le 2018){
                           $first = $ServiceTag.Substring(0,5)
                           $second = $ServiceTag.Substring(5,3)
                           $last = $ServiceTag.Substring(8,4)
                           $new_SN = "CN-0$first-QDC00-$second-$last"

                           $SerialNumber = ($MonitorInfoCSV | Where-Object { $_.SerialNumber -like "*$new_SN*" }).SerialNumber
                           $new_ServiceTag = ($MonitorInfoCSV | Where-Object { $_.SerialNumber -like "$SerialNumber" }).ServiceTag

                           Write-Host " Manufacturer Name   " -ForeGroundColor Green -NoNewLine
                           Write-Host ": $ManufacturerName"
                           Write-Host " Year of Manufacture " -ForeGroundColor Green -NoNewLine
                           Write-Host ": $year"
                           Write-Host " Serial Number       " -ForeGroundColor Green -NoNewLine
                           Write-Host ": $SerialNumber"
                           Write-Host " Service Tag         " -ForeGroundColor Green -NoNewLine
                           Write-Host ": $new_ServiceTag"
                           Write-Host ""
                       }else{
                           $SerialNumber = ($MonitorInfoCSV | Where-Object { $_.ServiceTag -eq "$ServiceTag" }).SerialNumber

                           Write-Host " Manufacturer Name   " -ForeGroundColor Green -NoNewLine
                           Write-Host ": $ManufacturerName"
                           Write-Host " Year of Manufacture " -ForeGroundColor Green -NoNewLine
                           Write-Host ": $year"
                           Write-Host " Serial Number       " -ForeGroundColor Green -NoNewLine
                           Write-Host ": $SerialNumber"
                           Write-Host " Service Tag         " -ForeGroundColor Green -NoNewLine
                           Write-Host ": $ServiceTag"
                           Write-Host ""
                     
                       }

                    }

                 }catch {
                    Write-Output " No Record was found!"
                 }


               
                try{
                    $network = Get-WmiObject -Query "select * from Win32_NetworkAdapterConfiguration where IPEnabled='True'" -ComputerName $computerName
                    Write-Host " Network Info............................................................"
                    ForEach ($networks in $network){
                        $description = $networks.Description
                        $IPv4Address = $networks.IPAddress -match "(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})"
                        $MACAddress = $networks.MACAddress -Replace ":","-"
                        Write-Host " Description         " -ForeGroundColor Green -NoNewLine
                        Write-Host ": $description"
                        Write-Host " IPAddress           " -ForeGroundColor Green -NoNewLine
                        Write-Host ": $IPv4Address"
                        Write-Host " MACAddress          " -ForeGroundColor Green -NoNewLine
                        Write-Host ": $MACAddress"

                    }
                }Catch{
                    Write-Output " No Record was found!"
                }


                Write-Host ""
                Write-Host " System Unit Info........................................................"
                $ComputerSystems = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $computerName
                ForEach ($Compu in $ComputerSystems){
                    $HName = $Compu.Name
                    $Domain = $Compu.Domain
                    $Manufacturer = $Compu.Manufacturer
                    $Model = $Compu.Model
                    Write-Host " Host Name           " -ForeGroundColor Green -NoNewLine
                    Write-Host ": $HName"
                    Write-Host " Domain              " -ForeGroundColor Green -NoNewLine
                    Write-Host ": $Domain"
                    Write-Host " Manufacturer        " -ForeGroundColor Green -NoNewLine
                    Write-Host ": $Manufacturer"
                    Write-Host " Model               " -ForeGroundColor Green -NoNewLine
                    Write-Host ": $Model"

                }

                $SerialNumber = Get-WmiObject -Class Win32_Bios -ComputerName $computerName -Property SerialNumber
                ForEach ($SN in $SerialNumber){
                    $SerialNumber = $SN.SerialNumber
                    Write-Host " Serial Number       " -ForeGroundColor Green -NoNewLine
                    Write-Host ": $SerialNumber"
                }


                $bootTime = (Get-WmiObject Win32_OperatingSystem -ComputerName $computerName).LastBootUpTime
                $year = $bootTime.substring(0,4)
                $month = $bootTime.substring(4,2)
                $date = $bootTime.substring(6,2)
                $hour = $bootTime.substring(8,2)
                $minutes = $bootTime.substring(10,2)

                if ($hour + $minutes -le 1199){
                    Write-Host " System Boot Time    " -ForeGroundColor Green -NoNewLine
                    Write-Host ": $month/$date/$year" $hour':'$minutes 'AM'
                   
                }else {
                    Write-Host " System Boot Time    " -ForeGroundColor Green -NoNewLine
                    Write-Host ": $month/$date/$year" $hour':'$minutes 'PM'
                }


                $os = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $computerName
                $availableMemoryMB = [math]::Round($os.FreePhysicalMemory / 1024)

                $totalMemory = (Get-WmiObject -Class Win32_ComputerSystem -ComputerName $computerName).TotalPhysicalMemory
                
                Write-Host " Physical Memory     " -ForeGroundColor Green -NoNewLine
                Write-Host ":" $availableMemoryMB "MB /" ([math]::round($totalMemory / 1MB)) "MB"



                $LogicDisk = get-wmiobject Win32_LogicalDisk -ComputerName $computerName
                Write-Host " Logical Disk" -ForeGroundColor Green
                ForEach ($Logic_Disk in $LogicDisk){
                    $DriveLetter = $Logic_Disk.DeviceID -Replace ":",""
                    $VolumeName = $Logic_Disk.VolumeName
                    $TotalSize = $Logic_Disk.Size
                    $FreeSpace = $Logic_Disk.FreeSpace

                    Write-Host "        Drive $DriveLetter      " -ForeGroundColor Green -NoNewLine
                    Write-Host ":"([Math]::Round($FreeSpace / 1MB))"MB" "/" ([Math]::Round($TotalSize / 1MB))"MB $VolumeName"
                    
                }
                

            }else {
               Write-Host " Connection Failed!!"
            }

        }
        catch [System.Management.ManagementException] {
            Write-Host " ManagementException: $_"
        }
        catch [System.UnauthorizedAccessException] {
            Write-Host " UnauthorizedAccessException: $_"
        }
        catch [System.SystemException] {
            Write-Host " SystemException: $_"
        }
        catch {
            Write-Host " An unexpected error occurred: $_"
        }

        Write-Host ""

        $cancel = Read-Host -Prompt " Do you want to continue? (y/n)"

    } while ($cancel -eq 'y')
    exit
}

Get-PCinfo
