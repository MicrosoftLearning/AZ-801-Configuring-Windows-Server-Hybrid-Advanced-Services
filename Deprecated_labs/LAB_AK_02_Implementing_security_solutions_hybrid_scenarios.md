---
lab:
    title: 'Lab: Implementing Security Solutions in Hybrid Scenarios'
    type: 'Answer Key'
    module: 'Module 2: Implementing Security Solutions in Hybrid Scenarios'
---

# Lab answer key: Implementing Security Solutions in Hybrid Scenarios

**Note:** An **[interactive lab simulation](https://mslabs.cloudguides.com/guides/AZ-801%20Lab%20Simulation%20-%20Implementing%20security%20solutions%20in%20hybrid%20scenarios)** is available that allows you to click through this lab at your own pace. You may find slight differences between the interactive simulation and the hosted lab, but the core concepts and ideas being demonstrated are the same. 

## Exercise 1: Creating an Azure Log Analytics workspace and an Azure Automation account

#### Task 1: Create an Azure Log Analytics workspace 

1. Connect to **SEA-SVR2**, and then, if needed, sign in with the credentials provided by the instructor.
1. On **SEA-SVR2**, start Microsoft Edge, go to the Azure portal at `https://portal.azure.com/`, and sign in by using the credentials of a user account with the Owner role in the subscription you'll be using in this lab.
1. On **SEA-SVR2**, in the Azure portal, in the **Search resources, services, and docs** text box, on the toolbar, search for and select **Log Analytics workspaces**, and then, on the **Log Analytics workspaces** page, select **+ Create**.
1. On the **Basics** tab of the **Create Log Analytics workspace** page, enter the following settings, select **Review + Create**, and then select **Create**:

   | Settings | Value |
   | --- | --- |
   | Subscription | the name of the Azure subscription you are using in this lab |
   | Resource group | the name of a new resource group **AZ801-L0201-RG** |
   | Log Analytics Workspace | any unique name |
   | Region | choose a region near you |

   >**Note**: Wait for the deployment to complete. The deployment should take about 1 minute.

#### Task 2: Create and configure an Azure Automation account

1. On **SEA-SVR2**, in the Azure portal, in the **Search resources, services, and docs** text box, on the toolbar, search for and select **Automation Accounts**, and then, on the **Automation Accounts** page, select **+ Create**.
1. On the **Create an Automation Account** page, specify the following settings, and select **Review + Create**. Upon validation, select **Create**:

   | Settings | Value |
   | --- | --- |
   | Subscription | the name of the Azure subscription you are using in this lab |
   | Resource group | **AZ801-L0201-RG** |
   | Name | any unique name |
   | Region | the name of the Azure region determined based on **[Workspace mappings documentation](https://docs.microsoft.com/en-us/azure/automation/how-to/region-mappings)** |

   >**Note**: Make sure that you specify the Azure region based on **[Workspace mappings documentation](https://docs.microsoft.com/en-us/azure/automation/how-to/region-mappings)**.

   >**Note**: Wait for the deployment to complete. The deployment might take about 3 minutes.

1. On the deployment page, select **Go to resource**.
1. On the **Automation account** page, in the **Configuration Management** section, select **Inventory**.
1. On the **Inventory** page, in the **Log Analytics workspace** drop-down list, select the Log Analytics workspace you created earlier in this task and select **Enable**.

   >**Note**: Wait for the installation of the corresponding Log Analytics solution to complete. This might take about 3 minutes. 

   >**Note**: This automatically installs the **Change tracking** solution as well.

1. On the **Automation account** page, in the **Update Management** section, select **Update management** and select **Enable**.

   >**Note**: Wait for the installation to complete. This might take about 5 minutes.

## Exercise 2: Configuring Microsoft Defender for Cloud

#### Task 1: Enable Defender for Cloud and automatic agent installation

1. On **SEA-SVR2**, in the Azure portal, in the **Search resources, services, and docs** text box, on the toolbar, search for and select **Microsoft Defender for Cloud**.
1. On the **Microsoft Defender for Cloud \| Getting started** page, select **Upgrade**, and then select **Install agents**.

   > **Note:** Your subscription may already have the enhanced security of Defender for Cloud enabled, in which case, continue to the next task.

#### Task 2: Enable enhanced security of Defender for Cloud

1. On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, on the **Microsoft Defender for Cloud | Overview** page, in the **Management** section of the vertical menu on the left, select **Environment settings**.
1. On the **Environment settings** page, select the entry representing your Azure subscription.
1. On the **Settings \| Defender plans** page, select the tile **Enable all Microsoft Defender for Cloud plans**.

   > **Note:** Note that you can selectively disable individual Microsoft Defender plans listed on the same page.

1. Set all of the plans to **Off** except for the **Servers** and select **Save**.
1. On the **Settings \| Defender plans** page, on the top side, select **Settings & monitoring**.
1. On the **Settings & monitoring** page, in the list of extensions, to the right side of the **Log Analytics agent/Azure Monitor agent** entry, select the **Edit configuration** link.
1. On the **Auto-provisioning configuration**, in the **Workspace selection** section, select the option **Custom workspace**, in the drop-down menu, select the entry representing the workspace you created in the previous exercise, and then select **Apply**.
1. On the **Settings & monitoring** page, in the list of extensions, set **Guest Configuration agent (preview)** to **On**.
1. On the **Settings & monitoring** page, in the list of extensions, set **Vulnerability assessment for machines** to **On**. To the right side, select the **Edit configuration** link.
1. On the **Extension deployment configuration** page, ensure that the **Microsoft threat and vulnerability management** option is selected, and then select **Apply**.
1. On the **Settings & monitoring** page, select **Continue**.   
1. On the **Defender plan** page, select **Save** and then close the page.
1. Browse back to the **Microsoft Defender for Cloud | Overview** page, and then, in the **Management** section of the vertical menu on the left, select **Environment settings**.
1. On the **Environment settings** page, expand the entry representing your Azure subscription and select the entry representing the Log Analytics workspace you created in the previous exercise.
1. On the **Settings \| Defender plans** page, select the tile **Enable all Microsoft Defender for Cloud plans**, and then select **Save**.

   > **Note:** To enable all Defender for Cloud features including threat protection capabilities, you must enable enhanced security features on the subscription containing the applicable workloads. Enabling it at the workspace level doesn't enable just-in-time VM access, adaptive application controls, and network detections for Azure resources. In addition, the only Microsoft Defender plans available at the workspace level are Microsoft Defender for servers and Microsoft Defender for SQL servers on machines.

1. On the **Settings \| Defender plans** page, in the vertical menu on the left side, in the **Settings** section, select **Data collection**.
1. On the **Settings \| Data collection**, select **All Events**, and then select **Save**.

   > **Note:** Selecting a data collection tier in Defender for Cloud only affects the storage of security events in your Log Analytics workspace. The Log Analytics agent will still collect and analyze the security events required for Defender for Cloud's threat protection, regardless of the level of security events you choose to store in your workspace. Choosing to store security events enables investigation, search, and auditing of those events in your workspace.

## Exercise 3: Provisioning Azure VMs running Windows Server

#### Task 1: Start Azure Cloud Shell

1. On **SEA-SVR2**, in the Azure portal, open the Cloud Shell pane by selecting on the toolbar icon directly next to the search text box.
1. If prompted to select either **Bash** or **PowerShell**, select **PowerShell**.

   >**Note**: If this is the first time you are starting Cloud Shell and you are presented with the **You have no storage mounted** message, select the subscription you are using in this lab, and select **Create storage**.

#### Task 2: Deploy an Azure VM by using an Azure Resource Manager template

1. In the toolbar of the Cloud Shell pane, select the **Upload/Download files** icon, in the drop-down menu, select **Upload**, and upload the file **C:\\Labfiles\\Lab02\\L02-sub_template.json** into the Cloud Shell home directory.
1. Repeat the previous step twice to upload the **C:\\Labfiles\\Lab02\\L02-rg_template.json** and **C:\\Labfiles\\Lab02\\L02-rg_template.parameters.json** files into the Cloud Shell home directory.
1. To create the resource group that will be hosting the lab environment, in the **PowerShell** session in the Cloud Shell pane, enter the following commands, and after entering each command, press Enter (replace the `<Azure_region>` placeholder with the name of an Azure region where you intend to deploy resources in this lab):

   >**Note**: You can use the **(Get-AzLocation).Location** command to list the names of available Azure regions:

   ```powershell 
   $location = '<Azure_region>'
   New-AzSubscriptionDeployment -Location $location -Name az801l2001deployment -TemplateFile ./L02-sub_template.json -rgLocation $location -rgName 'AZ801-L0202-RG'
   ```

1. To deploy an Azure virtual machine (VM) into the newly created resource group, enter the following command and press Enter:

   ```powershell 
   New-AzResourceGroupDeployment -Name az801l2002deployment -ResourceGroupName AZ801-L0202-RG -TemplateFile ./L02-rg_template.json -TemplateParameterFile ./L02-rg_template.parameters.json
   ```

   >**Note**: Wait for deployment to complete. This should take about 3 minutes.

1. Close Cloud Shell.

## Exercise 4: Onboarding on-premises Windows Server into Microsoft Defender for Cloud and Azure Automation

#### Task 1: Perform manual installation of the Log Analytics agent

1. On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, browse back to the **Microsoft Defender for Cloud \| Overview** page, and then, in the **General** section of the vertical menu on the left, select **Inventory**.
1. On the **Microsoft Defender for Cloud \| Inventory** page, select **+ Add non-Azure servers**.
1. On the **Onboard servers to Defender for Cloud** page, next to the entry representing the Log Analytics workspace you provisioned earlier in this lab, select **Upgrade**.

   > **Note:** After the upgrade completes successfully, the label of the **Upgrade** button will change to **+ Add Servers**.

1. Select the **+ Add Servers** button. This will automatically display the **Agents management** page, from which you can download the Log Analytics agent installers and identify the workspace ID and keys necessary to complete the agent installation.
1. On the **Agents management** page, record the values of **Workspace ID** and **Primary key**. You will need them later in this task.
1. On the **Agents management** page, select the **Download Windows Agent (64 bit)** link.
1. After the download completes, select **Open file**. This will start the **Microsoft Monitoring Agent Setup** wizard.
1. On the **Welcome to the Microsoft Monitoring Agent Setup Wizard** page of the **Microsoft Monitoring Agent Setup** wizard, select **Next**.
1. On the **Important Notice** page of the **Microsoft Monitoring Agent Setup** wizard, select **I agree**.
1. On the **Destination Folder** page of the **Microsoft Monitoring Agent Setup** wizard, select **Next**.
1. On the **Agent Setup Options** page of the **Microsoft Monitoring Agent Setup** wizard, select the **Connect the agent to Azure Log Analytics (OMS)** checkbox, and then select **Next**.
1. On the **Azure Log Analytics** page of the **Microsoft Monitoring Agent Setup** wizard, enter the values of **Workspace ID** and **Workspace Key** you recorded earlier in this task, and then select **Next**.
1. On the **Ready to Install** page of the **Microsoft Monitoring Agent Setup** wizard, select **Install**.
1. After the installation completes, on the **Microsoft Monitoring Agent configuration completed successfully** page, select **Finish**.

#### Task 2: Perform unattended installation of the Log Analytics agent

1. On **SEA-SVR2**, select **Start**, and then select **Windows PowerShell (Admin)**.
1. To extract the content of the **MMASetup-AMD64.exe** file, in the **Windows PowerShell** console, enter the following commands, and after entering each command, press Enter:
	
   ```powershell
   New-Item -ItemType Directory -Path 'C:\Labfiles\L02\' -Force
   Copy-Item -Path $env:USERPROFILE\Downloads\MMASetup-amd64.exe -Destination 'C:\Labfiles\L02\' -Force
   Set-Location -Path C:\Labfiles\L02
   .\MMASetup-amd64.exe /c /t:C:\Labfiles\L02
   Remove-Item -Path .\MMASetup-amd64.exe
   ```

1. To copy the installation files to the target **SEA-SVR1**, in the **Windows PowerShell** console, enter the following commands, and after entering each command, press Enter:
	
   ```powershell
   New-Item -ItemType Directory -Path '\\SEA-SVR1\c$\Labfiles\L02' -Force
   Copy-Item -Path 'C:\Labfiles\L02\*' -Destination '\\SEA-SVR1\c$\Labfiles\L02' -Recurse -Force
   ```

1. To perform the installation of the Log Analytics agent on **SEA-SVR1**, in the **Windows PowerShell** console, enter the following command and press Enter (replace the `<WorkspaceID>` and `<PrimaryKey>` placeholders with the values of **Workspace ID** and **Workspace Key** you recorded in the previous task of this exercise):

   ```powershell
   Invoke-Command -ComputerName SEA-SVR1.contoso.com -ScriptBlock { Start-Process -FilePath C:\Labfiles\L02\setup.exe -ArgumentList '/qn NOAPM=1 ADD_OPINSIGHTS_WORKSPACE=1 OPINSIGHTS_WORKSPACE_AZURE_CLOUD_TYPE=0 OPINSIGHTS_WORKSPACE_ID="<WorkspaceID>" OPINSIGHTS_WORKSPACE_KEY="<PrimaryKey>" AcceptEndUserLicenseAgreement=1' -Wait }
   ```

   > **Note:** Wait for the installation to complete. This should take about 1 minute.

#### Task 3: Enable Azure Automation solutions for Azure VMs

1. On **SEA-SVR2**, switch to the Microsoft Edge window displaying the Azure portal, and browse to the Azure Automation account page you provisioned earlier in this lab. 
1. On the **Automation account** page, in the **Configuration Management** section, select **Inventory**.
1. On the **Inventory** page, in the toolbar, select **+ Add Azure VMs**.
1. On the **Enable Inventory** page, in the list of VMs, ensure that the checkbox next to the **az801l02-vm0** entry is selected and select **Enable**.

   > **Note:** The VM has to be connected to the Log Analytics workspace associated with the Automation Account solutions in order to be listed as **ready to enable**.

1. Browse back to the **Automation account** page and in the **Update Management** section, select **Update management**.
1. On the **Update management** page, in the toolbar, select **+ Add Azure VMs**.
1. On the **Enable Update management** page, in the list of VMs, ensure that the checkbox next to the **az801l02-vm0** entry is selected and select **Enable**.

   > **Note:** Just as with the Inventory and Change tracking solutions, the VM has to be connected to the Log Analytics workspace associated with the Automation Account solutions in order to be listed as **ready to enable**.

#### Task 4: Enable Azure Automation solutions for on-premises servers

1. On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, browse back to the **Automation account** page, and then, in the **Configuration Management** section, select **Inventory**.
1. On the **Inventory** page, select the **Click to manage machines** link.
1. On the **Manage Machines** page, select the **Enable on all available and future machines** option, and then select **Enable**.

   > **Note:** This option applies to on-premises servers that have the Log Analytics agent installed and registered with the Azure Log Analytics workspace associated with the Azure Automation account hosting the Inventory, Change Tracking, and Update Management solutions.

1. Browse back to the **Automation account** page and in the **Update Management** section, select **Update management**.
1. On the **Update management** page, select the **Click to manage machines** link.
1. On the **Manage Machines** page, select the **Enable on all available and future machines** option, and then select **Enable**.

   > **Note:** Just as with the Inventory and Change tracking solutions, this option applies to on-premises servers that have the Log Analytics agent installed and registered with the Azure Log Analytics workspace associated with the Azure Automation account hosting the Inventory, Change Tracking, and Update Management solutions.

## Exercise 5: Verifying the hybrid capabilities of Microsoft Defender for Cloud and Azure Automation solutions

#### Task 1: Validate threat detection capabilities for Azure VMs

1. On **SEA-SVR2**, switch to the Microsoft Edge window displaying the Azure portal. 
1. In the Azure portal, in the **Search resources, services, and docs** text box, on the toolbar, search for and select **Virtual machines**.
1. On the **Virtual machines** page, select **az801l02-vm0**.
1. On the **az801l02-vm0** page, in the **Operations** section, select **Run command**, and then select **RunPowerShellScript**.
1. On the **Run Command Script** page, in the **PowerShell Script** section, enter the following commands, and then select **Run** to trigger a threat detection alert:

   ```powershell
   New-Item -ItemType Directory -Path 'C:\Temp' -Force
   Start-Process -FilePath powershell.exe -ArgumentList '-nop -exec bypass -EncodedCommand "cABvAHcAZQByAHMAaABlAGwAbAAgAC0AYwBvAG0AbQBhAG4AZAAgACIAJgAgAHsAIABpAHcAcgAgAGgAdAB0AHAAcwA6AC8ALwBkAG8AdwBuAGwAbwBhAGQALgBzAHkAcwBpAG4AdABlAHIAbgBhAGwAcwAuAGMAbwBtAC8AZgBpAGwAZQBzAC8AUwB5AHMAbQBvAG4ALgB6AGkAcAAgAC0ATwB1AHQARgBpAGwAZQAgAGMAOgBcAHQAZQBtAHAAXABzAHYAYwBoAG8AcwB0AC4AZQB4AGUAIAB9ACIA"' -Wait
   ```

1. On **SEA-SVR2**, in the Azure portal, browse to the **Microsoft Defender for Cloud \| Overview** page. 
1. On the **Microsoft Defender for Cloud \| Overview** page, in the vertical menu on the left side, in the **General** section, select **Security alerts**.
1. On the **Microsoft Defender for Cloud \| Security alerts** page, note the alert of high severity indicating a suspicious use of PowerShell on **az801l02-vm0**.
1. Select the security alert, on the **Security alert** page, select **Take action**, and review the possible actions.

   > **Note:** To minimize the possibility of future attacks, you should consider implementing security recommendations.

#### Task 2: Validate the threat detection capabilities for on-premises servers

1. On **SEA-SVR2**, switch to the **Windows PowerShell** console.
1. To trigger a threat detection alert, in the **Windows PowerShell** console, enter the following commands, and then, after entering each command, press Enter:
	
   ```powershell
   New-Item -ItemType Directory -Path 'C:\Temp' -Force
   powershell -nop -exec bypass -EncodedCommand "cABvAHcAZQByAHMAaABlAGwAbAAgAC0AYwBvAG0AbQBhAG4AZAAgACIAJgAgAHsAIABpAHcAcgAgAGgAdAB0AHAAcwA6AC8ALwBkAG8AdwBuAGwAbwBhAGQALgBzAHkAcwBpAG4AdABlAHIAbgBhAGwAcwAuAGMAbwBtAC8AZgBpAGwAZQBzAC8AUwB5AHMAbQBvAG4ALgB6AGkAcAAgAC0ATwB1AHQARgBpAGwAZQAgAGMAOgBcAHQAZQBtAHAAXABzAHYAYwBoAG8AcwB0AC4AZQB4AGUAIAB9ACIA"
   ```

1. On **SEA-SVR2**, switch to the Microsoft Edge window displaying the Azure portal and browse back to the **Microsoft Defender for Cloud \| Security alerts** page.
1. On the **Microsoft Defender for Cloud \| Security alerts** page, note the alert of high severity indicating a suspicious use of PowerShell on **SEA-SVR2**.
1. Select the security alert, on the **Security alert** page, select **Take action**, and review the possible actions.

   > **Note:** To minimize the possibility of future attacks, you should consider implementing security recommendations.

#### Task 3: Review the features and capabilities that apply to hybrid scenarios

1. On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, browse back to the **Microsoft Defender for Cloud \| Overview** page, and then, in the **General** section of the vertical menu on the left, select **Inventory**.
1. On the **Inventory** page, in the list of resources, identify the entries representing the **az801l02-vm0** Azure VM as well as **SEA-SVR1.contoso.com** and **SEA-SVR2.contoso.com** on-premises servers.

   > **Note:** It might take a few minutes before the entries representing the Azure and on-premises VMs appear on the **Inventory** page.

   > **Note:** In case **az801l02-vm0** reports **Not installed** status in the **Monitoring agent** column, select the **az801l02-vm0** link. On the **Resource health (Preview)** page, review **Recommendations**, and then select the entry **Log Analytics agent should be installed on virtual machines**. On the **Log Analytics agent should be installed on virtual machines** page, select **Fix**. On the **Fixing resources** page, in the **Workspace ID** drop-down list, select the default workspace created by Defender for Cloud, and then select **Fix 1 resource**. 

1. On the **Inventory** page, select the **az801l02-vm0** link, and then, on the **Resource health (Preview)** page, review **Recommendations**.
1. Browse back to the **Inventory** page, select the link representing **SEA-SVR2**, and then, on the **Resource health (Preview)** page, review **Recommendations**.

#### Task 4: Validate Azure Automation solutions

1. On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, browse back to the page of the Azure Automation account you provisioned earlier in this lab, and then, in the **Configuration Management** section, select **Inventory**.
1. On the **Inventory** page, review the **Machines** tab and verify that it includes both Azure VM and the on-premises servers you registered with the Log Analytics workspace earlier in this lab.

   >**Note**: You might need to wait longer in case either or both of types of systems are not listed on the **Machines** tab.

1. On the **Inventory** page, review the remaining tabs, including **Software**, **Files**, **Windows Registry**, and **Windows Services** tabs.

   >**Note**: The collected data and files is configurable via the **Edit Settings** option in the toolbar of the **Inventory** page.

   >**Note**: This automatically installs the **Change tracking** solution as well.

1. Browse back to the page of the Azure Automation account you provisioned earlier in this lab, and then, in the **Configuration Management** section, select **Change tracking**. 
1. Identify the numbers associated with the **Events**, **Files**, **Registry**, **Software**, and **Windows Services** entries. If any of them are greater than 0, you can find more details regarding the corresponding changes on the **Changes** and **Events** tabs at the bottom of the page.

   >**Note**: In this case as well, the tracked changes are configurable via the **Edit Settings** option in the toolbar of the **Change tracking** page.

1. Browse back to the page of the Azure Automation account you provisioned earlier in this lab, and then, in the **Update Management** section, select **Update management**.
1. On the **Update management** page, review the **Machines** tab and verify that it includes both Azure VM and the on-premises servers you registered with the Log Analytics workspace earlier in this lab.
1. Identify the compliance status for each entry on the **Machines** tab, and then browse to the **Missing updates** tab.

   >**Note**: You have the option of scheduling automated deployment of missing updates for both on-premises servers and Azure VMs.

## Exercise 6: Deprovisioning the Azure environment

#### Task 1: Start a PowerShell session in Cloud Shell

1. On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, open the Cloud Shell pane by selecting the Cloud Shell icon.

#### Task 2: Identify all Azure resources provisioned in the lab

1. From the Cloud Shell pane, run the following command to list all resource groups created in this lab:

   ```powershell
   Get-AzResourceGroup -Name 'AZ801-L02*'
   ```

   > **Note**: Verify that the output contains only the resource group you created in this lab. This group will be deleted in this task.

1. Run the following command to delete all the resource groups you created in this lab:

   ```powershell
   Get-AzResourceGroup -Name 'AZ801-L02*' | Remove-AzResourceGroup -Force -AsJob
   ```

   >**Note**: The command executes asynchronously (as determined by the *-AsJob* parameter), so while you'll be able to run another PowerShell command immediately afterwards within the same PowerShell session, it will take a few minutes before the resource groups are actually removed.
