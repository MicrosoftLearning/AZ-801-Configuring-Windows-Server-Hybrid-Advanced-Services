---
lab:
    title: 'Lab: Implementing operational monitoring in hybrid scenarios'
    type: 'Answer Key'
    module: 'Module 9 - Implementing operational monitoring in hybrid scenarios'
---

# Lab answer key: Implementing operational monitoring in hybrid scenarios

## Exercise 1: Preparing a monitoring environment

#### Task 1: Deploy an Azure virtual machine

1. Connect to **SEA-SVR2**, and if needed, sign in with the credentials provided by your instructor.
1. On **SEA-SVR2**, start Microsoft Edge, go to the Azure portal at `https://portal.azure.com/`, and sign in by using the credentials of a user account with the Owner role in the subscription you'll be using in this lab.
1. On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, open the Azure Cloud Shell pane by selecting the Cloud Shell button in the Azure portal.
1. If prompted to select either **Bash** or **PowerShell**, select **PowerShell**.

   > **Note:** If this is the first time you're starting Cloud Shell and you're presented with the **You have no storage mounted** message, select the subscription you are using in this lab, and then select **Apply**.

1. In the toolbar of the Cloud Shell pane, select the **Upload/Download files** icon, in the drop-down menu select **Upload**, and upload the file **C:\\Labfiles\\Lab09\\L09-rg_template.json** into the Cloud Shell home directory.
1.	Repeat the previous step to upload the **C:\Labfiles\Lab09\L09-rg_template.parameters.json** file into the Cloud Shell home directory.
1. To create the resource group that will be hosting the lab environment, in the **PowerShell** session in the Cloud Shell pane, enter the following commands, and after entering each command, press Enter (replace the `<Azure_region>` placeholder with the name of an Azure region where you intend to deploy resources in this lab):

   >**Note**: You can use the **(Get-AzLocation).Location** command to list the names of available Azure regions:

   ```powershell 
   $location = '<Azure_region>'
   $rgName = 'AZ801-L0901-RG'
   New-AzResourceGroup -ResourceGroupName $rgName -Location $location
   ```

1. To deploy an Azure virtual machine (VM) into the newly created resource group, enter the following command and press Enter:

   ```powershell 
   New-AzResourceGroupDeployment -Name az801l0901deployment -ResourceGroupName $rgName -TemplateFile ./L09-rg_template.json -TemplateParameterFile ./L09-rg_template.parameters.json -AsJob
   ```
1. When prompted, insert the credentials provided by your instructor.

   >**Note**: Do not wait for the deployment to complete but instead proceed to the next task. The deployment should take about 3 minutes.

#### Task 2: Register the Microsoft.Insights and Microsoft.AlertsManagement resource providers

1. To register the Microsoft.Insights and Microsoft.AlertsManagement resource providers, on **SEA-SVR2**, from the Cloud Shell pane, enter the following commands, and after entering each command, press Enter.

   ```powershell
   Register-AzResourceProvider -ProviderNamespace Microsoft.Insights
   Register-AzResourceProvider -ProviderNamespace Microsoft.AlertsManagement
   ```

   >**Note**: To verify the registration status, you can use the **Get-AzResourceProvider** cmdlet.

1. Close Cloud Shell.

   >**Note**: Do not wait for the registration process to complete but instead proceed to the next task. The registration should take about 3 minutes.

#### Task 3: Create and configure an Azure Log Analytics workspace

1. On **SEA-SVR2**, in the Azure portal, in the **Search resources, services, and docs** text box, in the toolbar, search for and select **Log Analytics workspaces**, and then, from the **Log Analytics workspaces** page, select **+ Create**.
1. On the **Basics** tab of the **Create Log Analytics workspace** page, enter the following settings, select **Review + Create**, and then select **Create**:

   | Settings | Value |
   | --- | --- |
   | Subscription | **the name of the Azure subscription you are using in this lab** |
   | Resource group | the name of a new resource group **AZ801-L0902-RG** |
   | Log Analytics Workspace | **any unique name** |
   | Region | **the name of the Azure region into which you deployed the virtual machine in the previous task** |

   >**Note**: Wait for the deployment to complete. The deployment should take about 1 minute.

