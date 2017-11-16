Function Invoke-Migrations {
    <#
    .SYNOPSIS
        Get questions from StackExchange

    .DESCRIPTION
        Get questions from StackExchange

    .PARAMETER Site
        StackExchange site to get questions from. Default is stackoverflow

    .PARAMETER Tag
        Search by tag

        Limited to 5 tags

    .PARAMETER Unanswered
        Return only questions not marked as answered

    .PARAMETER NoAnswers
        Return only questions with no answers

    .PARAMETER Featured
        Return only featured questions

    .PARAMETER FromDate
        Return only questions posted after this date

    .PARAMETER ToDate
        Return only questions posted before this date

    .PARAMETER Order
        Ascending or Descending

    .PARAMETER Sort
        Sorting method:
            activity
            creation
            votes
            hot
            week
            month

    .PARAMETER Uri
        The base Uri for the StackExchange API.

        Default: https://api.stackexchange.com

    .PARAMETER Version
        The StackExchange API version to use.

    .PARAMETER PageSize
        Items to retrieve per query. Defaults to 30

    .PARAMETER MaxResults
        Maximum number of items to return. Defaults to 100

        Specify $null or 0 to set this to the maximum value

    .PARAMETER Body
        Hash table with query options for specific object

        These don't appear to be case sensitive

        Example for recent powershell activity:
            -Body @{
                site  =  'stackoverflow'
                tagged = 'powershell'
                order =  'desc'
                sort =   'activity'
            }

    .EXAMPLE
        Invoke-Migrations

        # List sites on StackExchange

    .EXAMPLE
        Get-SEQuestion -UnAnswered -Tag PowerShell -FromDate $(Get-Date).AddDays(-1) -Site ServerFault

        # Get unanswered questions...
        #    Tagged PowerShell...
        #    From the past day...
        #    From the ServerFault site

    .EXAMPLE
        Get-SEQuestion -Featured -Tag PowerShell -Site StackOverflow -MaxResults 20

        # Get featured questions...
        #    Tagged PowerShell...
        #    From the stackoverflow site
        #    Limited to 20 items

    .FUNCTIONALITY
        StackExchange

    .LINK
        http://ramblingcookiemonster.github.io/Building-A-PowerShell-Module

    .LINK
        https://github.com/RamblingCookieMonster/PSStackExchange

    .LINK
        https://api.stackexchange.com/docs/questions



    #>
    [cmdletbinding()]
    param(
        [switch]$ModeElastic
    )

        [string]$Object = "local"
        if     ($ModeElastic) { $Object = "azure" }

        Write-Debug ( "Running $($MyInvocation.MyCommand).`n" +
                    "PSBoundParameters:`n$($PSBoundParameters | Format-List | Out-String)" )


    Try
    {

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

        return   $sqlBatchUnion

    }
    Catch
    {
        Throw $_
    }
}