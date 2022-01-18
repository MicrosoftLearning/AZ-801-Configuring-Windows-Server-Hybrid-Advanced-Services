---
lab:
    title: 'Lab: Implementing failover clustering'
    module: 'Module 3: High availability in Windows Server'
---

# Lab: Implementing failover clustering

## Scenario

As the business of Contoso, Ltd. grows, it's becoming increasingly important that many of the applications and services on its network are always available. Contoso has many services and applications that must be available to internal and external users who work in different time zones around the world. Many of these applications can't be made highly available by using Network Load Balancing (NLB). Therefore, you should use a different technology to make these applications highly available.

As one of the senior network administrators at Contoso, you're responsible for implementing failover clustering on the servers that are running Windows Server to provide high availability for network services and applications. You're also responsible for planning the failover cluster configuration and deploying applications and services on the failover cluster.

## Objectives

After completing this lab, you'll be able to:

- Configure a failover cluster.
- Deploy and configure a highly available file server on the failover cluster.
- Validate the deployment of the highly available file server.

## Estimated time: **60 minutes**

## Lab setup

Virtual machines: **AZ-801T00A-SEA-DC1**, **AZ-801T00A-SEA-SVR1**, and **AZ-801T00A-SEA-SVR2** must be running. Other VMs can be running, but they aren't required for this lab.

> **Note**: **AZ-801T00A-SEA-DC1**, **AZ-801T00A-SEA-SVR1**, and **AZ-801T00A-SEA-SVR2** virtual machines are hosting the installation of **SEA-DC1**, **SEA-SVR1**, and **SEA-SVR2**

1. Select **SEA-SVR2**.
1. Sign in using the following credentials:

   - Username: **Administrator**
   - Password: **Pa55w.rd**
   - Domain: **CONTOSO**

For this lab, you'll use the available VM environment.

## Exercise 1: Configuring iSCSI storage

### Scenario

Contoso has important applications and services that it wants to make highly available. Some of these services can't use NLB, so you have decided to implement failover clustering. You decide to use Internet Small Computer System Interface (iSCSI) storage for failover clustering. First, you'll configure iSCSI storage to support your failover cluster.

The main tasks for this exercise are to:

- Install Failover Clustering.
- Configure iSCSI virtual disks.

#### Task 1: Install Failover Clustering

1. On **SEA-SVR2**, start Windows PowerShell as administrator.
1. On **SEA-SVR2**, use Windows PowerShell to install the **Failover-Clustering** feature including management tools on **SEA-SVR1** and **SEA-SVR2**.
1. On **SEA-SVR2**, use Windows PowerShell to install the **FS-iSCSITarget-Server** feature on **SEA-DC1**.
 
#### Task 2: Configure iSCSI virtual disks

> **Important:** The lab uses **SEA-DC1**, which serves as an Active Directory Domain Services (AD DS) domain controller to host shared iSCI storage for a Windows Server-based cluster. This is not meant to represent in any way a recommended configuration but is done to simplify the lab configuration and minimize the number of lab virtual machines. In any production environment, domain controllers should not be used to host shared storage for failover clusters. Instead, such storage should be hosted on highly available infrastructure. 

1. On **SEA-SVR2**, start two more Windows PowerShell windows as administrator.
1. Establish a PowerShell Remoting session to **SEA-DC1** and **SEA-SVR1**, respectively, by using the second and third Windows PowerShell window.
1. Create three iSCSI virtual disks on **SEA-DC1** by using the PowerShell Remoting session to **SEA-DC1** to create the **C:\\Storage** directory and run the **New-IscsiVirtualDisk** cmdlet with the following parameters:

   - Disk1:
      - Storage location: **C:\\Storage**
      - Disk name: **Disk1**
      - Size: **10 GB**
   - Disk2:
      - Storage location: **C:\\Storage**
      - Disk name: **Disk2**
      - Size: **10 GB**
   - Disk3:
      - Storage location: **C:\\Storage**
      - Disk name: **Disk3**
      - Size: **10 GB**

1. Start the iSCSI initiator (MSiSCSI) service on **SEA-SVR2** and **SEA-SVR1** and configure it to start automatically by using the local Windows PowerShell session to **SEA-SVR2** and the PowerShell Remoting session to **SEA-SVR1** to run the **Start-Service** and **Set-Service** cmdlets.
1. Create an iSCSI target on **SEA-DC1** by using the PowerShell Remoting session to **SEA-DC1** to run the **New-IscsiServerTarget** cmdlet with the following parameters:

   - Target name: **ISCSI-L03**
   - InitiatorsIds: 
      - **"IQN:iqn.1991-05.com.microsoft:sea-svr1.contoso.com"**
      - **"IQN:iqn.1991-05.com.microsoft:sea-svr2.contoso.com"**

### Results

After completing this exercise, you should have successfully installed the Failover Clustering feature on **SEA-SVR1** and **SEA-SVR2** as well as initialized iSCSI components on **SEA-DC1**, **SEA-SVR1**, and **SEA-SVR2**.

## Exercise 2: Configuring a failover cluster

### Scenario

In this exercise, you'll prepare for cluster installation and then create a cluster.

The main tasks for this exercise are to:

1. Connect clients to the iSCSI targets.
1. Initialize the disks.
1. Validate and create a failover cluster.

#### Task 1: Connect clients to the iSCSI targets

