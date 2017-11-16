[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Management.SqlParser") | Out-Null

$ParseOptions = New-Object Microsoft.SqlServer.Management.SqlParser.Parser.ParseOptions
$ParseOptions.BatchSeparator = 'GO'
$Parser = new-object Microsoft.SqlServer.Management.SqlParser.Parser.Scanner($ParseOptions)

function Get-SqlBatchAction
{
	[cmdletbinding()]
	param (
		[string] $sql
	)

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
