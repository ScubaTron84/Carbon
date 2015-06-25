# Copyright 2012 Aaron Jensen
# 
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

function Install-Msi
{
    <#
    .SYNOPSIS
    Runs an MSI installer.

    .DESCRIPTION
    There are two problems running an MSI (for MicroSoft Installer):
    
     * The installer runs asynchronously, which means running/invoking it returns immediately, with no notification about whether it succeeded or failed.
     * A UI is shown.
    
    This function will run an MSI installer and wait for the MSI to finish.  If the install process returns a non-zero exit code, an error will be written.
    
    You can optionally run the installer in quiet mode.  This hides any installer UI and installs the package with the default options.
    
    .EXAMPLE
    Install-Msi -Path Path\to\installer.msi
    
    Runs installer.msi, and waits untils for the installer to finish.  If the installer has a UI, it is shown to the user.

    .EXAMPLE
    Get-ChildItem *.msi | Install-Msi

    Demonstrates how to pipe MSI files into `Install-Msi` for installation.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [Alias('FullName')]
        [string[]]
        # The path to the installer to run. Wildcards supported.
        $Path,
        
        [Switch]
        # This switch is ignored. Installers are run in quiet mode by default.
        $Quiet,

        [Switch]
        # Install the MSI even if it has already been installed. Will cause a repair/reinstall to run.
        $Force
    )

    Set-StrictMode -Version 'Latest'
    
    Get-Msi -Path $Path |
        ForEach-Object {
            $msi = $_
            if( $PSCmdlet.ShouldProcess( $msi.Path, "install" ) )
            {
                $msiProcess = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i",$msi.Path,"/quiet" -NoNewWindow -Wait -PassThru

                if( $msiProcess.ExitCode -ne $null -and $msiProcess.ExitCode -ne 0 )
                {
                    Write-Error ("{0} {1} installation failed. (Exit code: {2}; MSI: {3})" -f $msi.ProductName,$msi.ProductVersion,$msiProcess.ExitCode,$msi.Path)
                }
            }
        }
}

Set-Alias -Name 'Invoke-WindowsInstaller' -Value 'Install-Msi'