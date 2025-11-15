# Default setup for new PC

This 'pc_setup.ps1' script allows you to automate the installation of new applications such as: Adobe Reader, Chrome browser, MS Office 2024 LTS, as well as perform some minor modifications on your computer, such as: formatting the second disk to save new data, changing the position of the bottom toolbar.

Paste all the installation files into a folder and share the Windows folder on the network [Sharing Guide](https://www.youtube.com/watch?v=Ameo1hwrsv8). The rest of the apps I used can be downloaded from their official websites. Download links:
- [Adobe Acrobat Reader](https://get.adobe.com/reader)
- [Chrome Browser](https://www.google.com/intl/en_en/chrome)
- [Office Deployment Tool](https://www.microsoft.com/en-us/download/details.aspx?id=49117)
- [Office Customization Tool](https://config.office.com/deploymentsettings)

```Remember not to change the file names, or the script won't work```

### Run Script
1. Download the repository. Click 'Search' in the left corner -> write 'Windows PowerShell' -> Right-Click -> click 'Run as Administrator' -> paste the following command in the terminal: ```Expand-Archive -Path "$env:USERPROFILE\Downloads\default-setup-new-pc-main.zip" -DestinationPath "$env:USERPROFILE\Downloads\default-setup-new-pc-main" -Force```

2. Enter the folder and edit 'pc_setup.ps1' using Notepad, WordPad or Visual Studio Code. Find the variable section. I have briefly explained what the variables are used for in the file. Save the script after making modifications.

3. Open the Windows PowerShell window ('Run as Administrator') and paste the following command into the terminal: ``` Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$env:USERPROFILE\Downloads\default-setup-new-pc-main\default-setup-new-pc-main\pc_setup.ps1`"" ```

4. After run script, you can select the application you want to install. 
Avaliable options:
"[1] Install Chrome"
"[2] Install Adobe Reader"
"[3] Install MS Office 2024 LTS"
"[4] Change the toolbar"
"[5] Clean up disk"
For example, if you want to install everything, you need to enter ```1,2,3,4,5``` in the command line (CLI). Remember to change the variables and be careful, as you can format the operating system drive using the command.

The last thing to do is change the default applications in Windows settings. For .pdf files, we replace them with Adobe Reader and for .html files, we also change the HTTP and HTTPS protocols to the Chrome browser.

Documentatnion:
[Adobe Acrobat Reader Documentation](https://helpx.adobe.com/pdf/adobe_reader_reference.pdf)
[Google Chrome Documentation](https://developer.chrome.com/docs?hl=en)
[Office Customization Tool Documentation](https://learn.microsoft.com/pl-pl/microsoft-365-apps/admin-center/overview-office-customization-tool)
[Office Deployment Tool Documentation](https://learn.microsoft.com/pl-pl/microsoft-365-apps/deploy/overview-office-deployment-tool)