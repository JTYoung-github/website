#Synopsis:
########################################
The terraform script will complete the following:

- Create the necessary security group
- Deploy a VM in AWS
- download and install the necessary repos, including docker-ce and docker compose
- clone the git repo, which provides the application
- builds the website and brings it online.
- creates an admin user, to complete the tests

Note:
I contemplated using Auto scaling groups and Load balancers for this, however thought as the database is local to each VM, this wouldn't provide the usual benefits they would usually.


#Pre-requisites:
########################################
- a Programmatic account created in your AWS account. 
	whilst I know there is a way of configuring temporary access through IAM for users, I've not worked with this previously and didn't have the time to fully look into this

- Configure your key pair within AWS, to complete the build on the VMs and to access them post build.
	I haven't automated this because this requires an external certificate which is likely specific to the user running terraform. 


Configurations before running the main.tf file:

change line 2 & 3:
	Input programmatic credentials, with full permissions over EC2 and Security Groups

Change Line 11:
	Use the Key Pair name, that's configured in AWS for your user. you will reference to "Linux" as that is my current certificate's name

Change line 62 & 76:
	Need to update with the certificate file name, that's configured with the key pair used above.	

Ensure key pair certificate is in same directory as the terraform script.

set the credentials for the admin user, that's created for the webapp e.g.:
	User.objects.create_superuser('<Admin_username>', '<Admin_email_address>', '<Admin_Password>')"


#How to use the main terraform script
########################################

Ensure you have the following files in your currently working directory:


./createadmin
./main.tf
./<certificate used for key_pair>

run the following commands:

cd ./web_app_deployment #ensure current directory is the Terraform build directory. 
terraform init # download AWS provider
terraform plan # ensures no issues with the main.tf file
terraform apply # select yes, if no errors. can use flag "--auto-approve" if you don't want to be prompted.

wait until terraform has deployed and then run tests.