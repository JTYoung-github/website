#Synopsis:
########################################
The terraform script will complete the following:

- turn the website off
- remove the previous files from the website
- clone the git repo, with the updated application
- build the website and bring it online
- Creates the same admin user, to complete the tests



#Pre-requisites:
########################################
- have a pre-configured key pair from which you can connect to the VM.
	I haven't automated this because this requires an external certificate which is likely specific to the user running terraform.



configurations required on the main.tf file:

change line 11:
	update this with the hostname of the VM you are needing to udpate.

change line 22 & 35:
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

cd ./web_app_update #ensure current directory is the Terraform build directory. 
terraform init # download AWS provider
terraform plan # ensures no issues with the main.tf file
terraform apply # select yes, if no errors. can use flag "--auto-approve" if you don't want to be prompted.
terraform destroy # this is to remove the resource created for running the update, as it's currently a null update 

wait until terraform has deployed and then run tests.