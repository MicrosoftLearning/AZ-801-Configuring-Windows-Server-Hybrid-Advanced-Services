---
lab:
    title: 'Lab: Upgrade and migrate in Windows Server'
    module: 'Module 6: Upgrade and migrate in Windows Server'
---

# Lab: Upgrade and migrate in Windows Server

## Lab scenario

Contoso is exploring the hybrid model for its infrastructure services that would facilitate migration of its on-premises Windows servers to Azure virtual machines (VMs). To assist with this initiative, and you were tasked with evaluating the process of deploying Active Directory Domain Services (AD DS) domain controllers in Azure VMs. Your intention is to identify differences between the manual process currently used for on-premises deployments and the deployment methods available in Azure. In addition, you want to test and document the Storage Migration Services functionality to validate its usage for migrations of on-premises file servers. 

## Objectives

In this lab, you will:

- Deploy AD DS domain controllers in Azure.
- Migrate file servers by using Storage Migration Service.

## Estimated time: 60 minutes

## Lab Environment
  
Virtual machines: **AZ-801T00A-SEA-DC1**, **AZ-801T00A-SEA-SVR1**, and **AZ-801T00A-SEA-SVR2** must be running. Other VMs can be running, but they aren't required for this lab.

> **Note**: **AZ-801T00A-SEA-DC1**, **AZ-801T00A-SEA-SVR1**, and **AZ-801T00A-SEA-SVR2** virtual machines are hosting the installation of **SEA-DC1**, **SEA-SVR1**, and **SEA-SVR2**, respectively.

1. Select **SEA-SVR2**.
1. Sign in using the following credentials:

   - Username: **Administrator**
   - Password: **Pa55w.rd**
   - Domain: **CONTOSO**

For this lab, you'll use the available VM environment and an Azure subscription. Before you begin the lab, ensure that you have an Azure subscription and a user account with the Owner role in that subscription.

## Exercise 1: Deploying AD DS domain controllers in Azure

> **Note**: Hybrid scenarios commonly involve extending on-premises AD DS environment to Azure by deploying additional domain controllers from the existing on-premises domains into Azure VMs. Performing such task in a lab would require either setting up Site-to-Site VPN connection to an Azure virtual network or provisioning the entire lab environment in Azure, with a portion of it emulating an on-premises site. For the sake of simplicity, this exercise involves deploying domain controllers in Azure VMs into a new forest and domain. The focus is on identifying unique aspects of domain controller configuration and provisioning process when using Azure VMs.

The main tasks for this exercise are to:

1. Deploy a domain controller by using an Azure Resource Manager (ARM) template.
1. Deploy Azure Bastion. 
1. Deploy an Azure VM by using the Azure portal.
1. Manually promote a domain controller in an Azure VM.
1. Remove Azure resources deployed in the exercise.

#### Task 1: Deploy a domain controller by using an Azure Resource Manager (ARM) template

