---
lab:
    title: 'Lab: Configuring security in Windows Server'
    module: 'Module 1: Windows Server security'
---

# Lab: Configuring security in Windows Server

## Scenario

Contoso Pharmaceuticals is a medical research company with about 5,000 employees worldwide. They have specific needs for ensuring that medical records and data remain private. The company has a headquarters location and multiple worldwide sites. Contoso has recently deployed a Windows Server and Windows client infrastructure. You have been asked to implement improvements in the server security configuration.

**Note:** An **[interactive lab simulation](https://mslabs.cloudguides.com/guides/AZ-801%20Lab%20Simulation%20-%20Configuring%20security%20in%20Windows%20Server)** is available that allows you to click through this lab at your own pace. You may find slight differences between the interactive simulation and the hosted lab, but the core concepts and ideas being demonstrated are the same. 

## Objectives

After completing this lab, you will be able to:

- Configure Windows Defender Credential Guard.
- Locate problematic user accounts.
- Implement and verify LAPS (Local Administrator Password Solution).

## Estimated time: 40 minutes

## Lab setup

Virtual machines: **AZ-801T00A-SEA-DC1**, **AZ-801T00A-SEA-SVR1**, and **AZ-801T00A-SEA-SVR2** must be running. Other VMs can be running, but they aren't required for this lab.

> **Note**: **AZ-801T00A-SEA-DC1**, **AZ-801T00A-SEA-SVR1**, and **AZ-801T00A-SEA-SVR2** virtual machines are hosting the installation of **SEA-DC1**, **SEA-SVR1**, and **SEA-SVR2**.

1. Select **SEA-SVR2**.
1. Sign in using the credentials provided by the instructor.

For this lab, you'll use the available VM environment.

## Exercise 1: Configuring Windows Defender Credential Guard

### Scenario

You decided to implement Windows Defender Credential Guard on the servers and administrative workstations to protect against Pass-the-Hash and Pass-the-Ticket credential thefts. You will use Group Policy to enable Credential Guard on your existing servers. For all new servers, you will use the Hypervisor-Protected Code Integrity (HVCI) and Windows Defender Credential Guard hardware readiness tool to enable Credential Guard before the new servers are domain-joined.

In this lab, you will set up the Group Policy and run the HVCI and Windows Defender Credential Guard hardware readiness tool on an existing server.

> **Note**: In the lab environment, Credential Guard will not be available on VMs because they don't meet the prerequisites. This, however, will not prevent you from stepping through the process of implementing it by using Group Policy and evaluating its readiness by using corresponding tools.

The main tasks for this exercise are to:

1. Enable Windows Defender Credential Guard using Group Policy.
1. Enable Windows Defender Credential Guard using the HVCI and Windows Defender Credential Guard hardware readiness tool.

#### Task 1: Enable Windows Defender Credential Guard using Group Policy

1. On **SEA-SVR2**, open the **Group Policy Management** console.
1. In the **Group Policy Management** console, browse through **Forest: contoso.com**, **Domains**, **contoso.com**, and then create a Group Policy Object (GPO) named **CredentialGuard_GPO** linked to the **IT** organizational unit (OU).
1. Open **CredentialGuard_GPO** in the Group Policy Management Editor and browse to the **Computer Configuration\\Policies\\Administrative Templates\\System\\Device Guard** node.
1. Enable the **Turn On Virtualization Based Security** option with the following settings:

   - Select Platform Security Level: **Secure Boot and DMA Protection**.
   - Credential Guard Configuration: **Enabled with UEFI lock**.
   - Secure Launch Configuration: **Enabled**

1. Close the **Group Policy Management Editor** window.
1. Close the **Group Policy Management** console window.

#### Task 2: Enable Windows Defender Credential Guard using the HVCI and Windows Defender Credential Guard hardware readiness tool

1. On **SEA-SVR2**, start Windows PowerShell as administrator.
1. To run the HVCI and Windows Defender Credential Guard hardware readiness tool, at the Windows PowerShell command prompt, run the following commands:

   ```powershell
   Set-Location -Path C:\Labfiles\Lab01\
   .\DG_Readiness_Tool.ps1 -Enable -AutoReboot
   ```

1. Wait until the tool completes its run and follow the prompts to restart the operating system.
1. Once the restart completes, sign back into **SEA-SVR2** with the credentials provided by the instructor.

### Results

After completing this exercise, you will have:

1. Used Group Policy to implement Windows Defender Credential Guard on all computers in your organization.
1. Enabled Windows Defender Credential guard immediately on your local computer.

## Exercise 2: Locating problematic accounts

### Scenario

You want to check whether your organization has user accounts with passwords that are configured not to expire and remediate this setting. You also want to check which accounts haven’t signed in for 90 days or more and disable them.

The main tasks for this exercise are to:

1. Locate and reconfigure domain accounts with non-expiring passwords.
1. Locate and disable domain accounts that have not been used to sign in for at least 90 days.

#### Task 1: Locate and reconfigure domain accounts with non-expiring passwords

1. On **SEA-SVR2**, start Windows Powershell as administrator.
1. To list Active Directory-enabled user accounts with a non-expiring password, at the Windows PowerShell command prompt, run the following command:

   ```powershell
   Get-ADUser -Filter {Enabled -eq $true -and PasswordNeverExpires -eq $true}
   ```

1. Review the list of user accounts returned.
1. To enable password expiration for all user accounts in the result set, at the Windows PowerShell command prompt, run the following command:

   ```powershell
   Get-ADUser -Filter {Enabled -eq $true -and PasswordNeverExpires -eq $true} | Set-ADUser -PasswordNeverExpires $false
   ```

1. To verify the outcome, rerun the command from step 2 and notice that no results are returned.

#### Task 2: Locate and disable domain accounts that have not been used to sign in for at least 90 days

1. To identify Active Directory user accounts that have not been used to sign in for at least 90 days, at the Windows PowerShell command prompt, run the following command:

   ```powershell
   $days = (Get-Date).AddDays(-90)
   Get-ADUser -Filter {LastLogonTimeStamp -lt $days -and enabled -eq $true} -Properties LastLogonTimeStamp
   ```

   > **Note**: In the lab environment, no results will be returned.

1. To disable Active Directory user accounts that have not been used to sign in for at least 90 days, run the following command:

   ```powershell
   Get-ADUser -Filter {LastLogonTimeStamp -lt $days -and enabled -eq $true} -Properties LastLogonTimeStamp | Disable-ADAccount
   ```

   > **Note**: In the lab environment, no results will be returned.

## Exercise 3: Implementing LAPS

### Scenario

At present, the same local administrator account password is used across all servers and workstations at Contoso. To remedy this problem, you will configure and deploy LAPs.

The main tasks for this exercise are to:

1. Prepare computer accounts for implementing LAPS (Local Administrator Password Solution).
1. Prepare Active Directory (AD DS) for LAPS.
1. Deploy LAPS client-side extension.
1. Verify LAPS.

#### Task 1: Prepare computer accounts for implementing LAPS (Local Administrator Password Solution)

1. To create a designated OU and move the **SEA-SVR1** computer account to it, on **SEA-SVR2**, at the Windows PowerShell command prompt, run the following command:

   ```powershell
   New-ADOrganizationalUnit -Name "Seattle_Servers"
   Get-ADComputer SEA-SVR1 | Move-ADObject –TargetPath "OU=Seattle_Servers,DC=Contoso,DC=com"
   ```

1. To install LAPS, at the Windows PowerShell command prompt, run the following command:

   ```powershell
   Msiexec /i C:\Labfiles\Lab01\LAPS.x64.msi
   ```

1. When prompted, step through the **Welcome to the Local Administrator Password Solution Setup Wizard** with the default settings until you reach the **Custom Setup** page.
1. On the **Custom Setup** page of the **Local Administrator Password Solution Setup** wizard, in the drop-down menu next to **Management Tools**, select **Entire feature will be installed on the local hard drive**, and complete the wizard by accepting the default settings and launching the setup. 
1. Wait until the setup completes. 
1. To enable the Windows Defender Firewall with Advanced Security rule that allows incoming Server Message Block (SMB) connections from other domain-joined servers, at the Windows PowerShell command prompt, enter the following commands, and after each, press Enter:

   ```
   $rule = Get-NetFirewallRule | Where-Object DisplayName -eq 'File and Printer Sharing (SMB-In)' 
   $rule | Set-NetFirewallRule -Profile Domain
   $rule | Enable-NetFirewallRule
   ```

   > **Note**: This is required to connect to **SEA-SVR2** from **SEA-SVR1** later in this lab.

#### Task 2: Prepare AD DS for LAPS

1. To prepare the domain for LAPS, on **SEA-SVR2**, at the Windows PowerShell command prompt, run the following commands:

   ```powershell
   Import-Module admpwd.ps
   Update-AdmPwdADSchema
   Set-AdmPwdComputerSelfPermission -Identity "Seattle_Servers"
   ```

1. On *SEA-SVR2** open **Group Policy Management** console.
1. In the **Group Policy Management** console, browse through **Forest: contoso.com**, **Domains**, **contoso.com**, and then create a Group Policy Object (GPO) named **LAPS_GPO** linked to the **Seattle_Servers** OU.
1. Open **LAPS_GPO** in the Group Policy Management Editor and browse to the **Computer Configuration\\Policies\\Administrative Templates\\LAPS** node.
1. Enable the **Enable local admin password management** option.
1. Configure the **Password Settings** option with the following settings:

   - Select Platform Security Level: **Secure Boot and DMA Protection**.
   - Credential Guard Configuration: **Enabled with UEFI lock**.
   - Secure Launch Configuration: **Enabled**

1. Close the Group Policy Management Editor window.

   - Password Length: **20**
   - Password Age (Days): **30**

1. Close the Group Policy Management Editor.
1. Close the **Group Policy Management** console window.

#### Task 3: Deploy LAPS client-side extension

1. Switch to the console session to **SEA-SVR1** and then, if needed, sign in with the credentials provided by the instructor.

   > **Note:** You will be prompted to change your password, as a result of running in the previous exercise the script that enables password expiration. Choose an arbitrary password and use it throughout the remainder of the lab.

1. Once you sign in, to access the Windows PowerShell command prompt, exit the **SConfig** menu.
1. To install LAPS silently with the default settings, at the Windows PowerShell command prompt, run the following command:

   ```powershell
   Start-Process msiexec.exe -Wait -ArgumentList '/i \\SEA-SVR2.contoso.com\c$\Labfiles\Lab01\LAPS.x64.msi /quiet'
   ```

1. To trigger the processing of Group Policy that will apply LAPS settings locally, at the Windows PowerShell command prompt, run the following command:

   ```powershell
   gpupdate /force
   ```

#### Task 4: Verify LAPS

1. Switch to the console session to **SEA-SVR2**.
1. From the **Start** menu, launch **LAPS UI**.
1. In the **LAPS UI** dialog box, in the **ComputerName** text box, enter **SEA-SVR1**, and then select **Search**.
1. Review the **Password** and the **Password expires** values, and then select **Exit**.
1. Switch to the **Windows PowerShell** console and then, to verify the value of the password, at the Windows PowerShell command prompt, run the following command:

   ```powershell
   Get-ADComputer -Identity SEA-SVR1 -Properties ms-Mcs-AdmPwd
   ```

1. Review the password assigned to SEA-SVR1 and note that it matches the one displayed in the **LAPS UI** tool.

   > **Note:** The value of the password is, in this case, enclosed in a pair of braces.

### Results

After completing this exercise, you will have:

- Prepared an OU and computer accounts for LAPS.
- Prepared your AD DS for LAPS.
- Deployed LAPS client-side extension.
- Verified that you implemented LAPS successfully.
