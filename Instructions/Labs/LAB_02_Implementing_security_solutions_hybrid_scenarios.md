---
lab:
    title: 'Lab: Implementing Security Solutions in Hybrid Scenarios'
    module: 'Module 2: Implementing Security Solutions in Hybrid Scenarios'
---

# Lab: Implementing Security Solutions in Hybrid Scenarios

## Scenario

To identify Microsoft Azure security-related integration features with which you can further enhance your on-premises and cloud security environment, you have decided to onboard Windows servers in your proof-of-concept environment into Microsoft Defender for Cloud. You also want to integrate on-premises servers and Azure VMs running Windows Server with Azure Automation-based solutions, including Inventory, Change tracking, and Update management.

## Objectives

After completing this lab, you'll be able to:

- Create an Azure Log Analytics workspace and an Azure Automation account.
- Configure Defender for Cloud.
- Provision Azure VMs running Windows Server.
- Onboard on-premises Windows Server into Defender for Cloud and Azure Automation.
- Verify the hybrid capabilities of Defender for Cloud and Azure Automation solutions.

## Estimated time: 75 minutes

## Lab setup

Virtual machines: **AZ-801T00A-SEA-DC1**, **AZ-801T00A-SEA-SVR1**, and **AZ-801T00A-SEA-SVR2** must be running. Other VMs can be running, but they aren't required for this lab.

> **Note**: **AZ-801T00A-SEA-DC1**, **AZ-801T00A-SEA-SVR1**, and **AZ-801T00A-SEA-SVR2** virtual machines are hosting the installation of **SEA-DC1**, **SEA-SVR1**, and **SEA-SVR2**, respectively.

1. Select **SEA-SVR2**.
1. Sign in using the following credentials:

   - Username: **Administrator**
   - Password: **Pa55w.rd**
   - Domain: **CONTOSO**

For this lab, you'll use the available VM environment and an Azure subscription. Before you begin the lab, ensure that you have an Azure subscription and a user account with the Owner or Contributor role in that subscription.

## Exercise 1: Creating an Azure Log Analytics workspace and an Azure Automation account

### Scenario

To prepare for your evaluation, you will start by creating an Azure Log Analytics workspace and Azure Automation account that will provide core functionality for the security-related solutions, including Inventory, Change tracking, and Update management.

The main tasks for this exercise are as follows:

1. Create an Azure Log Analytics workspace 
1. Create and configure an Azure Automation account

#### Task 1: Create an Azure Log Analytics workspace 

