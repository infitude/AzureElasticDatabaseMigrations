#
# Script.ps1
#


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
git status
git commit -m "Commit 1"
git status

# copy the second commit files over (remove the Commit_2 from the name)
Get-ChildItem -Path C:\Projects\GitHub\AzureElasticDatabaseMigrations\SampleDatabaseProject -Recurse | ?{$_.Name -like "*_Commit_2.sql"} | % {
	$copyto = "C:\Temp\SampleDatabase\" + $_.Name.Replace("_Commit_2","")
	$copyto
	Copy-Item $_.FullName $copyto 

	git add $copyto 
}

# check status and commit
git status
git commit -m "Commit 2"
git status

git log


# put me back into project folder
#Set-Location -Path C:\Projects\GitHub\AzureElasticDatabaseMigrations\SampleDatabaseProject