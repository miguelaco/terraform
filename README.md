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

## Create a new app registration

This will create a new app registration with permission to create resources.

```
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/<subscription_id_2>" --name "terraform"
Changing "terraform2" to a valid URI of "http://terraform2", which is the required format used for service principal names
Retrying role assignment creation: 1/36
{
  "appId": "<app_id>",
  "displayName": "terraform",
  "name": "http://terraform",
  "password": "<password>",
  "tenant": "<tenant_id>"
}
```

## Export env for Terraform

Export env variables for Terraform Azure provider.

```
$ export ARM_SUBSCRIPTION_ID=<subscription_id_2>
$ export ARM_CLIENT_ID=<app_id>
$ export ARM_CLIENT_SECRET=<password>
$ export ARM_TENANT_ID=<tenant_id>
```

## Edit vars

Edit vars file with your cluster configuration. Select how many masters and agents you want and set vm sizes in case you are not happy with the defaults. You should also provide a valid ssh key to setup ssh access for the vms.

```
$ vi main.tfvars
```

## Create infrastructure

Use terraform CLI to create infrastructure.

```
$ terraform init
$ terraform plan -var-file main.tfvars
$ terraform apply -var-file main.tfvars
```