1. On **SEA-SVR2**, mount the iSCSI disks on **SEA-DC1** by using the **Windows PowerShell** window hosting PowerShell Remoting session to **SEA-DC1**, to run the **Add-IscsiVirtualDiskTargetMapping** cmdlet.
1. On **SEA-SVR2**, connect to the iSCSI Target hosted on **SEA-DC1** from **SEA-SVR2** by using the local Windows PowerShell session to run the following commands:

   ```powershell
   New-iSCSITargetPortal -TargetPortalAddress SEA-DC1.contoso.com  
   Connect-iSCSITarget -NodeAddress iqn.1991-05.com.microsoft:sea-dc1-iSCSI-L03-target
   Get-iSCSITarget | fl
   ```

   > **Note:** Verify that after you run the last command, the value for the **IsConnected** variable is True.

1. On **SEA-SVR2**, connect to the iSCSI Target hosted on **SEA-DC1** from **SEA-SVR1** by using the PowerShell Remoting session to **SEA-SVR1** to run the following commands:

   ```powershell
   New-iSCSITargetPortal -TargetPortalAddress SEA-DC1.contoso.com  
   Connect-iSCSITarget -NodeAddress iqn.1991-05.com.microsoft:sea-dc1-iSCSI-L03-target
   Get-iSCSITarget | fl
   ```

   > **Note:** Verify that after you run the last command, the value for the **IsConnected** variable is True.


#### Task 2: Initialize the disks

1. On **SEA-SVR2**, list the local disks by using the local Windows PowerShell session to run the **Get-Disk** cmdlet.
1. On **SEA-SVR2**, initialize the three iSCSI disks with the following settings by using the local Windows PowerShell session:

   - PartitionStyle: **MBR**
   - New-Partition Size: **5GB**
   - File System : **NTFS**
   - Assign drive letters: **E**, **F**, and **G**, respectively.

#### Task 3: Create a failover cluster

1. On **SEA-SVR2**, create a failover cluster named **SEA-CL03** with the IP address set to **172.16.10.125** and **SEA-SVR2.contoso.com** as the first node by using the local Windows PowerShell session.
1. On **SEA-SVR2**, add the **SEA-SVR1** as the second node to the newly created cluster by using the local Windows PowerShell session.

### Results

After completing this exercise, you should have configured disks and created a failover cluster.

## Exercise 3: Deploying and configuring a highly available file server

### Scenario

At Contoso, file services are important services that must be made highly available. After you have created a cluster infrastructure, you decide to configure a highly available file server and then implement settings for failover and failback.

The main tasks for this exercise are to:

1. Add the file server application to the failover cluster.
1. Add a shared folder to a highly available file server.
1. Configure the failover and failback settings.

#### Task 1: Add the file server application to the failover cluster

1. On **SEA-SVR2**, open the **Failover Cluster Manager** console and verify that you are automatically connected to the **SEA-CL03.contoso.com** cluster.
1. In the **Nodes** node, verify that both of the **SEA-SVR2** and **SEA-SVR1** nodes are running.
1. In the **Storage** node, select **Disks**, and then verify that three cluster disks are online.
1. Add **File Server** as a cluster role with the **File Server for general use** option and the following settings:

   - Client Access Name: **FSCluster**
   - Address: **172.16.0.130**
   - Storage: **Cluster Disk 1, Cluster Disk 2**

#### Task 2: Add a shared folder to a highly available file server

1. On **SEA-SVR2**, in the **Failover Cluster Manager** console, add a file share to the **FSCluster** role with the following settings (leave all others with the default values):

   - File share profile: **SMB Share - Quick**
   - Name: **Docs**

#### Task 3: Configure the failover and failback settings

1. On **SEA-SVR2**, in the **Failover Cluster Manager** console, use the **Properties** dialog box of the **FSCluster** cluster role to configure the following settings:

   - Failback: **between 4 and 5 hours**
   - Preferred owners: **SEA-SVR2** and **SEA-SVR1** with **SEA-SVR1** on the top of the list

### Results

After completing this exercise, you should have configured a highly available file server.

## Exercise 4: Validating the deployment of the highly available file server

### Scenario

In implementing a failover cluster, you want to perform failover and failback tests. Additionally, you want to change the witness disk in the quorum.

The main tasks for this exercise are to:

1. Validate the highly available file server deployment.
1. Validate the failover and quorum configuration for the File Server role.

#### Task 1: Validate the highly available file server deployment

1. On **SEA-SVR2**, open File Explorer and verify that you can access the **\\\\FSCluster\\Docs** share.
1. Create a test text document in the share.
1. On **SEA-SVR2**, use the **Failover Cluster Manager** console to move the **FSCluster** role to another node.
1. On **SEA-SVR2**, in File Explorer, verify that you can still access the **\\\\FSCluster\\Docs** share.

#### Task 2: Validate the failover and quorum configuration for the File Server role

1. On **SEA-SVR2**, in the **Failover Cluster Manager** console, identify the current owner for the **FSCluster** role.
1. Stop the Cluster service on the node, which is the current owner of the **FSCluster** role.
1. On **SEA-SVR2**, use File Explorer to verify that the **\\\\FSCluster\\Docs** share is still available.
1. On **SEA-SVR2**, use the **Failover Cluster Manager** console to start the Cluster service on the node on which you stopped it in step 2.
1. On **SEA-SVR2**, in the **Failover Cluster Manager** console, configure cluster quorum for **FSCluster** by using the default settings.
1. In the **Failover Cluster Manager** console, browse to the **Disks** node and take the disk marked as **witness disk in Quorum** offline.
1. On **SEA-SVR2**, use File Explorer to verify that the **\\\\FSCluster\\Docs** share is still available.
1. Bring the witness disk online.

### Results

After completing this exercise, you should have validated high availability with Failover Clustering.

