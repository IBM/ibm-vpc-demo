
##############################################################
# Terraform Provider declaration
# Note: var.region is mapped to local.provider_region
##############################################################

provider "ibm" {

  ibmcloud_api_key      = var.ibmcloud_api_key
  region                = local.provider_region
  ibmcloud_timeout      = 3600
}

