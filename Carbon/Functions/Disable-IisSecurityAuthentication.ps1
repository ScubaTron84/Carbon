# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

function Disable-CIisSecurityAuthentication
{
    <#
    .SYNOPSIS
    Disables anonymous or basic authentication for all or part of a website.

    .DESCRIPTION
    By default, disables an authentication type for an entire website.  You can disable an authentication type at a specific path under a website by passing the virtual path (*not* the physical path) to that directory as the value of the `VirtualPath` parameter.

    Beginning with Carbon 2.0.1, this function is available only if IIS is installed.

    .LINK
    Enable-CIisSecurityAuthentication

    .LINK
    Get-CIisSecurityAuthentication
    
    .LINK
    Test-CIisSecurityAuthentication
    
    .EXAMPLE
    Disable-CIisSecurityAuthentication -SiteName Peanuts -Anonymous

    Turns off anonymous authentication for the `Peanuts` website.

    .EXAMPLE
    Disable-CIisSecurityAuthentication -SiteName Peanuts Snoopy/DogHouse -Basic

    Turns off basic authentication for the `Snoopy/DogHouse` directory under the `Peanuts` website.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The site where anonymous authentication should be set.
        $SiteName,
        
        [Alias('Path')]
        [string]
        # The optional path where anonymous authentication should be set.
        $VirtualPath = '',

        [Parameter(Mandatory=$true,ParameterSetName='Anonymous')]
        [Switch]
        # Enable anonymouse authentication.
        $Anonymous,
        
        [Parameter(Mandatory=$true,ParameterSetName='Basic')]
        [Switch]
        # Enable basic authentication.
        $Basic,
        
        [Parameter(Mandatory=$true,ParameterSetName='Windows')]
        [Switch]
        # Enable Windows authentication.
        $Windows
    )
    
    Set-StrictMode -Version 'Latest'

    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    $authType = $pscmdlet.ParameterSetName
    $getArgs = @{ $authType = $true; }
    $authSettings = Get-CIisSecurityAuthentication -SiteName $SiteName -VirtualPath $VirtualPath @getArgs
    
    if( -not $authSettings.GetAttributeValue('enabled') )
    {
        return
    }

    $authSettings.SetAttributeValue('enabled', 'False')
    $fullPath = Join-CIisVirtualPath $SiteName $VirtualPath
    if( $pscmdlet.ShouldProcess( $fullPath, ("disable {0} authentication" -f $authType) ) )
    {
        $authSettings.CommitChanges()
    }
}


