---
lab:
    title: 'Lab: Implementing operational monitoring in hybrid scenarios'
    module: 'Module 9: Implementing operational monitoring in hybrid scenarios'
---

# Lab: Implementing operational monitoring in hybrid scenarios

## Lab scenario

You need to evaluate Microsoft Azure functionality that would provide insight into the performance and configuration of Azure resources, focusing in particular on Azure virtual machines (VMs). To accomplish this, you intend to examine the capabilities of Azure Monitor, including Log Analytics.

## Objectives

After completing this lab, you'll be able to:

- Prepare a monitoring environment.
- Configure monitoring of on-premises servers.
- Configure monitoring of Azure VMs.
- Evaluate monitoring services.

## Estimated time: 60 minutes

## Lab Environment
  
Virtual machines: **AZ-801T00A-SEA-DC1** and **AZ-801T00A-SEA-SVR2** must be running. Other VMs can be running, but they aren't required for this lab.

> **Note**: **AZ-801T00A-SEA-DC1** and **AZ-801T00A-SEA-SVR2** virtual machines are hosting the installation of **SEA-DC1** and **SEA-SVR2**.

1. Select **SEA-SVR2**.
1. Sign in using the following credentials:

   - Username: **Administrator**
   - Password: **Pa55w.rd**
   - Domain: **CONTOSO**

For this lab, you'll use the available VM environment and an Azure subscription. Before you begin the lab, ensure that you have an Azure subscription and a user account with the Owner role in that subscription.

## Exercise 1: Preparing a monitoring environment

The main tasks for this exercise are to:

1. Deploy an Azure virtual machine.
1. Register the Microsoft.Insights and Microsoft.AlertsManagement resource providers.
1. Create and configure an Azure Log Analytics workspace.

#### Task 1: Deploy an Azure virtual machine

In this task, you will deploy a virtual machine that will be used to test monitoring scenarios.

