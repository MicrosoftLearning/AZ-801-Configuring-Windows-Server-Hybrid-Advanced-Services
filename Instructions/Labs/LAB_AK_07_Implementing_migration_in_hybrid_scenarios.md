---
lab:
    title: 'Lab: Migrating Hyper-V VMs to Azure by using Azure Migrate'
    type: 'Answer Key'
    module: 'Module 7: Design for Migration'
---

# Lab answer key: Migrating Hyper-V VMs to Azure by using Azure Migrate

## Exercise 1: Prepare the lab environment

#### Task 1: Deploy an Azure VM by using an Azure Resource Manager QuickStart template

1. Connect to **SEA-SVR2** and then, if needed, sign in as **CONTOSO\\Administrator** with the password **Pa55w.rd**.
1. On **SEA-SVR2**, start Microsoft Edge, go to the **[301-nested-vms-in-virtual-network Azure QuickStart template](https://github.com/az140mp/azure-quickstart-templates/tree/master/demos/nested-vms-in-virtual-network)** and select **Deploy to Azure**. (You'll find the button **Deploy to Azure** in the `README.md` file after the list of resources created by the template.) This will automatically redirect the browser to the **Hyper-V Host Virtual Machine with nested VMs** page in the Azure portal.
1. When prompted, in the Azure portal, sign in by using the credentials of a user account with the Owner role in the subscription you'll be using in this lab.
1. On the **Hyper-V Host Virtual Machine with nested VMs** page in the Azure portal, specify the following settings (Leave others with their default values.):

   | Setting | Value | 
   | --- | --- |
   | Subscription | the name of the Azure subscription you are using in this lab |
   | Resource group | the name of a new resource group **AZ801-L0701-RG** |
   | Region | the name of an Azure region into which you can provision Azure VMs |
   | Virtual Network Name | **az801l07a-hv-vnet** |
   | Host Network Interface1Name | **az801l07a-hv-vm-nic1** |
   | Host Network Interface2Name | **az801l07a-hv-vm-nic2** |
   | Host Virtual Machine Name | **az801l07a-hv-vm** |
   | Host Admin Username | **Student** |
   | Host Admin Password | **Pa55w.rd1234** |

1. On the **Hyper-V Host Virtual Machine with nested VMs** page, select **Review + create** and then select **Create**.

   > **Note**: Wait for the deployment to complete. The deployment might take about 10 minutes.

#### Task 2: Deploy Azure Bastion 

> **Note**: Azure Bastion allows for connection to the Azure VMs without public endpoints which you deployed in the previous task of this exercise, while providing protection against brute force exploits that target operating system level credentials.

1. On **SEA-SVR2**, in the browser window displaying the Azure portal, open the **Azure Cloud Shell** pane by selecting the **Cloud Shell** button in the Azure portal.
1. If prompted to select either **Bash** or **PowerShell**, select **PowerShell**.

   > **Note:** If this is the first time you're starting **Cloud Shell** and you're presented with the **You have no storage mounted** message, select the subscription you are using in this lab, and then select **Create storage**.

1. From the PowerShell session on the **Cloud Shell** pane, run the following commands to add a subnet named **AzureBastionSubnet** to the virtual network **az801l07a-hv-vnet** you created earlier in this exercise:

   ```powershell
   $resourceGroupName = 'AZ801-L0701-RG'
   $vnet = Get-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Name 'az801l07a-hv-vnet'
   $subnetConfig = Add-AzVirtualNetworkSubnetConfig `
    -Name 'AzureBastionSubnet' `
    -AddressPrefix 10.0.7.0/24 `
    -VirtualNetwork $vnet
   $vnet | Set-AzVirtualNetwork
   ```

1. Close the **Cloud Shell** pane.
1. In the Azure portal, in the **Search resources, services, and docs** text box, on the toolbar, search for and select **Bastions** and then, on the **Bastions** page, select **+ Create**.
1. On the **Basic** tab of the **Create a Bastion** page, specify the following settings and select **Review + create**:

   | Setting | Value | 
   | --- | --- |
   | Subscription | the name of the Azure subscription you are using in this lab |
   | Resource group | **AZ801-L0701-RG** |
   | Name | **az801l07a-bastion** |
   | Region | the same Azure region to which you deployed the resources in the previous tasks of this exercise |
   | Tier | **Basic** |
   | Virtual network | **az801l07a-hv-vnet** |
   | Subnet | **AzureBastionSubnet (10.0.7.0/24)** |
   | Public IP address | **Create new** |
   | Public IP name | **az801l07a-hv-vnet-ip** |

   > **Note**: The bastion must be created in the same Azure region as the virtual network.

1. On the **Review + create** tab of the **Create a Bastion** page, select **Create**:

   > **Note**: Wait for the deployment to complete before you proceed to the next task. The deployment might take about 5 minutes.

#### Task 3: Deploy a nested VM in the Azure VM

1. In the Azure portal, in the **Search resources, services, and docs** text box, on the toolbar, search for and select **Virtual machines** and then, on the **Virtual machines** page, select **az801l07a-hv-vm**.
1. On the **az801l07a-hv-vm** page, select **Connect** and then, in the drop-down menu, select **Bastion**. On the **Bastion** tab of the **az801l07a-hv-vm \| Connect** page, select **Use Bastion**.
1. When prompted, provide the following credentials and select **Connect**:

   | Setting | Value | 
   | --- | --- |
   | User Name |**Student** |
   | Password |**Pa55w.rd1234** |

1. Within the Remote Desktop session to **az801l07a-hv-vm**, in the **Server Manager** window, select **Local Server**, select the **On** link next to the **IE Enhanced Security Configuration** label. In the **IE Enhanced Security Configuration** dialog box, select both **Off** options, and then select **OK**.
1. From the Remote Desktop session, open File Explorer and browse to the **F:** drive. Create two folders **F:\\VHDs** and **F:\\VMs**. 
1. Within the Remote Desktop session to **az801l07a-hv-vm**, start Microsoft Edge, complete the initial setup, go to [Windows Server Evaluations](https://techcommunity.microsoft.com/t5/windows-11/accessing-trials-and-kits-for-windows-eval-center-workaround/m-p/3361125), provide the requested information, download the Windows Server 2022 **VHD** file, and copy it to the **F:\VHDs** folder. 
1. Within the Remote Desktop session to **az801l07a-hv-vm**, select **Start**, select **Windows Administrative Tools**, and then select **Hyper-V Manager**. 
1. In the **Hyper-V Manager** console, select the **az801l07a-hv-vm** node. 
1. Select **New** and then, in the cascading menu, select **Virtual Machine**. This will start the **New Virtual Machine Wizard**. 
1. On the **Before You Begin** page of the **New Virtual Machine Wizard**, select **Next >**.
1. On the **Specify Name and Location** page of the **New Virtual Machine Wizard**, specify the following settings and select **Next >**:

   | Setting | Value | 
   | --- | --- |
   | Name | **az801l07a-vm1** | 
   | Store the virtual machine in a different location | selected | 
   | Location | **F:\VMs** |

1. On the **Specify Generation** page of the **New Virtual Machine Wizard**, ensure that the **Generation 1** option is selected, and then select **Next >**.
1. On the **Assign Memory** page of the **New Virtual Machine Wizard**, set **Startup memory** to **2048**, and then select **Next >**.
1. On the **Configure Networking** page of the **New Virtual Machine Wizard**, in the **Connection** drop-down list, select **NestedSwitch**, and then select **Next >**.
1. On the **Connect Virtual Hard Disk** page of the **New Virtual Machine Wizard**, select the option **Use an existing virtual hard disk**, set location to the **VHD** file you downloaded to the **F:\VHDs** folder, and then select **Next >**.
1. On the **Summary** page of the **New Virtual Machine Wizard**, select **Finish**.
1. In the **Hyper-V Manager** console, select the newly created virtual machine, and then select **Start**. 
1. In the **Hyper-V Manager** console, verify that the virtual machine is running, and then select **Connect**. 
1. In the **Virtual Machine Connection** window to **az801l07a-vm1**, on the **Hi there** page, select **Next**. 
1. In the **Virtual Machine Connection** window to **az801l07a-vm1**, on the **License terms** page, select **Accept**. 
1. In the **Virtual Machine Connection** window to **az801l07a-vm1**, on the **Customize settings** page, set the password of the built-in Administrator account to **Pa55w.rd**, and then select **Finish**. 
1. In the **Virtual Machine Connection** window to **az801l07a-vm1**, in the **Action** menu, select **Ctrl + Alt + Delete** and then, when prompted, sign in by using the newly set password.
1. In the **Virtual Machine Connection** window to **az801l07a-vm1**, select **Start**. In the **Start** menu, select **Windows PowerShell** and then, in the **Administrator: Windows PowerShell** window, run the following to set the computer name. 

   ```powershell
   Rename-Computer -NewName 'az801l07a-vm1' -Restart
   ```

## Exercise 2: Prepare for assessment and migration by using Azure Migrate
  
#### Task 1: Configure Hyper-V environment

1. Within the Remote Desktop session to **az801l07a-hv-vm**, in the browser window, go to [https://aka.ms/migrate/script/hyperv](https://aka.ms/migrate/script/hyperv), and download the Azure Migrate configuration PowerShell script.

   >**Note**: The script performs the following tasks:

   >- Checks that you're running the script on a supported PowerShell version
   >- Verifies that you have administrative privileges on the Hyper-V host
   >- Allows you to create a local user account that the Azure Migrate service uses to communicate with the Hyper-V host (This user account is added to **Remote Management Users**, **Hyper-V Administrators**, and **Performance Monitor Users** groups on the Hyper-V host.) 
   >- Checks that the host is running a supported version of Hyper-V, and the Hyper-V role
   >- Enables the WinRM service, and opens ports 5985 (HTTP) and 5986 (HTTPS) on the host (This is required for metadata collection.) 
   >- Enables PowerShell remoting on the host
   >- Checks that the Hyper-V Integration Services is enabled on all VMs managed by the host
   >- Enables CredSSP on the host if needed

1. Within the Remote Desktop session to **az801l07a-hv-vm**, select **Start** and then select **Windows PowerShell ISE**. 
1. In the **Administrator: Windows PowerShell ISE** window, on the console pane, run the following commands to copy the script to the **C:\\Labfiles\\Lab07** folder and remove the Zone.Identifier alternate data stream, which, in this case, indicates that the file was downloaded from the Internet:

   ```powershell
   New-Item -ItemType Directory -Path C:\Labfiles\Lab07 -Force
   Copy-Item -Path "$env:USERPROFILE\Downloads\MicrosoftAzureMigrate-Hyper-V.ps1" -Destination 'C:\Labfiles\Lab07'
   Unblock-File -Path C:\Labfiles\Lab07\MicrosoftAzureMigrate-Hyper-V.ps1
   Set-Location -Path C:\Labfiles\Lab07
   ```

1. In the **Administrator: Windows PowerShell ISE** window, open the **MicrosoftAzureMigrate-Hyper-V.ps1** script residing in the **C:\\Labfiles\\Lab07** folder and run it. When prompted for confirmation, enter **Y** and press Enter, with the exception of the following prompts, in which case, enter **N** and press Enter:

   - Do you use SMB share(s) to store the VHDs?
   - Do you want to create non-administrator local user for Azure Migrate and Hyper-V Host communication? 

#### Task 2: Create an Azure Migrate project

1. Within the Remote Desktop session to **az801l07a-hv-vm**, in the browser window, go to the [Azure portal](https://portal.azure.com), and sign in by using the credentials of a user account with the Owner role in the subscription you are using in this lab.
1. In the Azure portal, in the **Search resources, services, and docs** text box, on the toolbar, search for and select **Azure Migrate**, and then, on the **Azure Migrate \| Get Started** page, in the **Servers, databases, and web apps** section, select **Discover, assess, and migrate**.
1. On the **Azure Migrate \| Servers, databases, and web apps** page, select **Create Project**.
1. On the **Create Project** page, specify the following settings (leave others with their default values) and select **Create**:

   | Setting | Value | 
   | --- | --- |
   | Subscription | the name of the Azure subscription you are using in this lab |
   | Resource group | the name of a new resource group **AZ801-L0702-RG** |
   | Migrate project | **az801l07a-migrate-project** |
   | Geography | the name of your country or a geographical region |

#### Task 3: Implement the target Azure environment

1. Within the Remote Desktop session to **az801l07a-hv-vm**, in the Azure portal, in the **Search resources, services, and docs** text box, on the toolbar, search for and select **Virtual networks**. On the **Virtual networks** page, select **+ Create** on the command bar. 
1. On the **Basics** tab of the **Create virtual network** page, specify the following settings (leave others with their default values) and select **Next: IP Addresses**:

   | Setting | Value |
   | --- | --- |
   | Subscription | the name of the Azure subscription you are using in this lab |
   | Resource group | the name of a new resource group **AZ801-L0703-RG** |
   | Name | **az801l07a-migration-vnet** |
   | Region | the name of the Azure region into which you deployed the virtual machine earlier in this lab |

1. On the **IP addresses** tab of the **Create virtual network** page, select the **Recycle Bin** icon. In the **IPv4 address space** text box, type **10.7.0.0/16** and select **+ Add subnet**.
1. On the **Add subnet** page, specify the following settings (leave others with their default values) and select **Add**:

   | Setting | Value |
   | --- | --- |
   | Subnet name | **subnet0** |
   | Subnet address range | **10.7.0.0/24** |

1. Back on the **IP addresses** tab of the **Create virtual network** page, select **Review + create**.
1. On the **Review + create** tab of the **Create virtual network** page, select **Create**.
1. In the Azure portal, browse back to the **Virtual networks** page, and then, select **+ Create** on the command bar.
1. On the **Basics** tab of the **Create virtual network** page, specify the following settings (leave others with their default values) and select **Next: IP Addresses**:

   | Setting | Value |
   | --- | --- |
   | Subscription | the name of the Azure subscription you are using in this lab |
   | Resource group | **AZ801-L0703-RG** |
   | Name | **az801l07a-test-vnet** |
   | Region | the name of the Azure region into which you deployed the virtual machine earlier in this lab |

1. On the **IP addresses** tab of the **Create virtual network** page, select the **Recycle Bin** icon. In the **IPv4 address space** text box, type **10.7.0.0/16** and select **+ Add subnet**.
1. On the **Add subnet** page, specify the following settings (leave others with their default values) and select **Add**:

   | Setting | Value |
   | --- | --- |
   | Subnet name | **subnet0** |
   | Subnet address range | **10.7.0.0/24** |

1. Back on the **IP addresses** tab of the **Create virtual network** page, select **Review + create**.
1. On the **Review + create** tab of the **Create virtual network** page, select **Create**.
1. In the Azure portal, search for and select **Storage accounts**. Then, on the **Storage accounts** page, select **+ Create** on the command bar.
1. On the **Basics** tab of the **Create a storage account** page, specify the following settings (leave others with their default values):

   | Setting | Value | 
   | --- | --- |
   | Subscription | the name of the Azure subscription you are using in this lab |
   | Resource group | **AZ801-L0703-RG** |
   | Storage account name | any globally unique name between 3 and 24 characters in length consisting of letters and digits | 
   | Location | the name of the Azure region in which you created the virtual network earlier in this task |
   | Performance | **Standard** |
   | Redundancy | **Locally redundant storage (LRS)** |

1. On the **Basics** tab of the **Create a storage account** page, select the **Data protection** tab.
1. On the **Data protection** tab of the **Create a storage account** page, clear the **Enable soft delete for blobs** and **Enable soft delete for containers** checkboxes, and then select **Review + create**.
1. On the **Review + create** tab, select **Create**.

## Exercise 3: Assess Hyper-V for migration by using Azure Migrate
  
#### Task 1: Deploy and configure the Azure Migrate appliance

1. Within the Remote Desktop session to **az801l07a-hv-vm**, in the browser window, in the Azure portal, search for and select **Azure Migrate**.
1. On the **Azure Migrate | Get Started** page, in the **Servers, databases, and web apps** section, select **Discover, assess, and migrate**.
1. On the **Azure Migrate \| Servers, databases, and web apps** page, in the **Azure Migrate: Discovery and Assessment** section, select **Discover**.
1. On the **Discover** page, ensure that the **Discover using appliance** option is selected and then, in the **Are your servers virtualized?** drop-down list, select **Yes, with Hyper-V**. 
1. On the **Discover** page, in the **Name your appliance** text box, type **az801l07a-vma1** and select the **Generate key** button.

   >**Note**: Wait for the key generation to complete and record its value. You will need it later in this exercise.

1. On the **Discover** page, in the **Download Azure Migrate appliance** text box, select the **.VHD file** option, select **Download** and then, when prompted, set the download location to the **F:\VMs** folder.

   >**Note**: Wait for the download to complete. This might take about 5 minutes.

1. Once the download completes, extract the content of the downloaded .ZIP file into the **F:\VMs** folder.

   >**Note**: As Microsoft Edge doesn't prompt by default, you may need to manually copy the .VHD file to the F:\VMs folder.

1. Within the Remote Desktop session to **az801l07a-hv-vm**, switch to the **Hyper-V Manager** console, select the **AZ801L07A-VM1** node, and then select **Import Virtual Machine**. This will start the **Import Virtual Machine** wizard.
1. On the **Before You Begin** page of the **Import Virtual Machine** wizard, select **Next >**.
1. On the **Locate Folder** page of the **Import Virtual Machine** wizard, specify the location of the extracted **Virtual Machines** folder and select **Next >**.
1. On the **Select Virtual Machine** page of the **Import Virtual Machine** wizard, select **Next >**.
1. On the **Choose Import Type** page of the **Import Virtual Machine** wizard, select **Register the virtual machine in-place (use the existing unique ID)**, and then select **Next >**.
1. On the **Configure Processor** page of the **Import Virtual Machine** wizard, set **Number of virtual processors** to **4**, and then select **Next >**.

   >**Note**: In a lab environment, you can ignore any error messages referring to the change of the number of virtual processors. In production scenarios, you should ensure that the virtual appliance has the sufficient number of compute resources assigned to it.

1. On the **Connect Network** page of the **Import Virtual Machine** wizard, in the **Connection** drop-down list, select **NestedSwitch**, and then select **Next >**.
1. On the **Summary** page of the **Import Virtual Machine** wizard, select **Finish**.

   >**Note**: Wait for the import to complete.

1. In the **Hyper-V Manager** console, select the newly imported virtual machine, select **Rename**, and then set its name to **az801l07a-vma1**.
1. Increase the memory size of the virtual machine to 4096 MB.
1. In the **Hyper-V Manager** console, select the newly imported virtual machine, and then select **Start**. 
1. In the **Hyper-V Manager** console, verify that the virtual machine is running, and then select **Connect**. 
1. In the **Virtual Machine Connection** window to the virtual appliance, on the **License terms** page, select **Accept**. 
1. In the **Virtual Machine Connection** window to the virtual appliance, on the **Customize settings** page, set the password of the built-in Administrator account to **Pa55w.rd**, and then select **Finish**. 
1. In the **Virtual Machine Connection** window to the virtual appliance, in the **Action** menu, select **Ctrl + Alt + Delete** and then, when prompted, sign in by using the newly set password.

   >**Note**: Within the **Virtual Machine Connection** window to the virtual appliance, a browser window displaying **Appliance Configuration Manager** will automatically open.

1. On the **Appliance Configuration Manager** page, select the **I agree** button and wait for the setup prerequisites to be successfully verified. 
1. On the **Appliance Configuration Manager** page, in the **Register with Azure Migrate** section, in the **Register Hyper-V appliance by pasting the key here** text box, paste the key you copied into Notepad earlier in this exercise, select **Login**, and then select **Copy code & login**. This will automatically open a new browser tab prompting you to enter the copied code.
1. On the **Enter code** pane in the newly opened browser tab, paste the code you copied onto the Clipboard, and then select **Next**. When prompted, sign in by providing the credentials of a user account with the Owner role in the subscription you are using in this lab.
1. When prompted **Are you trying to sign in to Microsoft Azure PowerShell?**, select **Continue**, and then close the newly opened browser tab.
1. In the browser window, on the **Appliance Configuration Manager** page, verify that registration was successful.
1. On the **Appliance Configuration Manager** page, in the **Manage credentials and discovery sources** section, select **Add credentials**. On the **Add credentials** pane, specify the following settings, and then select **Save**:

   | Setting | Value | 
   | --- | --- |
   | Friendly Name | **az801l07ahvcred** |   
   | User Name | **Student** |
   | Password | **Pa55w.rd1234** |

1. Within the browser window, on the **Appliance Configuration Manager** page, in the **Provide Hyper-V host/cluster details** section, select **Add discovery source**. On the **Add discovery source** pane, select the **Add single item** option. Ensure that the **Discovery source** drop-down list is set to **Hyper-V Host/Cluster**. In the **Map credentials** drop-down list, select the **az801l07ahvcred** entry, in the **IP address /FQDN** text box, type **10.0.2.1**, and then select **Save**.

   >**Note**: **10.0.2.1** is the IP address of the network interface of the Hyper-V host attached to the internal switch.

1. On the **Appliance Configuration Manager** page, in the **Provide Hyper-V host/cluster details** section, enable the toggle button for **Disable the slider if you don’t want to perform these features**, and then select **Start discovery**.

   >**Note**: It might take about 15 minutes per host for metadata of discovered servers to appear in the Azure portal.

#### Task 2: Configure, run, and view an assessment

1. From the **Virtual Machine Connection** window to the virtual appliance, switch to the Remote Desktop session to **az801l07a-hv-vm**. In the browser window displaying the Azure portal, browse back to the **Azure Migrate | Servers, databases and web apps** page and select **Refresh**. In the **Azure Migrate: Discovery and assessment** section, select **Assess** and then, in the drop-down menu, select **Azure VM**.
1. On the **Basics** tab of the **Create assessment** page, next to the **Assessment properties** label, select **Edit**.   
1. On the **Assessment properties** page, specify the following settings (leave others with their default values) and select **Save**:

   | Setting | Value | 
   | --- | --- |
   | Target location | the name of the Azure region you are using in this lab |
   | Storage type | **Premium managed disks** |
   | Reserved instances | **No reserved instances** |
   | Sizing criteria | **As on premises** |
   | VM series | **Dsv3_series** |
   | Comfort factor | **1** |
   | Offer | **Pay-As-You-Go** |
   | Currency | US Dollar ($) | 
   | Discount | **0** |
   | VM uptime | **31** Day(s) per month and **24** Hour(s) per day | 

   >**Note**: Considering the limited time inherent to the lab environment, the only viable option in this case is an **As on-premises** assessment. 

1. Back on the **Basics** tab of the **Create assessment** page, select **Next** to display the **Select servers to assess** tab.
1. On the **Select servers to assess** tab, set **Assessment name** to **az801l07a-assessment**.
1. Ensure that the **Create new** option of the **Select or create a group** setting is selected, set the group name to **az801l07a-assessment-group**, and then, in the list of machines to be added to the group, select **az801l07a-vm1**.
1. Select **Next** and then select **Create assessment**. 
1. Back on the **Azure Migrate \| Servers, databases and web apps** page, select **Refresh**. In the **Azure Migrate: Discovery and Assessment** section, verify that the **Assessments** **Total** line contains the **1** entry, and select it.
1. On the **Azure Migrate: Discovery and Assessment \| Assessments** page, select the newly created assessment **az801l07a-assessment**. 
1. On the **az801l07a-assessment** page, review the information indicating Azure readiness and monthly cost estimate for both compute and storage. 

   >**Note**: In real-world scenarios, you should consider installing the Dependency agent to provide more insights into server dependencies during the assessment stage.

## Exercise 4: Migrate Hyper-V VMs by using Azure Migrate

#### Task 1: Prepare for migration of Hyper-V VMs

1. Within the Remote Desktop session to **az801l07a-hv-vm**, in the browser window displaying the Azure portal, browse back to the **Azure Migrate | Servers, databases and web apps** page. 
1. On the **Azure Migrate | Servers, databases and web apps** page, in the **Azure Migrate: Server Migration** section, select the **Discover** link. 
1. On the **Discover** page, specify the following settings (leave others with their default values) and select **Create resources**:

   | Setting | Value | 
   | --- | --- |
   | Are your machines virtualized? | **Yes, with Hyper-V** |
   | Target region | the name of the Azure region you are using in this lab | 
   | Confirm the target region for migration | selected | 

   >**Note**: This step automatically triggers provisioning of an Azure Site Recovery vault.

1. On the **Discover** page, in step **1. Prepare Hyper-V host servers**, select the first **Download** link (not the **Download** button), in order to download the Hyper-V replication provider software installer.

   > **Note:** If you receive a browser notification that says **AzureSiteRecoveryProvider.exe can't be downloaded securely**, display the context-sensitive menu of the **Download** link and then, in the menu, select **Copy link**. Open another tab in the same browser window, paste the link you copied, and then press Enter.

1. Once the download completes, select the **Open file** link in the browser **Downloads** section. This will start the **Azure Site Recovery Provider Setup (Hyper-V server)** wizard.
1. On the **Microsoft Update** page of the **Azure Site Recovery Provider Setup (Hyper-V server)** wizard, select **Off**, and then select **Next**.
1. On the **Provider installation** page of the **Azure Site Recovery Provider Setup (Hyper-V server)** wizard, select **Install**.
1. Switch to the Azure portal and then, on the **Discover machines** page, in step 1 of the procedure for preparing on-premises Hyper-V hosts, select the **Download** button in order to download the vault registration key.
1. Switch to the **Provider installation** page of the **Azure Site Recovery Provider Setup (Hyper-V server)** wizard and select **Register**. This will start the **Microsoft Azure Site Recovery Registration Wizard**.
1. On the **Vault Settings** page of the **Microsoft Azure Site Recovery Registration Wizard**, select **Browse**, browse to the **Downloads** folder, select the vault credentials file, and then select **Open**.
1. Back on the **Vault Settings** page of the **Microsoft Azure Site Recovery Registration Wizard**, select **Next**.
1. On the **Proxy Settings** page of the **Microsoft Azure Site Recovery Registration Wizard**, accept the default settings and select **Next**.
1. On the **Registration** page of the **Microsoft Azure Site Recovery Registration Wizard**, select **Finish**.
1. Refresh the browser window displaying the **Discover** page. This will redirect you to the **Azure Migrate | Servers, databases and web apps** page.
1. On the **Azure Migrate | Servers, databases and web apps** page, in the **Azure Migrate: Server Migration** section, select the **Discover** link. 
1. On the **Discover** page, select **Finalize registration**.

   >**Note**: It might take up to 15 minutes for the discovery of virtual machines to complete.

#### Task 2: Configure replication of Hyper-V VMs

1. Once you receive the confirmation that the registration was finalized, browse back to the **Azure Migrate | Servers, databases and web apps** page and then, in the **Azure Migrate: Server Migration** section, select the **Replicate** link. 

   >**Note**: You might have to refresh the browser page displaying the **Azure Migrate | Servers, databases and web apps** page.

1. On the **Source settings** tab of the **Replicate** page, in the **Are your machines virtualized?** drop-down list, select **Yes, with Hyper-V** and then select **Next**.
1. On the **Virtual machines** tab of the **Replicate** page, specify the following settings (leave others with their default values) and select **Next**:

   | Setting | Value | 
   | --- | --- |
   | Import migration settings from an Azure Migrate assessment | **Yes, apply migration settings from an Azure Migrate assessment** |
   | Select group | **az801l07a-assessment-group** |
   | Select assessment | **az801l07a-assessment** |
   | Virtual machines | **az801l07a-vm1** |

1. On the **Target settings** tab of the **Replicate** page, specify the following settings (leave others with their default values) and select **Next**:

   | Setting | Value | 
   | --- | --- |
   | Subscription | the name of the Azure subscription you are using in this lab |
   | Resource group | **AZ801-L0703-RG** |
   | Replication Storage Account | the name of the storage account you created earlier in this lab | 
   | Virtual Network | **az801l07a-migration-vnet** |
   | Subnet | **subnet0** |

1. On the **Compute** tab of the **Replicate** page, ensure that the **Standard_D2s_v3** is selected in the **Azure VM Size** drop-down list. In the **OS Type** drop-down list, select **Windows** and then select **Next**.  
1. On the **Disks** tab of the **Replicate** page, accept the default settings and select **Next**.
1. On the **Tags** tab of the **Replicate** page, accept the default settings and select **Next**.
1. On the **Review + Start replication** tab of the **Replicate** page, select **Replicate**.  
1. To monitor the status of replication, back on the **Azure Migrate | Servers, databases and web apps** page, select **Refresh** and then, in the **Azure Migrate: Server Migration** section, select the **Replicating servers** entry. On the **Azure Migrate: Server Migration | Replicating machines** page, examine the **Status** column in the list of the replicating machines.
1. Wait until the status changes to **Protected**. This might take additional 15 minutes.

   >**Note**: You will need to to refresh the **Azure Migrate: Server Migration | Replicating machines** to update the **Status** information.

#### Task 3: Perform migration of Hyper-V VMs

1. In the Azure portal, on the **Azure Migrate: Server Migration | Replicating machines** page, select the entry representing the **az801l07a-vm1** virtual machine.
1. On the **az801l07a-vm1** page, select **Test migration**.
1. On the **Test migration** page, in the **Virtual network** drop-down list, select **az801l07a-test-vnet** and then select **Test migration**.

   >**Note**: Wait for the test migration to complete. This might take about 5 minutes.

1. In the Azure portal, in the **Search resources, services, and docs** text box, on the toolbar, search for and select **Virtual machines** and then, on the **Virtual machines** page, note the entry representing the newly replicated virtual machine **az801l07a-vm1-test**.

   > **Note:** Initially, the virtual machine will have the name consisting of the **asr-** prefix and randomly generated suffix, but will be renamed eventually to **az801l07a-vm1-test**.

1. In the Azure portal, browse back to the **Azure Migrate: Server Migration | Replicating machines** page, select **Refresh**, and then verify that the **az801l07a-vm1** virtual machine is listed with the **Cleanup test failover pending** status.
1. On the **Azure Migrate: Server Migration | Replicating machines** page, select the entry representing the **az801l07a-vm1** virtual machine.
1. On the **az801l07a-vm1** replicating machines page, select **Clean up test migration**.
1. On the **Test migrate cleanup** page, select the checkbox **Testing is complete. Delete test virtual machine** and then select **Cleanup Test**.
1. Once the test failover cleanup job completes, refresh the browser page displaying the **az801l07a-vm1** replicating machines page and note that the **Migrate** icon in the toolbar automatically becomes available.
1. On the **az801l07a-vm1** replicating machines page, select the **Migrate** link. 
1. On the **Migrate** page, ensure that **Yes** is selected in the **Shutdown machines before migration to minimize data loss?** drop-down list, select the checkbox next to the VM name **az801l07a-vm1**, and then select **Migrate**.
1. To monitor the status of migration, browse back to the **Azure Migrate | Servers, databases and web apps** page. In the **Azure Migrate: Server Migration** section, select the **Replicating servers** entry and then, on the **Azure Migrate: Server Migration | Replicating machines** page, examine the **Status** column in the list of the replicating machines. Verify that the status displays the **Planned failover finished** status.

   >**Note**: Migration is supposed to be a non-reversible action. If you want to see the completed information, browse back to the **Azure Migrate | Servers, databases and web apps** page, refresh the page, and then verify that the **Migrated Servers** entry in the **Azure Migrate: Server Migration** section has the value of **1**.

#### Task 4: Remove Azure resources deployed in the lab

1. On **SEA-SVR2**, in the browser window displaying the Azure portal, open the **Azure Cloud Shell** pane by selecting the **Cloud Shell** button in the Azure portal.
1. If prompted to select either **Bash** or **PowerShell**, select **PowerShell**. 

   > **Note:** If this is the first time you're starting **Cloud Shell** and you're presented with the **You have no storage mounted** message, select the subscription you are using in this lab, and then select **Create storage**.

1. From the **Cloud Shell** pane, run the following command to list all the resource groups you created in this lab:

   ```powershell
   Get-AzResourceGroup -Name 'AZ801-L070*'
   ```

   > **Note**: Verify that the output contains only the resource group you created in this lab. This group will be deleted in this task.

1. From the **Cloud Shell** pane, run the following to delete the resource group you created in this lab:

   ```powershell
   Get-AzResourceGroup -Name 'AZ801-L070*' | Remove-AzResourceGroup -Force -AsJob
   ```

   > **Note:** The command executes asynchronously (as determined by the *-AsJob* parameter), so while you will be able to run another PowerShell command immediately after within the same PowerShell session, it will take a few minutes before the resource groups are actually removed.
