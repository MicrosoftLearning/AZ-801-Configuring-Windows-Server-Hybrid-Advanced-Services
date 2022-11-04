---
lab:
    title: 'Lab: Implementing Azure-based recovery services'
    type: 'Answer Key'
    module: 'Module 5: Planning and implementing migration and recovery services in hybrid scenarios'
---

# Lab answer key: Implementing Azure-based recovery services

**Note:** An **[interactive lab simulation](https://mslabs.cloudguides.com/guides/AZ-801%20Lab%20Simulation%20-%20Implementing%20Azure-based%20recovery%20services)** is available that allows you to click through this lab at your own pace. You may find slight differences between the interactive simulation and the hosted lab, but the core concepts and ideas being demonstrated are the same. 

## Exercise 1: Creating and configuring an Azure Site Recovery vault

#### Task 1: Create an Azure Site Recovery vault

1. Connect to **SEA-SVR2**, and if needed, sign in as **CONTOSO\\Administrator** with the password **Pa55w.rd**.
1. On **SEA-SVR2**, start Microsoft Edge, go to the **[Azure portal](https://portal.azure.com)**, and sign in by using the credentials of a user account with the Owner role in the subscription you'll be using in this lab.
1. In the Azure portal, in the **Search resources, services, and docs** text box, on the toolbar, search for and select **Recovery Services vaults**, and on the **Recovery Services vaults** page, select **+ Create**.
1. On the **Basics** tab of the **Create Recovery Services vault** page, specify the following settings (leave others with their default values) and select **Review + create**:

   |Setting|Value|
   |---|---|
   |Subscription|the name of the Azure subscription you will be using in this lab|
   |Resource group|the name of a new resource group **AZ801-L0501-RG**|
   |Vault name|**az801l05a-rsvault**|
   |Location|the name of an Azure region where you can create an Azure Recovery Services vault and is close to the location of the lab environment|

1. On the **Review + create** tab of the **Create Recovery Services vault** page, select **Create**.

   > **Note:** Wait until the Recovery Services vault is provisioned. This should take about 2 minutes.

   > **Note:** By default, the Storage Replication type of the vault is set to Geo-redundant (GRS), as well as Soft Delete and Security Features are enabled. You will change these settings in the lab to simplify deprovisioning, but you should ensure they are enabled in your production environments.

#### Task 2: Configure the Azure Site Recovery vault

1. On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, on the deployment page, select **Go to resource**. 

   > **Note:** This will automatically display the **az801l05a-rsvault** page.

1. On the **az801l05a-rsvault** page, on the vertical menu on the left side, in the **Settings** section, select **Properties**. 
1. On the **az801l05a-rsvault | Properties** page, select the **Update** link under the **Backup Configuration** label.
1. On the **Backup Configuration** page, set **Storage replication type** to **Locally-redundant**, select **Save** and close the **Backup Configuration** page.

   > **Note:** Storage replication type cannot be changed after you implement protection.

1. On the **az801l05a-rsvault | Properties** page, select the **Update** link under the **Security Settings** label.
1. On the **Security Settings** page, set **Soft Delete** to **Disable**, set **Security Features** to **Disable**, select **Save**, and then close the **Security Settings** page.

## Exercise 2: Implementing Hyper-V VM protection by using Azure Site Recovery vault

#### Task 1: Implement an Azure recovery site

1. On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, use the **Search resources, services, and docs** text box in the toolbar to search for and select **Virtual networks**, and on the **Virtual networks** page, select **+ Create**.
1. On the **Basics** tab of the **Create virtual network** page, specify the following settings (leave others with their default values) and select **Next: IP Addresses**:

   |Setting|Value|
   |---|---|
   |Subscription|the name of the Azure subscription you are using in this lab|
   |Resource group|the name of a new resource group **AZ801-L0502-RG**|
   |Name|**az801l05-dr-vnet**|
   |Region|the name of the Azure region into which you deployed the Recovery Services vault earlier in this lab|

1. On the **IP addresses** tab of the **Create virtual network** page, select the recycle bin icon, in the **IPv4 address space** text box, enter **10.5.0.0/22** and select **+ Add subnet**.
1. On the **Add subnet** page, specify the following settings (leave others with their default values) and select **Add**:

   |Setting|Value|
   |---|---|
   |Subnet name|**subnet0**|
   |Subnet address range|**10.5.0.0/24**|

1. Back on the **IP addresses** tab of the **Create virtual network** page, select **Review + create**.
1. On the **Review + create** tab of the **Create virtual network** page, select **Create**.
1. On **SEA-SVR2**, in the Azure portal, browse back to the **Virtual networks** page and select **+ Create**.
1. On the **Basics** tab of the **Create virtual network** page, specify the following settings (leave others with their default values) and select **Next: IP Addresses**:

   |Setting|Value|
   |---|---|
   |Subscription|the name of the Azure subscription you are using in this lab|
   |Resource group|**AZ801-L0502-RG**|
   |Name|**az801l05-test-vnet**|
   |Region|the name of the Azure region into which you deployed the Recovery Services vault earlier in this lab|

1. On the **IP addresses** tab of the **Create virtual network** page, select the recycle bin icon, in the **IPv4 address space** text box, enter **10.5.0.0/22** and select **+ Add subnet**.

   > **Note:** Ignore the warning regarding the overlapping IP address space. This is intentional, so the IP address space of the test environment matches the IP address space of the disaster recovery environment.

1. On the **Add subnet** page, specify the following settings (leave others with their default values) and select **Add**:

   |Setting|Value|
   |---|---|
   |Subnet name|**subnet0**|
   |Subnet address range|**10.5.0.0/24**|

1. Back on the **IP addresses** tab of the **Create virtual network** page, select **Review + create**.
1. On the **Review + create** tab of the **Create virtual network** page, select **Create**.
1. On **SEA-SVR2**, in the Azure portal, use the **Search resources, services, and docs** text box in the toolbar to search for and select **Storage accounts**, and on the **Storage accounts** page, select **+ Create**.
1. On the **Basics** tab of the **Create storage account** page, specify the following settings (leave others with their default values):

   |Setting|Value|
   |---|---|
   |Subscription|the name of the Azure subscription you are using in this lab|
   |Resource group|**AZ801-L0502-RG**|
   |Storage account name|any globally unique name between 3 and 24 in length consisting of letters and digits, starting with a letter|
   |Region|the name of the Azure region into which you deployed the Recovery Services vault earlier in this lab|
   |Performance|Standard|
   |Redundancy|Locally redundant storage (LRS)|

1. On the **Basics** tab of the **Create storage account** page, select the **Data protection** tab.
1. On the **Data protection** tab of the **Create storage account** page, clear the **Enable soft delete for blobs** and **Enable soft delete for containers** checkboxes and select **Review + create**.

   > **Note:** These settings must be disabled when using the storage account for Azure Site Recovery.

1. On the **Review + create** tab of the **Create storage account** page, select **Create**.

#### Task 2: Prepare protection of a Hyper-V virtual machine

1. On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, use the **Search resources, services, and docs** text box in the toolbar to search for and select **Recovery Services vaults**, and on the **Recovery Services vaults** page, select the **az801l05a-rsvault** entry.
1. On the **az801l05a-rsvault** page, on the vertical menu on the left side, in the **Getting started** section, select **Site Recovery**.
1. On the **az801l05a-rsvault \| Site Recovery** page, in the **Hyper-V machines to Azure** section, select **1. Prepare infrastructure**. 
1. On the **Deployment planning** tab of the **Prepare infrastructure** page, in the **Deployment planning completed?** drop-down list, select **Yes, I have done it** and select **Next**.
1. On the **Source settings** tab of the **Prepare infrastructure** page, next to the **Are you Using System Center VMM to manage Hyper-V hosts** label, select the **No** option.
1. On the **Source settings** tab of the **Prepare infrastructure** page, select the **Add Hyper-V site** link. 
1. On the **Create Hyper-V Site** page, in the **Name** text box, enter **az801l05-site** and select **OK**.
1. On the **Source settings** tab of the **Prepare infrastructure** page, select the **Add Hyper-V server** link. 
1. On the **Add Server** page, select the **Download** link in step 3 of the procedure for adding on-premises Hyper-V hosts in order to download the installer for Microsoft Azure Site Recovery Provider.

   > **Note:** If you receive the Microsoft Edge notification that **AzureSiteRecoveryProvider.exe can't be downloaded securely**, move the cursor over the right side of the message to reveal the ellipsis symbol (**...**), select it, in the drop-down menu, select **Copy download link**, open another tab in the same Microsoft Edge window, paste the link you copied, and then press Enter.

1. In the download notification, select **Open file**. This will start the **Azure Site Recovery Provider Setup (Hyper-V server)** wizard.
1. On the **Microsoft Update** page, select **Off** and select **Next**.
1. On the **Provider installation** page, select **Install**.
1. Switch to the Microsoft Edge window displaying the Azure portal, and in the Add Server page, select the **Download** button in step 4 of the procedure for registering on-premises Hyper-V hosts in order to download the vault registration key.
1. Switch to the **Provider installation** wizard and select **Register**. This will start the **Microsoft Azure Site Recovery Registration Wizard**.
1. On the **Vault Settings** page of the **Microsoft Azure Site Recovery Registration Wizard**, select **Browse**. 
1. In the **Open** window, browse to the **Downloads** folder, select the vault credentials file, and select **Open**.
1. Back on the **Vault Settings** page of the **Microsoft Azure Site Recovery Registration Wizard**, select **Next**.
1. On the **Proxy Settings** page of the **Microsoft Azure Site Recovery Registration Wizard**, accept the default settings and select **Next**.
1. On the **Registration** page of the **Microsoft Azure Site Recovery Registration Wizard**, select **Finish**.

   > **Note:** In case the registration fails, select **Start**. On the **Start** menu, select the **Azure Site Recovery Services Provider** folder. In the folder, select **Azure Site Recovery Configurator** and re-run the registration procedure.

1. Switch back to the Microsoft Edge window displaying the Azure portal, close the **Add Server** page, and refresh the page. When prompted, select **Reload**. 
1. Back on the **az801l05a-rsvault | Site Recovery** page, in the **Hyper-V machines to Azure** section, select **1. Prepare infrastructure**. 
1. On the **Deployment planning** tab of the **Prepare infrastructure** page, in the **Deployment planning completed?** drop-down list, select **Yes, I have done it** and select **Next**.
1. On the **Source settings** tab of the **Prepare infrastructure** page, next to the **Are you Using System Center VMM to manage Hyper-V hosts** label, select the **No** option.
Verify that the **Hyper-V site** and **Hyper-V servers** settings are set correctly and select **Next**. 
1. On the **Target settings** tab of the **Prepare infrastructure** page, accept the default settings and select **Next**.
1. On the **Replication policy** tab of the **Prepare infrastructure** page, select **Create new policy and associate**. 
1. On the **Create and associate policy** page, specify the following settings (leave others with their default values) and select **OK**:

   |Setting|Value|
   |---|---|
   |Name|**az801l05-replication-policy**|
   |Copy frequency|**30 seconds**|

1. Back on the **Replication policy** tab of the **Prepare infrastructure** page, wait until the site has been associated with the policy and select **Next**.
1. On the **Review** tab of the **Prepare infrastructure** page, select **Prepare**.

#### Task 3: Enable replication of a Hyper-V virtual machine

1. On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, on the **az801l05a-rsvault \| Site Recovery** page, in the **Hyper-V machines to Azure** section, select **2. Enable replication**. 
1. On the **Source environment** tab of the **Enable replication** page, in the **Source location** drop-down list, select **az801l05-site** and select **Next**.
1. On the **Target environment** tab of the **Enable replication** page, specify the following settings (leave others with their default values) and select **Next**:

   |Setting|Value|
   |---|---|
   |Subscription|the name of the Azure subscription you are using in this lab|
   |Post-failover resource group|**AZ801-L0502-RG**|
   |Post-failover deployment model|**Resource Manager**|
   |Storage account|the name of the storage account you created in the first task of this exercise|
   |Azure network|Configure now for selected machines|
   |Virtual network|**az801l05-dr-vnet**|
   |Subnet|**subnet0 (10.5.0.0/24)**|

1. On the **Virtual machine selection** tab of the **Enable replication** page, select the **SEA-CORE1** checkbox and select **Next**.
1. On the **Replication settings** tab of the **Enable replication** page, in the **Defaults** row and **OS type** column, select **Windows** from the drop-down list and select **Next**.
1. On the **Replication policy** tab of the **Enable replication** page, accept the default settings and select **Next**.
1. On the **Review** tab of the **Enable replication** page, select **Enable replication**.

#### Task 4: Review Azure VM replication settings

1. On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, back on the **az801l05a-rsvault \| Site Recovery** page, on the vertical menu on the left side, select **Replicated items**. 
1. On the **az801l05a-rsvault \| Replicated items** page, ensure that there is an entry representing the **SEA-CORE1** virtual machine and verify that its **Replication Health** is listed as **Healthy** and that its **Status** is listed as either **Enabling protection** or displaying a current percentage of synchronization progress.

   > **Note:** You might need to wait a few minutes until the **SEA-CORE1** entry appears on the **az801l05a-rsvault \| Replicated items** page.

1. On the **az801l05a-rsvault \| Replicated items** page, select the **SEA-CORE1** entry.
1. On the **SEA-CORE1** replicated items page, review the **Health and status**, **Failover readiness**, **Latest recovery points**, and **Infrastructure view** sections. Note the **Planned Failover**, **Failover** and **Test Failover** toolbar icons.

   > **Note:** Wait until the status changes to **Protected**. The time required for this to take place depends on the available bandwidth of the connection between the lab environment and the Azure region hosting the Recovery Services vault. You will need to refresh the browser page for the status to be updated. 

1. On the **SEA-CORE1** replicated items page, select **Latest recovery points** and review **Latest crash-consistent** and **Latest app-consistent** recovery points. 

#### Task 5: Perform a failover of the Hyper-V virtual machine

1. On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, browse back to the **SEA-CORE1** replicated items page and select **Test failover**. 
1. On the **Test failover** page, specify the following settings (leave others with their default values) and select **OK**:

   |Setting|Value|
   |---|---|
   |Choose a recovery point|the default option|
   |Azure virtual network|**az801l05-test-vnet**|

1. In the Azure portal, browse back to the **az801l05a-rsvault** page, and on the vertical menu on the left side, in the **Monitoring** section, select **Site Recovery jobs**. Wait until the status of the **Test failover** job is listed as **Successful**.

   > **Note:** The time required for the test failover to complete depends on the available bandwidth of the connection between the lab environment and the Azure region hosting the Recovery Services vault. You will need to refresh the browser page for the status to be updated. 

   > **Note:** While waiting for the test failover to complete, proceed to Exercise 3, and after you finish it, step through the remaining portion of this exercise.

1. In the Azure portal, use the **Search resources, services, and docs** text box in the toolbar to search for and select **Virtual machines** and, on the **Virtual machines** page, note the entry representing the newly provisioned virtual machine.

   > **Note:** Initially, the virtual machine will have the name consisting of the **asr-** prefix and randomly generated suffix, but will be renamed eventually to **SEA-CORE1-test**.

1. In the Azure portal, browse back to the **SEA-CORE1** replicated item page and select **Cleanup test failover**.
1. On the **Test failover cleanup** page, select the **Testing is complete. Delete test failover virtual machine(s)** checkbox and select **OK**.
1. After the test failover cleanup job completes, refresh the browser page displaying the **SEA-CORE1** replicated items page and note that you have the option to perform planned and unplanned failover (the latter is labeled as **Failover**).

   > **Note:** The unplanned failover option is labeled as **Failover**.

1. On the **SEA-CORE1** replicated items page, select **Planned failover**. 
1. On the **Planned failover** page, note that the failover direction settings are already set and not modifiable. 
1. Close the **Planned failover** page without initiating a failover, and on the **SEA-CORE1** replicated items page, select **Failover**. 
1. On the **Failover** page, note that you have the option to choose a recovery point. 
1. Close the **Failover** page without initiating a failover.

## Exercise 3: Implementing Azure Backup

#### Task 1: Set up the Azure Recovery Services agent

> **Note:** In general, the same vault can be used to implement Azure Site Recovery and Azure Backup functionality. When choosing the Azure region to host the vault for the purpose of disaster recovery and backup, you should take into account recovery objectives, including the range of impact of a regional disaster as well as network latency considerations. In this lab, you will use the same vault for site recovery and backup to minimize the number of duplicate steps. 

> **Note:** To implement Azure Backup, you will be installing the Azure Recovery Services agent on **SEA-SVR2**, which already serves as the **Microsoft Azure Site Recovery Provider**. To eliminate dependency issues, you will start by uninstalling the existing installation of Azure Recovery Services agent.

1. On **SEA-SVR2**, select **Start**, and on the **Start** menu, select the **Settings** app.
1. In the **Settings** app, select **Apps**.
1. In the **Apps & features** pane, select **Microsoft Azure Recovery Services Agent**, select **Uninstall**, and follow the prompts to uninstall it.
   > **Note:** If you are getting an error message that says the installation has failed, then restart the VM and try again. 
1. On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, on the **az801l05a-rsvault** Recovery Services vault page, on the vertical menu on the left side, in the **Getting started** section, select **Backup**.
1. On the **az801l05a-rsvault \|Backup** page, specify the following settings:

   |Settings| Value|
   |---|---|
   |Where is your workload running?|**On-premises**|
   |What do you want to back up?|**Files and folders**|

1. On the **az801l05a-rsvault \|Backup** page, select **Prepare infrastructure**.
1. On the **Prepare infrastructure** page, select the **Download Agent for Windows Server or Windows Client** link.
1. After the download completes, in the **Downloads** notification of Microsoft Edge, select the **Open file** link. 

   > **Note:** This will start the **Microsoft Azure Recovery Services Agent Setup Wizard**, which, in this case, will launch automatically the **Register Server Wizard**.

1. On the **Installation Settings** page of the **Microsoft Azure Recovery Services Agent Setup Wizard**, accept the default settings and select **Next**.
1. On the **Proxy Configuration** page of the **Microsoft Azure Recovery Services Agent Setup Wizard**, accept the default settings, and then select **Next**.
1. On the **Microsoft Update Opt-in** page of the **Microsoft Azure Recovery Services Agent Setup Wizard**, select **I do not want to use Windows Update**, and then select **Next**.
1. On the **Installation** page of the **Microsoft Azure Recovery Services Agent Setup Wizard**, select **Install**.
1. After the installation completes, on the **Installation** page of the **Microsoft Azure Recovery Services Agent Setup Wizard**, select **Proceed to Registration**. This will launch the **Register Server Wizard**.
1. Switch to the Microsoft Edge window displaying the Azure portal, on the **Prepare infrastructure** page, select the **Already downloaded or using the latest Recovery Server Agent** checkbox , and select **Download**.
1. When prompted, whether to open or save the vault credentials file, select **Save**. This will save the vault credentials file to the local Downloads folder.
1. Switch back to the **Register Server Wizard**, and on the **Vault Identification** page, select **Browse**.
1. In the **Select Vault Credentials** dialog box, browse to the **Downloads** folder, select the vault credentials file you downloaded, and then select **Open**. Then select **Next** to open the **Encryption Setting** page.
1. On the **Encryption Setting** page of the **Register Server Wizard**, select **Generate Passphrase**.
1. On the **Encryption Setting** page of the **Register Server Wizard**, select the **Browse** button next to the **Enter a location to save the passphrase** drop-down list.
1. In the **Browse For Folder** dialog box, expand **This PC** node, select the **Documents** subfolder, and then select **OK**.
1. Select **Finish**, review the **Microsoft Azure Backup** warning, select **Yes**, and wait for the registration to complete.

   > **Note:** In a production environment, you should store the passphrase file in a secure location other than the server being backed up.

1. On the **Server Registration** page of the **Register Server Wizard**, review the warning regarding the location of the passphrase file, ensure that the **Launch Microsoft Azure Recovery Services Agent** checkbox is selected, and then select **Close**. This will automatically open the **Microsoft Azure Backup** console.

#### Task 2: Schedule Azure Backup

1. On **SEA-SVR2**, in the **Microsoft Azure Backup** console, in the Actions pane, select **Schedule Backup**.
1. In the **Schedule Backup Wizard**, on the **Getting started** page, select **Next**.
1. On the **Select Items to Backup** page, select **Add Items**.
1. In the **Select Items** dialog box, browse to the **C:\\Windows\\System32\\drivers\\etc\\** folder, select **hosts**, and then select **OK**.
1. On the **Select Items to Backup** page, select **Next**.
1. On the **Specify Backup Schedule** page, ensure that the **Day** option is selected, in the first drop-down list box below the **At following times (Maximum allowed is three times a day)** box, select **4:30 AM**, and then select **Next**.
1. On the **Select Retention Policy** page, accept the defaults, and then select **Next**.
1. On the **Choose Initial Backup type** page, accept the defaults, and then select **Next**.
1. On the **Confirmation** page, select **Finish**. When the backup schedule is created, select **Close**.

#### Task 3: Perform an on-demand backup

> **Note:** The option to run backup on demand becomes available after you create a scheduled backup.

1. In the **Microsoft Azure Backup** console, in the Actions pane, select **Back Up Now**.
1. In the **Back Up Now Wizard**, on the **Select Backup Item** page, ensure that the **Files and Folders** option is selected and select **Next**.
1. On the **Retain Backup Till** page, accept the default setting and select **Next**.
1. On the **Confirmation** page, select **Back Up**.
1. When the backup is complete, select **Close**.
1. On **SEA-SVR2**, switch to the Microsoft Edge window displaying the Azure portal, browse back to the **az801l05a-rsvault** Recovery Services vault page and select **Backup items**. 
1. On the **az801l05a-rsvault \| Backup items** page, select the **Azure Backup Agent** entry.
1. On the **Backup Items (Azure Backup Agent)** page, verify that there is an entry referencing drive **C** of **sea-svr2.contoso.com**.

#### Task 4: Perform file recovery by using Azure Recovery Services agent

1. On **SEA-SVR2**, open File Explorer, browse to the **C:\\Windows\\System32\\drivers\\etc\\** folder and delete the **hosts** file.
1. Switch to the Microsoft Azure Backup window and select **Recover data**. This will start the **Recover Data Wizard**.
1. On the **Getting Started** page of the **Recover Data Wizard**, ensue that **This server (sea-svr2.contoso.com)** option is selected and select **Next**.
1. On the **Select Recovery Mode** page, ensure that **Individual files and folders** option is selected, and select **Next**.
1. On the **Select Volume and Date** page, in the **Select the volume** drop-down list, select **C:\\**, accept the default selection of the available backup, and select **Mount**. 

   > **Note:** Wait for the mount operation to complete. This might take about 2 minutes.

1. On the **Browse And Recover Files** page, note the drive letter of the recovery volume, select **Browse**, and review the tip regarding the use of **Robocopy**. 
1. Select **Start**, expand the **Windows System** folder, and then select **Command Prompt**.
1. From the **Administrator: Command Prompt** window, run the following to copy the restore the **hosts** file to the original location (replace the `<recovery_volume>` placeholder with the drive letter of the recovery volume you identified earlier):

   ```cmd
   robocopy <recovery_volume>:\Windows\System32\drivers\etc C:\Windows\system32\drivers\etc hosts /r:1 /w:1
   ```

1. From the **Administrator: Command Prompt** window, run the following to verify that the file has been restored:

   ```cmd
   dir C:\Windows\system32\drivers\etc\hosts
   ```

1. Switch back to the **Recover Data Wizard**, and on the **Browse and Recover Files** page, select **Unmount**, and when prompted to confirm, select **Yes**. 

## Exercise 4: Deprovisioning the Azure lab environment

#### Task 1: Remove the protected items

1. On **SEA-SVR2**, switch to the Microsoft Edge window displaying the **Backup Items (Azure Backup Agent)** page of the Azure portal and select the entry referencing drive **C** of **sea-svr2.contoso.com**.
1. On the **C:\\ on sea-svr2.contoso.com** page, select the **sea-svr2.contoso.com** link.
1. On the **sea-svr2.contoso.com** page, select **Delete**. 
1. On the **Delete** page, specify the following information, select the **There is backup data of 1 backup items associated with this server. I understand that clicking "Confirm" will permanently delete all cloud backup data. This action cannot be undone. An alert may be sent to the administrators of this subscription notifying them of this deletion** checkbox, and then select **Delete**:

   |Settings| Value|
   |---|---|
   |Type the server name|**sea-svr2.contoso.com**|
   |Reason|**Decommissioned**|
   |Comments|**Decommissioned**|

1. On **SEA-SVR2**, in the Microsoft Edge displaying the Azure portal, browse to the **az801l05a-rsvault | Replicated items** page, and select the **SEA-CORE1** entry.
1. On the **SEA-CORE1** replicated items page, select the ellipsis in the toolbar, and from the drop-down menu, select **Disable replication**. 
1. On the **Disable replication** page, ensure that the **Disable replication and remove (Recommended)** entry appears in the **Remove replicated items** drop-down list, select **I don't want to provide feedback** checkbox, and then select **OK**.

#### Task 2: Delete the lab resource groups

1. On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, open the Azure Cloud Shell pane by selecting the Cloud Shell button in the Azure portal.
1. If prompted to select either **Bash** or **PowerShell**, select **PowerShell**.

   > **Note:** If this is the first time you're starting Cloud Shell and you're presented with the **You have no storage mounted** message, select the subscription you are using in this lab, and then select **Create storage**.

1. From the Cloud Shell pane, run the following to list all resource groups you created in this lab:

   ```powershell
   Get-AzResourceGroup -Name 'AZ801-L050*'
   ```

   > **Note**: Verify that the output contains only the resource group you created in this lab. This group will be deleted in this task.

1. From the Cloud Shell pane, run the following command to delete all resource groups created throughout this lab:

   ```powershell
   Get-AzResourceGroup -Name 'AZ801-L050*' | Remove-AzResourceGroup -Force -AsJob
   ```

   > **Note:** The command executes asynchronously (as determined by the *-AsJob* parameter), so while you will be able to run another PowerShell command immediately after within the same PowerShell session, it will take a few minutes before the resource groups are actually removed.
