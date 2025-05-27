---
lab:
    title: 'Lab: Implementing Hyper-V Replica and Windows Server Backup'
    module: 'Module 4: Disaster Recovery in Windows Server'
---

# Lab: Implementing Hyper-V Replica and Windows Server Backup

## Scenario

You're working as an administrator at Contoso, Ltd. Contoso wants to assess and configure new disaster recovery and backup features and technologies. As the system administrator, you have been tasked with performing that assessment and implementation. You decided to evaluate **Hyper-V Replica** and Windows Server Backup.

## Objectives

After completing this lab, you'll be able to:

- Configure and implement **Hyper-V Replica**.
- Configure and implement backup with Windows Server Backup.

## Estimated time: 45 minutes

## Lab setup

Virtual machines: **AZ-801T00A-SEA-DC1**, **AZ-801T00A-SEA-SVR1**, and **AZ-801T00A-SEA-SVR2** must be running. Other VMs can be running, but they aren't required for this lab.

> **Note**: **AZ-801T00A-SEA-DC1**, **AZ-801T00A-SEA-SVR1**, and **AZ-801T00A-SEA-SVR2** virtual machines are hosting the installation of **SEA-DC1**, **SEA-SVR1**, and **SEA-SVR2**

1. Select **SEA-SVR2**.
1. Sign in using the credentials provided by the instructor.

For this lab, you'll use the available VM environment.

## Exercise 1: Implementing Hyper-V Replica

### Scenario

Before you start with a cluster deployment, you have decided to evaluate the new technology in Hyper-V for replicating VMs between hosts. You want to be able to manually mount a copy of a VM on another host if the active copy or host fails.

The main tasks for this exercise are to:

1. Install and configure Hyper-V Replica.
1. Configure Hyper-V replication.
1. Validate a failover.

#### Task 1: Install and configure Hyper-V Replica

1. On **SEA-SVR2**, start Windows PowerShell as administrator.
1. To identify the status of the Windows Defender Firewall with Advanced Security **Hyper-V Replica HTTP Listener (TCP-In)** rule on **SEA-SVR2**, at the Windows PowerShell prompt, run the following command:

   ```powershell
   Get-NetFirewallRule -DisplayName 'Hyper-V Replica HTTP Listener (TCP-In)'
   ```

1. To enable the Windows Defender Firewall with Advanced Security **Hyper-V Replica HTTP Listener (TCP-In)** rule on **SEA-SVR2**, at the Windows PowerShell prompt, run the following command:

   ```powershell
   Enable-NetFirewallRule -DisplayName 'Hyper-V Replica HTTP Listener (TCP-In)'
   ```

1. To configure **SEA-SVR2** as a Replica server for **Hyper-V Replica**, run the following commands:

   ```powershell
   New-Item -ItemType Directory -Path C:\ReplicaStorage -Force
   Set-VMReplicationServer -ReplicationEnabled $true -AllowedAuthenticationType Kerberos -KerberosAuthenticationPort 8080 -ReplicationAllowedFromAnyServer $true -DefaultStorageLocation C:\ReplicaStorage
   ```

1. To verify that **SEA-SVR2** is configured as a Replica server for **Hyper-V Replica**, run the following command:

   ```powershell
   Get-VMReplicationServer
   ```
  
   > **Note**: Verify that the output of the command includes the following settings:

   - **RepEnabled: True**
   - **AuthType: Kerb**
   - **KerAuthPort: 8080**
   - **CertAuthPort: 443**
   - **AllowAnyServer: True**

1. To identify the virtual machines present on **SEA-SVR2**, at the Windows PowerShell prompt, run the following command:

   ```powershell
   Get-VM
   ```

   > **Note**: Verify that the output of the command includes **SEA-CORE1**. 

   > **Note**: Leave the **Administrator: Windows PowerShell** window open.

1. On **SEA-SVR2**, open another Windows PowerShell window as administrator.
1. To establish a PowerShell Remoting session to **SEA-SVR1**, in the newly opened Windows PowerShell window, enter the following command, and then press Enter:

   ```powershell
   Enter-PSSession -ComputerName SEA-SVR1.contoso.com
   ```
 
   > **Note**: You can recognize the PowerShell Remoting session based on the PowerShell prompt that contains, in this case, the **[SEA-SVR1.contoso.com]** prefix.

1. To identify the status of the Windows Defender Firewall with Advanced Security **Hyper-V Replica HTTP Listener (TCP-In)** rule on **SEA-SVR1**, in the Windows PowerShell window hosting the PowerShell Remoting session to **SEA-SVR1**, run the following command:

   ```powershell
   Get-NetFirewallRule -DisplayName 'Hyper-V Replica HTTP Listener (TCP-In)'
   ```

   > **Note**: Review the output and verify that the **Enabled** property is set to **False**. To use **Hyper-V Replica**, you need to enable this firewall rule.

