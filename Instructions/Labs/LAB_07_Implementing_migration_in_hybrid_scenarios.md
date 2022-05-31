---
lab:
    title: 'Lab: Migrating Hyper-V VMs to Azure by using Azure Migrate'
    module: 'Module 7: Design for Migration'
---

# Lab: Migrating Hyper-V VMs to Azure by using Azure Migrate

## Lab scenario

Despite its ambitions to modernize its workloads as part of the migration to Azure, the Adatum Enterprise Architecture team realizes that, due to aggressive timelines, in many cases, it will be necessary to follow the lift-and-shift approach. To simplify this task, the team starts exploring the capabilities of Azure Migrate. Azure Migrate serves as a centralized hub to assess and migrate to Azure on-premises servers, infrastructure, applications, and data.

Azure Migrate provides the following features:

- Unified migration platform: A single portal to start, run, and track your migration to Azure.
- Range of tools: A range of tools for assessment and migration. Tools include Azure Migrate: Server Assessment and Azure Migrate: Server Migration. Azure Migrate integrates with other Azure services and with other tools and independent software vendor (ISV) offerings.
- Assessment and migration: In the Azure Migrate hub, you can assess and migrate:
    - Servers: Assess on-premises servers and migrate them to Azure virtual machines.
    - Databases: Assess on-premises databases and migrate them to Azure SQL Database or to SQL Managed Instance.
    - Web applications: Assess on-premises web applications and migrate them to Azure App Service by using the Azure App Service Migration Assistant.
    - Virtual desktops: Assess your on-premises virtual desktop infrastructure (VDI) and migrate it to Windows Virtual Desktop in Azure.
    - Data: Migrate large amounts of data to Azure quickly and cost-effectively using Azure Data Box products.

While databases, web apps, and virtual desktops are within the scope of the next stage of the migration initiative, the Adatum Enterprise Architecture team wants to start by evaluating the use of Azure Migrate for migrating their on-premises Hyper-V virtual machines to Azure VM.

## Objectives
  
After completing this lab, you will be able to:

-  Prepare for assessment and migration by using Azure Migrate.
-  Assess Hyper-V for migration by using Azure Migrate.
-  Migrate Hyper-V VMs by using Azure Migrate.

## Estimated Time: 120 minutes

## Lab Environment
  
Virtual machines: **AZ-801T00A-SEA-DC1** and **AZ-801T00A-SEA-SVR2** must be running. Other VMs can be running, but they aren't required for this lab.

> **Note**: **AZ-801T00A-SEA-DC1** and **AZ-801T00A-SEA-SVR2** virtual machines are hosting the installation of **SEA-DC1** and **SEA-SVR2**

1. Select **SEA-SVR2**.
1. Sign in using the following credentials:

   - Username: **Administrator**
   - Password: **Pa55w.rd**
   - Domain: **CONTOSO**

For this lab, you'll use the available VM environment and an Azure subscription. Before you begin the lab, ensure that you have an Azure subscription and a user account with the Owner role in that subscription.

## Exercise 1: Prepare the lab environment

The main tasks for this exercise are as follows:

1. Deploy an Azure VM by using an Azure Resource Manager QuickStart template.
1. Deploy Azure Bastion.
1. Deploy a nested VM in the Azure VM.

#### Task 1: Deploy an Azure VM by using an Azure Resource Manager QuickStart template