## Exercise 2: Configuring monitoring of on-premises servers

#### Task 1: Install the Azure Connect Machine Agent

1. On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal , In the Search bar of the Azure portal, type **Arc**, then select **Azure Arc**. 
1. In the navigation pane under **Azure Arc resources**, select **Machines**.
1.	Select **+ Add/Create**, and in the dropdown, select **Add a machine**. 
1.	Select **Generate script** from the **Add a single server** section. 
1.	In the **Add a server with Azure Arc** page, under **Project details**, select the Resource group you created earlier (**AZ801-L0901-RG**). 
1.	Under **Server details**, select the name of the Azure region into which you deployed the virtual machine in the previous task.
1.	Review the SQL Server and Connectivity options. Uncheck **Connect SQL Server**, accept the remaining default values and select **Next**. 
1.	In the **Tags** tab, review the default available tags and Select **Next**. 
1.	In the **Add a server with Azure Arc** tab, scroll down and select the **Download** button.

      >**Note**: if your browser blocks the download, allow it in the Microsoft Edge browser; select the ellipsis button (…), and then select **Keep**. 

1. Right-click the **Windows Start** button and select **Windows PowerShell (Admin)**.

   >If you get a UAC prompt, enter the credentials provided by your instructor. 
 
1. Type **cd C:\Users\Administrator.CONTOSO\Downloads** or enter the folder location where you downloaded the script.  
1. Enter the following command to change the execution policy:

   ```powershell 
   Set-ExecutionPolicy -ExecutionPolicy Unrestricted
   ```
1. Enter A for Yes to All and press Enter. 
1. Enter the following command and press **Enter**. 

   ```powershell 
   .\OnboardingScript.ps1
   ```
1. Enter **R** to **Run once** and press **Enter** (this may take a couple minutes).
The setup process opens a new Microsoft Edge browser tab to authenticate the Azure Arc agent. Select your administrator account and wait for the message **Authentication complete**. Return to Windows PowerShell and wait for the installation to complete before closing the window.
1. Return to the Azure portal page where you downloaded the script and select **Close**.
1. Close the **Add servers with Azure Arc** page and navigate back to the **Azure Arc Machines** page.
1. Select **Refresh** until the **SEA-SVR2** server name appears and the Status is  **Connected** in the Arc console.

#### Task 2: Enable Monitoring using Insights

1.	Navigate to Azure Arc from the Azure portal search window, select **SEA-SVR2** Azure Arc machine, and open the **SEA-SVR2** Arc machine.
1.	In the navigation pane, under **Monitoring** select **Insights**, and select **Enable**.
1.	On the **Monitoring configuration** page, under **Data collection rule**, select **Create New**.
1.	In the **Create new rule** page, enter the following settings and then select **create**:

      | Settings | Value |
      | --- | --- |
      | **Data collection rule name** | Arc |
      | **Enable processes and dependencies (Map)** | Enabled |
      | **Subscription** | the name of the Azure subscription you are using in this lab |
      | **Log Analytics Workspace** | the name of the Log Analytics Workspace you created in this lab |

1.	Select **Configure**.

   >**Note**:This deployment may take several minutes. Wait until the deployment completes before continuing with the next exercise.

#### Task 3: Enable monitoring and diagnostic settings

1.	On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, in the Search bar of the Azure portal, search for and select **Data collection rules**.
1.	In the **Data collection rules** page, select the **MSVM1-Arc** data collection rule you created earlier.
1.	Under **Configuration**, select **Data sources** and select **Performance counters**.
1.	In the **Add data source** page, in the **Basic** tab, select **all** Performance counters.
1.	Change the sample rate for each counter to 10 seconds and select **Save**.
1.	Under **Monitoring**, select **Diagnostic settings** and select **+ Add Diagnostic setting**.
1.	Type **ArcDiagSettings** for the name of the **Diagnostic setting**.
1.	Under **Metrics**, select **All metrics** and under **Destination details**, select **Send to Log Analytics workspace**.
1.	Use the name of the Azure subscription you are using in this lab and the Log Analytics workspace you created earlier. Select **Save** and close the **Diagnostic settings** window.

