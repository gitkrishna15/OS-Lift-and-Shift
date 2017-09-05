# OS-Lift-and-Shift
Lift and Shift any OS workload to Oracle Cloud (IaaS)

Who can benefit/leverage?

The below process will help in guiding you any Operating system Workload to Oracle Public Cloud.

If you have a Application/Server which is old/new and you find it uncomfortable/lengthy to shift it to cloud the traditional way, this process will help you image your OS and move to oracle cloud (IaaS) with everything in place as it is.

Sucessfully Tested under below Environment:

 1:  Operating system is installed on 1 disk(LUN) (eg: /dev/sda )
 
 2:  Tested and updated script to work only on EL 6 and EL 7
 
 3:  Considered Network-Adapter to have boot PROTOCOL as DHCP and adapter type as Ethernet

High Level Explaination of the Entire Process

STEP 1:

The First part of the Process is to prepare the Source OS server. 

As part of the Pre-steps, 

Shutdown any services running on the server (application/DB)

Execute the script to take care of all below steps part of STEP 1:

Create an OPC user ( for future enhancement )

Disbale Firewall for the time the process in running

Make changes to Network components which would help in bringing the system up in Cloud Infrastrucure

Backup all files affected in the process for easy rollback

STEP 2:

The next stage of the process is to create a raw image of the entire disk and compress it to tar.gz format

This step would require space (same as the size of disk to store the raw image and its compressed tar image)

Option 1:

Make sure you have enough space on your Windows Workstation ( if required plugin External Hardrive for the space required)

Execute the Script provided which will create the raw image and prepare tar.gz image

Option 2:

If enough space on separate disk/LUN is available in Source OS, continue to execute the script with correct option

Once the image tar.gz file is available use any of the tools(WinSCP/Filezilla/scp) to copy the image over to System/Server where GUI browser is available to upload the image to Oracle Cloud


STEP 3:

Once the image is created and moved. Go back to source server and run the script in Step 1 with input parameter as "rollback"
This will rollback all changes


STEP 4:

Once the image file is available.

Open a browser and access the Oracle public cloud link (cloud.oracle.com)

Use your cloud credential to login

Once logged in select "Compute" -> "Open Service Console"

Then select "Images" tab and click on "Upload Image"

Browse and select the image (<filename>.tar.gz) and upload

Once the upload is complete, click on "Associate Image"

Select your uploaded image and Provide a name to it

Once done, the uploaded image is now visible in the list of images below

Select the Image and click on the sandwich icon on the right

Select "create instance" option from here and proceed to select the image you uploaded under Image topic

Go to next step "Shape" using the right arrow or click on Shape

Select you required shape based on (OCPU/Memory) requirement (General Purpose : oc3)

Move to next step "Instance", select High availability as per your need (Active)

Give name to your instance and upload the publick key which would be used to connect to it

Move to "Network" step and give DNS Hostname prefix

Uncheck the "IP Network" option, as we would be using the "shared network" (if required one can proceed with IP-Network configuration as per requirement, we are keeping it simple in this use case)

Create a security list and assign to the list

Move to next step Storage which would show the exact same size as the original disk/LUN in source

Move to "Review", review your selected values and click on "Create"

Orchestration will start and bring up the 3 orchestration (master/storage/instance)

Once the Orchestrations are in ready state.

Move to Instance tab and refresh. check the instance we created and select and open it.

Check the status and Public IP for it

Note the Public IP for the Server

STEP 5:

Open Putty and provide the Public IP address

Go to Connection-ssh-Auth on the left side panel and upload the private key pair for the public key used to create instance
open the connection and login using the account used previously



Performing all above steps will result with your server in Cloud.

We are working to test the same on Other Operating System Versions and incorporate more options in future.
This is a test case which resulted sucessfully for us, please feel free to test it out but with care.
