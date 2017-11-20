Function Invoke-Migrations {
    <#
    .SYNOPSIS
        Invoke a SQL database migration

    .DESCRIPTION
        Invoke a SQL database migration

    .PARAMETER ModeElastic
        Run the migration against a Azure Elastic Database

    .EXAMPLE
        Invoke-Migrations

        # Creates SQL script from files in the current folder

    .FUNCTIONALITY
        Invoke-Migrations

    .LINK
        https://github.com/infitude/AzureElasticDatabaseMigrations
    #>

    [cmdletbinding()]
    param(
        [String]$ConnectionString,
        [switch]$ModeElastic
    )

    [string]$Object = "local"
    if     ($ModeElastic) { $Object = "azure" }

    Write-Debug ( "Running $($MyInvocation.MyCommand).`n" +
                "PSBoundParameters:`n$($PSBoundParameters | Format-List | Out-String)" )

    Try {

         # get an array of commit ids
         [array]$revlist = git rev-list HEAD

        # get the initial commit id
        $initialCommit = $revlist[$revlist.Count - 1]

        # checkout the initial commit (using plumbing commands)
        git read-tree -um $initialCommit

        # string to build up and hold all batches
        $sqlBatchUnion = ''

        # for all the files, parse them and see if they create
        Get-ChildItem  | Foreach-Object {
                [String]$t = Get-Content $_.FullName

                # parse the SQL batch and see if it contains a create table statement
                $thisSqlBatch = Get-SqlBAtchAction $t

                # warn for create table sql baches
                if ($thisSqlBatch.hasCreateTable -eq $true) {
                        $message =  'WARNING - SQL CREATE TABLE statement in {0}' -f $_.FullName
                        Write-Debug $message
                    }

                # append the sql to the union of batches
                $sqlBatchUnion += $t
                $sqlBatchUnion += "`n"
            }

        # chckout master
        git read-tree -um master


        #sqlcmd -S "DEV-DB-01" -i $SQLScriptsPath | Out-File -Append -filepath $SQLScriptsLogPath
        #Invoke-Sqlcmd -Query "SELECT GETDATE() AS TimeOfQuery;" -ServerInstance "MyComputer\MyInstance" 
        
        return   $sqlBatchUnion

    }
    Catch
    {
        Throw $_
    }
}