## Exercise 3: Evaluating monitoring services

#### Task 1: Review Azure Monitor monitoring and alerting functionality

1.	On **SEA-SVR2**, in the Azure portal, browse to the **Monitor | Alerts** page.
1.	Select **+ Create** and then select **Alert rule**.
1.	In the **Select a resource** page, in the **Browse** tab, expand **AZ801-L0901-RG** and select the **SEA-SVR2** Azure Arc machine. 
1. Select **Apply**.
1.	Select **Next: Condition >** and in the **Create an alert rule** page, in the **Select a signal** drop-down, select **Custom log search**.
1.	In the query window, copy and paste the following KQL query:

      ```kql
      // Chart CPU usage trends by computer
      // Calculate CPU usage patterns over the last hour, chart by percentiles.
      InsightsMetrics
      | where TimeGenerated > ago(1h)
      | where Origin == "vm.azm.ms"
      | where Namespace == "Processor"
      | where Name == "UtilizationPercentage"
      | summarize avg(Val) by bin(TimeGenerated, 5m), Computer //split up by computer
      | render timechart
      ```

1.	Select **Run** and view the data in the Results and the **Chart** tabs.
1.	Select **Continue Editing Alert**.
1.	In the **Create an alert rule** page, under **Measurement**, specify the following settings, and leave the other settings with their default values:

      | Settings | Value |
      | --- | --- |
      | **Aggregation granularity** | 1 minute |

1.	Under **Alert logic**, enter the following settings and then select **Next: Actions >**.

      | Settings | Value |
      | --- | --- |
      | **Operator** | Greater than |
      | **Threshold value** | 10 |
      | **Frequency of evaluation** | 1 minute |

1. In the **Action** tab of the **Create an alert rule** page, in the **select action** section, select **use action groups**, and in the **select action groups** page select **create action group**.
1. In the **Create action group** page, enter the following settings and then select **Next: Notifications >**.

      | Settings | Value |
      | --- | --- |
      | **Subscription** | the name of the Azure subscription you are using in this lab |
      | **Resource group** | AZ801-L0901-RG |
      | **Region** | Leave the default setting |
      | **Action group name** | any unique name |
      | **Display name** | any unique name (12 characters or less) |

1. In the **Create action group** page, under **Notification type**, select **Email Azure Resource Manager Role**, and then in the **Name** field, type **Admin email**.
1. In the **Email Azure Resource Manager Role** page, select **Owner** from the drop-down list, and click **Ok**.
1.	In the **Create action group** page, select **Review + create**, and then **Create**.

      >**Note**: It can take up to 10 minutes for a metric alert rule to become active.

1.	In the **Create alert rule** page, select **Next: Details >**.
1.	Leave the default settings, but under **Alert rule details**, type **High CPU alert** for the alert rule name and description.
1.	Select **Review + Create**, then select **Create**.
1.	Browse to the **SEA-SVR2** Azure Arc machine, Right-click the **Windows Start** button and select **Windows PowerShell (Admin)**.
1. Enter the following command and click **Enter**:

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

1.	On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, open another tab, browse to the **Monitor** page, and then select **Alerts**.

      >**Note**: You may have to wait for a few minutes and refresh the Monitor | Alerts page.

## Exercise 4: Configuring monitoring of Azure VMs

#### Task 1: Configure diagnostic settings and VM Insights

1.	On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, in the Search bar of the Azure portal, search for **Virtual machines** and select **az801l09-vm0**.
1.	On the **az801l09-vm0** page, under **Monitoring**, select **Diagnostic settings**.
1.	On the **Diagnostic settings** tab, select the  diagnostics storage account from the drop-down list, and then select **Enable guest-level monitoring**.

      >**Note**: Wait for the operation to take effect. This might take about 3 minutes.

1.	Switch to the **Performance counters** tab of the **az801l09-vm0 | Diagnostic settings** page and review the available counters.

      >**Note**: By default, CPU, memory, disk, and network counters are enabled. You can switch to the **Custom view** for a more detailed listing.

