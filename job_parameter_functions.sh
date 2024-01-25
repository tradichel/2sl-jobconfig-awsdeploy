set_ssm_parameter_job_config(){
  ssm_name="$1"
  kmskeyid="$2"
  tier="$2"

  #secure string doesn't work with 
  #cloudformation at the time I wrote
  #these scripts - default to standard,
  #secure string which is encrypted with 
  #the AWS managed KMS key

  if [ "$tier" == "" ]; then tier="Standard"; fi
  parmtype='SecureString'

  func=${FUNCNAME[0]}
  validate_set $func "ssm_name" "$ssm_name"

  if [ "$profile" != "" ]; then useprofile=" --profile $profile"; fi

  if [ "$kmskeyid" != "" ]; then
    echo "aws ssm put-parameter --name $ssm_name --overwrite --key-id $kmskeyid --value file://.$ssm_name \
       --tier $tier --type $parmtype $useprofile"
    aws ssm put-parameter --name $ssm_name --overwrite --key-id $kmskeyid --value file://.$ssm_name \
       --tier $tier --type $parmtype $useprofile
  else
    echo "aws ssm put-parameter --name $ssm_name --overwrite --value file://.$ssm_name \
       --tier $tier --type $parmtype $useprofile"
    aws ssm put-parameter --name $ssm_name --overwrite --value file://.$ssm_name \
       --tier $tier --type $parmtype $useprofile
  fi
}


