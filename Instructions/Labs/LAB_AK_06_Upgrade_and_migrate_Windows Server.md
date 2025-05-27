---
lab:
    title: 'Lab: Upgrade and migrate in Windows Server'
    type: 'Answer Key'
    module: 'Module 6 - Upgrade and migrate in Windows Server'
---

# Lab answer key: Upgrade and migrate in Windows Server

## Exercise 1: Deploying AD DS domain controllers in Azure

#### Task 1: Deploy a domain controller by using an Azure Resource Manager (ARM) template

1. Connect to **SEA-SVR2**, and then, if needed, sign in with the credentials provided by the instructor.
1. On **SEA-SVR2**, start Microsoft Edge, and access a customized version of the QuickStart template at **[Create a new Windows VM and create a new AD Forest, Domain and DC](https://github.com/az140mp/azure-quickstart-templates/tree/master/application-workloads/active-directory/active-directory-new-domain)**. 
1. On the **Create a new Windows VM and create a new AD Forest, Domain and DC** page, select **Deploy to Azure**. This will automatically redirect the browser to the **Create an Azure VM with a new AD Forest** page in the Azure portal.
1. On the **Create an Azure VM with a new AD Forest** page, select **Edit template**.
1. On the **Edit template** page, browse to the **storageProfile** section (starting with the line **195**) and verify that the **sku** (on line **199**) is set to **2022-Datacenter**, that the **version** (on line **200**) is set to **latest** and that **dataDisks** **caching** (on line **213**) is set to **None**.

   > **Note**: Caching on the disks hosting AD DS database and log files should be set to **None**.

1. On the **Edit template** page, browse to the **extension** section (starting with the line **233**) and note that the template uses PowerShell Desired State Configuration to run the **CreateADPDC.ps1** script within the deployed Azure virtual machine (VM).

   > **Note**: To review the script, you can use the following steps:

   1. On **SEA-SVR2**, open another tab in the Microsoft Edge window, and again access the customized version of QuickStart template at **[Create a new Windows VM and create a new AD Forest, Domain and DC](https://github.com/az140mp/azure-quickstart-templates/tree/master/application-workloads/active-directory/active-directory-new-domain)**.
   1. On the **Create a new Windows VM and create a new AD Forest, Domain and DC** page, in the listing of the repository content, select the **DSC** folder, and then select **CreateADPDC.ps1** file.
   1. On the **azure-quickstart-templates/application-workloads/active-directory/active-directory-new-domain/DSC/CreateADPDC.ps1** page, review the content of the script and note that it installs a number of server roles, including Active Directory Domain Services and DNS, placing the NTDS database and logs, as well as the SYSOVL share on drive **F**. 
   1. Close the Microsoft Edge tab and switch back to the one displaying the **Edit template** page in the Azure portal.

1. On the **Edit template** page, browse to the section that provisions an availability set (starting with the line **110**) and note that the template creates an availability set and deploys the VM into it (as indicated by the **dependsOn** element on line **181**).

   > **Note**: Later in this exercise, you will deploy another Azure VM into the same availability set and configure it as an additional domain controller in the same domain. The use of an availability set provides additional resiliency.

1. Browse to the section that provisions the network interface of the Azure VM (starting with the line **110**) and note that the private IP address allocation method is set to **Static** (on line **164**).

   > **Note**: Using the static assignment is common when deploying domain controllers, but it is essential for servers that host the DNS server role.

1. Browse to the section that deploys a nested template(starting with line **266**) and note that the template updates the DNS server address within the virtual network hosting the Azure VM operating as a domain controller with the DNS server role installed.

   > **Note**: Configuring the custom DNS server virtual network setting that points to the Azure VM running the domain controller with the DNS server role ensures that any Azure VM subsequently deployed into the same virtual network will automatically use that DNS server for name resolution, effectively providing the domain join functionality.

1. On the **Edit template** page, select **Discard**.
1. Back on the **Create an Azure VM with a new AD Forest** page, select **Edit parameters**.
1. On the **Edit parameters** page, select **Load file**, in the **File Upload** dialog box, browse to the **C:\\Labfiles\\Lab06** folder, select the **L06-rg_template.parameters.json** file, and then select **Open**.
1. On the **Edit template** page, select **Save**.
1. Back on the **Create an Azure VM with a new AD Forest** page, below the **Resource group** drop-down list, select **Create new**, in the **Name** text box, enter **AZ801-L0601-RG**, and then select **OK**.
1. On the **Create an Azure VM with a new AD Forest** page, if needed, adjust the deployment settings so they have the following values (leave others with their default values):

   | Setting | Value | 
   | --- | --- |
   | Subscription | the name of the Azure subscription you are using in this lab |
   | Resource group | the name of a new resource group **AZ801-L0601-RG** |
   | Region | the name of an Azure region into which you can provision Azure VMs |
   | Admin Username | **Student** |
   | Admin Password | **Pa55w.rd1234** |
   | Domain name | **contoso.com** |
   | Vm Size | **Standard_D2s_v3** |
   | _artifacts Location | **`https://raw.githubusercontent.com/az140mp/azure-quickstart-templates/master/application-workloads/active-directory/active-directory-new-domain/`** |
   | Virtual Machine Name | **az801l06a-dc1** |
   | Virtual Network Name | **az801l06a-vnet** |
   | Virtual Network Address Range | **10.6.0.0/16** |
   | Network Interface Name | **az801l06a-dc1-nic1** |
   | Private IP Address | **10.6.0.4** |
   | Subnet Name | **adSubnet** |
   | Subnet Range | **10.6.0.0/24** |
   | Availability Set Name | **adAvailabilitySet** |

1. On the **Create an Azure VM with a new AD Forest** page, select **Review + create**, and then select **Create**.

   > **Note**: Wait for the deployment to complete before you proceed to the next task. This might take about 15 minutes. 

#### Task 2: Deploy Azure Bastion 

> **Note**: Azure Bastion allows for connection to the Azure VMs without public endpoints which you deployed in the previous task of this exercise, while providing protection against brute force exploits that target operating system level credentials.

1. On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, open the Azure Cloud Shell pane by selecting the Cloud Shell button in the Azure portal.
1. If prompted to select either **Bash** or **PowerShell**, select **PowerShell**.

   > **Note:** If this is the first time you're starting Cloud Shell and you're presented with the **You have no storage mounted** message, select the subscription you are using in this lab, and then select **Create storage**.

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

1. Close the Cloud Shell pane.
1. In the Azure portal, in the **Search resources, services, and docs** text box, on the toolbar, search for and select **Bastions**, and then, on the **Bastions** page, select **+ Create**.
1. On the **Basic** tab of the **Create a Bastion** page, specify the following settings, and then select **Review + create**:

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

1. On the **Review + create** tab of the **Create a Bastion** page, select **Create**:

   > **Note**: Do not wait for the deployment to complete but instead proceed to the next task. The deployment might take about 5 minutes.

#### Task 3: Deploy an Azure VM by using the Azure portal

> **Note**: You could fully automate the deployment of the second Azure VM and its setup as an additional domain controller in the same domain as the first one you provisioned in the first task of this exercise. However, the use of graphical interface in this case should provide additional guidance regarding differences between provisioning domain controllers in on-premises and Azure-based scenarios.

1. On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, in the **Search resources, services, and docs** text box, on the toolbar, search for and select **Virtual machines**. 
1. On the **Virtual machines** page, select **+ Create**, and then, in the drop-down menu, select **Azure virtual machine**.
1. On the **Basics** tab of the **Create a virtual machine** blade, specify the following settings (leave others with their default values):

   | Setting | Value |
   | --- | --- |
   | Subscription | the name of the Azure subscription you are using in this lab |
   | Resource group | select the existing resource group **AZ801-L0601-RG** |
   | Virtual machine name | **az801l06a-dc2** |
   | Region | select the same Azure region into which you deployed the first virtual machine earlier in this exercise |
   | Availability options | **Availability set** |
   | Availability set | **adAvailabilitySet** |
   | Image | **Windows Server 2022 Datacenter: Azure Edition - Gen2** |
   | Run with Azure Spot discount | **No** |
   | Size | **Standard D2s v3** |
   | Username | **Student** |
   | Password | **Pa55w.rd1234** |
   | Public inbound ports | **None** |
   | Would you like to use an existing Windows Server license? | **No** |

1. Select **Next: Disks >**, and then, on the **Disks** tab of the **Create a virtual machine** blade, specify the following settings (leave others with their default values):

   | Setting | Value |
   | --- | --- |
   | OS disk type | **Standard SSD** |

1. On the **Disks** tab of the **Create a virtual machine** blade, in the **Data disks** section, select **Create and attach a new disk**.
1. On the **Create a new disk** page, specify the following settings (leave others with their default values), and then select **OK**:

   | Setting | Value |
   | --- | --- |
   | Name | **az801l06a-dc2_DataDisk_0** |
   | Source type | **None (empty disk)** |
   | Size | **32 GiB** **Premium SSD** |

1. Back on the **Disks** tab of the **Create a virtual machine** blade, select **Next: Networking >**, and then, on the **Networking** tab of the **Create a virtual machine** blade, specify the following settings (leave others with their default values):

   | Setting | Value |
   | --- | --- |
   | Virtual network | **az801l06a-vnet** |
   | Subnet | **adSubnet (10.6.0.0/24)** |
   | Public IP | **None** |
   | NIC network security group | **None** |
   | Enable accelerated networking | disabled |
   | Place this virtual machine behind an existing load balancing solution? | disabled |

1. Select **Next: Management >**, and then, on the **Management** tab of the **Create a virtual machine** blade, specify the following settings (leave others with their default values):

   | Setting | Value |
   | --- | --- |
   | Patch orchestration options | **Manual updates** |

1. Select **Next: Monitoring >**, and then, on the **Monitoring** tab of the **Create a virtual machine** blade, specify the following settings (leave others with their default values):

   | Setting | Value |
   | --- | --- |
   | Boot diagnostics | **Enable with managed storage account (recommended)** |

1. Select **Next: Advanced >**, on the **Advanced** tab of the **Create a virtual machine** blade, review the available settings without modifying any of them, and then select **Review + Create**.
1. On the **Review + Create** blade, select **Create**.

   > **Note**: Wait for the deployment to complete. The deployment might take about 3 minutes.

#### Task 4: Manually promote a domain controller in an Azure VM

1. On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, on the deployment page, select **Go to resource**.
1. On the **az801l06a-dc2** page, on the vertical menu of the left side, in the **Settings** section, select **Networking**.
1. On the **az801l06a-dc2 \| Networking** page, select the link to the network interface of the **az801l06a-dc2** virtual machine.
1. On the network interface page, on the vertical menu of the left side, in the **Settings** section, select **IP Configurations**.
1. On the **IP Configurations** page, select **ipconfig1** entry.
1. On the **ipconfig1** page, in the **Private IP address settings** section, select **Static**, and then select **Save**.

   > **Note**: Using the static assignment is common when deploying domain controllers, but it is essential for servers that host the DNS server role.

   > **Note**: Assigning static IP address to a network interface of an Azure VM will trigger a restart of its operating system.

1. On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, browse back to the **az801l06a-dc2** page.
1. On the **az801l06a-dc2** page, select **Connect**, from the drop-down menu, select **Bastion**. 
1. On the Bastion page, provide the following credentials, and then select **Connect**:

   | Setting | Value | 
   | --- | --- |
   | User Name |**Student** |
   | Password |**Pa55w.rd1234** |

> **Note**: **Edge** by default will block popups. To allow popups for **Bastion** go to **Settings** in **Edge**, select **Cookies and site permissions** on the left, **Pop-ups and redirects** under **All permissions** and finally toggle **Block (recommended)** off.

1. Within the Remote Desktop session to **az801l06a-dc2**, select **Start**, and then select **Windows PowerShell**.
1. To install the AD DS and DNS server roles, at the Windows PowerShell command prompt, enter the following command, and then press Enter:
	
   ```powershell
   Install-WindowsFeature -Name AD-Domain-Services,DNS -IncludeManagementTools
   ```

   > **Note**: Wait for the installation to complete. This might take about 3 minutes.

1. To configure the data disk, at the Windows PowerShell prompt, enter the following commands, and after entering each command, press Enter:

   ```powershell
   Get-Disk | Where PartitionStyle -eq 'RAW' |  Initialize-Disk -PartitionStyle MBR
   New-Partition -DiskNumber 2 -UseMaximumSize -AssignDriveLetter
   Format-Volume -DriveLetter F -FileSystem NTFS
   ```

1. Within the Remote Desktop session to **az801l06a-dc2**, switch to the **Server Manager** window.
1. In **Server Manager**, select the **Notifications** flag symbol, and then, in the **Post-deployment Configuration** section, select the **Promote this server to a domain controller** link. This will start **Active Directory Domain Services Configuration Wizard**.
1. On the **Deployment Configuration** page of **Active Directory Domain Services Configuration Wizard**, under **Select the deployment operation**, verify that **Add a domain controller to an existing domain** is selected.
1. In the **Domain** text box, enter **contoso.com** domain.
1. In the **Supply the credentials to perform this operation** section, select **Change**.
1. In the **Credentials for deployment operation** dialog box, in the **User name** box, enter **Student@contoso.com**, in the **Password** box, enter **Pa55w.rd1234**, and then select **OK**. 
1. Back on the **Deployment Configuration** page of **Active Directory Domain Services Configuration Wizard**, select **Next**.
1. On the **Domain Controller Options** page, ensure that the **Domain Name System (DNS) server** and **Global Catalog (GC)** checkboxes are selected. Ensure that the **Read-only domain controller (RODC)** checkbox is cleared.
1. In the **Type the Directory Services Restore Mode (DSRM) password** section, enter and confirm the password **Pa55w.rd1234**, and then select **Next**.
1. On the **DNS Options** page of **Active Directory Domain Services Configuration Wizard**, select **Next**.
1. On the **Additional Options** page, select **Next**.
1. On the **Paths** page, change the drive of the path settings from **C:** to **F:** for the **Database** folder, **Log files** folder, and **SYSVOL** folder, and then select **Next**.
1. On the **Review Options** page, select **Next**.
1. On the **Prerequisite Check** page, note the warnings regarding network adapter not having static IP address, and then select **Install**.

   > **Note**: The warning is expected because the static IP address is assigned on the platform level, rather than within the operating system.

   > **Note**: The operating system will restart automatically to complete the promotion process.

1. On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, on the **az801l06a-dc2** page, select **Connect**, from the drop-down menu, select **Bastion**.  
1. On the Bastion page, provide the following credentials, and then select **Connect**:

   | Setting | Value | 
   | --- | --- |
   | User Name |**Student** |
   | Password |**Pa55w.rd1234** |

1. Within the Remote Desktop session to **az801l06a-dc2**, wait until the **Server Manager** window opens and verify that the list of locally installed roles includes **AD DS** and **DNS**.

#### Task 5: Remove Azure resources deployed in the exercise

1. On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, open a PowerShell session within the Azure Cloud Shell pane by selecting the Cloud Shell button in the Azure portal.
1. From the Cloud Shell pane, run the following command to list all resource groups you created in this lab:

   ```powershell
   Get-AzResourceGroup -Name 'AZ801-L060*'
   ```

   > **Note**: Verify that the output contains only the resource group you created in this lab. This group will be deleted in this task.

1. From the Cloud Shell pane, run the following command to delete the resource group you created in this lab:

   ```powershell
   Get-AzResourceGroup -Name 'AZ801-L060*' | Remove-AzResourceGroup -Force -AsJob
   ```

   > **Note:** The command executes asynchronously (as determined by the *-AsJob* parameter), so while you will be able to immediately run another PowerShell command within the same PowerShell session, it will take a few minutes before the resource groups are actually removed.

## Exercise 2: Migrating file servers by using Storage Migration Service

#### Task 1: Install Windows Admin Center

1. On **SEA-SVR2**, select **Start**, and then select **Windows PowerShell**.
1. In the **Windows PowerShell** console, enter the following command, and then press Enter to download the latest version of Windows Admin Center:
	
   ```powershell
   Start-BitsTransfer -Source https://aka.ms/WACDownload -Destination "$env:USERPROFILE\Downloads\WindowsAdminCenter.msi"
   ```
1. Enter the following command, and then press Enter to install Windows Admin Center:
	
   ```powershell
   Start-Process msiexec.exe -Wait -ArgumentList "/i $env:USERPROFILE\Downloads\WindowsAdminCenter.msi /qn /L*v log.txt REGISTRY_REDIRECT_PORT_80=1 SME_PORT=443 SSL_CERTIFICATE_OPTION=generate"
   ```

   > **Note**: Wait until the installation completes. This should take about 2 minutes.

#### Task 2: Set up file services

1. On **SEA-SVR2**, on the taskbar, select **File Explorer**.
1. In File Explorer, browse to the **C:\\Labfiles\\Lab06** folder.
1. In File Explorer, in the details pane, select the file **L06_SetupFS.ps1**, display its context menu, and then, in the menu, select **Edit**.

   >**Note:** This will automatically open the file **L06_SetupFS.ps1** in the script pane of Windows PowerShell ISE.

1. In the Windows PowerShell ISE script pane, review the script, and then execute it by selecting the **Run Script** icon in the toolbar or by pressing F5. 

   >**Note:** Wait for the script to complete. This should take about 1 minute.

   >**Note:** The script initializes an extra data disk on **SEA-SVR1** and **SEA-SVR2**, creates an NTFS volume on each, assigns the **S:** drive letter to each volume, creates a share named **Data** using the **S:\Data** folder on **SEA-SVR1**, and adds to it sample files with a total size of about 1 GB. 

#### Task 3: Perform migration by using Storage Migration Service

1. On **SEA-SVR2**, start Microsoft Edge, and then go to **https://SEA-SVR2.contoso.com**. 
   
   >**Note**: If the link does not work, on **SEA-SVR2**, open File Explorer, select Downloads folder, in the Downloads folder select **WindowsAdminCenter.msi** file and install manually. After the install completes, refresh Microsoft Edge.

   >**Note**: If you get **NET::ERR_CERT_DATE_INVALID** error, select **Advanced** on the Edge browser page, at the bottom of page select **Continue to sea-svr2-contoso.com (unsafe)**.

1. When prompted, in the **Windows Security** dialog box, enter the credentials provided by the instructor, and then select **OK**.

1. Review the **New in this release** pop-up window and select **Close** in its upper-right corner.
1. In the **All connections** pane of Windows Admin Center, in the upper-right corner, select the **Settings** icon (the cog wheel).
1. In the left pane, select **Extensions**. Review the available extensions.
1. In the details pane, select **Installed extensions** and verify that the list includes the **Storage Migration Service** extension.

   >**Note:** If there is an update available, select the **Storage Migration Service** extension entry and select **Update**.

1. On the top menu, next to **Settings**, select the drop-down arrow, and then select **Server Manager**.
1. In the **All connections** pane, select the **sea-svr2.contoso.com** link.
1.  On the **sea-svr2.contoso.com** page, on the **Tools** menu, select the **Storage Migration Service** entry.
1. In the **Storage Migration Service** pane, select **Install**.

   >**Note:** This will automatically install the Storage Migration Service and its required components.

1. In the **Migrate storage in three steps** pane, select **Close**.
1. In the **Storage Migration Service** pane, scroll down to the bottom of the page and select **+ New job**.
1. In the **New job** pane, in the **Job name** text box, enter **SVR1toSVR2**, ensure that the **Windows servers and clusters** **Source devices** option is selected, and select **OK**.
1. In the **Storage Migration Service > SVR1toSVR2** pane, on the **Inventory servers** tab, review the **Check the prerequisites** pane and select **Next**.
1. On the **Inventory servers** tab, in the **Enter credentials** pane, if necessary, enter the credentials of the **CONTOSO\\Administrator** user account, clear the **Migrate from failover clusters** checkbox, and then select **Next**.
1. On the **Inventory servers** tab, in the **Install required features** pane, select **Next**.
1. On the **Inventory servers** tab, in the **Add and scan devices** pane, select **+ Add a device**.
1. On the **Add source device**, ensure that the **Device name** option is selected, in the **Name** text box, enter **SEA-SVR1.contoso.com**, and then select **Add**.
1. In the **Specify your credentials** pane, select the **Use another account for this connection** option , enter the credentials provided by the instructor, select **Use these credentials for all connections**, and then select **Continue**.

   > **Note**: To perform single sign-on, you would need to set up Kerberos constrained delegation<!--Marcin can this be 'a Kerberos constrained delegation'?-->.

1. On the list of devices, select the newly added **SEA-SVR1.contoso.com** entry, in the **Add and scan devices** pane, in the toolbar, select the ellipsis (**...**) symbol, and then, in the drop-down menu, select **Start scan**.

   >**Note:** Wait until the scan completes successfully. This should take about 1 minute.

1. On the **Inventory servers** tab, in the **Add and scan devices** pane, select **Next**. 

   >**Note:** This will transition to the second stage of the migration job accessible via the **Transfer data** tab in the **Storage Migration Service > SVR1toSVR2** pane.

1. On the **Transfer data** tab, in the **Enter credentials for the destination device** pane, verify that the **CONTOSO\\Administrator** user account is being used and select **Next**.
1. In the **Specify the destination for: sea-svr1.contoso.com** pane, ensure that the **Destination** option is set to **Use an existing server or VM**, in the **Destination device** text box, enter **SEA-SVR2.contoso.com** and select **Scan**.

   >**Note:** Wait until the scan completes successfully. This should take about 1 minute.

   >**Note:** In hybrid scenarios, you also have the option of automatically creating an Azure VM serving as the destination of the migration job.

1. After the scan completes, in the **Specify the destination for: sea-svr1.contoso.com** pane, review the **Map each source volume to a destination volume** section and ensure that the **S:** source volume is mapped to the **S:** destination volume.
1. In the **Specify the destination for: sea-svr1.contoso.com** pane, review the **Select the shares to transfer** section, ensure that the **Data** source share is included in the transfer, and then select **Next**.
1. On the **Transfer data** tab, in the **Adjust transfer settings** pane, specify the following settings (leave others with their default values), and then select **Next**:

   | Setting | Value | 
   | --- | --- |
   | Back up folders that would be overwritten (Azure File Sync-enabled shares aren't backed up) | enabled |
   | Validation method | **CRC 64** |
   | Max duration (minutes) | **60** |
   | Migrate users and groups | **Reuse accounts with the same name** |
   | Max retries | **3** |
   | Delay between retries (seconds) | **60** |

1. On the **Transfer data** tab, in the **Install required features** pane, wait for the installation of **SMS-Proxy** on **SEA-SVR2.contoso.com** to complete, and then select **Next**.
1. On the **Transfer data** tab, in the **Validate source and destination devices** pane, select **Validate**, and after the validation successfully completes, select **Next**.
1. On the **Transfer data** tab, in the **Start the transfer** pane, select **Start transfer**, wait until it completes, and then select **Next**.

   >**Note:** Wait until the transfer completes successfully. This should take less than 1 minute.

   >**Note:** This will transition to the third stage of the migration job accessible via the **Cut over to the new servers** tab on the **Storage Migration Service > SVR1toSVR2** pane.

1. On the **Cut over to the new servers** tab, in the **Enter credentials for the source devices** and the **Enter credentials for the destination devices** sections, accept the stored credentials of the **CONTOSO\\Administrator** user account and select **Next**.
1. On the **Cut over to the new servers** tab, in the **Configure cutover from sea-svr1.contoso.com to sea-svr2.contoso.com** pane, in the **Source network adapters** section, specify the following settings:

   | Setting | Value | 
   | --- | --- |
   | Use DHCP | disabled |
   | IP address | **172.16.10.111** |
   | Subnet | **255.255.0.0** |
   | Gateway | **172.16.10.1** |

1. On the **Cut over to the new servers** tab, in the **Configure cutover from sea-svr1.contoso.com to sea-svr2.contoso.com** pane, in the **Destination network adapters** drop-down list, select **Ethernet**.
1. On the **Cut over to the new servers** tab, in the **Configure cutover from sea-svr1.contoso.com to sea-svr2.contoso.com** pane, in the **Rename the source device after cutover** section, select the **Choose a new name** option, in the **New source computer name**<!--text box?-->, enter **SEA-SVR1-OLD**, and then select **Next**.
1. On the **Cut over to the new servers** tab, in the **Adjust cutover settings** pane, in the **Cutover timeout (minutes)** text box, enter **30**, in the **Enter AD credentials** section, leave the **Stored credentials** option enabled, and then select **Next**.
1. On the **Cut over to the new servers** tab, in the **Validate source and destination device** pane, select **Validate**, and after the validation successfully completes, select **Next**.
1. On the **Cut over to the new servers** tab, in the **Cut over to the new servers** pane, select **Start cutover**.

   >**Note:** The cutover will trigger two consecutive restarts of both **SEA-SVR1** and **SEA-SVR2**.

#### Task 4: Validate migration outcome

1. On **SEA-SVR2**, sign in with the credentials provided by the instructor.
1. On **SEA-SVR2**, select **Start**, and then select **Windows PowerShell**.
1. To identify the IPv4 addresses assigned to the network interface of **SEA-SVR2**, in the **Windows PowerShell** console, enter the following command, and then press Enter:
	
   ```powershell
   Get-NetIPAddress | Where-Object AddressFamily -eq 'IPv4' | Select-Object IPAddress
   ```

   >**Note:** Verify that the output includes both **172.16.10.11** and **172.16.10.12**.

1. To identify the NetBIOS name assigned to **SEA-SVR2**, in the **Windows PowerShell** console, enter the following command, and then press Enter:
	
   ```powershell
   nbtstat -n
   ```

   >**Note:** Verify that the output includes both **SEA-SVR1** and **SEA-SVR2**.

1. To identify the local shares on **SEA-SVR2**, in the **Windows PowerShell** console, enter the following command, and then press Enter:
	
   ```powershell
   Get-SMBShare
   ```

   >**Note:** Verify that the output includes the **Data** share hosted in the **S:\Data** folder.

1. To identify the content of the **Data** share on **SEA-SVR2**, in the **Windows PowerShell** console, enter the following command, and then press Enter:
	
   ```powershell
   Get-ChildItem -Path 'S:\Data'
   ```