1. On **SEA-SVR2**, start Microsoft Edge, go to the **[Azure portal](https://portal.azure.com)**, and sign in by using the credentials of a user account with the Owner role in the subscription you'll be using in this lab.
1. From the Azure portal, create a Log Analytics workspace with the following settings:

   | Settings | Value |
   | --- | --- |
   | Subscription | the name of the Azure subscription you are using in this lab |
   | Resource group | the name of a new resource group **AZ801-L0201-RG** |
   | Log Analytics Workspace | any unique name |
   | Region | the name of the Azure region into which you deployed the virtual machine in the previous task |

   >**Note**: Wait for the deployment to complete. The deployment should take about 1 minute.

#### Task 2: Create and configure an Azure Automation account

1. On **SEA-SVR2**, in the Azure portal, create an Azure Automation account with the following settings:

   | Settings | Value |
   | --- | --- |
   | Subscription | the name of the Azure subscription you are using in this lab |
   | Resource group | **AZ801-L0201-RG** |
   | Name | any unique name |
   | Region | the name of the Azure region determined based on [Workspace mappings documentation](https://docs.microsoft.com/en-us/azure/automation/how-to/region-mappings) |

   >**Note**: Make sure that you specify the Azure region based on the [Workspace mappings documentation](https://docs.microsoft.com/en-us/azure/automation/how-to/region-mappings).

   >**Note**: Wait for the deployment to complete. The deployment might take about 3 minutes.

1. In the Azure portal, browse to the newly created Azure Automation account. 
1. From the **Automation account** page, browse to its **Inventory** page.
1. In the **Inventory** page, enable the solution by associating it with the Log Analytics workspace you created earlier in this task.

   >**Note**: Wait for the installation of the corresponding Log Analytics solution to complete. This might take about 3 minutes. 

   >**Note**: This automatically installs the **Change tracking** solution as well.

1. From the **Automation account** page, browse to its **Update Management** page.
1. On the **Automation account** page, enable the solution by associating it with the Log Analytics workspace you created earlier in this task.

   >**Note**: Wait for the installation to complete. This might take about 5 minutes.

## Exercise 2: Configuring Microsoft Defender for Cloud

### Scenario

Next, you need to make sure you will be able take advantage of the enhanced security features offered by Defender for Cloud. This will allow you to properly evaluate the features and capabilities that apply to Windows Server hybrid scenarios.

The main tasks for this exercise are as follows:

1. Enable Defender for Cloud and automatic agent installation.
1. Enable enhanced security of Defender for Cloud.

#### Task 1: Enable Defender for Cloud and automatic agent installation

In this task, you will connect to your Azure subscription and enable enhanced security features of Defender for Cloud.

1. On **SEA-SVR2**, in the Azure portal, browse to the **Microsoft Defender for Cloud** page.
1. Upgrade your subscription to Defender for Cloud and enable automatic agent installation. 

   > **Note:** Your subscription may already have the enhanced security of Defender for Cloud enabled, in which case, continue to the next task.

#### Task 2: Enable enhanced security of Defender for Cloud

In this task, you will enable enhanced security of Defender for Cloud.

1. On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, from the **Microsoft Defender for Cloud | Overview** page, browse to the **Environment settings** page.
1. On the **Environment settings** page, review the Defender for Cloud plans available in your Azure subscription.

   > **Note:** Note that you can selectively disable individual Microsoft Defender plans listed on the same page.

1. Enable the **Microsoft Defender for Servers** plan. 
1. Browse to the **Settings & monitoring** page (by clicking the setting link next to the plan). 
1. In the list of extensions, perform the following tasks:

   - Enable **Log Analytics agent/Azure Monitoring Agent** select the log analytics agent (default) option and leverage the Log Analytics workspace you created in the previous exercise.
   - Enable **Vulnerability assessment for machines** with the **Microsoft threat and vulnerability management** option.


1. Browse to the **Cloud Environment settings** page in Defender for Cloud.
1. On the **Environment settings** page, expand the entry representing your Azure subscription and review the entry representing the Log Analytics workspace you created in the previous exercise.
1. On the **Settings \| Defender plans** page, enable all Defender for Cloud plans available in the workspace.

   > **Note:** To enable all Defender for Cloud features including threat protection capabilities, you must enable enhanced security features on the subscription containing the applicable workloads. Enabling it at the workspace level doesn't enable just-in-time VM access, adaptive application controls, and network detections for Azure resources. In addition, the only Microsoft Defender plans available at the workspace level are Microsoft Defender for servers and Microsoft Defender for SQL servers on machines.

1. For the workspace you created in the previous exercise, set the scope of **Data collection** to **All Events**.

   > **Note:** Selecting a data collection tier in Defender for Cloud only affects the storage of security events in your Log Analytics workspace. The Log Analytics agent will still collect and analyze the security events required for Defender for Cloud's threat protection, regardless of the level of security events you choose to store in your workspace. Choosing to store security events enables investigation, search, and auditing of those events in your workspace.

## Exercise 3: Provisioning Azure VMs running Windows Server

### Scenario

You must test Defender for Cloud functionality in hybrid scenarios, including its benefits for Azure VMs that are running Windows Server. To accomplish this, you'll provision Azure VMs that are running Windows Server by using an Azure Resource Manager template.

The main tasks for this exercise are as follows:

1. Start Azure Cloud Shell.
1. Deploy an Azure VM by using an Azure Resource Manager template.

#### Task 1: Start Azure Cloud Shell

In this task, you will start Azure Cloud Shell.

1. On **SEA-SVR2**, in the Azure portal, open a PowerShell session in the Azure Cloud Shell pane.
1. If this is the first time you're starting Cloud Shell, accept its default configuration settings.

#### Task 2: Deploy an Azure VM by using an Azure Resource Manager template

In this task, you will deploy an Azure VM by using an Azure Resource Manager template.

1. On **SEA-SVR2**, in the Azure portal, in the Cloud Shell pane, upload the files **C:\\Labfiles\\Lab02\\L02-sub_template.json**, **C:\\Labfiles\\Lab02\\L02-rg_template.json**, and **C:\\Labfiles\\Lab02\\L02-rg_template.parameters.json** files into the Cloud Shell home directory.
1. To create the resource group that will be hosting the lab environment, in the **PowerShell** session in the Cloud Shell pane, run the following commands (replace the `<Azure_region>` placeholder with the name of an Azure region where you intend to deploy resources in this lab):

   >**Note**: You can use the **(Get-AzLocation).Location** command to list the names of available Azure regions:

   ```powershell 
   $location = '<Azure_region>'
   New-AzSubscriptionDeployment -Location $location -Name az801l2001deployment -TemplateFile ./L02-sub_template.json -rgLocation $location -rgName 'AZ801-L0202-RG'
   ```

1. To deploy an Azure virtual machine (VM) into the newly created resource group, run the following command:

   ```powershell 
   New-AzResourceGroupDeployment -Name az801l2002deployment -ResourceGroupName AZ801-L0202-RG -TemplateFile ./L02-rg_template.json -TemplateParameterFile ./L02-rg_template.parameters.json
   ```

   >**Note**: Wait for deployment to complete. This should take about 3 minutes.

1. Close Cloud Shell.

## Exercise 4: Onboarding on-premises Windows Server into Microsoft Defender for Cloud and Azure Automation

### Scenario

You'll onboard **SEA-SVR1** and **SEA-SVR2** into Defender for Cloud to determine the Defender for Cloud features that you can use to enhance security for servers running in your on-premises environment.

The main tasks for this exercise are as follows:

1. Perform manual installation of the Log Analytics agent.
1. Perform unattended installation of the Log Analytics agent.
1. Enable Azure Automation solutions for Azure VMs.
1. Enable Azure Automation solutions for on-premises servers.

#### Task 1: Perform manual installation of the Log Analytics agent

In this task, you will perform manual installation of the Log Analytics agent.

1. On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, browse to the **Microsoft Defender for Cloud \| Inventory** page of Defender for Cloud.
1. On the **Microsoft Defender for Cloud \| Inventory** page, select **+ Add non-Azure servers**.
1. On the **Onboard servers to Defender for Cloud** page, upgrade the Log Analytics workspace **az801-l02-workspace**.

   > **Note:** After the upgrade completes successfully, the label of the **Upgrade** button will change to **+ Add Servers**.

1. Use the **+ Add Servers** button to browse to the **az801-l02-workspace \| Agents management** page, from which you can download the Log Analytics agent installers and identify the workspace ID and keys necessary to complete the agent installation.
1. On the **az801-l02-workspace \| Agents management** page, record the values of **Workspace ID** and **Primary key**. You will need them later in this task.
1. From the **az801-l02-workspace \| Agents management** page, download the Windows Agent (64 bit).
1. Use the downloaded executable to launch the **Microsoft Monitoring Agent Setup** wizard.
1. On the **Azure Log Analytics** page of the **Microsoft Monitoring Agent Setup** wizard, enter the values of **Workspace ID** and **Primary Key** you recorded earlier in this task and complete the installation of Microsoft Monitoring Agent with the default settings.

#### Task 2: Perform unattended installation of the Log Analytics agent

In this task, you will perform unattended installation of the Log Analytics agent.

1. On **SEA-SVR2**, start **Windows PowerShell** as administrator.
1. To extract the content of the **MMASetup-AMD64.exe** file, in the **Windows PowerShell** console, run the following commands:
	
   ```powershell
   New-Item -ItemType Directory -Path 'C:\Labfiles\L02\' -Force
   Copy-Item -Path $env:USERPROFILE\Downloads\MMASetup-amd64.exe -Destination 'C:\Labfiles\L02\' -Force
   Set-Location -Path C:\Labfiles\L02
   .\MMASetup-amd64.exe /c /t:C:\Labfiles\L02
   Remove-Item -Path .\MMASetup-amd64.exe
   ```

1. To copy the installation files to the target **SEA-SVR1**, in the **Windows PowerShell** console, run the following commands:
	
   ```powershell
   New-Item -ItemType Directory -Path '\\SEA-SVR1\c$\Labfiles\L02' -Force
   Copy-Item -Path 'C:\Labfiles\L02\*' -Destination '\\SEA-SVR1\c$\Labfiles\L02' -Recurse -Force
   ```

1. To perform the installation of the Log Analytics agent on **SEA-SVR1**, in the **Windows PowerShell** console, run the following command (replace the `<WorkspaceID>` and `<PrimaryKey>` placeholders with the values of **Workspace ID** and **Workspace Key** you recorded in the previous task of this exercise):

   ```powershell
   Invoke-Command -ComputerName SEA-SVR1.contoso.com -ScriptBlock { Start-Process -FilePath C:\Labfiles\L02\setup.exe -ArgumentList '/qn NOAPM=1 ADD_OPINSIGHTS_WORKSPACE=1 OPINSIGHTS_WORKSPACE_AZURE_CLOUD_TYPE=0 OPINSIGHTS_WORKSPACE_ID="<WorkspaceID>" OPINSIGHTS_WORKSPACE_KEY="<PrimaryKey>" AcceptEndUserLicenseAgreement=1' -Wait }
   ```

   > **Note:** Wait for the installation to complete. This should take about 1 minute.

#### Task 3: Enable Azure Automation solutions for Azure VMs

1. On **SEA-SVR2**, switch to the Microsoft Edge window displaying the Azure portal, and browse to the Azure Automation account page you provisioned earlier in this lab. 
1. From the Automation account page, browse to its **Inventory** page.
1. On the **Inventory** page, use the **+ Add Azure VMs** button in the toolbar to enable inventory and change tracking for the **az801l02-vm0** Azure VM. 

   > **Note:** The VM has to be connected to the Log Analytics workspace associated with the Automation Account solutions in order to be listed as **ready to enable**.

1. Browse to the **Update management** page of the Automation account.
1. On the **Update management** page, use the **+ Add Azure VMs** button in the toolbar to enable update management for the **az801l02-vm0** Azure VM. 

   > **Note:** Just as with the Inventory solution, the VM has to be connected to the Log Analytics workspace associated with the Automation Account solutions in order to be listed as **ready to enable**.

   > **Note:** On-premises VMs are onboarded as the result of installation of the Log Analytics agent and registration with the Azure Log Analytics workspace associated with the Azure Automation account hosting the Inventory, Change Tracking, and Update Management solutions, which you performed in the previous task of this exercise.

#### Task 4: Enable Azure Automation solutions for on-premises servers

1. On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, browse to the **Azure Automation account** page you provisioned earlier in this lab. 
1. From the **Automation account** page, browse to its **Inventory** page.
1. On the **Inventory** page, use the **Click to manage machines** link to enable inventory and change tracking for the on-premises servers.

   > **Note:** This option applies to on-premises servers that have the Log Analytics agent installed and registered with the Azure Log Analytics workspace associated with the Azure Automation account hosting the Inventory, Change Tracking, and Update Management solutions.

1. Browse to the **Update management** page of the Automation account.
1. On the **Update management** page, use the **Click to manage machines** link to enable update management for the on-premises servers.

   > **Note:** Just as with the Inventory and Change tracking solutions, this option applies to on-premises servers that have the Log Analytics agent installed and registered with the Azure Log Analytics workspace associated with the Azure Automation account hosting the Inventory, Change Tracking, and Update Management solutions.

## Exercise 5: Verifying the hybrid capabilities of Microsoft Defender for Cloud and Azure Automation solutions

### Scenario

With a mix of on-premises Azure VMs and servers that are running Windows Server, you want to validate the capabilities of Defender for Cloud and Azure Automation security-related solutions that are available in both cases. You'll simulate a cyberattack on both resources and identify alerts in Defender for Cloud.

The main tasks for this exercise are as follows:

1. Validate threat detection capabilities for Azure VMs.
1. Validate the threat detection capabilities for on-premises servers.
1. Review the features and capabilities that apply to hybrid scenarios.
1. Validate Azure Automation solutions.

#### Task 1: Validate threat detection capabilities for Azure VMs

In this task, you will validate threat detection capabilities for Azure VMs.

1. On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, browse to the page of the **az801l02-vm0** virtual machine.
1. On the **az801l02-vm0** page, use the **Run command** feature to run the following PowerShell commands to trigger a threat detection alert:

   ```powershell
   New-Item -ItemType Directory -Path 'C:\Temp' -Force
   Start-Process -FilePath powershell.exe -ArgumentList '-nop -exec bypass -EncodedCommand "cABvAHcAZQByAHMAaABlAGwAbAAgAC0AYwBvAG0AbQBhAG4AZAAgACIAJgAgAHsAIABpAHcAcgAgAGgAdAB0AHAAcwA6AC8ALwBkAG8AdwBuAGwAbwBhAGQALgBzAHkAcwBpAG4AdABlAHIAbgBhAGwAcwAuAGMAbwBtAC8AZgBpAGwAZQBzAC8AUwB5AHMAbQBvAG4ALgB6AGkAcAAgAC0ATwB1AHQARgBpAGwAZQAgAGMAOgBcAHQAZQBtAHAAXABzAHYAYwBoAG8AcwB0AC4AZQB4AGUAIAB9ACIA"' -Wait
   ```

1. On **SEA-ADM1**, in the Azure portal, browse to the **Microsoft Defender for Cloud \| Security alerts** page.
1. On the **Microsoft Defender for Cloud \| Security alerts** page, note the alert of high severity indicating a suspicious use of PowerShell on **az801l02-vm0**.
1. Select the security alert, on the **Security alert** page, select **Take action**, and then review the possible actions.

   > **Note:** To minimize the possibility of future attacks, you should consider implementing security recommendations.

#### Task 2: Validate the threat detection capabilities for on-premises servers

In this task, you will validate the threat detection capabilities for on-premises servers.

1. On **SEA-ADM1**, switch to the **Windows PowerShell** console.
1. To trigger a threat detection alert, in the **Windows PowerShell** console, run the following commands:
	
   ```powershell
   New-Item -ItemType Directory -Path 'C:\Temp' -Force
   powershell -nop -exec bypass -EncodedCommand "cABvAHcAZQByAHMAaABlAGwAbAAgAC0AYwBvAG0AbQBhAG4AZAAgACIAJgAgAHsAIABpAHcAcgAgAGgAdAB0AHAAcwA6AC8ALwBkAG8AdwBuAGwAbwBhAGQALgBzAHkAcwBpAG4AdABlAHIAbgBhAGwAcwAuAGMAbwBtAC8AZgBpAGwAZQBzAC8AUwB5AHMAbQBvAG4ALgB6AGkAcAAgAC0ATwB1AHQARgBpAGwAZQAgAGMAOgBcAHQAZQBtAHAAXABzAHYAYwBoAG8AcwB0AC4AZQB4AGUAIAB9ACIA"
   ```

1. On **SEA-ADM1**, switch to the Microsoft Edge window displaying the Azure portal and browse back to the **Microsoft Defender for Cloud \| Security alerts** page.
1. On the **Microsoft Defender for Cloud \| Security alerts** page, note the alert of high severity indicating a suspicious use of PowerShell on **SEA-SVR2**.
1. Select the security alert, on the **Security alert** page, select **Take action**, and review the possible actions.

   > **Note:** To minimize the possibility of future attacks, you should consider implementing security recommendations.

#### Task 3: Review the features and capabilities that apply to hybrid scenarios

In this task, you will review the Defender for Cloud features and capabilities that apply to hybrid scenarios.

1. On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, browse to the **Microsoft Defender for Cloud \| Inventory** page.
1. On the **Inventory** page, in the list of resources, identify the entries representing the **az801l02-vm0** Azure VM as well as **SEA-SVR1.contoso.com** and **SEA-SVR2.contoso.com** on-premises servers.

   > **Note:** It might take a few minutes before the entries representing the Azure and on-premises VMs appear on the **Inventory** page.

   > **Note:** In case **az801l02-vm0** reports **Not installed** status in the **Monitoring agent** column, select the **az801l02-vm0** link. On the **Resource health (Preview)** page, review **Recommendations**, select the **Log Analytics agent should be installed on virtual machines** entry. On the **Log Analytics agent should be installed on virtual machines** page, select **Fix**. On the **Fixing resources** page, from the **Workspace ID** drop-down list, select the default workspace created by Defender for Cloud, and then select **Fix 1 resource**. 

1. Browse to the **Resource health (Preview)** page of **az801l02-vm0** and review **Recommendations**.
1. Browse to the **Resource health (Preview)** page of **SEA-SVR2** and review **Recommendations**.

#### Task 4: Validate Azure Automation solutions

1. On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, browse back to the **Inventory** page of the Azure Automation account you provisioned earlier in this lab.
1. On the **Inventory** page, review the **Machines** tab and verify that it includes both Azure VM and the on-premises servers you registered with the Log Analytics workspace earlier in this lab.

   >**Note**: You might need to wait longer, if either Azure VM servers or on-premises servers or both are not listed on the **Machines** tab.

1. On the **Inventory** page, review the remaining tabs, including **Software**, **Files**, **Windows Registry**, and **Windows Services** tab.

   >**Note**: The collected data and files is configurable via the **Edit Settings** option in the toolbar of the **Inventory** page.

   >**Note**: This automatically installs the **Change tracking** solution as well.

1. Browse to the **Change tracking** page of the same Azure Automation account. 
1. Identify the numbers associated with the **Events**, **Files**, **Registry**, **Software**, and **Windows Services** entries. If any of them are greater than 0, you can find more details regarding the corresponding changes on the **Changes** and **Events** tabs at the bottom of the page.

   >**Note**: In this case as well, the tracked changes are configurable via the **Edit Settings** option in the toolbar of the **Change tracking** page.

1. Browse to the **Update management** page of the same Azure Automation account.
1. On the **Update management** page, review the **Machines** tab and verify that it includes both Azure VM and the on-premises servers you registered with the Log Analytics workspace earlier in this lab.
1. Identify the compliance status for each entry on the **Machines** tab, and then browse to the **Missing updates** tab.

   >**Note**: You have the option of scheduling automated deployment of missing updates for both on-premises servers and Azure VMs.

## Exercise 6: Deprovisioning the Azure environment

### Scenario

To minimize Azure-related charges, you'll deprovision the Azure resources that were provisioned throughout this lab.

The main tasks for this exercise are:

1. Start a PowerShell session in Cloud Shell.
1. Identify and remove all Azure resources that were provisioned in the lab.

#### Task 1: Start a PowerShell session in Cloud Shell

1. On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, open the Cloud Shell pane.

#### Task 2: Identify and remove all Azure resources that were provisioned in the lab

1. From the Cloud Shell pane, run the following command to list all resource groups created in this lab:

   ```powershell
   Get-AzResourceGroup -Name 'AZ801-L02*'
   ```

   > **Note**: Verify that the output contains only the resource groups you created in this lab. These groups will be deleted in this task.

1. To delete all resource groups you created in this lab, run the following command:

   ```powershell
   Get-AzResourceGroup -Name 'AZ801-L02*' | Remove-AzResourceGroup -Force -AsJob
   ```

   >**Note**: The command executes asynchronously (as determined by the *-AsJob* parameter), so while you'll be able to run another PowerShell command immediately afterwards within the same PowerShell session, it will take a few minutes before the resource groups are actually removed.

## Results

After completing this lab, you have:

- Created an Azure Log Analytics workspace and an Azure Automation account.
- Configured Defender for Cloud.
- Provisioned Azure VMs running Windows Server.
- Onboarded on-premises Windows Server into Defender for Cloud and Azure Automation.
- Verified the hybrid capabilities of Defender for Cloud and Azure Automation solutions.
