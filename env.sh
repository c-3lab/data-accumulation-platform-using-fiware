export ARM_TENANT_ID=$(az account show --query tenantId | sed 's/"//g')
export ARM_SUBSCRIPTION_ID=$(az account show --query id | sed 's/"//g')
export TF_VAR_psql_admin_password=psqladminpass
export TF_VAR_mongodb_password=mongodbpass_orion
export TF_VAR_psql_cygnus_password=cygnuspass
export TF_VAR_psql_kong_password=kongpass
export TF_VAR_mongodb_iot_agent_password=mongodbpass_iot_agent
