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

function Disable-CFirewallStatefulFtp
{
    <#
    .SYNOPSIS
    Disables the `StatefulFtp` Windows firewall setting.

    .DESCRIPTION
    Uses the `netsh` command to disable the `StatefulFtp` Windows firewall setting.

    If the firewall isn't configurable, writes an error and returns without making any changes.

    .LINK
    Assert-CFirewallConfigurable

    .EXAMPLE
    Disable-CFirewallStatefulFtp

    Disables the `StatefulFtp` Windows firewall setting.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
    )

    Set-StrictMode -Version 'Latest'

    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    if( -not (Assert-CFirewallConfigurable) )
    {
        return
    }
    
    Invoke-ConsoleCommand -Target 'firewall' `
                          -Action 'disabling stateful FTP' `
                          -ScriptBlock {
        netsh advfirewall set global StatefulFtp disable
    }
}