1.	On the **az801l09-vm0 | Diagnostic settings** page, on the **Logs** tab, review the available event log collection options.

      >**Note**: By default, log collection includes critical, error, and warning entries from the Application Log and System log, as well as Audit failure entries from the Security log. You can customize them from the **Logs** tab.

#### Task 2: Enable VM Insights

1.	From the **Monitoring** section on the vertical menu on the left side, browse to the **az801l09-vm0 | Insights** page.
1.	On the **az801l09-vm0 | Insights** page, select **Enable**.

      >**Note**: This setting provides the Azure VM Insights functionality. VM Insights is an Azure Monitor solution that facilitates monitoring performance and health of both Azure VMs and on-premises computers running Windows or Linux.

1.	In the **Monitoring configuration** page, under4 **Data Collection rule**, select **Create New**, and in the name field type **AZ801vm0**.
1.	Under **Processes and dependencies**, select **Enable processes and dependencies (Map)**.
1.	Leave the name of the Azure subscription you are using in this lab.
1.	From the **Log Analytics workspaces** drop-down menu, select the Log Analytics Workspace that you created earlier.
1.	Select **Create**, then **Configure**.

      >**Note**: This option enables monitoring and alerting capabilities using health model, which consists of a hierarchy of health monitors built using the metrics emitted by Azure Monitor for VMs.
      This deployment may take some time. Wait for the deployment to complete and return to the process Map before ending the lab. This will allow you to review the process Map data. 

## Exercise 5: Evaluating monitoring services

#### Task 1: Review Azure Monitor monitoring and alerting functionality

1. On **SEA-SVR2**, in the Azure portal, browse to the **Monitor \| Insights** page, and under **Insights**, select **Virtual Machines**. On the **Monitor | Virtual Machines** page, select the **Performance** tab and you should see the **CPU/Memory** utilization and other categories.
1.	On the **Monitor | Alerts** page, select **+ Create**, then select **Alert rule**.
1.	In the **Select a resource** page, expand the **AZ801-L0901-RG** resource group, select  **az801l09-vm0**, and click **Apply**. 
1. Select **Next: Condition >**.
1.	From the **signal** dropdown list, select **Percentage CPU**.
1.	In the **Alert logic** section, specify the following settings (leave others with their default values), and then select **Next: Actions >**:

      | Settings | Value |
      | --- | --- |
      | Threshold type | **Static** |
      | Aggregation type | **Average** |
      | Value is | **Greater than** |
      | Threshold value | **10** |
      | Check every | **1 minute** |
      | Lookback period | **1 minute** |

1.	On the  **Create an alert rule** page, on the **Actions** tab, select the **+ Create action group** button.
1.	On the **Basics** tab of the **Create an action group** page, specify the following settings (leave others with their default values), and then select **Next: Notifications >**:

      | Settings | Value |
      | --- | --- |
      | Subscription | the name of the Azure subscription you are using in this lab |
      | Resource group | **AZ801-L0902-RG** |
      | Action group name | **az801l09-ag1** |
      | Display name | **az801l09-ag1** |

1.	On the **Notifications** tab of the **Create an action group** page, in the **Notification type** drop-down list, select **Email/Azure Resource Manager Role**. In the **Name** text box, type **admin email notification**, and then select the **Edit details** (pencil) icon.
1.	On the **Email Azure Resource Manager Role** select **Contributor**, click **OK**.
1.	In the **Create action group** page, select **Review + create**, and then **Create**.

      >**Note**: It can take up to 10 minutes for a metric alert rule to become active.

1.	Back on the **Create an alert rule** page, select **Next: Details >**, in the **Alert rule details** section, specify the following settings (leave others with their default values):

      | Settings | Value |
      | --- | --- |
      | Resource group | **AZ801-L0902-RG** |
      | Severity | **3 - Informational** |
      | Alert rule name | **CPU Percentage above the test threshold** |
      | Description | **CPU Percentage above the test threshold** |
      | Enable upon creation | **Yes** |

      >**Note**: If you don't see the field **Enable upon creation**, expand the **Advanced options** section.

