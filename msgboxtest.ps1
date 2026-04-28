$source = @"
using System;
using System.Runtime.InteropServices;

public class MsgBoxDemo {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int MessageBox(IntPtr hWnd, String text, String caption, uint type);
    
    public static void Show(string message) {
        MessageBox(IntPtr.Zero, message, "Add-Type Demo", 0);
    }
}
"@

# Compile the C# source. By default Add-Type emits a temp DLL in 
# %LOCALAPPDATA%\Temp with a randomized name (something like 
# abc123de.dll) and loads it into the current PowerShell AppDomain.
Add-Type -TypeDefinition $source -Language CSharp

# Now [MsgBoxDemo] is available as a .NET type in this PowerShell session.
[MsgBoxDemo]::Show("Hello from a runtime-compiled DLL")
