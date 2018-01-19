function Add-MsSqlUserWithRole(
    [Parameter(Mandatory)][string] $ServerAddress, 
    [Parameter(Mandatory)][String] $DatabaseName, 
    [Parameter(Mandatory)][string] $UserName, 
    [Parameter(Mandatory)][string[]] $Roles
) {
    # Check if Assembly is already loaded...
    if (([appdomain]::CurrentDomain.GetAssemblies() | Where-Object {
            $_.Location -ne $null -and $_.Location.Contains('Microsoft.SqlServer.Smo')}) -eq $null
    ) {
        [Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo')
        Write-Output ""
    }

    $sqlServer = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $ServerAddress
    $database = $sqlServer.Databases[$DatabaseName]

    # Check SqlLogin is valid...
    if (-not ($sqlServer.Logins.Contains($UserName))) {
        Write-Error "$User is not a valid user for $ServerAddress"
    }

    # Check database exists...
    if ($database -eq $null) {
        Write-Error ("$DatabaseName is not valid on $ServerAddress. Available databases are: `n" +
            "$($sqlServer.Databases | ForEach-Object {"- $_ `n"})"
        )
    }

     # Check user exists in database...
    if (-not ($database.Users.Contains($UserName))) {
        $user = New-Object ('Microsoft.SqlServer.Management.Smo.User') ($database, $UserName)
        $user.Login = $UserName
        $user.Create()
        Write-Output "Adding $User to $DatabaseName..."
    }
    
    foreach($role in $Roles) {
        # Check role exists in database...
        if ($database.Roles[$role] -eq $null) {
            Write-Error ("$role is not a valid Role in $DatabaseName on $ServerAddress. Available roles are: `n" +
                "$($database.Roles | ForEach-Object {"- $_ `n"})"
            )
        }
        else { # Assign user to database role...
            ($database.Roles[$role]).AddMember($UserName)
            Write-Verbose "Adding $UserName as $role to $DatabaseName"
        }
    }
    Write-Output ""
}

function Publish-MsSqlQuery(
    [Parameter(Mandatory)][string] $ServerAddress, 
    [Parameter(Mandatory)][String] $DatabaseName, 
    [Parameter(Mandatory)][string] $CommandText
) {
    $result # Store the Query Result
    $connection = New-Object System.Data.SqlClient.SQLConnection("Server=$ServerAddress;Database=$DatabaseName;Integrated Security=True");
    $command    = New-Object System.Data.SqlClient.SQLCommand($CommandText, $connection);
    
    try {
        $connection.Open()
        $result = $command.ExecuteNonQuery()
    }
    catch {
        Write-Error ("Could not execute the command `"$($CommandText)`" against the database $DatabaseName 
            $_.Exception.Message `n
            $_.Exception.StackTrace"
        )
    }
    finally {
        $connection.Close()
        $connection = $null
        $command    = $null
    }
    return $result
}

Export-ModuleMember -Function Add-*
Export-ModuleMember -Function Publish-*