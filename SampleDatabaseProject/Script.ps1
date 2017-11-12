#
# Script.ps1
#

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Management.SqlParser") | Out-Null

# turn on verbose and/or debug output
$VerbosePreference = "continue"
$DebugPreference = "continue"

$ParseOptions = New-Object Microsoft.SqlServer.Management.SqlParser.Parser.ParseOptions
$ParseOptions.BatchSeparator = 'GO'
$Parser = new-object Microsoft.SqlServer.Management.SqlParser.Parser.Scanner($ParseOptions)

function parse-sql( [string] $sql ) {
	$Parser.SetSource($Sql,0)
	$Token=[Microsoft.SqlServer.Management.SqlParser.Parser.Tokens]::TOKEN_SET
	
	$sqlBatch = [PSCustomObject]@{
		hasCreateTable = $false
	}

	$createState = $false

	$Start =0
	$End = 0
	$State =0 
	$IsEndOfBatch = $false
	$IsMatched = $false
	$IsExecAutoParamHelp = $false

	while(($Token = $Parser.GetNext([ref]$State ,[ref]$Start, [ref]$End, [ref]$IsMatched, [ref]$IsExecAutoParamHelp ))-ne [Microsoft.SqlServer.Management.SqlParser.Parser.Tokens]::EOF) {
		try{
			($TokenPrs =[Microsoft.SqlServer.Management.SqlParser.Parser.Tokens]$Token) | Out-Null
			#$TokenPrs
			#$Sql.Substring($Start,($end-$Start)+1)
			
			# detect TABLE token following a CREATE token
			if($TokenPrs -eq "TOKEN_TABLE" -and $createState -eq $true) {
				$sqlBatch.hasCreateTable = $true 
			}
			# detect CREATE token
			if ($TokenPrs -eq "TOKEN_CREATE") {
				$createState = $true
			} else {
				$createState = $false
			}
		}catch{
			$TokenPrs = $null
		} 
	}
	return $sqlBatch
}


# remove the test folder
Remove-Item C:\Temp\SampleDatabase -recurse -Force

# create test folder
New-Item C:\Temp\SampleDatabase -type directory -Force

# set to working directory (convenience for GIT commands)
Set-Location -Path C:\Temp\SampleDatabase

# init the git repo
git init

# copy the first commit files over (remove the Commit_1 from the name)
Get-ChildItem -Path C:\Projects\GitHub\AzureElasticDatabaseMigrations\SampleDatabaseProject -Recurse | ?{$_.Name -like "*_Commit_1.sql"} | % {
	$copyto = "C:\Temp\SampleDatabase\" + $_.Name.Replace("_Commit_1","")
	$copyto
	Copy-Item $_.FullName $copyto 

	git add $copyto 
}

# check status and commit
git commit -m "Commit 1"

# copy the second commit files over (remove the Commit_2 from the name)
Get-ChildItem -Path C:\Projects\GitHub\AzureElasticDatabaseMigrations\SampleDatabaseProject -Recurse | ?{$_.Name -like "*_Commit_2.sql"} | % {
	$copyto = "C:\Temp\SampleDatabase\" + $_.Name.Replace("_Commit_2","")
	$copyto
	Copy-Item $_.FullName $copyto 

	git add $copyto 
}

# check status and commit
git commit -m "Commit 2"

# see whats happening
git status
git log

# get an array of commit ids
[array]$revlist = git rev-list HEAD

# get the initial commit id
$initialCommit = $revlist[$revlist.Count - 1]
$initialCommit

# checkout the initial commit (using plumbing commands)
git read-tree -um $initialCommit

# for all the files, parse them and see if they create
Get-ChildItem  | % { 
		$t = Get-Content $_.FullName		

		$thisSqlBatch = parse-sql $t 
		#parse-sql $t 

		#$thisSqlBatch | Get-Member
		if ($thisSqlBatch.hasCreateTable -eq $true) {
				$message =  'WARNING - SQL CREATE TABLE statement in {0}' -f $_.FullName
				Write-Debug $message
			}

		#		$thisTokens = parse-sql $t 
		## see file and tokens in debug
		#Write-Debug $_.FullName
		#Write-Debug $thisTokens.Count
		#foreach ($token in $thisTokens) {
		#	$message = 'token {0}  has value {1}' -f $token[0], $token[1]
		#	Write-Debug $message
		#}
		#$thisTokens -contains 'TOKEN_CREATE'
		#$thisTokens | ?{$_.[0] -eq "TOKEN_CREATE"} | %{$_.[1]}
		
	}

# chckout master
git read-tree -um master

# put me back into project folder
Set-Location -Path C:\Projects\GitHub\AzureElasticDatabaseMigrations\SampleDatabaseProject