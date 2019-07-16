
#temp location to save temp files
$file ='D:\DBA\Data\output.txt' 
$file_final ='D:\DBA\Data\output_final.txt'

#list of servers whose space needs to be calculated
$list = 
'NAV-C01AS01D',
'NAV-C01AS02P',
'NAV-C02AS01P',
'NAV-C03AS01D',
'NAV-C04AS01P',
'NAV-C05AS01P',
'NAV-C06AS01P',
'NAV-C08AS01P',
'NAV-C09AS01P',
'NAV-C09AS02P',
'NAV-C10AS01P',
'NAV-C10AS02P',
'NAV-C11AS01P',
'NAV-C11AS02D',
'NAV-C12AS01P',
'NAV-C13AS01P',
'NAV-C14AS01P',
'NAV-C14AS02D',
'NAV-C15AS01P',
'NAV-C16AS01P',
'NAV-C16AS02P',
'NAV-C17AS01D',
'NAV-C17AS01P',
'NAV-C18AS01P',
'NAV-C18AS02P',
'NAV-C18AS03D',
'NAV-C18AS04D',
'NAV-C19AS01D',
'NAV-C19AS01P',
'NAV-C20AS01P',
'NAV-C20AS02P',
'NAV-C20AS03D',
'NAV-C20AS04D',
'NAV-C20AS05D',
'NAV-C20AS06D',
'NAV-C20AS07D',
'NAV-C21AS01P',
'NAV-C21AS02P',
'NAV-C22AS01P',
'NAV-C22AS02P',
'NAV-C24AS01P',
'NAV-C24AS02D',
'NAV-C25AS01P',
'NAV-C25AS02P',
'NAV-C25AS03D',
'NAV-C25AS04D',
'NAV-C26AS01P',
'NAV-C26AS02P',
'NAV-C26AS03D',
'NAV-C26AS04D',
'NAV-C27AS01P',
'NAV-C27AS02P',
'NAV-C28AS01P',
'NAV-C28AS02D',
'NAV-C28AS03P',
'NAV-C28AS04D',
'NAV-C29AS01P',
'NAV-C30AS01D',
'NAV-C30AS02D',
'NAV-C30AS03P',
'NAV-C30AS04P',
'NAV-C31AS01D',
'NAV-C32AS01P',
'NAV-C32AS02D',
'NAV-C33AS01P',
'NAV-C34AS01P',
'NAV-C34AS02P',
'NAV-C34AS03D',
'NAV-C34AS04D',
'NAV-C35AS01D',
'NAV-C35AS02D',
'NAV-E0WDB005',
'NAV-I0WAD001',
'NAV-I0WAS001',
'NAV-I0WAS002',
'NAV-I0WAS003',
'NAV-I0WAS004',
'NAV-I0WAV001',
'NAV-I0WAV002',
'NAV-I0WDB001',
'NAV-I0WDB002',
'NAV-I0WDB003',
'NAV-I0WDB004',
'NAV-I0WEX001',
'NAV-I0WFC001',
'NAV-I0WFS002',
'NAV-I0WMGMT01',
'NAV-I0WSFS002',
'NAV-I0WSIP01',
'NAV-I0WWW001',
'NAV-I0WWWW01',
'NAV-I0XAS001',
'NAV-I0XAS002',
'NAV-I0XAS003',
'NAV-I0XAS004',
'NAV-I0XDB002',
'NAV-I0XSV001',
'NAV-I0XWG001',
'NAV-I0XWW001',
'NAV-I0XWW002',
'NAV-I0XWW003',
'NAV-IOWDB003',
'NAV-IOWDB004',
'NAV-LOG01',
'NAV-LOG02',
'NAV-NAGIOS01',
'VPN01NAVETTI.COM',
'WINDOWSSERVER'


#database credentials where the data needs to be stored
$dataSource="NAV-C00DB01D"
$user="space"
$pwd="P@ssw0rd!"
$database="master"
$connectionString="Server=$dataSource;uid=$user;pwd=$pwd;Database=$database;Integrated Security=True;"
$connection=New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString=$connectionString
$connection.Open()
$command=New-Object System.Data.SqlClient.SqlCommand
$command.Connection=$connection
$query=";"

echo '' | Out-File $file


foreach ($server in $list){
 try
{
Get-WmiObject -Class Win32_LogicalDisk -ComputerName $server -Filter 'DriveType = 3' |select PSComputerName, Caption,@{N='Capacity_GB'; E={[math]::Round(($_.Size / 1GB), 2)}},@{N='FreeSpace_GB'; E={[math]::Round(($_.FreeSpace / 1GB), 2)}},@{N='PercentUsed'; E={[math]::Round(((($_.Size - $_.FreeSpace) / $_.Size) * 100), 2) }},@{N='PercentFree'; E={[math]::Round((($_.FreeSpace / $_.Size) * 100), 2) }} | Format-Table | Out-File -Append $file 
}
catch{
echo "break";
}

}



get-content $file | select-string -pattern 'PSComputerName ' -notmatch | Out-File $file_final
get-content $file_final | select-string -pattern '--------------' -notmatch | Out-File $file
[IO.File]::ReadAllText($file) -replace '\s+\r\n+', "`r`n" | Out-File $file_final
$content = [System.IO.File]::ReadAllText($file_final)
$content = $content.Trim()
[System.IO.File]::WriteAllText($file, $content)


$a = get-content $file

$query= ';'

foreach ( $rows in $a ){

$rows =$rows.replace(' ','|')
$rows =$rows.replace('||','|')
$rows =$rows.replace('||','|')
$rows =$rows.replace('||','|')
$rows =$rows.replace('||','|')
$rows =$rows.replace('||','|')
$rows =$rows.replace('||','|')
$rows =$rows.replace('||','|')
$rows =$rows.replace('||','|')
$rows =$rows.replace('||','|')
$rows =$rows.replace('||','|')
$rows =$rows.replace('||','|')
$rows =$rows.replace('||','|')
$rows =$rows.replace('||','|')
$rows =$rows.replace('||','|')
$rows =$rows.replace('||','|')
$rows =$rows.replace('||','|')
$rows =$rows.replace('||','|')
$rows =$rows.replace('||','|')
$rows =$rows.replace('||','|')
$rows =$rows.replace('||','|')


$array=$rows.Split('|')
$query=$query+"insert into master.dbo.space values ('"+$array[0]+"','"+$array[1]+"','"+$array[2]+"','"+$array[3]+"','"+$array[4]+"',CONVERT(VARCHAR(24),GETDATE(),112));"


}

$command.CommandText=$query 
$result=$command.ExecuteReader()
$connection.close()
