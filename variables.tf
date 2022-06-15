
#variable "ibmcloud_api_key" {
#  description = "Enter your IBM Cloud API Key"
#}

variable "resource_prefix" {
  type        = string
  default     = "vpc-demo"
    validation {
       condition = can(regex("^([a-z]|[a-z][-a-z0-9]*[a-z0-9])$", var.resource_prefix))
       error_message = "Please enter a string which starts with a character, no underscores allowed."
    }
  description = "Prefix that is used to name the IBM Cloud resources that are provisioned to build the Demo Application. It is not possible to create multiple resources with same name. Make sure that the prefix is unique."
}

variable "ssh_key_name" {
  type        = string
  description = "Name of the SSH key configured in your IBM Cloud account that is used to establish a connection to the application nodes. Ensure that the SSH key is present in the same resource group and region where the cluster is being provisioned and our automation supports only one ssh key that can be attached to the application nodes. If you do not have an SSH key in your IBM Cloud account, create one by using the [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys) instructions. If left blank then a key will be generated."
  validation {
#    condition = can(regex("^[a-z]+(-[a-z0-9]+)*$|^$", var.ssh_key_name))
    error_message = "Our automation code supports only one ssh key to be attached to the application node."
  }
}

variable "resource_group_name" {
  type        = string
  default     = "default"
  description = "Resource group name from your IBM Cloud account where the VPC resources should be deployed. For more information, see[Managing resource groups](https://cloud.ibm.com/docs/account?topic=account-rgs&interface=ui)."
}

variable "region" {
  type        = string
  default     = "us-south"
  description = "Name of the IBM Cloud region where the resources need to be provisioned.(Examples: us-east, us-south, etc.) For more information, see [Region and data center locations for resource deployment](https://cloud.ibm.com/docs/overview?topic=overview-locations)."
}

variable "image_name" {
  type        = string
  default     = "ibm-ubuntu-20-04-minimal-amd64-2"
  description = "Name of the image that will be used to provision the Application nodes. Only Ubuntu stock images of any version available to the IBM Cloud account in the specific region are supported."
}

variable "profile" {
  type        = string
  default     = "cx2-2x4"
  description = "The virtual server instance profile type name to be used to create the Application nodes. For more information, see [Instance Profiles](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles)"
  validation {
    condition     = can(regex("^[b|c|m]x[0-9]+d?-[0-9]+x[0-9]+", var.profile))
    error_message = "Specified profile must be a valid IBM Cloud VPC GEN2 Instance Storage profile name [Learn more](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles)."
  }
}

variable "subnets" {
  description = "Enter the number of subnets to create."
  default = 2
}

variable "postgresql" {
  type = bool
  default = true
}