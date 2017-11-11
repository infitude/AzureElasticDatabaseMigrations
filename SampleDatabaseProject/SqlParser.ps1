#
# SqlParser.ps1
#
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Management.SqlParser") | Out-Null
$ParseOptions = New-Object Microsoft.SqlServer.Management.SqlParser.Parser.ParseOptions
$ParseOptions.BatchSeparator = 'GO'

$Parser = new-object Microsoft.SqlServer.Management.SqlParser.Parser.Scanner($ParseOptions)
$Sql = "Create Procedure MyProc as Select top(10) * from dbo.Table"
$Parser.SetSource($Sql,0)
$Token=[Microsoft.SqlServer.Management.SqlParser.Parser.Tokens]::TOKEN_SET
$Start =0
$End = 0
$State =0 
$IsEndOfBatch = $false
$IsMatched = $false
$IsExecAutoParamHelp = $false
while(($Token = $Parser.GetNext([ref]$State ,[ref]$Start, [ref]$End, [ref]$IsMatched, [ref]$IsExecAutoParamHelp ))-ne [Microsoft.SqlServer.Management.SqlParser.Parser.Tokens]::EOF) {
    try{
        ($TokenPrs =[Microsoft.SqlServer.Management.SqlParser.Parser.Tokens]$Token) | Out-Null
        $TokenPrs
        $Sql.Substring($Start,($end-$Start)+1)
    }catch{
        $TokenPrs = $null
    }    
}