1. On **SEA-SVR2**, start Microsoft Edge, go to the **[Azure portal](https://portal.azure.com)**, and sign in by using the credentials of a user account with the Owner role in the subscription you'll be using in this lab.
1. On **SEA-SVR2**, start Microsoft Edge, and go to a customized version of the QuickStart template at **[Create a new Windows VM and create a new AD Forest, Domain and DC](https://github.com/az140mp/azure-quickstart-templates/tree/master/application-workloads/active-directory/active-directory-new-domain)**. 
1. From the **Create a new Windows VM and create a new AD Forest, Domain and DC** page, initiate a deployment to Azure. 
1. On the **Create an Azure VM with a new AD Forest** page, select **Edit template**.
1. On the **Edit template** page, browse to the **storageProfile** section (starting with the line **195**) and verify that the **sku** (on line **199**) is set to **2022-Datacenter** and that **dataDisks** **caching** (on line **213**) is set to **None**.

   > **Note**: Caching on the disks hosting AD DS database and log files should be set to **None**.

1. On the **Edit template** page, browse to the **extension** section (starting with the line **233**) and note that the template uses PowerShell Desired State Configuration to run the **CreateADPDC.ps1** script within the deployed Azure virtual machine (VM).

   > **Note**: To review the script, you can use the following steps:

   1. On **SEA-SVR2**, open another tab in the Microsoft Edge window, and go to the customized version of the QuickStart template at **[Create a new Windows VM and create a new AD Forest, Domain and DC](https://github.com/az140mp/azure-quickstart-templates/tree/master/application-workloads/active-directory/active-directory-new-domain)**.
   1. On the **Create a new Windows VM and create a new AD Forest, Domain and DC** page, in the listing of the repository content, select the **DSC** folder, and then select the **CreateADPDC.ps1** file.
   1. On the **azure-quickstart-templates/application-workloads/active-directory/active-directory-new-domain/DSC/CreateADPDC.ps1** page, review the content of the script and note that it installs a number of server roles, including Active Directory Domain Services and DNS, placing the NTDS database and logs, as well as the SYSOVL share on drive **F**. 
   1. Close the Microsoft Edge tab and switch back to the one displaying the **Edit template** page in the Azure portal.

1. On the **Edit template** page, browse to the section that provisions an availability set (starting with the line **110**) and note that the template creates an availability set and deploys the VM into it (as indicated by the **dependsOn** element on line **181**).

   > **Note**: Later in this exercise, you will deploy another Azure VM into the same availability set and configure it as an additional domain controller in the same domain. The use of an availability set provides additional resiliency.

1. Browse to the section that provisions the network interface of the Azure VM (starting with the line **110**) and note that the private IP address allocation method is set to **Static** (on line **164**).

   > **Note**: Using the static assignment is common when deploying domain controllers, but it is essential for servers that host the DNS server role.

1. Browse to the section that deploys a nested template (starting with line **266**) and note that the template updates the DNS server address within the virtual network hosting the Azure VM operating as a domain controller with the DNS server role installed.

   > **Note**: Configuring the custom DNS server virtual network setting that points to the Azure VM running the domain controller with the DNS server role ensures that any Azure VM subsequently deployed into the same virtual network will automatically use that DNS server for name resolution, effectively providing the domain join functionality.

1. Close the **Edit template** page without applying any changes to the template.
1. Back on the **Create an Azure VM with a new AD Forest** page, select **Edit parameters**.
1. On the **Edit parameters** page, replace the default parameters by uploading the **C:\\Labfiles\\Lab06\\L06-rg_template.parameters.json** file.
1. Initiate a deployment with the following settings (leave others with their default values):

   | Setting | Value | 
   | --- | --- |
   | Subscription | the name of the Azure subscription you are using in this lab |
   | Resource group | the name of a new resource group **AZ801-L0601-RG** |
   | Region | the name of an Azure region into which you can provision Azure VMs |
   | Admin Username | **Student** |
   | Admin Password | **Pa55w.rd1234** |
   | Domain name | **contoso.com** |
   | Vm Size | **Standard D2s v3** |
   | Virtual Machine Name | **az801l06a-dc1** |
   | Virtual Network Name | **az801l06a-vnet** |
   | Virtual Network Address Range | **10.6.0.0/16** |
   | Network Interface Name | **az801l06a-dc1-nic1** |
   | Private IP Address | **10.6.0.4** |
   | Subnet Name | **adSubnet** |
   | Subnet Range | **10.6.0.0/24** |
   | Availability Set Name | **adAvailabilitySet** |

   > **Note**: Wait for the deployment to complete before you proceed to the next task. This might take about 15 minutes. 

#### Task 2: Deploy Azure Bastion 

> **Note**: Azure Bastion allows for connection to the Azure VMs without the public endpoints that you deployed in the previous task of this exercise, while providing protection against brute force exploits that target operating system level credentials.

1. On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, open a PowerShell session in Cloud Shell.
1. From the PowerShell session in the Cloud Shell pane, run the following commands to add a subnet named **AzureBastionSubnet** to the virtual network **az801l06a-vnet** you created earlier in this exercise:

   ```powershell
   $resourceGroupName = 'AZ801-L0601-RG'
   $vnet = Get-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Name 'az801l06a-vnet'
   $subnetConfig = Add-AzVirtualNetworkSubnetConfig `
    -Name 'AzureBastionSubnet' `
    -AddressPrefix 10.6.255.0/24 `
    -VirtualNetwork $vnet
   $vnet | Set-AzVirtualNetwork
   ```

1. In the Azure portal, deploy Azure Bastion with the following settings:

   | Setting | Value | 
   | --- | --- |
   | Subscription | the name of the Azure subscription you are using in this lab |
   | Resource group | the name of a new resource group **AZ801-L0602-RG** |
   | Name | **az801l06a-bastion** |
   | Region | the same Azure region to which you deployed the resources in the previous tasks of this exercise |
   | Tier | **Basic** |
   | Virtual network | **az801l06a-vnet** |
   | Subnet | **AzureBastionSubnet (10.6.255.0/24)** |
   | Public IP address | **Create new** |
   | Public IP name | **az801l06a-vnet-ip** |

   > **Note**: Do not wait for the deployment to complete but instead proceed to the next task. The deployment might take about 5 minutes.

#### Task 3: Deploy an Azure VM by using the Azure portal

> **Note**: You could fully automate the deployment of the second Azure VM and its setup as an additional domain controller in the same domain as the first one you provisioned in the first task of this exercise. However, the use of graphical interface in this case should provide additional guidance regarding differences between provisioning domain controllers in on-premises and Azure-based scenarios.

1. On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, create a virtual machine with the following settings (leave others with their default values):

   | Setting | Value |
   | --- | --- |
   | Subscription | the name of the Azure subscription you are using in this lab |
   | Resource group | the name of a new resource group **AZ801-L0601-RG** |
   | Virtual machine name | **az801l06a-dc2** |
   | Region | select the same Azure region into which you deployed the first virtual machine earlier in this exercise |
   | Availability options | **Availability set** |
   | Availability set | **adAvailabilitySet** |
   | Image | **Windows Server 2022 Datacenter - Gen2** |
   | Azure Spot instance | **No** |
   | Size | **Standard D2s v3** |
   | Username | **Student** |
   | Password | **Pa55w.rd1234** |
   | Public inbound ports | **None** |
   | Would you like to use an existing Windows Server license? | **No** |
   | OS disk type | **Standard SSD** |
   | Data disk name | **az801l06a-dc2_DataDisk_0** |
   | Data disk source type | **None (empty disk)** |
   | Data disk size | **32 GiB** **Premium SSD** |
   | Virtual network | **az801l06a-vnet** |
   | Subnet | **adSubnet (10.6.0.0/24)** |
   | Public IP | **None** |
   | NIC network security group | **None** |
   | Accelerated networking | enabled |
   | Place this virtual machine behind an existing load balancing solution? | disabled |
   | Boot diagnostics | **Enable with managed storage account (recommended)** |
   | Patch orchestration options | **Manual updates** |  

   > **Note**: Wait for the deployment to complete. The deployment might take about 3 minutes.

#### Task 4: Manually promote a domain controller in an Azure VM

1. On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, configure the private IP address assigned to the network interface of the **az801l06a-dc2** virtual machine to use the static assignment. 

   > **Note**: Using the static assignment is common when deploying domain controllers, but it is essential for servers that host the DNS server role.

   > **Note**: Assigning static IP address to a network interface of an Azure VM will trigger a restart of its operating system.

1. On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, browse to the **az801l06a-dc2** page.
1. From the **az801l06a-dc2** page, establish an RDP session to **az801l06a-dc2** via the Bastion service and authenticate using the following credentials:

   | Setting | Value | 
   | --- | --- |
   | User Name |**Student** |
   | Password |**Pa55w.rd1234** |

1. Within the Remote Desktop session to **az801l06a-dc2**, start a Windows PowerShell session.
1. To install the AD DS and DNS server roles, at the Windows PowerShell prompt, run the following command:
	
   ```powershell
   Install-WindowsFeature -Name AD-Domain-Services,DNS -IncludeManagementFeatures
   ```

   > **Note**: Wait for the installation to complete. This might take about 3 minutes.

1. To configure the data disk, at the Windows PowerShell prompt, run the following commands:

   ```powershell
   Get-Disk | Where PartitionStyle -eq 'RAW' |  Initialize-Disk -PartitionStyle MBR
   New-Partition -DiskNumber 2 -UseMaximumSize -AssignDriveLetter
   Format-Volume -DriveLetter F -FileSystem NTFS
   ```

1. Within the Remote Desktop session to **az801l06a-dc2**, switch to the **Server Manager** window.
1. From **Server Manager**, initiate **Active Directory Domain Services Configuration Wizard** to perform the domain controller promotion.
1. In **Active Directory Domain Services Configuration Wizard**, select the option to **Add a domain controller to an existing domain** and specify **contoso.com** as the target domain.
1. Use the **CONTOSO\\Student** username and **Pa55w.rd1234** password as credentials to perform the promotion.
1. Specify the options that designate the new domain controller as writeable, as well as include the **Domain Name System (DNS) server** and **Global Catalog (GC)** components.
1. Set the **Directory Services Restore Mode (DSRM) password** to **Pa55w.rd1234**.
1. Change the drive hosting the folders hosting the AD DS database, log files, and SYSVOL from drive **C** to drive **F**.
1. On the **Prerequisite Check** page, note the warnings regarding network adapter not having static IP address and initiate the promotion. 

   > **Note**: The warning is expected because the static IP address is assigned on the platform level, rather than within the operating system.

   > **Note**: The operating system will restart automatically to complete the promotion process.

1. On **SEA-SVR2**, reconnect to **az801l06a-dc2** via the Bastion service.
1. Within the Remote Desktop session to **az801l06a-dc2**, use **Server Manager** to verify that locally installed roles include **AD DS** and **DNS**.

#### Task 5: Remove Azure resources deployed in the exercise

#### Task 1: Start a PowerShell session in Cloud Shell

1. On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, open the Cloud Shell pane by selecting the Cloud Shell icon.
1. From the Cloud Shell pane, run the following command to list all the resource groups created in this exercise:

   ```powershell
   Get-AzResourceGroup -Name 'AZ801-L060*'
   ```

   > **Note**: Verify that the output contains only the resource groups you created in this exercise. These groups will be deleted in this task.

1. Run the following command to delete all resource groups you created in this exercise:

   ```powershell
   Get-AzResourceGroup -Name 'AZ801-L060*' | Remove-AzResourceGroup -Force -AsJob
   ```

   > **Note:** The command executes asynchronously (as determined by the *-AsJob* parameter), so while you will be able to immediately run another PowerShell command within the same PowerShell session, it will take a few minutes before the resource groups are actually removed.

## Exercise 2: Migrating file servers by using Storage Migration Service

The main tasks for this exercise are to:

1. Install Windows Admin Center.
1. Set up file services.
1. Perform migration by using Storage Migration Service.
1. Validate migration outcome.

#### Task 1: Install Windows Admin Center

1. On **SEA-ADM1**, start **Windows PowerShell** as Administrator.

   >**Note**: Perform the next two steps in case you have not already installed Windows Admin Center on **SEA-ADM1**.

1. In the **Windows PowerShell** console, run the following command to download the latest version of Windows Admin Center:
	
   ```powershell
   Start-BitsTransfer -Source https://aka.ms/WACDownload -Destination "$env:USERPROFILE\Downloads\WindowsAdminCenter.msi"
   ```
1. Run the following command to install Windows Admin Center:
	
   ```powershell
   Start-Process msiexec.exe -Wait -ArgumentList "/i $env:USERPROFILE\Downloads\WindowsAdminCenter.msi /qn /L*v log.txt REGISTRY_REDIRECT_PORT_80=1 SME_PORT=443 SSL_CERTIFICATE_OPTION=generate"
   ```

   > **Note**: Wait until the installation completes. This should take about 2 minutes.

#### Task 2: Set up file services

1. On **SEA-SVR2**, open the file **C:\\Labfiles\\Lab06\\L06_SetupFS.ps1** in Windows PowerShell ISE.
1. In the Windows PowerShell ISE script pane, review the script and then execute it. 

   >**Note:** Wait for the script to complete. This should take about 1 minute.

   >**Note:** The script initializes an extra data disk on **SEA-SVR1** and **SEA-SVR2**, creates an NTFS volume on each, assigns the **S:** drive letter to each volume, creates a share named **Data** using the **S:\Data** folder on **SEA-SVR1**, and adds to it sample files of the total size of about 1 GB. 

#### Task 3: Perform migration by using Storage Migration Service

1. On **SEA-ADM1**, start Microsoft Edge and connect to the local instance of Windows Admin Center at **https://SEA-ADM1.contoso.com**. 
1. If prompted, authenticate with the following credentials:

   - Username: **CONTOSO\\Administrator**
   - Password: **Pa55w.rd**

1. On **SEA-ADM1**, in Windows Admin Center, review the installed extensions and verify that the list includes the **Storage Migration Service** extension.

   >**Note:** If there is an update available, select the **Storage Migration Service** extension entry and select **Update**.

1. From the **All connections** pane, connect to **sea-svr2.contoso.com**.
1. From the **Tools** menu on the **sea-svr2.contoso.com** page, start **Storage Migration Service** and invoke the **Install** action.

   >**Note:** This will automatically install the Storage Migration Service and its required components.

1. Close the **Migrate storage in three steps** pane.
1. In the **Storage Migration Service** pane, create a migration job named **SVR1toSVR2** with the **Source devices** set to **Windows servers and clusters**.
1. In the **Storage Migration Service > SVR1toSVR2** pane, on the **Inventory servers** tab, review the **Check the prerequisites** pane.
1. On the **Inventory servers** tab, in the **Enter credentials** pane, if necessary, enter the credentials of the **CONTOSO\\Administrator** user account and clear the **Migrate from failover clusters** checkbox.
1. On the **Inventory servers** tab, in the **Add and scan devices** pane, add the **SEA-SVR1.contoso.com** server by using the following credentials:

   - Username: **CONTOSO\\Administrator**
   - Password: **Pa55w.rd**

   > **Note**: To perform single sign-on, you would need to set up the Kerberos constrained delegation.

1. From the list of devices, select the newly added **SEA-SVR1.contoso.com** entry and initiate its scan.

   >**Note:** Wait until the scan completes successfully. This should take about 1 minute.

   >**Note:** After the scan completes, proceed to the second stage of the migration job accessible via the **Transfer data** tab in the **Storage Migration Service > SVR1toSVR2** pane.

1. Verify that the **CONTOSO\\Administrator** user account is being used for data transfer.
1. Set the destination device to **SEA-SVR2.contoso.com**.

   >**Note:** Wait until the scan completes successfully. This should take about 1 minute.

   >**Note:** In hybrid scenarios, you also have the option of automatically creating an Azure VM serving as the destination of the migration job.

1. After the scan completes, in the **Specify the destination for: sea-svr1.contoso.com** pane, review the **Map each source volume to a destination volume** section and ensure that the **S:** source volume is mapped to the **S:** destination volume.
1. In the **Specify the destination for: sea-svr1.contoso.com** pane, review the **Select the shares to transfer** section and ensure that the **Data** source share is included in the transfer.
1. On the **Transfer data** tab, in the **Adjust transfer settings** pane, specify the following settings (leave others with their default values):

   | Setting | Value | 
   | --- | --- |
   | Back up folders that would be overwritten (Azure File Sync-enabled shares aren't backed up | enabled |
   | Validation method | **CRC 64** |
   | Max duration (minutes) | **60** |
   | Migrate users and groups | **Reuse accounts with the same name** |
   | Max retries | **3** |
   | Delay between retries (seconds) | **60** |

   >**Note:** On the **Transfer data** tab, in the **Install required features** pane, wait for the installation of **SMS-Proxy** on **SEA-SVR2.contoso.com** to complete.

1. After the scan completes, on the **Transfer data** tab, in the **Validate source and destination device** pane, initiate validation and wait until it successfully completes.
1. On the **Transfer data** tab, in the **Start the transfer** pane, initiate data transfer.

   >**Note:** Wait until the transfer completes successfully. This should take less than 1 minute.

   >**Note:** This will transition to the third stage of the migration job accessible via the **Cut over to the new servers** tab in the **Storage Migration Service > SVR1toSVR2** pane.

1. On the **Cut over to the new servers** tab, in the **Enter credentials for the source devices** and the **Enter credentials for the destination devices** sections, accept the stored credentials of the **CONTOSO\\Administrator** user account.
1. On the **Cut over to the new servers** tab, in the **Configure cutover from sea-svr1.contoso.com to sea-svr2.contoso.com** pane, in the **Source network adapters** section, specify the following settings:

   | Setting | Value | 
   | --- | --- |
   | Use DHCP | disabled |
   | IP address | **172.16.10.111** |
   | Subnet | **255.255.0.0** |
   | Gateway | **172.16.10.1** |

1. On the **Cut over to the new servers** tab, in the **Configure cutover from sea-svr1.contoso.com to sea-svr2.contoso.com** pane, in the **Destination network adapters** drop-down list, select **Seattle**.
1. On the **Cut over to the new servers** tab, in the **Configure cutover from sea-svr1.contoso.com to sea-svr2.contoso.com** pane, in the **Rename the source device after cutover** section, select the option **Choose a new name**, and then in the **New source computer name** dialog box enter **SEA-SVR1-OLD**.
1. On the **Cut over to the new servers** tab, in the **Adjust cutover settings** pane, in the **Cutover timeout (minutes)** text box, enter **30**, and then, in the **Enter AD credentials** section, leave the **Stored credentials** option enabled.
1. On the **Cut over to the new servers** tab, in the **Validate source and destination device** pane, initiate validation.
1. After the validation completes successfully, on the **Cut over to the new servers** tab, start the cutover stage.

   >**Note:** The cutover will trigger two consecutive restarts of both **SEA-SVR1** and **SEA-SVR2**.

#### Task 4: Validate migration outcome

1. On **SEA-ADM1**, start **Windows PowerShell** as Administrator.
1. To identify the IPv4 addresses assigned to the network interface of **SEA-SVR2**, in the **Windows PowerShell** console, run the following command:
	
   ```powershell
   Get-NetIPAddress | Where-Object AddressFamily -eq 'IPv4' | Select-Object IPAddress
   ```

   >**Note:** Verify that the output includes both **172.16.10.11** and **172.16.10.12**.

1. To identify the NetBIOS name assigned to **SEA-SVR2**, in the **Windows PowerShell** console, run the following command:
	
   ```powershell
   nbtstat -n
   ```

   >**Note:** Verify that the output includes both **SEA-SVR1** and **SEA-SVR2**.

1. To identify the local shares on **SEA-SVR2**, in the **Windows PowerShell** console, run the following command:
	
   ```powershell
   Get-SMBShare
   ```

   >**Note:** Verify that the output includes the **Data** share hosted in the **S:\Data** folder.

1. To identify the content of the **Data** share on **SEA-SVR2**, in the **Windows PowerShell** console, run the following command:
	
   ```powershell
   Get-ChildItem -Path 'S:\Data'
   ```

#### Review

In this lab, you have:

- Deployed AD DS domain controllers in Azure.
- Migrated file servers by using Storage Migration Service.