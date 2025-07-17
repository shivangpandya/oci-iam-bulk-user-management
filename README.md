# oci-iam-bulk-user-management

​
There are times when you need to import many users into your system. Whether it’s for testing purposes, running a hackathon, or migrating users from another platform, having an efficient way to handle bulk user operations is essential—especially in enterprise environments.

 For an overview of the different methods available for bulk user import, refer to other  comprehensive blogs like this one or our Oracle documentation for OCI IAM with Identity domains .

In this post, we’ll walk through how to:

Bulk import users using a CSV file
Send login credentials automatically
Clean up by deleting users after testing, while preserving specific ones
 

For this test use case , we would be using the import using CSV method and with code developed using Faker library of python to generate about 1600 test users

Step 1: Preparing the Excel Sheet for Bulk Import
To begin, we’ll generate around 1,600 test users using Python’s Faker library. These synthetic users will be stored in a CSV file.
Your CSV should contain, at minimum, the following fields:
UserID
Last Name
First Name
Work Email
Primary Email Type
Federated
You can refer to the user_sample.csv template for a complete list of supported fields.

Here’s a sample preview of users generated via the Faker library:


![alt text](https://github.com/shivangpandya/oci-iam-bulk-user-management/blob/main/Testusers.png?raw=true)


 



 

Step 2: Importing Users
Once your CSV file is ready, use the Import Users feature to upload the data.

After the upload, users will automatically receive a login email at their respective email addresses with their credentials and instructions for accessing the system.


 
 ![alt text](https://github.com/shivangpandya/oci-iam-bulk-user-management/blob/main/Importusers.png?raw=true)


 

 

 

Step 3: Cleaning Up – Deleting Users (While Excluding Some)
 

Since Identity and Access Management (IAM) systems typically incur a per-user cost each month, it’s important to remove test users once they’re no longer needed.

To automate this, you can use a shell script to delete users in bulk while excluding a specific set of users (e.g., admin accounts or permanent testers). The script works by referencing an "exclude list" and skipping any users found in that list during deletion.

Here’s a basic idea of how the script functions:

It reads all users from the system.
Compares each user against an “exclusion list.”
Deletes only those not in the list.
This script can easily be modified to suit your environment or integrated into your CI/CD pipeline for test cleanup.

 

As you can see it skips a certain set of users which are in the exclude list while deleting the  rest of the users.  The script can be modified to work according to the use case.

![alt text](https://github.com/shivangpandya/oci-iam-bulk-user-management/blob/main/script-detail.png?raw=true)


 

Final Thoughts


Managing bulk users can be tedious without automation. Using scripts and structured imports not only saves time but also helps avoid unnecessary costs and errors

Please find the attached github link to see the link for the code .

​