1.	Select **Review + Create**, then select **Create**.
1.	In the Azure portal, search for and select **Virtual machines**, and on the **Virtual machines** page, select **az801l09-vm0**.
1. On the **az801l09-vm0** page, in the **Operations** section, select **Run command**, and then select **RunPowerShellScript**.
1. On the **Run Command** page, select **RunPowerShellScript**, enter the following commands and select **Run** to increase the **CPU utilization** within the target operating system.

   >**Note**: Copy the script to Notepad first and then paste it into the script window before executing the script.

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

   >**Note**: This should increase the CPU utilization above the threshold of the newly created alert rule. This may take a few minutes.

1.	On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, open another tab, browse to the **az801l09-vm0** virtual machine page, and then the **Monitoring | Alerts** page. Note the number of **Sev 3** alerts, and then select the **Sev 3** row.

      >**Note**: You might need to wait for a few minutes and select **Refresh**. If it takes longer, you can simply continue with the lab and return to the **Monitoring | Alerts** page later to view the data.

1.	On the **CPU Percentage above the test threshold** page, review generated alerts. Close the page when you have finished reviewing.


#### Task 2: Review Azure Monitor VM Insights functionality

1. On **SEA-SVR2**, in the Azure portal, browse back to the **az801l09-vm0** virtual machine page.
1. On the **az801l09-vm0** virtual machine page, on the vertical menu on the left side, in the **Monitoring** section, select **Insights**.
1. On the **az801l09-vm0 \| Insights** page, on the **Performance** tab, review the default set of metrics, including logical disk performance, CPU utilization, available memory, as well as bytes sent and received rates.
1. On the **az801l09-vm0 \| Insights** page, select the **Map** tab and review the autogenerated map.
1. On the **az801l09-vm0 \| Insights** page, select the **Health** tab and review its content.

   >**Note**: The availability of health information is dependent on completion of the workspace upgrade.

#### Task 3: Review Azure Log Analytics functionality

1. On **SEA-SVR2**, in the Azure portal, browse back to the **Monitor** page and select **Logs**.
1. In the **New Query 1** page, click **Select scope**. 
1. On the **Select a scope** page, select the **Browse** tab, select the unique workspace you created earlier in this lab, and then select **Apply**.
1. In the query window, paste the following query, select **Run**, and review the resulting chart:

   ```kql
   // Virtual Machine available memory
   // Chart the VM's available memory over the last hour.
   InsightsMetrics
   | where TimeGenerated > ago(1h)
   | where Name == "AvailableMB"
   | project TimeGenerated, Name, Val
   | render timechart
   ```

1. On the **New Query 1** tab, select the **Tables** header, and review the list of tables in the **Azure Resources** section.

   >**Note**: The names of several tables correspond to the solutions you installed earlier in this lab. In particular, **InsightMetrics** is used by Azure VM Insights to store performance metrics.

1. Move the cursor over the **VMComputer** entry, select the **See Preview data** icon, and review the results.

   >**Note**: Verify that the data includes entries for both **az801l09-vm0** and **SEA-SVR2.contoso.com**.

   >**Note**: You might need to wait a few minutes before the update data becomes available.

## Exercise 6: Deprovisioning the Azure environment

#### Task 1: Start a PowerShell session in Cloud Shell

1. On **SEA-SVR2**, in the Microsoft Edge window displaying the Azure portal, open the Cloud Shell pane by selecting the **Cloud Shell** icon.

#### Task 2: Delete all Azure resources provisioned in the lab

1. From the Cloud Shell pane, run the following command to list all resource groups created in this lab:

   ```powershell
   Get-AzResourceGroup -Name 'AZ801-L09*'
   ```

   > **Note**: Verify that the output contains only the resource group you created in this lab. This group will be deleted in this task.

1. Run the following command to delete all resource groups you created in this lab:

   ```powershell
   Get-AzResourceGroup -Name 'AZ801-L09*' | Remove-AzResourceGroup -Force -AsJob
   ```

   >**Note**: The command executes asynchronously (as determined by the *-AsJob* parameter). So, while you'll be able to run another PowerShell command immediately afterwards within the same PowerShell session, it will take a few minutes before the resource groups are actually removed.
