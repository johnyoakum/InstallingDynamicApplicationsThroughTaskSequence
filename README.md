# Installing Dynamic Applications Through Task Sequence
Dynamically Install Applications using the ConfigMgr Administration Service During a Task Sequence 

In this blog post, I am going to show you how to leverage the ConfigMgr administration service to retrieve all the available applications in your environment and use that list to build a dynamic variable list for applications to be installed. Where this is beneficial is when you have multiple of the same applications in your environment, and you want to be able to install the latest version of that application. 

Let’s first talk about what the ConfigMgr Administration Service is. The ConfigMgr administration service is part of your SMS Provider. It provides API interoperability access over HTTPS. The administration service is a representational state transfer (REST) API based on the Open Data (OData) v4 protocol. It allows you to perform API calls and perform actions against the ConfigMgr site server. There are many uses for this functionality, but for the purposes of this article, we will only be using the ability to get applications. For further information, please see What is the administration service - Configuration Manager | Microsoft Learn. And here is an article on set it up if you want to leverage it through the CMG. How to set up the admin service - Configuration Manager | Microsoft Learn 

There are so many things you can do when you start leveraging dynamic applications. This post covers just the basic way of leveraging them with PowerShell and the administration service. I will not get into making sure that your administration service is set up correctly, just one way how to leverage it. 

It can be a time-consuming task when creating task sequences to add in every application that you want to deploy to an environment. And every time you add an updated version of that application, you must go back into every task sequence and update the application in there so that you are deploying/installing the latest one you packaged up. This can help alleviate a lot of that time you may spend doing just that. This script that is attached will query the administration service for all the applications in your environment and then will create task sequences variables with those applications from that list that you wish to install. The beauty is that we are using wildcard characters to pull all the applications that start with that same name that you choose and then select the latest version from that list and add it to a variable. This means that you will no longer have to worry about modifying your task sequence every time you update/create a new version of the application, thus saving time. The only time you would have to go back into those applications in your Task Sequence is when you want to add or remove applications. 

Here's how to set it up: 

Start by copying and pasting the attached script into your editor of choice 

Modify line 29, adding in the service account password that you will need to access the administration service 

Modify line 30, adding in the domain and username that will be used to access the administration service 

Modify line 31, adding in your ConfigMgr site server FQDN 

Follow the example on line 43 to add in the applications you wish to install 

Run the script and test that the results you are seeing match what you expect to see 

Now let’s add it to our Task sequence. 

Modify line 28 on your script and set Debug to $false 

In your Task Sequence, add a new step above your “Install Applications” step that Runs a PowerShell Script 

Check the radio button that says “Enter a PowerShell script” 
![EnterPowerShellScript](https://github.com/johnyoakum/InstallingDynamicApplicationsThroughTaskSequence/assets/17698593/1807690d-41e3-49ce-a5c7-9e4c351e0616)

Click the Add Script button 

Copy and paste your code into the box pops up and click OK 
![PowershellScript](https://github.com/johnyoakum/InstallingDynamicApplicationsThroughTaskSequence/assets/17698593/1b89e334-adc4-4c3f-a232-ce8c0efd645e)



Change the PowerShell execution policy to “Bypass” 
![ExecutionPolicy](https://github.com/johnyoakum/InstallingDynamicApplicationsThroughTaskSequence/assets/17698593/6191e50f-44f4-41d1-832a-2b07937a34c5)

Now click over to your “Install Applications” step 

Select the radio button for “Install applications according to dynamic variable list 
![DynamicAppChoice](https://github.com/johnyoakum/InstallingDynamicApplicationsThroughTaskSequence/assets/17698593/aeb12ddf-7d33-4a33-bddc-6dee9b05a429)

In the “Base variable name” section, enter “XApplications” 
![BaseVariable](https://github.com/johnyoakum/InstallingDynamicApplicationsThroughTaskSequence/assets/17698593/13045ae5-7944-4e16-9cfd-cfca280221e7)

Click OK on the Task Sequence editor and you are good to go 

As you can imagine, leveraging this process can save you time from having to go in and modify every task sequence and manually adding in the applications one at a time. Now, there is one caveat to all of this that you need to be aware of. All your applications will need to have a check box checked on them. It is found on the Application Properties and it is called “Allow this application to be installed from the Install Application task sequence action without being deployed”. 
![ApplicationAvailability](https://github.com/johnyoakum/InstallingDynamicApplicationsThroughTaskSequence/assets/17698593/30e69aa6-ad99-4e49-a250-acfad8ec0471)

