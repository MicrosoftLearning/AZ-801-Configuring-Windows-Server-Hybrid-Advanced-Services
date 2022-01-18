---
lab:
    title: 'Lab: Implementing Azure-based recovery services'
    module: 'Module 5: Planning and implementing migration and recovery services in hybrid scenarios'
---

# Lab: Implementing Azure-based recovery services

## Scenario 
To address concerns regarding the outdated operational model, the limited use of automation, and reliance on tape backups for restores and disaster recovery, you decide to use Microsoft Azure-based recovery services. As the first step, you'll implement Azure Site Recovery and Azure Backup.

## Objectives
After completing this lab, you'll be able to: 

- Create and configure an Azure Site Recovery vault.
- Implement Hyper-V VM protection by using Azure Site Recovery vault.
- Implement Azure Backup.
- Deprovision the Azure lab environment.

## Estimated time: 60 minutes

## Lab setup

Virtual machines: **AZ-801T00A-SEA-DC1**, **AZ-801T00A-SEA-SVR1**, and **AZ-801T00A-SEA-SVR2** must be running. Other VMs can be running, but they aren't required for this lab.

> **Note**: **AZ-801T00A-SEA-DC1**, **AZ-801T00A-SEA-SVR1**, and **AZ-801T00A-SEA-SVR2** virtual machines are hosting the installation of **SEA-DC1**, **SEA-SVR1**, and **SEA-SVR2**

1. Select **SEA-SVR2**.
1. Sign in using the following credentials:

   - Username: **Administrator**
   - Password: **Pa55w.rd**
   - Domain: **CONTOSO**

For this lab, you'll use the available VM environment and an Azure subscription. Before you begin the lab, ensure that you have an Azure subscription and a user account with the Owner or Contributor role in that subscription.

## Exercise 1: Creating and configuring an Azure Site Recovery vault

### Scenario

To implement Azure Site Recovery for VM running in an Azure VM, with Azure as the disaster recovery site, you have to first create and configure an Azure Site Recovery vault.

The main tasks for this exercise are as follows:

1. Create an Azure Site Recovery vault.
1. Configure the Azure Site Recovery vault.

#### Task 1: Create an Azure Site Recovery vault

