$VMSwitches = Get-VMSwitch | Where-Object -FilterScript { $_.SwitchType -Eq "External" -Or $_.SwitchType -Eq "Internal" }
$VMSwitchNames = $VMSwitches | Select-Object -ExpandProperty Name
$HostNetworkAdapters = @{}
ForEach($VMSwitchName in $VMSwitchNames) {
    $HostNetworkAdapterName = "vEthernet ($VMSwitchName)"
    $HostNetworkAdapters[$VMSwitchName] = Get-NetAdapter -Name $HostNetworkAdapterName
}


ForEach($VM in @(Get-VM)) {
    ForEach($VMNetworkAdapter in @(Get-VMNetworkAdapter -VM $VM)) {


        If($HostNetworkAdapters.ContainsKey($VMNetworkAdapter.SwitchName)) {
            ForEach($VMIPAddress in $VMNetworkAdapter.IPAddresses) {
                $VMIPAddress = [System.Net.IPAddress]::Parse($VMIPAddress)
                $Line = Switch($VMIPAddress.AddressFamily) {
                    "InterNetwork" {
                        "$VMIPAddress"
                    }
                    "InterNetworkV6" {
                        $HostInterfaceIndex = $HostNetworkAdapters[$VMNetworkAdapter.SwitchName].IfIndex
                        "$VMIPAddress%$HostInterfaceIndex"
                    }
                    default {}
                }
                $Line = $Line.PadRight(64, " ")
                $Line = "$Line $($VM.Name.ToLower())"
                $Line
            }
        }
        
        
    }
}

