The purpose of this readme is to advise you of changes in Azure which will unfortunately affect some of the labs in AZ-801T00-A, Configuring Windows Server Hybrid Advanced Services. You may already be aware of the fact that the Log Analytics agent, also known as the Microsoft Monitoring Agent (MMA)  has now been retired as of today, August 31, 2024. As a result, the ability to onboard new non-Azure servers to Defender for Servers via Log Analytics workspaces will be removed from both the Inventory and Getting Started blades in Azure. There will also be some impacts as a result of the retiral of Azure Automation Update Management.

This impacts the following labs:
- Lab 02
- Lab 09

The recommendation for servers that have been onboarded previously using the Log Analytics agent is to now connect those machines via Azure Arc-enabled servers. We are currently investigating this solution as an option for these labs. We wanted to assure you that we are working to get these labs updated as quickly as possible. However, this will take a little bit of time to implement, test, and rewrite the lab instructions, as well as going through all of the security and compliance requirements at Microsoft. We need to do this in order to ensure that the Authorized Lab Hosters can successfully deploy the updated lab versions.

For the time being, students won’t be able to perform Lab 02 and Lab 09, and we sincerely apologize for any temporary disruption and inconvenience this may cause.

Of course, content updates will need be made as well so look for that in the near future, but we feel that addressing the lab functionality is the priority we need to focus on first. We will keep you apprised of changes as we get those in place. Please be patient as we work through these issues. 

Thank you,
The Microsoft WWL courseware team
