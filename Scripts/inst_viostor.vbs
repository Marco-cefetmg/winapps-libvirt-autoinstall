Set colDrivers = wmi.ExecQuery("SELECT * FROM Win32_PNPEntity WHERE ConfigManagerErrorCode <> 0")

For Each objDriver in colDrivers
    WScript.Echo "PNPDeviceID: " & objDriver.PNPDeviceID
    If InStr(objDriver.PNPDeviceID, "PCI\VEN_1AF4&DEV_1042") > 0 Or InStr(objDriver.PNPDeviceID, "PCI\VEN_1AF4&DEV_1001") > 0 Then
        WScript.Echo "Virtio storage detected."
        Dim WshShell
        Set WshShell = CreateObject("WScript.Shell")
        WshShell.Run "pnputil.exe /add-driver ""E:\viostor\w10\amd64\viostor.inf"" /install", 0, True
        Set WshShell = Nothing
    End If
Next