1. On **SEA-SVR2**, start Microsoft Edge, browse to the [301-nested-vms-in-virtual-network Azure QuickStart template](https://github.com/az140mp/azure-quickstart-templates/tree/master/demos/nested-vms-in-virtual-network) and select **Deploy to Azure**. (You find the button **Deploy to Azure** in the `README.md` file after the list of resources created by the template.)
1. When prompted, in the Azure portal, sign in by using the credentials of a user account with the Owner role in the subscription you'll be using in this lab.
1. On the **Hyper-V Host Virtual Machine with nested VMs** page in the Azure portal, perform a deployment with the following settings (leave others with their default values):

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

   > **Note**: Wait for the deployment to complete. The deployment might take about 10 minutes.

#### Task 2: Deploy Azure Bastion 

> **Note**: Azure Bastion allows for connection to the Azure VMs without public endpoints which you deployed in the previous task of this exercise, while providing protection against brute force exploits that target operating system level credentials.

1. On **SEA-SVR2**, in the browser window displaying the Azure portal, open a PowerShell session on the **Cloud Shell** pane.
1. From the PowerShell session on the **Cloud Shell** pane, run the following commands to add a subnet named **AzureBastionSubnet** to the virtual network named **az801l07a-hv-vnet** you created earlier in this exercise:

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
1. From the Azure portal, create an Azure Bastion instance with the following settings:

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
   
   > **Note**: Wait for the deployment to complete before you proceed to the next task. The deployment might take about 5 minutes.

#### Task 3: Deploy a nested VM in the Azure VM

1. In the Azure portal, browse to the **az801l07a-hv-vm** virtual machine page.
1. From the **az801l07a-hv-vm** page, connect to the operating system running within the virtual machine, via Azure Bastion, with the following credentials:

   | Setting | Value | 
   | --- | --- |
   | User Name |**Student** |
   | Password |**Pa55w.rd1234** |

1. Within the Remote Desktop session to **az801l07a-hv-vm**, in the **Server Manager** window, disable **IE Enhanced Security Configuration**.
1. Use File Explorer to create two folders **F:\\VHDs** and **F:\\VMs**.
1. Use Microsoft Edge to download the Windows Server 2022 **VHD** file from [Windows Server Evaluations](https://techcommunity.microsoft.com/t5/windows-11/accessing-trials-and-kits-for-windows-eval-center-workaround/m-p/3361125) and copy it to the **F:\VHDs** folder. 
1. Use **Hyper-V Manager** to create a new virtual machine with the following settings:

   | Setting | Value | 
   | --- | --- |
   | Name | **az801l07a-vm1** | 
   | Store the virtual machine in a different location | selected | 
   | Location | **F:\VMs** |
   | Generation | **1** |
   | Memory | static set to **2048** MB |
   | Connection | **NestedSwitch** |
   | Virtual Hard Disk | the VHD file downloaded to the **F:\VHDs** folder |

1. Start the newly provisioned VM and connect to it by using the Virtual Machine Connection. 
1. In the **Virtual Machine Connection** window, initialize the operating system. 
1. Set the password of the built-in Administrator account to **Pa55w.rd**. 
1. In the **Virtual Machine Connection** window, sign in to **az801l07a-vm1**. 
1. Open a **Windows PowerShell** window and set the computer name to **az801l07a-vm1** by running:

   ```powershell
   Rename-Computer -NewName 'az801l07a-vm1' -Restart
   ```

## Exercise 2: Prepare for assessment and migration by using Azure Migrate
  
The main tasks for this exercise are as follows:

1. Configure Hyper-V environment.
1. Create an Azure Migrate project.
1. Implement the target Azure environment.

#### Task 1: Configure Hyper-V environment

1. Within the Remote Desktop session to **az801l07a-hv-vm**, in the browser window, go to [https://aka.ms/migrate/script/hyperv](https://aka.ms/migrate/script/hyperv), and download the Azure Migrate configuration PowerShell script.

   >**Note**: The script performs the following tasks: 
   >- Checks that you're running the script on a supported PowerShell version
   >- Verifies that you have administrative privileges on the Hyper-V host
   >- Allows you to create a local user account that the Azure Migrate service uses to communicate with the Hyper-V host (This user account is added to **Remote Management Users**, **Hyper-V Administrators**, and **Performance Monitor Users** groups on the Hyper-V host.) 
   >- Checks that the host is running a supported version of Hyper-V and the Hyper-V role
   >- Enables the WinRM service and opens ports 5985 (HTTP) and 5986 (HTTPS) on the host (This is required for metadata collection.) 
   >- Enables PowerShell remoting on the host
   >- Checks that the Hyper-V Integration Services is enabled on all VMs managed by the host
   >- Enables CredSSP on the host if needed

1. Within the Remote Desktop session to **az801l07a-hv-vm**, start **Windows PowerShell ISE**. 
1. In the **Administrator: Windows PowerShell ISE** window, run the following commands to copy the script to the **C:\\Labfiles\\Lab07** folder and remove the Zone.Identifier alternate data stream, which, in this case, indicates that the file was downloaded from the Internet:

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
1. In the Azure portal, browse to the **Azure Migrate** page and create a project with the following settings (leave others with their default values):

   | Setting | Value | 
   | --- | --- |
   | Subscription | the name of the Azure subscription you are using in this lab |
   | Resource group | the name of a new resource group **AZ801-L0702-RG** |
   | Migrate project | **az801l07a-migrate-project** |
   | Geography | the name of your country or a geographical region |

#### Task 3: Implement the target Azure environment

1. In the Azure portal, create a virtual network with the following settings (leave others with their default values):

   | Setting | Value |
   | --- | --- |
   | Subscription | the name of the Azure subscription you are using in this lab |
   | Resource group | the name of a new resource group **AZ801-L0703-RG** |
   | Name | **az801l07a-migration-vnet** |
   | Region | the name of the Azure region into which you deployed the virtual machine earlier in this lab |
   | Subnet name | **subnet0** |
   | Subnet address range | **10.7.0.0/24** |

1. In the Azure portal, create another virtual network with the following settings (leave others with their default values):

   | Setting | Value |
   | --- | --- |
   | Subscription | the name of the Azure subscription you are using in this lab |
   | Resource group | **AZ801-L0703-RG** |
   | Name | **az801l07a-test-vnet** |
   | Region | the name of the Azure region into which you deployed the virtual machine earlier in this lab |
   | Setting | Value |
   | --- | --- |
   | Subnet name | **subnet0** |
   | Subnet address range | **10.7.0.0/24** |

1. In the Azure portal, create a storage account with the following settings (leave others with their default values):

   | Setting | Value | 
   | --- | --- |
   | Subscription | the name of the Azure subscription you are using in this lab |
   | Resource group | **AZ801-L0703-RG** |
   | Storage account name | any globally unique name between 3 and 24 characters in length, consisting of letters and digits |
   | Location | the name of the Azure region in which you created the virtual network earlier in this task |
   | Performance | **Standard** |
   | Redundancy | **Locally redundant storage (LRS)** |
   | Enable soft delete for blobs | disabled |
   | Enable soft delete for containers | disabled |

## Exercise 3: Assess Hyper-V for migration by using Azure Migrate
  
The main tasks for this exercise are as follows:

1. Deploy and configure the Azure Migrate appliance
1. Configure, run, and view an assessment

#### Task 1: Deploy and configure the Azure Migrate appliance

1. Within the Remote Desktop session to **az801l07a-hv-vm**, in the browser window, in the Azure portal, browse to the newly created Azure Migrate project. 
1. On the **Azure Migrate | Get Started** page, in the **Servers, databases, and web apps** section, select **Discover, assess, and migrate** and then go to the **Discover** page.
1. On the **Discover** page, ensure that the **Discover using appliance** option is selected and set the value of **Are your servers virtualized?** setting to **Yes, with Hyper-V**. 
1. On the **Discover** page, set the value of the appliance to **az801l07a-vma1** and generate the corresponding key.

   >**Note**: Wait for the key generation to complete and record its value. You will need it later in this exercise.

1. From the **Discover** page, download the **.VHD file** of the appliance VM to the **F:\VMs** folder.

   >**Note**: Wait for the download to complete. This might take about 5 minutes.

1. Once the download completes, extract the content of the downloaded .ZIP file into the **F:\VMs** folder.

   >**Note**: As Microsoft Edge doesn't prompt by default, you may need to manually copy the .VHD file to the F:\VMs folder.

1. Within the Remote Desktop session to **az801l07a-hv-vm**, use the **Hyper-V Manager** console to import the virtual machine, of which you copied the VM files, into the **F:\VMs** folder. Use the **Register the virtual machine in-place (use the existing unique ID)** option, set the **Number of virtual processors** to **4**, and then connect it to **NestedSwitch**.

   >**Note**: In a lab environment, you can ignore any error messages referring to the change of the number of virtual processors. In production scenarios, you should ensure that the virtual appliance has the sufficient number of compute resources assigned to it.

1. Rename the newly imported virtual machine to **az801l07a-vma1**.
1. Start the newly imported virtual machine and connect to it by using the **Virtual Machine Connection** window. 
1. In the **Virtual Machine Connection** window to the virtual appliance, accept the **License terms** and set the password of the built-in Administrator account to **Pa55w.rd**. 
1. In the **Virtual Machine Connection** window to the virtual appliance, in the **Action** menu, select **Ctrl + Alt + Delete** and then, when prompted, sign in by using the newly set password.

   >**Note**: Within the **Virtual Machine Connection** window to the virtual appliance, a browser window displaying **Appliance Configuration Manager** will automatically open.

1. On the **Appliance Configuration Manager** page, select the **I agree** button and wait for the setup prerequisites to be successfully verified. 
1. On the **Appliance Configuration Manager** page, in the **Register Hyper-V appliance by pasting the key here** text box, paste the key you copied into Notepad earlier in this exercise, select **Login**, and then sign in to your subscriptions by using the device code. 
1. When prompted **Are you trying to sign in to Microsoft Azure PowerShell?**, select **Continue** and close the newly opened browser tab.
1. On the **Appliance Configuration Manager** page, verify that registration was successful.
1. On the **Appliance Configuration Manager** page, in the **Manage credentials and discovery sources** section, add credentials with the following settings:

   | Setting | Value | 
   | --- | --- |
   | Friendly Name | **az801l07ahvcred** | 
   | User Name | **Student** |
   | Password | **Pa55w.rd1234** |

1. Within the browser window, on the **Appliance Configuration Manager** page, in the **Provide Hyper-V host/cluster details** section, add a discovery source set to **Hyper-V Host/Cluster**, set its **Friendly name** to **az801l07ahvcred** and its **IP address /FQDN** to **10.0.2.1**.

   >**Note**: **10.0.2.1** is the IP address of the network interface of the Hyper-V host attached to the internal switch.

1. On the **Appliance Configuration Manager** page, in the **Provide Hyper-V host/cluster details** section, enable the toggle button for **Disable the slider if you don’t want to perform these features**, and then select **Start discovery**. 

   >**Note**: It might take about 15 minutes per host for metadata of discovered servers to appear in the Azure portal.

#### Task 2: Configure, run, and view an assessment

1. From the **Virtual Machine Connection** window to the virtual appliance, switch to the Remote Desktop session to **az801l07a-hv-vm**. In the browser window displaying the Azure portal, browse back to the **Azure Migrate | Servers, databases and web apps** page and select **Refresh**. In the **Azure Migrate: Discovery and assessment** section, select **Assess** and then, in the drop-down menu, select **Azure VM**.
1. On the **Create assessment** page, specify the following settings (leave others with their default values):

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
   | Assessment name | az801l07a-assessment** |
   | Select or create a group | **az801l07a-assessment-group** |
   | List of machines to be added to the group | **az801l07a-vm1** |

   >**Note**: Considering the limited time inherent to the lab environment, the only viable option in this case is an **As on-premises** assessment. 

1. Back on the **Azure Migrate \| Servers, databases and web apps** page, select **Refresh**. In the **Azure Migrate: Discovery and Assessment** section, verify that the **Assessments** **Total** line contains the **1** entry, and then select it.
1. On the **Azure Migrate: Discovery and Assessment \| Assessments** page, select the newly created assessment **az801l07a-assessment**. 
1. On the **az801l07a-assessment** page, review the information indicating Azure readiness and monthly cost estimate for both compute and storage. 

   >**Note**: In real-world scenarios, you should consider installing the Dependency agent to provide more insights into server dependencies during the assessment stage.

## Exercise 4: Migrate Hyper-V VMs by using Azure Migrate
  
The main tasks for this exercise are as follows:

1. Prepare for migration of Hyper-V VMs.
1. Configure replication of Hyper-V VMs.
1. Perform migration of Hyper-V VMs.
1. Remove Azure resources deployed in the lab.

#### Task 1: Prepare for migration of Hyper-V VMs

1. Within the Remote Desktop session to **az801l07a-hv-vm**, in the browser window displaying the Azure portal, browse back to the **Azure Migrate | Servers, databases and web apps** page. 
1. On the **Azure Migrate | Servers, databases and web apps** page, in the **Azure Migrate: Server Migration** section, select the **Discover** link. 
1. On the **Discover** page, create resources by specifying the following settings (leave others with their default values):

   | Setting | Value | 
   | --- | --- |
   | Are your machines virtualized? | **Yes, with Hyper-V** |
   | Target region | the name of the Azure region you are using in this lab | 
   | Confirm the target region for migration | selected |

   >**Note**: This step automatically triggers the provisioning of an Azure Site Recovery vault.

1. On the **Discover** page, in step **1. Prepare Hyper-V host servers**, select the first **Download** link (not the **Download** button), in order to download the Hyper-V replication provider software installer.

   > **Note:** If you receive a browser notification that says **AzureSiteRecoveryProvider.exe can't be downloaded securely**, display the context-sensitive menu of the **Download** link and then, in the menu, select **Copy link**. Open another tab in the same browser window, paste the link you copied, and then press Enter.

1. Use the downloaded file to install the **Azure Site Recovery Provider** with the default settings.
1. During the installation, switch to the Azure portal and then, on the **Discover machines** page, in step 1 of the procedure for preparing on-premises Hyper-V hosts, select the **Download** button in order to download the vault registration key and use it to register the **Azure Site Recovery Provider**.
1. Refresh the browser window displaying the **Discover** page. 
1. On the **Azure Migrate | Servers, databases and web apps** page, in the **Azure Migrate: Server Migration** section, select the **Discover** link. 
1. On the **Discover** page, finalize registration.

   >**Note**: It might take up to 15 minutes for the discovery of virtual machines to complete.

#### Task 2: Configure replication of Hyper-V VMs

1. Once you receive the confirmation that the registration was finalized, browse back to the **Azure Migrate | Servers, databases and web apps** page, in the **Azure Migrate: Server Migration** section, select the **Replicate** link. 

   >**Note**: You might have to refresh the browser page displaying the **Azure Migrate | Servers, databases and web apps** page.

1. On the **Replicate** page, in the **Are your machines virtualized?** drop-down list, select **Yes, with Hyper-V**.
1. On the **Virtual machines** tab of the **Replicate** page, specify the following settings (leave others with their default values):

   | Setting | Value | 
   | --- | --- |
   | Import migration settings from an Azure Migrate assessment | **Yes, apply migration settings from an Azure Migrate assessment** |
   | Select group | **az801l07a-assessment-group** |
   | Select assessment | **az801l07a-assessment** |
   | Virtual machines | **az801l07a-vm1** |

1. On the **Target settings** tab of the **Replicate** page, specify the following settings (leave others with their default values):

   | Setting | Value | 
   | --- | --- |
   | Subscription | the name of the Azure subscription you are using in this lab |
   | Resource group | **AZ801-L0703-RG** |
   | Replication Storage Account | the name of the storage account you created earlier in this lab | 
   | Virtual Network | **az801l07a-migration-vnet** |
   | Subnet | **subnet0** |

1. On the **Compute** tab of the **Replicate** page, ensure that the **Standard_D2s_v3** is selected in the **Azure VM Size** drop-down list. In the **OS Type** drop-down list, select **Windows**.
1. To monitor the status of replication, back on the **Azure Migrate | Servers, databases and web apps** page, select **Refresh** and then, in the **Azure Migrate: Server Migration** section, select the **Replicating servers** entry. On the **Azure Migrate: Server Migration | Replicating machines** page, examine the **Status** column in the list of the replicating machines. 
1. Wait until the status changes to **Protected**. This might take an additional 15 minutes.

   >**Note**: You will need to refresh the **Azure Migrate: Server Migration | Replicating machines** to update the **Status** information.

#### Task 3: Perform migration of Hyper-V VMs

1. In the Azure portal, on the **Azure Migrate: Server Migration | Replicating machines** page, select the entry representing the **az801l07a-vm1** virtual machine.
1. From the **az801l07a-vm1** page, initiate **Test migration** using the **az801l07a-test-vnet** virtual network as the target.

   >**Note**: Wait for the test migration to complete. This might take about 5 minutes.

1. In the Azure portal, go to the **Virtual machines** page and note the entry representing the newly replicated virtual machine **az801l07a-vm1-test**.

   > **Note:** Initially, the virtual machine will have the name consisting of the **asr-** prefix and randomly generated suffix, but will be renamed eventually to **az801l07a-vm1-test**.

1. In the Azure portal, browse back to the **Azure Migrate: Server Migration | Replicating machines** page, select **Refresh**, and then verify that the **az801l07a-vm1** virtual machine is listed with the **Cleanup test failover pending** status.
1. On the **Azure Migrate: Server Migration | Replicating machines** page, go to the **az801l07a-vm1** replicating machines page, and then trigger the **Clean up test migration** action, specifying **Testing is complete. Delete test virtual machine**.
1. Once the test failover cleanup job completes, refresh the browser page displaying the **az801l07a-vm1** replicating machines page and note that the **Migrate** icon in the toolbar automatically becomes available.
1. On the **az801l07a-vm1** replicating machines page, trigger the **Migrate** action. 
1. On the **Migrate** page, ensure that the **Shutdown machines before migration to minimize data loss?** option is selected.
1. To monitor the status of migration, browse back to the **Azure Migrate | Servers, databases and web apps** page. In the **Azure Migrate: Server Migration** section, select the **Replicating servers** entry and then, on the **Azure Migrate: Server Migration | Replicating machines** page, examine the **Status** column in the list of the replicating machines. Verify that the status displays the **Planned failover finished** status.

   >**Note**: Migration is supposed to be a non-reversible action. If you want to see the completed information, browse back to the **Azure Migrate | Servers, databases and web apps** page, refresh the page, and then verify that the **Migrated Servers** entry in the **Azure Migrate: Server Migration** section has the value of **1**.

#### Task 4: Remove Azure resources deployed in the lab

1. On **SEA-SVR2**, in the browser window displaying the Azure portal, open a PowerShell session on the **Azure Cloud Shell** pane.
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
