#Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
$folder='G:\Me inc\NextLevelBi\git\metaprogramming\'
$fileName='meta-generator-with-macro.xlsm'
$path=$folder+$fileName

$DebugPreference="Continue"

$excel = New-Object -ComObject Excel.Application 
$Excel.visible = $true
$workbook = $excel.Workbooks.Open($path)

$macro = 'generateSelect'
$app = $excel.Application
$app.Run(($fileName+"!ThisWorkbook."+$macro)) #generateSelect

$workbook.close($false)
[void][System.Runtime.InteropServices.Marshal]::ReleaseComObject([System.__ComObject]$excel)
[gc]::Collect()
[gc]::WaitForPendingFinalizers()
Remove-Variable excel -ErrorAction SilentlyContinue