1. On **SEA-SVR2**, start Microsoft Edge, go to the **[Azure portal](https://portal.azure.com)**, and sign in by using the credentials of a user account with the Owner role in the subscription you'll be using in this lab.
1. In the Azure portal, create a Recovery Services vault with the following settings (leave others with their default values):

   |Setting|Value|
   |---|---|
   |Subscription|the name of the Azure subscription you will be using in this lab|
   |Resource group|the name of a new resource group **AZ801-L0501-RG**|
   |Vault name|**az801l05a-rsvault**|
   |Location|the name of an Azure region where you can create an Azure Recovery Services vault and is close to the location of the lab environment|

   > **Note:** Wait until the Recovery Services vault is provisioned. This should take about 2 minutes.

   > **Note:** By default, the Storage Replication type of the vault is set to Geo-redundant (GRS) and Soft Delete is enabled. You will change these settings in the lab to simplify deprovisioning, but you should ensure they are enabled in your production environments.

#### Task 2: Configure the Azure Site Recovery vault

1. On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, browse to the newly created Azure Recovery Services vault. 
1. In the Azure portal, set the vault's **Storage replication type** to **Locally-redundant**.

   > **Note:** Storage replication type cannot be changed after you implement protection.

1. In the Azure portal, disable the vault's **Soft Delete** and **Security Features** settings.

## Exercise 2: Implementing Hyper-V VM protection by using Azure Site Recovery vault

### Scenario

With a test Hyper-V VM and a Recovery Services vault created, you can now proceed to implement Hyper-V VM protection by using Azure Site Recovery. You will perform a test failover and review the settings of the planned and unplanned failover. 

The main tasks for this exercise are as follows:

1. Implement an Azure recovery site.
1. Prepare protection of a Hyper-V virtual machine.
1. Enable replication of a Hyper-V virtual machine.
1. Review Azure VM replication settings.
1. Perform a failover of the Hyper-V virtual machine.

#### Task 1: Implement an Azure recovery site

1. On **SEA-SVR2**, in the Azure portal, create a virtual network with the following settings (leave others with their default values):

   |Setting|Value|
   |---|---|
   |Subscription|the name of the Azure subscription you are using in this lab|
   |Resource group|the name of a new resource group **AZ801-L0502-RG**|
   |Name|**az801l05-dr-vnet**|
   |Region|the name of the Azure region into which you deployed the Recovery Services vault earlier in this lab|

1. Within the new virtual network, create a subnet with the following settings (leave others with their default values):

   |Setting|Value|
   |---|---|
   |Subnet name|**subnet0**|
   |Subnet address range|**10.5.0.0/24**|

1. On **SEA-SVR2**, in the Azure portal, create another virtual network with the following settings (leave others with their default values):

   |Setting|Value|
   |---|---|
   |Subscription|the name of the Azure subscription you are using in this lab|
   |Resource group|**AZ801-L0502-RG**|
   |Name|**az801l05-test-vnet**|
   |Region|the name of the Azure region into which you deployed the Recovery Services vault earlier in this lab|

   > **Note:** Ignore the warning regarding the overlapping IP address space. This is intentional, so the IP address space of the test environment matches the IP address space of the disaster recovery environment.

1. Within the new virtual network, create a subnet with the following settings (leave others with their default values):

   |Setting|Value|
   |---|---|
   |Subnet name|**subnet0**|
   |Subnet address range|**10.5.0.0/24**|

1. On **SEA-SVR2**, in the Azure portal, create a storage account with the following settings (leave others with their default values):

   |Setting|Value|
   |---|---|
   |Subscription|the name of the Azure subscription you are using in this lab|
   |Resource group|**AZ801-L0502-RG**|
   |Storage account name|any globally unique name between 3 and 24 in length consisting of letters and digits, starting with a letter|
   |Region|the name of the Azure region into which you deployed the Recovery Services vault earlier in this lab|
   |Performance|Standard|
   |Redundancy|Locally redundant storage (LRS)|
   |Enable soft delete for blobs|disabled|
   |Enable soft delete for containers|disabled|

   > **Note:** The soft delete functionality for blobs and containers must be disabled when using the storage account for Azure Site Recovery.

#### Task 2: Prepare protection of a Hyper-V virtual machine

1. On **SEA-SVR2**, in the Azure portal, browse to the **az801l05a-rsvault** Recovery Services vault blade. 
1. On the **az801l05a-rsvault** blade, on the vertical menu, start the configuration of **Site Recovery**
1. On the **az801l05a-rsvault \| Site Recovery** blade, in the **Hyper-V machines to Azure** section, select **1. Prepare infrastructure** and specify the following settings:

   |Setting|Value|
   |---|---|
   |Deployment planning completed?|**Yes, I have done it**|
   |Are you Using System Center VMM to manage Hyper-V hosts|**No**|
   |Source setting: Hyper-V Site|**az801l05-site**|

1. On the **Source settings** tab of the **Prepare infrastructure** blade, select the **Add Hyper-V server** link. 
1. On the **Add Server** blade, select the **Download** link in step 3 of the procedure for adding on-premises Hyper-V hosts in order to download the Microsoft Azure Site Recovery Provider.
1. Install **AzureSiteRecoveryProvider.exe** with the **Microsoft Update** option disabled. 
1. From the Azure portal, download the vault registration key into the **Downloads** folder.
1. Complete the **Provider installation** wizard and start the **Microsoft Azure Site Recovery Registration Wizard**.
1. When prompted, in the **Microsoft Azure Site Recovery Registration Wizard**, provide the location of the vault credentials file.
1. Complete the **Microsoft Azure Site Recovery Registration Wizard** with the default settings. 
1. Refresh the browser page displaying the Azure portal and repeat the initial steps of the **1. Prepare infrastructure** procedure.
1. After you reach the **Source settings** tab of the **Prepare infrastructure** blade, verify that the **Hyper-V site** and **Hyper-V servers** settings are set correct and continue to the next step. 
1. On the **Target settings** tab of the **Prepare infrastructure** blade, accept the default settings.
1. On the **Replication policy** tab of the **Prepare infrastructure** blade, create a new policy with the following settings and associate it with the Hyper-V site:

   |Setting|Value|
   |---|---|
   |Name|**az801l05-replication-policy**|
   |Copy frequency|**30 seconds**|

1. Complete the **Prepare infrastructure** procedure and wait until the association process completes.

#### Task 3: Enable replication of a Hyper-V virtual machine

1. On **SEA-SVR2**, in the Azure portal, on the **az801l05a-rsvault \| Site Recovery** blade, in the **Hyper-V machines to Azure** section, select **2. Enable replication**. 
1. On the **Source environment** tab of the **Enable replication** blade, in the **Source location** drop-down list, select **az801l05-site**.
1. On the **Target environment** tab of the **Enable replication** blade, specify the following settings (leave others with their default values):

   |Setting|Value|
   |---|---|
   |Subscription|the name of the Azure subscription you are using in this lab|
   |Post-failover resource group|**AZ801-L0502-RG**|
   |Post-failover deployment model|**Resource Manager**|
   |Storage account|the name of the storage account you created in the first task of this exercise|
   |Azure network|Configure now for selected machines|
   |Virtual network|**az801l05-dr-vnet**|
   |Subnet|**subnet0 (10.5.0.0/24)**|

1. On the **Virtual machine selection** tab of the **Enable replication** blade, select the **SEA-CORE1** entry.
1. On the **Replication settings** tab of the **Enable replication** blade, set the **Defaults** and **OS type** to **Windows**.
1. Complete the **Enable replication** procedure with the default settings.

#### Task 4: Review Azure VM replication settings

1. In the Azure portal, back on the **az801l05a-rsvault \| Site Recovery** blade, browse to the **az801l05a-rsvault \| Replicated items** blade.
1. On the **az801l05a-rsvault \| Replicated items** blade, ensure that there is an entry representing the **SEA-CORE1** virtual machine and verify that its **Replication Health** is listed as **Healthy** and that its **Status** is listed as either **Enabling protection** or displaying a current percentage of synchronization progress.

   > **Note** You might need to wait a few minutes until the **SEA-CORE1** entry appears on the **az801l05a-rsvault \| Replicated items** blade.

1. From the **az801l05a-rsvault \| Replicated items** blade, browse to the **SEA-CORE1** replicated items blade.
1. On the **SEA-CORE1** replicated items blade, review the **Health and status**, **Failover readiness**, **Latest recovery points**, and **Infrastructure view** sections. Note the **Planned Failover**, **Failover** and **Test Failover** toolbar icons.

   > **Note:** Wait until the status changes to **Protected**. The time required for this to take place depends on the available bandwidth of the connection between the lab environment and the Azure region hosting the Recovery Services vault. You will need to refresh the browser page for the status to be updated.

1. On the **SEA-CORE1** replicated items blade, select **Latest recovery points** and review **Latest crash-consistent** and **Latest app-consistent** recovery points. 

#### Task 5: Perform a failover of the Hyper-V virtual machine

1. On **SEA-SVR2**, in the browser window displaying the Azure portal, on the **SEA-CORE1** replicated items blade, initiate **Test failover** with the following settings (leave others with their default values) and select **OK**:

   |Setting|Value|
   |---|---|
   |Choose a recovery point|the default option|
   |Azure virtual network|**az801l05-test-vnet**|

1. In the Azure portal, browse back to the **az801l05a-rsvault** blade, and from there, browse to the listing of **Site Recovery jobs**. Wait until the status of the **Test failover** job is listed as **Successful**.

   > **Note:** The time required for the test failover to complete depends on the available bandwidth of the connection between the lab environment and the Azure region hosting the Recovery Services vault. You will need to refresh the browser page for the status to be updated. 

   > **Note:** While waiting for the test failover to complete, proceed to Exercise 3 and, after you finish it, step through the remaining portion of this exercise.

1. In the Azure portal, browse to the **Virtual machines** blade and note the entry representing the newly provisioned virtual machine.

   > **Note:** Initially, the virtual machine will have the name consisting of the **asr-** prefix and randomly generated suffix, but will be renamed eventually to **SEA-CORE1-test**.

1. In the Azure portal, browse back to the **SEA-CORE1** replicated item blade and initiate **Cleanup test failover**.
1. After the test failover cleanup job completes, refresh the browser page displaying the **SEA-CORE1** replicated items blade and note that you have the option to perform planned or unplanned failover.
1. From the **SEA-CORE1** replicated items blade, browse to the **Planned failover** blade.
1. On the **Planned failover** blade, note that the failover direction settings are already set and not modifiable. 
1. Close the **Planned failover** blade without initiating a failover. 
1. From the **SEA-CORE1** replicated items blade, browse to the **Failover** blade.
1. On the **Failover** blade, note that you have the option to choose a recovery point. 
1. Close the **Failover** blade without initiating a failover.

## Exercise 3: Implementing Azure Backup

### Scenario

While waiting for the replication of the nested VM to complete, implement Azure Backup of the second Azure VM by using an Azure VM agent and Azure VM-level backup of the third Azure VM.

The main tasks for this exercise are as follows:

1. Set up the Azure Recovery Services agent.
1. Schedule Azure Backup.
1. Perform an on-demand backup.
1. Perform file recovery by using Azure Recovery Services agent.

#### Task 1: Set up the Azure Recovery Services agent

> **Note:** In general, the same vault can be used to implement Azure Site Recovery and Azure Backup functionality. When choosing the Azure region to host the vault for the purpose of disaster recovery and backup, you should take into account recovery objectives, including the range of impact of a regional disaster as well as network latency considerations. In this lab, you will use the same vault for site recovery and backup to minimize the number of duplicate steps. 

> **Note:** To implement Azure Backup, you will be installing the Azure Recovery Services agent on **SEA-SVR2**, which already serves as the **Microsoft Azure Site Recovery Provider**. To eliminate dependency issues, you will start by uninstalling the existing installation of Azure Recovery Services agent.

1. On **SEA-SVR2**, use the **Settings** app to uninstall **Microsoft Azure Recovery Services Agent**.
   > **Note:** If you are getting an error message that says the installation has failed, then restart the VM and try again. 
1. On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, on the **az801l05a-rsvault** Recovery Services vault blade, initiate **Backup** configuration with the following settings:

   |Settings| Value|
   |---|---|
   |Where is your workload running?|**On-premises**|
   |What do you want to back up?|**Files and folders**|

1. From the **az801l05a-rsvault \|Backup** blade, initiate the **Prepare infrastructure** procedure.
1. From the **Prepare infrastructure** blade, download Azure Recovery Services Agent to **SEA-SVR2**, start the **Microsoft Azure Recovery Services Agent Setup Wizard**, disable the Microsoft Updates option, and complete the installation with the default settings. 
1. After the installation completes, start the **Register Server Wizard**.
1. Switch to the Microsoft Edge window displaying the Azure portal, and from the **Prepare infrastructure** blade, download the vault credentials file to the local Downloads folder.
1. Switch back to the **Register Server Wizard** window, and when prompted to provide Vault Credentials, point to the newly downloaded file. 
1. On the **Encryption Setting** page of the **Register Server Wizard**, generate passphrase and store it in the local **Documents** folder. 
1. Review the **Microsoft Azure Backup** warning and proceed to complete the registration. This will automatically open the **Microsoft Azure Backup** console.

   > **Note** In a production environment, you should store the passphrase file in a secure location other than the server being backed up.

#### Task 2: Schedule Azure Backup

1. On **SEA-SVR2**, in the **Microsoft Azure Backup** console, schedule backup with the following settings (leave others with their default values):

   |Settings| Value|
   |---|---|
   |Items to back up|C:\\Windows\\System32\\drivers\\etc\\hosts|
   |Backup Schedule|Daily at 4:30 AM|
   |Retention Policy|default|
   |Initial Backup type|default|

#### Task 3: Perform an on-demand backup

> **Note** The option to run backup on demand becomes available after you create a scheduled backup.

1. In the **Microsoft Azure Backup** console, initiate an on-demand backup with the default settings.
1. Switch to the Microsoft Edge window displaying the Azure portal, browse back to the **az801l05a-rsvault** Recovery Services vault blade and display **Backup items**. 
1. From the **az801l05a-rsvault \| Backup items** blade, browse to the **Backup Items (Azure Backup Agent)** blade and verify that there is an entry referencing drive **C** of **sea-svr2.contoso.com**.

#### Task 4: Perform file recovery by using Azure Recovery Services agent

1. On **SEA-SVR2**, open File Explorer, browse to the **C:\\Windows\\System32\\drivers\\etc\\** folder and delete the **hosts** file.
1. Switch to the Microsoft Azure Backup window and start **Recover Data Wizard** with the following settings (leave others with their default values):

   |Settings| Value|
   |---|---|
   |Restore target|**This server (sea-svr2.contoso.com)**|
   |Restore items|**Individual files and folders**|
   |Select the volume|**C:\\**|

   > **Note** Wait for the mount operation to complete. This might take about 2 minutes.

1. On the **Browse And Recover Files** page, note the drive letter of the recovery volume, select **Browse**, and review the tip regarding the use of **Robocopy**. 
1. On **SEA-SVR2**, start **Command Prompt**.
1. From the **Administrator: Command Prompt** window, run the following to copy and restore the **hosts** file to the original location (replace `<recovery_volume>` with the drive letter of the recovery volume you identified earlier):

   ```cmd
   robocopy <recovery_volume>:\Windows\System32\drivers\etc C:\Windows\system32\drivers\etc hosts /r:1 /w:1
   ```

1. From the **Administrator: Command Prompt** window, run the following to verify that the file has been restored:

   ```cmd
   dir C:\Windows\system32\drivers\etc\hosts
   ```

1. Switch back to the **Recover Data Wizard** and unmount the mounted backup file. 

## Exercise 4: Deprovisioning the Azure lab environment

### Scenario

To minimize Azure-related charges, you want to deprovision the Azure resources provisioned throughout this lab.

The main tasks for this exercise are as follows:

1. Remove the protected items.
1. Delete the lab resource groups.

#### Task 1: Remove the protected items

1. On **SEA-SVR2**, switch to the Microsoft Edge window displaying the **Backup Items (Azure Backup Agent)** blade of the Azure portal and select the entry referencing drive **C** of **sea-svr2.contoso.com**.
1. On the **C:\\ on sea-svr2.contoso.com** blade, browse to the **sea-svr2.contoso.com** blade.
1. From the **sea-svr2.contoso.com** blade, specify the following information and delete the backup: 

   |Settings| Value|
   |---|---|
   |Type the server name|**sea-svr2.contoso.com**|
   |Reason|**Decommissioned**|
   |Comments|**Decommissioned**|

1. On **SEA-SVR2**, in the Microsoft Edge displaying the Azure portal, browse to the **az801l05a-rsvault | Replicated items** blade, and select the **SEA-CORE1** entry.
1. From the **SEA-CORE1** replicated items blade, disable replication and remove replicated items without providing feedback. 

#### Task 2: Delete the lab resource groups

1. On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, open a PowerShell session in the Azure Cloud Shell pane.

    > **Note** If this is the first time you're starting Cloud Shell and you're presented with the **You have no storage mounted** message, select the subscription you are using in this lab, and then select **Create storage**.

1. From the Cloud Shell pane, run the following command to list all resource groups you created in this lab:

   ```powershell
   Get-AzResourceGroup -Name 'AZ801-L070*'
   ```

   > **Note**: Verify that the output contains only the resource groups you created in this lab. These groups will be deleted in this task.

1. From the Cloud Shell pane, run the following command to delete all resource groups created in this lab:

   ```powershell
   Get-AzResourceGroup -Name 'AZ801-L050*' | Remove-AzResourceGroup -Force -AsJob
   ```

   > **Note** The command executes asynchronously (as determined by the *-AsJob* parameter). So, while you will be able to immediately run another PowerShell command within the same PowerShell session, it will take a few minutes before the resource groups are actually removed.
