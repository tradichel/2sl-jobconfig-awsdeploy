#!/bin/bash -e
#configure job
source container/resources/ssm/parameter/parameter_functions.sh
source container/resources/organizations/account/account_functions.sh

config_dir="ssm_job_config"

#############
# Get role to use to deploy job configuration
#############
default_profile="root-adminrole"

echo "Which AWS CLI profile will you use to deploy this parameter?"
echo "Enter L to list the profiles. Return to use the default profile."
read profile

if [ "$profile" == "L" ]; then
	echo -e "\nLocal AWS CLI Profiles"
	aws configure list-profiles
	echo -e "\nEnter profile:"
	read profile
fi

if [ "$profile" == "" ]; then profile=$default_profile; fi

#############
# Get the name of the container that will run the job
#############
echo -e "\nContainers:"; 
ls $config_dir | grep -v '.sh'
echo -e "\nEnter the name of the container that will run the job:"
read container

#############
# Get the job role
#############
echo -e "\nRoles:"; 
ls $config_dir/$container
echo -e "\nEnter job role: "
read jobrole

#############
# Get the job role
#############
echo -e "\nJobs:";
ls $config_dir/$container/$jobrole
echo -e "\nEnter job name: "
read jobname

parameter="/$config_dir/$container/$jobrole/$jobname"

echo "Deploy job config to AWS Parameter Store with AWS CLI Profile: $profile"
echo "Job is executed with this container: $container"
echo "Job is executed with this role: role"
echo "Job name: $jobname"
echo "Parameter name: $parameter"
echo "Parameter value:"
echo "~~~~~~~~~~~~~~~~~~~~~~"
cat ./$parameter
echo "~~~~~~~~~~~~~~~~~~~~~~"

#region=$(cat ./$parameter | grep region | cut -d '=' -f2)
#account=$(cat ./$parameter | grep account | cut -d '=' -f2)
#echo "Deploy to account: $account and region $region"
echo "Changed this to deploy the parameter to the current account."
echo "The parameter should be deployed in the same account where the secret"
echo "with credentials exists and where the EC2 instance will execute the job."

echo "Enter the account name where the parameter should be deployed"
read account

accountid=$(get_account_number_by_account_name $account)
echo $accountid

echo "Enter the region where the parameter should be deployed"
read region

#############
# Assume the AWS Organizations role for the account
#############
assume_organizations_role $account

#############
# Deploy the parameter
#############
set_ssm_parameter_job_config $parameter

############
# Display avaible jobs in account
############
echo -e "\nAvailable jobs in in this account:"
aws ssm describe-parameters --profile $profile --query Parameters[*].Name --output text | grep job