1. On **SEA-SVR2**, start Microsoft Edge, go to the **[Azure portal](https://portal.azure.com)**, and sign in by using credentials of a user account with the Owner role in the subscription you'll be using in this lab.
1. On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, open a PowerShell session in Azure Cloud Shell.
1. In the Cloud Shell pane, upload the **C:\\Labfiles\\Lab02\\L02-sub_template.json**, **C:\\Labfiles\\Lab09\\L09-rg_template.json**, and **C:\\Labfiles\\Lab09\\L09-rg_template.parameters.json** files into the Cloud Shell home directory.
1. To create the resource group that will be hosting the lab environment, in the **PowerShell** session in the Cloud Shell pane, run the following commands (replace the `<Azure_region>` placeholder with the name of an Azure region where you intend to deploy resources in this lab):

   >**Note**: You can use the **(Get-AzLocation).Location** command to list the names of available Azure regions:

   ```powershell 
   $location = '<Azure_region>'
   $rgName = 'AZ801-L0901-RG'
   New-AzResourceGroup -ResourceGroupName $rgName -Location $location
   ```

1. To deploy an Azure VM into the newly created resource group, run the following command:

   ```powershell 
   New-AzResourceGroupDeployment -Name az801l0901deployment -ResourceGroupName $rgName -TemplateFile ./L09-rg_template.json -TemplateParameterFile ./L09-rg_template.parameters.json -AsJob
   ```

   >**Note**: Do not wait for the deployment to complete but instead proceed to the next task. The deployment should take about 3 minutes.

#### Task 2: Register the Microsoft.Insights and Microsoft.AlertsManagement resource providers

1. To register the Microsoft.Insights and Microsoft.AlertsManagement resource providers, on **SEA-SVR2**, from the Cloud Shell pane, run the following commands:

   ```powershell
   Register-AzResourceProvider -ProviderNamespace Microsoft.Insights
   Register-AzResourceProvider -ProviderNamespace Microsoft.AlertsManagement
   ```

   >**Note**: To verify the registration status, you can use the **Get-AzResourceProvider** cmdlet.

   >**Note**: Do not wait for the registration process to complete but instead proceed to the next task. The registration should take about 3 minutes.

1. Close Cloud Shell.

#### Task 3: Create and configure an Azure Log Analytics workspace

In this task, you will create and configure an Azure Log Analytics workspace and Azure Automation-based solutions.

1. On **SEA-SVR2**, in the Azure portal, create a Log Analytics workspace with the following settings:

   | Settings | Value |
   | --- | --- |
   | Subscription | the name of the Azure subscription you are using in this lab |
   | Resource group | the name of a new resource group **AZ801-L0902-RG** |
   | Log Analytics Workspace | any unique name |
   | Region | the name of the Azure region into which you deployed the virtual machine in the previous task |

   >**Note**: Make sure that you specify the same region into which you deployed virtual machines in the previous task.

   >**Note**: Wait for the deployment to complete. The deployment should take about 1 minute.

1. In the Azure portal, navigate to the blade of the newly provisioned workspace.
1. On the workspace blade, navigate to the **Agents management** blade and record the values of the **Workspace ID** and **Primary key**. You will need them in the next exercise.

#### Task 4: Install Service Map solution

1. On **SEA-SVR2**, in the Azure portal, search for the **Service Map** Marketplace item and navigate to the corresponding blade.
1. From the **Create Service Map Solution** blade, create the **Service Map** solution with the following settings:

   | Settings | Value |
   | --- | --- |
   | Subscription | the name of the Azure subscription you are using in this lab |
   | Resource group | **AZ801-L0902-RG** |
   | Log Analytics Workspace | the name of the Log Analytics workspace you created in the previous task |


## Exercise 2: Configuring monitoring of on-premises servers

The main task for this exercise is to:

1. Install the Log Analytics agent using setup wizard.

#### Task 1: Install agent using setup wizard

1. While connected to the console session on **SEA-SVR2**, in the browser window displaying the Azure portal, from the **Agents management** blade, download the 64-bit Windows Log Analytics agent. 
1. Install the agent with the default settings. When prompted, enter the **Workspace ID** and **Workspace Key (Primary Key)** you recorded in the previous exercise. 
1. On **SEA-SVR2**, start Windows PowerShell as administrator and, from the **Administrator: Windows PowerShell** console, run the following commands to install Dependency Agent:

   ```powershell
   Invoke-WebRequest "https://aka.ms/dependencyagentwindows" -OutFile InstallDependencyAgent-Windows.exe
   .\InstallDependencyAgent-Windows.exe /S
   ```

## Exercise 3: Configuring monitoring of Azure VMs

The main tasks for this exercise are to:

1. Review host-based monitoring.
1. Configure diagnostic settings and VM Insights.

#### Task 1: Review host-based monitoring

In this task, you will review default monitoring settings of Azure virtual machines.

1. In the Azure portal, browse to the **az801l09-vm0** virtual machine page.
1. On the **az801l09-vm0** page, in the **Monitoring** section, select **Metrics**.
1. On the **az801l09-vm0 \| Metrics** page, on the default chart, in the **Metric Namespace** drop-down list, note that only **Virtual Machine Host** metrics are available.

   >**Note**: This is expected because no guest-level diagnostic settings have been configured yet. However, you do have the option of enabling guest memory metrics directly from the **Metrics Namespace** drop down-list. You will enable it later in this exercise.

1. In the **Metric** drop-down list, review the list of available metrics.

   >**Note**: The list includes a range of CPU, disk, and network-related metrics that can be collected from the virtual machine host, without having access into guest-level metrics.

1. On the **az801l09-vm0 \| Metrics** page, display the chart illustrating the average percentage CPU utilization of **az801l09-vm0**.

#### Task 2: Configure diagnostic settings and VM Insights

In this task, you will configure Azure virtual machine diagnostic settings.

1. On the **az801l09-vm0** page, in the **Monitoring** section, select **Diagnostic settings** and enable guest-level monitoring.

   >**Note**: Wait for the operation to take effect. This might take about 3 minutes.

1. Switch to the **Performance counters** tab of the **az801l09-vm0 \| Diagnostic settings** page and review the available counters.

   >**Note**: By default, CPU, memory, disk, and network counters are enabled. You can switch to the **Custom** view for more detailed listing.

1. Switch to the **Logs** tab of the **az801l09-vm0 \| Diagnostic settings** page and enable guest-level monitoring. 

   >**Note**: Wait until the guest-level monitoring diagnostics are enabled. This should take about 3 minutes.

1. On the **az801l09-vm00 \| Diagnostic settings** page, on the **Overview** tab, review the available event log collection options.

   >**Note**: By default, log collection includes critical, error, and warning entries from the Application Log and System log, as well as Audit failure entries from the Security log. You can customize them from the **Logs** tab.

1. On the **az801l09-vm0 \| Diagnostic settings** page, select the **Logs** tab and review the available configuration settings.
1. On the **az801l09-vm0 \| Logs** page, in the vertical menu on the left side, in the **Monitoring** section, select **Metrics**.
1. On the **az801l09-vm0 \| Metrics** page, on the default chart, note that at this point, the **Metrics Namespace** drop-down list, in addition to the **Virtual Machine Host** entry includes also the **Guest (classic)** entry.

   >**Note**: This is expected because you enabled guest-level diagnostic settings. You also have the option to **Enable new guest memory metrics**.

1. In the **Metrics Namespace** drop-down list, select the **Guest (classic)** entry.
1. In the **Metric** drop-down list, review the list of available metrics and note that they include a range of metrics related to memory and logical disks.

   >**Note**: The list includes additional guest-level metrics not available when relying on the host-level monitoring only.

1. Using the option in the **Metrics Namespace** drop-down list, enable new guest memory metrics by following the instructions provided in the Azure portal.
1. Browse back to the **az801l09-vm0 \| Metrics** page, on the default chart, note that at this point, the **Metrics Namespace** drop-down list, in addition to the **Virtual Machine Host** and **Guest (classic)** entries, also includes the **Virtual Machine Guest** entry.

   >**Note**: You might need to refresh the page for the **Virtual Machine Guest** entry to appear.

1. On the **az801l09-vm0 \| Metrics** page, on the vertical menu on the left side, in the **Monitoring** section, select **Logs**.
1. On the **az801l09-vm0 \| Logs** page, enable log collection to the Log Analytics workspace you created earlier in this lab.
1. Browse to the **az801l09-vm0 \| Insights** page and enable the Azure Monitor VM Insights functionality.

   >**Note**: VM Insights is an Azure Monitor solution that facilitates monitoring performance and health of both Azure VMs and on-premises computers running Windows or Linux.

1. On **SEA-SVR2**, browse to the **Monitor \| Virtual Machines** page and upgrade **Performance** and **Map** functionality of the workspace you created earlier in this lab.

   >**Note**: This option enables monitoring and alerting capabilities using health model, which consists of a hierarchy of health monitors built using metrics emitted by Azure Monitor for VMs.

## Exercise 4: Evaluating monitoring services

The main tasks for this exercise are to:

1. Review Azure Monitor monitoring and alerting functionality.
1. Review Azure Monitor VM Insights functionality.
1. Review Azure Log Analytics functionality.

#### Task 1: Review Azure Monitor monitoring and alerting functionality

1. On **SEA-SVR2**, in the Azure portal, browse back to the **Monitor \| Metrics** blade.
1. Set the scope to the **az801l09-vm0** virtual machine. 

   >**Note**: This gives you the same view and options as those available from the **az801l09-vm0 \| Metrics** page.

1. On the **az801l09-vm0 \| Metrics** page, display the chart illustrating the average percentage CPU utilization of **az801l09-vm0**.
1. From the **Avg Percentage CPU for az801l09-vm0** pane on the **Monitor \| Metrics** page, create a new alert rule for average percentage of CPU utilization for **az801l09-vm0** with the following signal logic settings:

   | Settings | Value |
   | --- | --- |
   | Threshold | **Static** |
   | Operator | **Greater than** |
   | Aggregation type | **Average** |
   | Threshold value | **2** |
   | Aggregation granularity (Period) | **1 minute** |
   | Frequency of evaluation | **Every 1 Minute** |

   >**Note**: Creating an alert rule from Metrics is not supported for metrics from the Guest (classic) metric namespace. This can be accomplished by using Azure Resource Manager templates, as described in the document **[Send Guest OS metrics to the Azure Monitor metric store using a Resource Manager template for a Windows virtual machine](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/collect-custom-metrics-guestos-resource-manager-vm)**.

1. Create an action group for the new alert rule with the following settings (leave others with their default values) and select **Next: Notifications >**:

   | Settings | Value |
   | --- | --- |
   | Subscription | the name of the Azure subscription you are using in this lab |
   | Resource group | **AZ801-L0902-RG** |
   | Action group name | **az801l09-ag1** |
   | Display name | **az801l09-ag1** |
   | Notification type | **Email/SMS/Push/Voice** |
   | Notification name | **admin email** |
   | Notification email address | your email address | 

1. Configure alert rule details according to the following settings (leave others with their default values):

   | Settings | Value |
   | --- | --- |
   | Alert rule name | **CPU Percentage above the test threshold** |
   | Description | **CPU Percentage above the test threshold** |
   | Resource group | **AZ801-L0902-RG** |
   | Severity | **Sev 3** |
   | Enable rule upon creation | **Yes** |

   >**Note**: It can take up to 10 minutes for a metric alert rule to become active.

1. In the Azure portal, browse to the **az801l09-vm0** virtual machine page.
1. On the **az801l09-vm0** page, in the **Operations** section, use the **Run command** **RunPowerShellScript** functionality to run the following commands that are supposed to increase the CPU utilization within the target operating system and trigger an alert based on the newly configured rule:

   ```powershell
   $vCpuCount = Get-WmiObject Win32_Processor | Select-Object -ExpandProperty NumberOfLogicalProcessors
   ForEach ($vCpu in 1..$vCpuCount){ 
      Start-Job -ScriptBlock{
         $result = 1;
         ForEach ($loopCount in 1..2147483647){
            $result = $result * $loopCount
         }
      }
   }
   ```

1. On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, open another tab and browse to the **Alerts** page of Azure Monitor.
1. Review the list of alerts and display the details of the **Sev 3** alerts generated by the alert rule you created.

   >**Note**: You might need to wait for a few minutes and select **Refresh**.

#### Task 2: Review Azure Monitor VM Insights functionality

1. On **SEA-SVR2**, in the Azure portal, browse back to the **az801l09-vm0** virtual machine page.
1. On the **az801l09-vm0** virtual machine page, on the vertical menu on the left side, in the **Monitoring** section, select **Insights**.
1. On the **az801l09-vm0 \| Insights** page, on the **Performance** tab, review the default set of metrics, including logical disk performance, CPU utilization, available memory, as well as bytes sent and received rates.
1. On the **az801l09-vm0 \| Insights** page, select the **Map** tab and review the autogenerated map.
1. On the **az801l09-vm0 \| Insights** page, select the **Health** tab and review its content.

   >**Note**: The availability of health information is dependent on completion of the workspace upgrade.

#### Task 3: Review Azure Log Analytics functionality

1. On **SEA-SVR2**, in the Azure portal, browse back to the **Monitor** page and select **Logs**.
1. On the **Select a scope** page, use the **Recent** tab to select the unique workspace you created earlier in this lab, and then select **Apply**.
1. In the query window, run the following query and review the resulting chart:

   ```kql
   // Virtual Machine available memory
   // Chart the VM's available memory over the last hour.
   InsightsMetrics
   | where TimeGenerated > ago(1h)
   | where Name == "AvailableMB"
   | project TimeGenerated, Name, Val
   | render timechart
   ```

1. Select **Queries** in the toolbar, in the **Queries** pane, expand the **Virtual machines** node, review and run the **Track VM availability** query and review the results.
1. On the **New Query 1** tab, select the **Tables** header, and review the list of tables in the **Azure Monitor for VMs** section.

   >**Note**: The names of several tables correspond to the solutions you installed earlier in this lab. In particular, **InsightMetrics** is used by Azure VM Insights to store performance metrics.

1. Move the cursor over the **VMComputer** entry, select the **See Preview data** icon, and review the results.

   >**Note**: Verify that the data includes entries for both **az801l09-vm0** and **SEA-SVR2.contoso.com**.

   >**Note**: You might need to wait a few minutes before the update data becomes available.

1. On **SEA-SVR2**, in the Azure portal, browse to the page of the Log Analytics workspaces you created earlier in this lab.
1. From the workspace page, browse to its **Solutions** page.
1. From the **Solutions** page, browse to the page of the **Service Map** solution.
1. On the **ServiceMap** page, on the **Machines** tab, select **SEA-SVR2** to display is service map.
1. Zoom in to review the map illustrating the network ports available on **SEA-SVR2**, select different ports and review the corresponding connection information.
1. For each connection, switch between the **Summary** and **Properties** views, with the latter providing more detailed information regarding connection targets.

## Exercise 5: Deprovisioning the Azure environment

The main tasks for this exercise are to:

1. Start a PowerShell session in Cloud Shell.
1. Delete all Azure resources provisioned in the lab.

#### Task 1: Start a PowerShell session in Cloud Shell

1. On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, open the Cloud Shell pane by selecting the Cloud Shell icon.

#### Task 2: Delete all Azure resources provisioned in the lab

1. From the Cloud Shell pane, run the following command to list all resource groups created in this lab:

   ```powershell
   Get-AzResourceGroup -Name 'AZ801-L09*'
   ```

   > **Note**: Verify that the output contains only the resource groups you created in this lab. These groups will be deleted in this task.

1. Run the following command to delete all resource groups you created in this lab:

   ```powershell
   Get-AzResourceGroup -Name 'AZ801-L09*' | Remove-AzResourceGroup -Force -AsJob
   ```

   >**Note**: The command executes asynchronously (as determined by the *-AsJob* parameter). So while you'll be able to run another PowerShell command immediately afterwards within the same PowerShell session, it will take a few minutes before the resource groups are actually removed.


#### Review

In this lab, you have:

- Prepared a monitoring environment.
- Configured monitoring of on-premises servers.
- Configured monitoring of Azure VMs.
- Evaluated monitoring services.
