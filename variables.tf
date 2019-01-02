variable "cluster_id" {
  description = "The cluster ID."
}

variable "os_username" {
  description = "Username of the OS."
  default     = "operador"
}

variable "region" {
  description = "Azure region to launch servers."
  default     = "West Europe"
}

variable "master_instance_type" {
  description = "Azure DC/OS master instance type"
  default     = "Standard_D4s_v3"
}

variable "gosec_instance_type" {
  description = "Azure DC/OS master instance type"
  default     = "Standard_D4s_v3"
}

variable "private_agent_instance_type" {
  description = "Azure DC/OS Private Agent instance type"
  default     = "Standard_D4s_v3"
}

variable "public_agent_instance_type" {
  description = "Azure DC/OS Public instance type"
  default     = "Standard_D2s_v3"
}

variable "bootstrap_instance_type" {
  description = "Azure DC/OS Bootstrap instance type"
  default     = "Standard_D2s_v3"
}

variable "hdfs_instance_type" {
  description = "Azure HDFS instance type"
  default     = "Standard_D4s_v3"
}

variable "num_of_private_agents" {
  description = "DC/OS Private Agents Count"
  default     = 2
}

variable "num_of_public_agents" {
  description = "DC/OS Private Agents Count"
  default     = 1
}

variable "num_of_masters" {
  description = "DC/OS Master Nodes Count (Odd only)"
  default     = 3
}

variable "num_of_gosecs" {
  description = "Gosec Nodes Count"
  default     = 3
}

variable "num_of_hdfs" {
  description = "HDFS Nodes Count"
  default     = 1
}

variable "instance_disk_size" {
  description = "Default size of the root disk (GB)"
  default     = "50"
}

variable "private_agent_disk_size" {
  description = "Default size of the root disk (GB)"
  default     = "128"
}

variable "bootstrap_name_prefix" {
  description = "Bootstrap name prefix"
  default     = "bootstrap"
}

variable "master_name_prefix" {
  description = "Master name prefix"
  default     = "master"
}

variable "gosec_name_prefix" {
  description = "Gosec name prefix"
  default     = "gosec"
}

variable "public_agent_name_prefix" {
  description = "Master name prefix"
  default     = "public-agent"
}

variable "private_agent_name_prefix" {
  description = "Master name prefix"
  default     = "private-agent"
}

variable "hdfs_name_prefix" {
  description = "HDFS name prefix"
  default     = "hdfs"
}

variable "subnet_id" {
  description = "Subnet you want to use if already created"
  default     = ""
}
