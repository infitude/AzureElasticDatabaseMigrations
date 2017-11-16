$ModuleManifestName = 'AzureElasticDatabaseMigrations.psd1'
$ModuleManifestPath = "$PSScriptRoot\..\AzureElasticDatabaseMigrations\$ModuleManifestName"
$SampleDatabaseProjectPath = "$PSScriptRoot\SampleDatabaseProject"
$TestGitSqlProjectPath = "C:\Temp\SampleDatabase\"

Describe 'Module Manifest Tests' {
    It 'Passes Test-ModuleManifest' {
        Test-ModuleManifest -Path $ModuleManifestPath | Should Not BeNullOrEmpty
        $? | Should Be $true
    }
}

Describe 'Sql Integration Tests' {
    It 'Attempts to perform GIT commands on a sample SQL script repository' {

        # remove the test folder
        Remove-Item $TestGitSqlProjectPath -recurse -Force

        # create test folder
        New-Item $TestGitSqlProjectPath -type directory -Force

        # set to working directory (convenience for GIT commands)
        Set-Location -Path $TestGitSqlProjectPath

        # init the git repo
        git init

        # copy the first commit files over (remove the Commit_1 from the name)
        Get-ChildItem -Path $SampleDatabaseProjectPath -Recurse | Where-Object{$_.Name -like "*_Commit_1.sql"} | Foreach-Object {
            $copyto = $TestGitSqlProjectPath + $_.Name.Replace("_Commit_1","")
            $copyto
            Copy-Item $_.FullName $copyto

            git add $copyto
        }

        # check status and commit
        git commit -m "Commit 1"

        # copy the second commit files over (remove the Commit_2 from the name)
        Get-ChildItem -Path $SampleDatabaseProjectPath -Recurse | ?{$_.Name -like "*_Commit_2.sql"} | % {
            $copyto = $TestGitSqlProjectPath + $_.Name.Replace("_Commit_2","")
            $copyto
            Copy-Item $_.FullName $copyto

            git add $copyto
        }

        # check status and commit
        git commit -m "Commit 2"

        #Invoke-Migrations

        # see whats happening
        #git status
        #Write-Debug git log

        # # get an array of commit ids
        # [array]$revlist = git rev-list HEAD

        # # get the initial commit id
        # $initialCommit = $revlist[$revlist.Count - 1]
        # #$initialCommit

        # # checkout the initial commit (using plumbing commands)
        # git read-tree -um $initialCommit

        # $sqlBatchUnion = ''

        # # for all the files, parse them and see if they create
        # Get-ChildItem  | % {
        #         $t = Get-Content $_.FullName

        #         # parse the SQL batch and see if it contains a create table statement
        #         $thisSqlBatch = Get-SqlBAtchAction $t

        #         # warn for create table sql baches
        #         if ($thisSqlBatch.hasCreateTable -eq $true) {
        #                 $message =  'WARNING - SQL CREATE TABLE statement in {0}' -f $_.FullName
        #                 Write-Debug $message
        #             }

        #         # append the sql to the union of batches
        #         $sqlBatchUnion += $t
        #         $sqlBatchUnion += "`n"
        #     }

        #  #   $sqlBatchUnion

        # # chckout master
        # git read-tree -um master

        # put me back into project folder
        Set-Location -Path $PSScriptRoot

    }
}