1. To enable the Windows Defender Firewall with Advanced Security **Hyper-V Replica HTTP Listener (TCP-In)** rule on **SEA-SVR1**, in the Windows PowerShell window hosting the PowerShell Remoting session to **SEA-SVR1**, run the following command:

   ```powershell
   Enable-NetFirewallRule -DisplayName 'Hyper-V Replica HTTP Listener (TCP-In)'
   ```

1. To configure **SEA-SVR1** as a Replica server for **Hyper-V Replica**, in the Windows PowerShell window hosting the PowerShell Remoting session to **SEA-SVR1**, run the following commands:

   ```powershell
   New-Item -ItemType Directory -Path C:\ReplicaStorage -Force
   Set-VMReplicationServer -ReplicationEnabled $true -AllowedAuthenticationType Kerberos -ReplicationAllowedFromAnyServer $true -DefaultStorageLocation C:\ReplicaStorage
   ```

   > **Note**: Leave the second **Administrator: Windows PowerShell** window open.

#### Task 2: Configure Hyper-V replication

1. On **SEA-SVR2**, switch to the **Administrator: Windows PowerShell** window displaying the local PowerShell session.
1. To enable replication of the virtual machine **SEA-CORE1** from **SEA-SVR2** to **SEA-SVR1**, on **SEA-SVR2**, at the Windows PowerShell prompt of the local session, run the following command:

   ```powershell
   Enable-VMReplication SEA-CORE1 -ReplicaServerName SEA-SVR1.contoso.com -ReplicaServerPort 80 -AuthenticationType Kerberos -ComputerName SEA-SVR2.contoso.com
   ```

1. To start replication of the virtual machine **SEA-CORE1** from **SEA-SVR2** to **SEA-SVR1**, on **SEA-SVR2**, run the following command:

   ```powershell
   Start-VMInitialReplication SEA-CORE1
   ```

1. To identify status of replication of the virtual machine **SEA-CORE1** from **SEA-SVR2** to **SEA-SVR1** was successfully started, run the following command:

   ```powershell
   Get-VMReplication
   ```

   > **Note**: In the output of the command, identify the **State** value and verify it is listed as **InitialReplicationInProgress**. Wait for about 5 minutes, rerun the same command, and verify that the **State** value changed to **Replicating**. Wait until this happens before you proceed to the next steps. In addition, ensure that **Primary server** is listed as **SEA-SVR2** and **ReplicaServer** is listed as **SEA-SVR1**.

1. On **SEA-SVR2**, switch to the **Administrator: Windows PowerShell** window displaying the PowerShell Remoting session to **SEA-SVR1**.
1. To verify that a replica of **SEA-CORE1** is present on **SEA-SVR1**, in the Windows PowerShell window hosting the PowerShell Remoting session to **SEA-SVR1**, run the following command:

   ```powershell
   Get-VM
   ```

   > **Note**: Ensure that the output of the command lists **SEA-CORE1**.

   > **Note**: Leave both Windows PowerShell sessions open.

##### Task 3: Validate a failover

1. On **SEA-SVR2**, switch to the **Administrator: Windows PowerShell** window displaying the local PowerShell session.
1. To prepare for a failover of the **SEA-CORE1** virtual machine to **SEA-SVR1**, on **SEA-SVR2**, in the Windows PowerShell window hosting the local session, run the following command:

   ```powershell
   Start-VMFailover -Prepare -VMName SEA-CORE1 -ComputerName SEA-SVR2.contoso.com
   ```

   > **Note**: When prompted, enter **Y**, and then press Enter. This command prepares for the planned failover of **SEA-CORE1** by triggering the replication of any pending changes.

1. On **SEA-SVR2**, switch to the **Administrator: Windows PowerShell** window displaying the PowerShell Remoting session to **SEA-SVR1**.
1. To initiate a failover of the **SEA-CORE1** virtual machine to **SEA-SVR1**, on **SEA-SVR2**, in the Windows PowerShell window hosting the PowerShell Remoting session to **SEA-SVR1**, run the following command:

   ```powershell
   Start-VMFailover -VMName SEA-CORE1 -ComputerName SEA-SVR1.contoso.com
   ```

1. To configure the replica VM as the primary VM, on **SEA-SVR2**, in the Windows PowerShell window hosting the PowerShell Remoting session to **SEA-SVR1**, run the following command:

   ```powershell
   Set-VMReplication -Reverse -VMName SEA-CORE1 -ComputerName SEA-SVR1.contoso.com
   ```

1. To start the newly designated primary VM on **SEA-SVR1**, on **SEA-SVR2**, in the Windows PowerShell window hosting the PowerShell Remoting session to **SEA-SVR1**, run the following command:

   ```powershell
   Start-VM -VMName SEA-CORE1 -ComputerName SEA-SVR1.contoso.com
   ```

1. To verify that the VM was successfully started, on **SEA-SVR2**, in the Windows PowerShell window hosting the PowerShell Remoting session to **SEA-SVR1**, run the following command:

   ```powershell
   Get-VM
   ```

   > **Note**: In the result table, verify that **State** is listed as **Running**.

