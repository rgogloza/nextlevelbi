#Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
$folder='G:\Me inc\NextLevelBi\git\metaprogramming\'
$fileName='meta-generator.xlsx'
$path=$folder+$fileName

$DebugPreference="Continue"

$excel = New-Object -ComObject Excel.Application 
$excel.visible = $true
$workbook = $excel.Workbooks.Open($path)
$excel.DisplayAlerts = $false

#how to get workbook
$structureDefinitionSheet = $workbook.Sheets.Item(1)
$structureDefinitionSheet = $workbook.Sheets['Structure definition']

$configSheet = $workbook.Sheets['Config']

#this is not good practice
Write-Debug = $configSheet.Range('B2').Value2
Write-Debug = $configSheet.Range('C2').Value2

$tableDefinitions = $structureDefinitionSheet.ListObjects | where-object { $_.DisplayName -eq "TableDefinitions" }    
# all tables
$tables = $structureDefinitionSheet.ListObjects
# specified table
$tableDefinitions = $structureDefinitionSheet.ListObjects["TableDefinitions"]


$rows = $tableDefinitions.ListRows
foreach($row in $rows) {
    $tableName = $row.Range.Columns[1].Value2
    $columnDefinition='  ' + $row.Range.Columns[2].Value2 + ' ' + $row.Range.Columns[3].Value2 + ' COMMENT "' + $row.Range.Columns[4].Value2 + '",'
    Write-Debug "Table Name: $tableName"
    Write-Debug "ColumnDefinition: $columnDefinition" 
}

$workbook.SaveAs($folder+"metaprogramming_version2.xlsx")

#or just save
#or comment all saves and just close
#$workbook.save()

$workbook.Close()
[void][System.Runtime.InteropServices.Marshal]::ReleaseComObject([System.__ComObject]$excel)
[gc]::Collect()
[gc]::WaitForPendingFinalizers()
Remove-Variable excel -ErrorAction SilentlyContinue