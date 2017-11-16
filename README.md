# Azure Elastic Database Migrations
Manage the development and deployment lifecycle of Azure Elastic Database Migrations using Powershell, GIT, T-SQL and SQL Database elastic jobs.

## Instructions
```
# One time setup
    # Download the repository
    # Unblock the zip
    # Extract the AzureElasticDatabaseMigrations folder to a module path (e.g. $env:USERPROFILE\Documents\WindowsPowerShell\Modules\)

    #Simple alternative, if you have PowerShell 5, or the PowerShellGet module:
        Install-Module AzureElasticDatabaseMigrations

# Import the module.
    Import-Module AzureElasticDatabaseMigrations

# Alternatively,
    Import-Module \\Path\To\AzureElasticDatabaseMigrations  (use -Force to force a reload)

# Get commands in the module
    Get-Command -Module AzureElasticDatabaseMigrations

# Get help
    Get-Help Invoke-Migrations -Full
    Get-Help about_AzureElasticDatabaseMigrations

```


## Overview

AEDM utilises the GIT commit history to create SQL database migration scripts that can be applied to a SQL database schema and data.  A database table records a history of the 'commit scripts' that have been applied to a database.

``
You must be sure that all scripts written are idempotent. That is, the script must be able to run multiple times, even if it has failed before in an incomplete state.
``

### Ordering

Within a GIT commit, the files that have been created or modified are appended in file name order, allowing control over the sequence in which alterations or data changes are applied to the database.

## Usage

The AEDM script can be executed by hand, hooked into the project build tasks of Visual Studio or excuted by a VSTS build task.  In Visual Studio, the commit scripts are run aganst the local or development database. In VSTS, the commit scripts are used in a SQL Database elastic job.

### Register-Migrations

Register creates a log table in SQL Server.  The log table is created either in the local database or the sharding database

### Invoke-Migrations

Migrate checks the log table and creates commit scripts for all commits not current in the database.  Each commit script is applied either directly or via a SQL Database elastic job in a loop.

Invoke-Migrations uses Merge-Migrations to create a commit script for the files in the lastest GIT commit.  Applies this script to the database and updates the log table with the commit id and time.

``
Note: Any files with '__clean' in the filename is ignored by the migrate command, see the clean command for details.
``

### Initialize-Migrations

Initialize creates a commit script by merging from all GIT commits any files with __clean in the filename.  They will be merged in filename order and applied to the database.  The log table is truncated.

## Testing

Tests are run using `Pester`, an example cmd line to execute a test is : 

```
Invoke-Pester -Script "c:\Temp\PSTest\test\AzureElasticDatabaseMigrations.Tests.ps1" -TestName 'Sql Integration Tests'
```

## Development

The IDE used to develop this solution is Visial Studio Code

To turn on debugging (or control verbose messages) ;
```
# turn on verbose and/or debug output;
    $VerbosePreference = "continue"
    $DebugPreference = "continue"

```

## GIT Commands

List files changed in a commit, note this doesn't work on first commit

```
git diff-tree --no-commit-id --name-only -r <commit id>
```

List all commit ids

```
git rev-list HEAD
```

Checkout files in a commit and then get back to master

```
git checkout <commit id>
git checkout master

git read-tree -um <commit id>  *** is this right?
git read-tree -um master
```

## Notes and Links

Get started with elastic database tools;
https://docs.microsoft.com/en-us/azure/sql-database/sql-database-elastic-scale-get-started

Installing Elastic Database jobs overview;
https://docs.microsoft.com/en-us/azure/sql-database/sql-database-elastic-jobs-service-installation

Setting up and using GitHub in Visual Studio 2017;
https://blogs.msdn.microsoft.com/benjaminperkins/2017/04/04/setting-up-and-using-github-in-visual-studio-2017/

Approved Verbs for Windows PowerShell Commands;
https://msdn.microsoft.com/en-us/library/ms714428(v=vs.85).aspx

SQL Parser;
https://sqlblogcasts.com/blogs/sqlandthelike/archive/2012/03/13/parsing-t-sql-the-easy-way.aspx

Replicate git checkout in plumbing commands;
https://stackoverflow.com/questions/24921595/how-to-replicate-git-checkout-using-only-plumbing-commands
