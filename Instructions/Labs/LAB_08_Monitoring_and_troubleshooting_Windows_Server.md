---
lab:
    title: 'Lab: Monitoring and troubleshooting Windows Server'
    module: 'Module 8: Monitoring, performance, and troubleshooting'
---

# Lab: Monitoring and troubleshooting Windows Server

## Scenario

Contoso, Ltd. is a global engineering and manufacturing company with its head office in Seattle, Washington, in the United States. An IT office and datacenter are in Seattle to support the Seattle location and other locations. Contoso recently deployed a Windows Server server and client infrastructure.

Because the organization deployed new servers, it's important to establish a performance baseline with a typical load for these new servers. You've been asked to work on this project. Additionally, to make the process of monitoring and troubleshooting easier, you decided to perform centralized monitoring of event logs.

**Note:** An **[interactive lab simulation](https://mslabs.cloudguides.com/guides/AZ-801%20Lab%20Simulation%20-%20Monitoring%20and%20troubleshooting%20Windows%20Server)** is available that allows you to click through this lab at your own pace. You may find slight differences between the interactive simulation and the hosted lab, but the core concepts and ideas being demonstrated are the same. 

## Objectives

After completing this lab, you'll be able to:

- Establish a performance baseline.
- Identify the source of a performance problem.
- Review and configure centralized event logs.

## Estimated time: **40 minutes**

## Lab setup

Virtual machines: **AZ-801T00A-SEA-DC1** and **AZ-801T00A-SEA-SVR2** must be running. Other VMs can be running, but they aren't required for this lab.

> **Note**: **AZ-801T00A-SEA-DC1** and **AZ-801T00A-SEA-SVR2** virtual machines are hosting the installation of **SEA-DC1** and **SEA-SVR2**.

1. Select **SEA-SVR2**.
1. Sign in using the following credentials:

   - Username: **Administrator**
   - Password: **Pa55w.rd**
   - Domain: **CONTOSO**

For this lab, you'll use the available VM environment.

## Exercise 1: Establishing a performance baseline

### Scenario

In this exercise, you'll use Performance Monitor on the server and create a baseline by using typical performance counters.

The main tasks for this exercise are to:

1. Create and start a data collector set.
1. Create a typical workload on the server.
1. Analyze the collected data.

> **Note**: After starting the Data Collector Set, there might be a delay of 10 minutes for the results to appear.

#### Task 1: Create and start a data collector set

1. On **SEA-SVR2**, open Performance Monitor.
1. Use Performance Monitor to create a new **User Defined** data collector set with the following settings:

   - Name: **SEA-SVR2 Performance**
   - Create: **Create manually (Advanced)**
   - Type of data: **Performance counter**
   - Performance counters (using the default instance options):

      - **Memory\\Pages/sec**
      - **Network Interface\\Bytes Total/sec**
      - **PhysicalDisk\\% Disk Time**
      - **PhysicalDisk\\Avg. Disk Queue Length**
      - **Processor\\% Processor Time**
      - **System\\Processor Queue Length**

   - Sample interval: **1** second

1. In Performance Monitor, start the **SEA-SVR2 Performance** data collector. 

#### Task 2: Create a typical workload on the server

1. On **SEA-SVR2**, start Windows PowerShell as administrator.
1. To emulate a typical workload, at the Windows PowerShell command prompt, run the following commands:


   ```powershell
   fsutil file createnew bigfile 104857600
   Copy-Item -Path .\bigfile -Destination \\SEA-DC1.contoso.com\c$\ -Force
   Copy-Item -Path \\SEA-DC1.contoso.com\c$\bigfile -Destination .\bigfile2 -Force
   Remove-Item -Path .\bigfile* -Force
   Remove-Item -Path \\SEA-DC1.contoso.com\c$\bigfile -Force
   ```

1. Leave the Windows PowerShell window open.

#### Task 3: Analyze the collected data

1. On **SEA-SVR2**, switch to Performance Monitor.
1. Stop the **SEA-SVR2 Performance** data collector set.
1. In Performance Monitor, in the navigation pane, browse to **Reports**, **User Defined**, **SEA-SVR2**, **SEA-SVR2\_DateTime-000001**, and then review the report data by using the Report view.
1. Record the values that are listed in the report for later analysis. Recorded values include:

   - **Memory\\Pages/sec**
   - **Network Interface\\Bytes Total/sec**
   - **PhysicalDisk\\% Disk Time**
   - **PhysicalDisk\\Avg. Disk Queue Length**
   - **Processor\\% Processor Time**
   - **System\\Processor Queue Length**

### Results

After this exercise, you should have established a baseline for performance-comparison purposes.

## Exercise 2: Identifying the source of a performance problem

### Scenario

In this exercise, you'll simulate a load to represent the system in live usage, gather performance data by using your data collector set, and then determine the potential cause of the performance problem.

The main tasks for this exercise are to:

1. Create additional workload on the server.
1. Capture performance data by using a data collector set.
1. Remove the workload and review the performance data.

#### Task 1: Create additional workload on the server

1. On **SEA-SVR2**, open File Explorer.
1. In File Explorer, browse to **C:\Labfiles\Lab08** and launch **CPUSTRES64**.
1. Configure the first highlighted task to run **BUSY (75%)**.

   > **Note**: **CPUSTRES64.EXE** is a SysInternals utility that can be used to simulate CPU activity by running up to 64 threads in a loop.

#### Task 2: Capture performance data by using a data collector set

1. On **SEA-SVR2**, switch to Performance Monitor.
1. In Performance Monitor, browse to **Data Collector Sets**, **User Defined**, and then in the results pane, start the **SEA-SVR2 Performance** data collector set.

   > **Note**: Wait 1 minute to allow the data capture to occur.

#### Task 3: Remove the workload and review the performance data

1. On **SEA-SVR2**, close CPUSTRES64.
1. Switch to Performance Monitor.
1. Stop the **SEA-SVR2 Performance** data collector set.
1. In Performance Monitor, in the navigation pane, browse to **Reports**, **User Defined**, **SEA-SVR2**, **SEA-SVR2\_DateTime-000002**, and then review the report. 
1. Record the values that are listed in the report:

   - **Memory\\Pages/sec**
   - **Network Interface\\Bytes Total/sec**
   - **PhysicalDisk\\% Disk Time**
   - **PhysicalDisk\\Avg. Disk Queue Length**
   - **Processor\\% Processor Time**
   - **System\\Processor Queue Length**

### Results

After this exercise, you should have used performance tools to identify a potential performance bottleneck.

### Exercise 3: Viewing and configuring centralized event logs

### Scenario

In this exercise, you'll use **SEA-SVR2** to collect application event log entries from **SEA-DC1**. 

The main tasks for this exercise are to:

1. Configure subscription prerequisites.
1. Create a subscription and verify the results.

#### Task 1: Configure subscription prerequisites

1. On **SEA-SVR2**, switch to Windows PowerShell.
1. To enable creating and managing subscriptions of events forwarded to **SEA-SVR2**, run the following command:

   ```powershell
   WECUtil qc /q
   ```

1. To ensure that the event source and collector have their local date and time synchronized, run the following command:

   ```powershell
   w32tm /resync /computer:SEA-DC1.contoso.com
   ```

1. To allow WinRM connectivity in case of Kerberos authentication issues, run the following command:

   ```powershell
   Set-Item WSMan:localhost\client\trustedhosts -Value *.contoso.com -Force
   ```

1. To establish a PowerShell Remoting session to **SEA-DC1**, run the following command:

   ```powershell
   Enter-PSSession -ComputerName SEA-DC1.contoso.com
   ```

1. To ensure that Windows Remote Management (WinRM) is enabled on **SEA-DC1**, run the following command:

   ```powershell
   winrm qc
   ```

   > **Note**: Verify that the WinRM service is already running and that it's set up for remote management.

1. To ensure that the relevant Windows Defender Firewall with Advanced Security rules are enabled on **SEA-DC1**, run the following command:

   ```powershell
   Set-NetFirewallRule -DisplayGroup 'Remote Event Log Management' -Enabled True -Profile Domain -PassThru
   ```

   > **Note**: Leave the Windows PowerShell window open.

1. On **SEA-SVR2**, open **Active Directory Users and Computers**.
1. In the **Active Directory Users and Computers** console, add the **SEA-SVR2** computer account to the **Event Log Readers** group.

#### Task 2: Create a subscription and verify the results

1. On **SEA-SVR2**, open **Event Viewer**.
1. Create a new subscription with the following properties:

   - Name: **SEA-DC1 Events**
   - Computers: **SEA-DC1**
   - Collector: **initiated**
   - Events: **Critical**, **Warning**, **Information**, and **Error**
   - Logged: **Last 24 hours**
   - Logs: **Application** and **System** **Windows Logs**

1. On **SEA-SVR2**, switch to the **Event Viewer** window, and then expand **Windows Logs** in the navigation pane.
1. Select **Forwarded Events** and verify that the forwarded events include those generated on **SEA-DC1**.
