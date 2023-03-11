Prerequisites:
--------------
Terraform: Install Terraform on your computer 
Google Cloud SDK: Install the Google Cloud SDK 
Google Cloud project: Create a Google Cloud project 
Authenticate to Google cloud either by setting up the environmental variable or gcloud auth login command 

To get started, follow the instructions below:
---------------------------------------------
Step 1: Run this command to clone the repo 
"git clone https://github.com/dineshsala/vmo2_tech_test.git"

Step 2: Navigate to the folder containing this Terraform configuration file and input the Google Cloud project id as a variable in "terraform.tfvars" file

Step 3: Manual commands to run or follow step 4 to run the script file:
	terraform init
	terraform plan
	terraform apply -auto-approve

Step 4(optional): Alternatively, you can run the "run.sh" script file by running ./run.sh
	(Note:To make sure this file is executable by running this command "chmod +x run.sh")

Step 5: Destroy the created resourced by running "terraform destroy" command

================================================================
I have added an output folder to the project and uploaded images of the created resources for your reference. These images can provide a visual representation of the infrastructure and help you understand the resources that were created by Terraform.

Great exercise!! Thanks for the opportunity :)
===============================================================