1. To identify the status of the replication of the virtual machine **SEA-CORE1** from **SEA-SVR1** to **SEA-SVR2**, on **SEA-SVR2**, in the Windows PowerShell window hosting the PowerShell Remoting session to **SEA-SVR1**, run the following command:

   ```powershell
   Get-VMReplication
   ```

   > **Note**: In the output of the command, identify the **State** value and verify it is listed as **Replicating**. In addition, ensure that **Primary server** is listed as **SEA-SVR1** and **ReplicaServer** as **SEA-SVR2**.

1. To stop the replicating VM on the primary server, on **SEA-SVR2**, in the Windows PowerShell window hosting the PowerShell Remoting session to **SEA-SVR1**, run the following command:

   ```powershell
   Stop-VM -VMName SEA-CORE1
   ```

1. Leave both Windows PowerShell windows open.

   > **Note**: If you want to verify the results of this exercise by using graphical tools, you can use Hyper-V Manager on **SEA-SVR2**, and then add the **SEA-SVR1** and **SEA-SVR2** servers to the **Hyper-V** console. You can then verify that the **SEA-CORE1** VM exists on both **SEA-SVR1** and **SEA-SVR2** and that replication is running from **SEA-SVR2** to **SEA-SVR1**.

## Exercise 2: Implementing backup and restore with Windows Server Backup

### Scenario

You must evaluate Windows Server Backup for your member servers. You decided to configure Windows Server Backup of the **SEA-SVR2** server and to perform a trial backup to the network share on **SEA-SVR2**.

The main tasks for this exercise are to:

1. Configure Windows Server Backup settings.
1. Perform a backup to a network share.

#### Task 1: Configure Windows Server Backup settings

1. On **SEA-SVR2**, use File Explorer to create a **C:\\BackupShare** folder on **SEA-SVR2**. Share the folder so that **Authenticated Users** have Read/Write permissions.
1. On **SEA-SVR2**, switch to the **Administrator: Windows PowerShell** window displaying the PowerShell Remoting session to **SEA-SVR1**.
1. In the PowerShell Remoting session to **SEA-SVR1**, use the **Install-WindowsFeature** cmdlet to install the **Windows-Server-Backup** feature on **SEA-SVR1**.
1. In the PowerShell Remoting session to **SEA-SVR1**, use the **wbadmin /?** and **Get-Command** commands to review the functionality of the **wbadmin** utility and the cmdlets of the **WindowsServerBackup** module.

#### Task 2: Perform a backup to a network share

1. From **SEA-SVR2**, create the folder and files to be backed up on **SEA-SVR1** by using the PowerShell Remoting session to **SEA-SVR1** to run the following commands:

   ```powershell
   New-Item -ItemType Directory -Path 'C:\Files' -Force
   fsutil file createnew C:\Files\report1.docx 25432108
   fsutil file createnew C:\Files\report2.docx 25432108
   fsutil file createnew C:\Files\report3.docx 25432108
   fsutil file createnew C:\Files\report4.docx 25432108
   ```

1. To define the variables for backup policy and the file path to back up by using Windows Server Backup, on **SEA-SVR2**, in the Windows PowerShell window hosting the PowerShell Remoting session to **SEA-SVR1**, run the following commands:

   ```powershell
   $policy = New-WBPolicy
   $fileSpec = New-WBFileSpec -FileSpec 'C:\Files'
   ```

1. To define a Windows Server Backup policy that references the variables you defined in the previous step, on **SEA-SVR2**, use the PowerShell Remoting session to **SEA-SVR1** to run the following command:

   ```powershell
   Add-WBFileSpec -Policy $policy -FileSpec $fileSpec
   ```

1. To configure a backup location on the **SEA-SVR2** using the network share you created in the previous task, on **SEA-SVR2**, use the PowerShell Remoting session to **SEA-SVR1** to run the following commands (when prompted to sign in, enter the credentials provided by the instructor.):

   ```powershell
   $cred = Get-Credential
   $networkBackupLocation = New-WBBackupTarget -NetworkPath "\\SEA-SVR2.contoso.com\BackupShare" -Credential $cred
   ```

1. To add the backup location to the backup policy, use the PowerShell Remoting session to **SEA-SVR1** to run the following command:

   ```powershell
   Add-WBBackupTarget -Policy $policy -Target $networkBackupLocation
   ```

1. To enable Volume Shadow Copy Service, use the PowerShell Remoting session to **SEA-SVR1** to run the following command:

   ```powershell
   Set-WBVssBackupOptions -Policy $policy -VssCopyBackup
   ```

1. To start a backup job, use the PowerShell Remoting session to **SEA-SVR1** to run the following command:

   ```powershell
   Start-WBBackup -Policy $policy
   ```

   > **Note**: Wait until the backup completes. This should take about 1 minute.

1. On **SEA-SVR2**, switch to File Explorer, browse to **C:\\BackupShare**, and then verify that the folder includes the newly created backup in the **WindowsImageBackup** subfolder.
