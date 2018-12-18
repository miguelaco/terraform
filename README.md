# Azure Terraform template for Stratio EOS

## Login to Azure Cloud with the CLI

```
$ az login

Note, we have launched a browser for you to login. For old experience with device code, use "az login --use-device-code"
Se está abriendo en una sesión de navegador existente.
You have logged in. Now let us find all the subscriptions to which you have access...
[
  {
    "cloudName": "AzureCloud",
    "id": "<subscription_id_1>",
    "isDefault": false,
    "name": "Pago por uso",
    "state": "Enabled",
    "tenantId": "<tenant_id>",
    "user": {
      "name": "your-azure-account@example.com",
      "type": "user"
    }
  },
  {
    "cloudName": "AzureCloud",
    "id": "<subscription_id_2>",
    "isDefault": true,
    "name": "Pago por uso",
    "state": "Enabled",
    "tenantId": "<tenant_id>",
    "user": {
      "name": "your-azure-account@example.com",
      "type": "user"
    }
  }
]
```

Sign in with your Azure account and note the subscriptionId you want to use.

## Select your subscription

```
az account list
[
  {
    "cloudName": "AzureCloud",
    "id": "3cd5500c-7ea9-4117-ae9d-7050bc97cd63",
    "isDefault": false,
    "name": "Pago por uso",
    "state": "Enabled",
    "tenantId": "9c2f8eb6-5bf1-4597-8f4b-0357395935f5",
    "user": {
      "name": "asistemas@stratio.com",
      "type": "user"
    }
  },
  {
    "cloudName": "AzureCloud",
    "id": "1bcdf04d-a95b-47b0-8dd4-949b505d210f",
    "isDefault": true,
    "name": "Pago por uso",
    "state": "Enabled",
    "tenantId": "9c2f8eb6-5bf1-4597-8f4b-0357395935f5",
    "user": {
      "name": "asistemas@stratio.com",
      "type": "user"
    }
  }
]

az account set -s 1bcdf04d-a95b-47b0-8dd4-949b505d210f

az account show
{
  "environmentName": "AzureCloud",
  "id": "1bcdf04d-a95b-47b0-8dd4-949b505d210f",
  "isDefault": true,
  "name": "Pago por uso",
  "state": "Enabled",
  "tenantId": "9c2f8eb6-5bf1-4597-8f4b-0357395935f5",
  "user": {
    "name": "asistemas@stratio.com",
    "type": "user"
  }
}
```

## Setup

```
$ ./setup.sh
---------------------------------------------
 Setup state backend
---------------------------------------------
Resource group terraform created
Storage account stratio20397 created
Container tfstate created
---------------------------------------------
 Setup configuration
---------------------------------------------
Enter your cluster name: sanitas
Number of masters? (default: 3): 1
Number of public agents? (default: 1): 1
Number of private agents? (default: 5): 1
Instance type for bootstrap? (default: Standard_D2s_v3): 
Instance type for masters? (default: Standard_D4s_v3): Standard_D2s_v3
Instance type for gosec? (default: Standard_D4s_v3): Standard_D2s_v3
Instance type for public agents? (default: Standard_D4s_v3): Standard_D2s_v3
Instance type for private agents? (default: Standard_D4s_v3): Standard_D2s_v3
Creating sanitas.tfvars:
cluster_id = "sanitas"
num_of_masters = "1"
num_of_public_agents = "1"
num_of_private_agents = "1"
bootstrap_instance_type = "Standard_D2s_v3"
master_instance_type = "Standard_D2s_v3"
gosec_instance_type = "Standard_D2s_v3"
public_agent_instance_type = "Standard_D2s_v3"
private_agent_instance_type = "Standard_D2s_v3"
---------------------------------------------
 Generate SSH keypair
---------------------------------------------
---------------------------------------------
---------------------------------------------
 Terraform init
---------------------------------------------

Initializing the backend...

Successfully configured the backend "azurerm"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Checking for available provider plugins on https://releases.hashicorp.com...
- Downloading plugin for provider "azurerm" (1.20.0)...

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the
corresponding provider blocks in configuration, with the constraint strings
suggested below.

* provider.azurerm: version = "~> 1.20"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
---------------------------------------------
Successfully initialized, you can further customize your infrastructure editing terraform.tfvars
```

## Create infrastructure

Use terraform CLI to create infrastructure.

```
$ terraform plan
$ terraform apply
```