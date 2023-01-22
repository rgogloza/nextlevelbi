# This script does Power BI workspace inventory and extracts SQL queries.
# Connects to Power BI service, goes through datasets and extracts SQL code from M queries
# The output are 2 CSV files, one with SQL queries and second with everything else.
# You can modify code easily to connect to local Power BI model
# -------------------------------------------------------------------------------------
#
# Remarks :
# ---------

Function Beautify-Sql {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        $expression,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [int] $start
    )

    $end = $expression.IndexOf('"])')
    $sql_query = $expression.Substring($start,($end-$start))
    $sql_query = $sql_query.Replace('#(tab)',' ')
    $sql_query = $sql_query.Replace('#(lf)',' ') #`n
    return $sql_query
}

Function Create-ReportLine {
    [CmdletBinding()]

    Param(
        [Parameter(Mandatory=$true)]
        $reportName,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $source,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $tableName,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $lastModified,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $sqlQuery
    )

    $query = New-Object -TypeName PSObject
    $query | Add-Member -MemberType NoteProperty -Name 'Report Name' -Value $reportName
    $query | Add-Member -MemberType NoteProperty -Name 'Source' -Value $source
    $query | Add-Member -MemberType NoteProperty -Name 'Table Name' -Value $tableName    
    $query | Add-Member -MemberType NoteProperty -Name 'Last Modified' -Value $lastModified
    $query | Add-Member -MemberType NoteProperty -Name 'Query' -Value $sqlQuery
    return $query
}

Function Compute-SQL {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        $expression
    )
    
    #first pattern when query is written
    $PATTERN1='[Query="'
    $startMQuery = (&{if($expression.IndexOf($PATTERN1) -gt 0) {($expression.IndexOf($PATTERN1) + $PATTERN1.Length)}})
    if($startMQuery -gt 0) {
        $sql_query = Beautify-Sql $expression $startMQuery
        $sql_query = $sql_query.Replace('[','').Replace(']','')
        return $sql_query
    }


    #second pattern when ALL records from table are loaded
    # case when when starts with Source{[Schema
    $PATTERN2 = 'Source{[Schema="'    
       
    $schemaBegin = (&{if($expression.indexOf($PATTERN2) -gt 0) {($expression.IndexOf($PATTERN2) + $PATTERN2.Length)}})
    
    
    $end2 = ($expression.IndexOf('"]}[Data]'))
    $sql_query = ''
    
    if (($schemaBegin -gt 0 -and $end2 -gt 0)) {
        $all_from_table = $expression.Substring($schemaBegin, ($end2 - $schemaBegin))        
        $sql_query = $all_from_table.replace('",Item="','.')
        $sql_query = $sql_query.Replace('[','').Replace(']','')        
    }
    return $sql_query  
}

Function Create-CSV {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        $filePath,

        [Parameter(Mandatory=$true)]
        $exportObjects
    )

    if(Test-Path $filePath) {
        Remove-Item -Path $filePath -Force
    }
    $exportObjects | Export-Csv -Force -Path $filePath -NoTypeInformation -NoClobber -Delimiter $DELIMITER
}

Function Extract-Sources {
    $queries = [System.Collections.ArrayList]::new()
    $otherSources = [System.Collections.ArrayList]::new()
    foreach($db in $srv.databases) { 
        foreach($table in $db.Model.Tables ){
            foreach($partition in $table.Partitions) {
                if($partition.SourceType -in ('M','Calculated')) {
                
                    $sqlQuery = Compute-SQL $partition.Source.Expression            
                    $reportLine = ""
                    if($sqlQuery -ne '') {
                        $reportLine = Create-ReportLine $db.Name "DB" $table.Name $partition.ModifiedTime $sqlQuery                
                        $queries.add($reportLine) > $null
                    } else {
                        $expression = ($partition.Source.Expression).Replace("`n","`t`t") 
                        $reportLine = Create-ReportLine $db.Name "Other" $table.Name $partition.ModifiedTime $expression
                        $otherSources.add($reportLine) > $null
                    }
                }
            }
        }
    }
    return $queries, $otherSources
}

#### configuration begin

$localExportFolder = "C:\goglozar\pbi-inventory\" 
$sqlInventoryFile = $localExportFolder+"power_bi_db_inventory.csv"
$otherInventoryFile = $localExportFolder+"power_bi_other_inventory.csv"
$workspaceLink = "powerbi://api.powerbi.com/v1.0/myorg/Workspace-Name" # you can also experiment and connect to your local PBI model "localhost:54228" # 
$DELIMITER = "^"

### configuration end

# connect to Power BI Service

Connect-PowerBIServiceAccount 

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.AnalysisServices.Tabular")
$srv = New-Object Microsoft.AnalysisServices.Tabular.Server
$srv.Connect($workspaceLink)

# collect queries and source names
$queries, $otherSources = Extract-Sources

#Export for DB model
Create-CSV $sqlInventoryFile $queries
Write-Output "SQL Queries to be found in: $sqlInventoryFile"

Create-CSV $otherInventoryFile $otherSources
Write-Output "Other inventory to be found in: $otherInventoryFile"