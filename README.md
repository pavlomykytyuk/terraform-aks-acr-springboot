# Overview  
This project demonstrates the creation of an Azure Container Registry (ACR) to store Docker images securely in a private container registry. Additionally, it provisions an Azure Kubernetes Service (AKS) cluster to host Kubernetes deployments.

# Prerequisites
Before starting, ensure you have the following:

A Microsoft Azure account.
Installed Azure CLI.
Installed Terraform.
Installed kubectl.

# Steps
1. Login into the Azure account using azure cli
    ```
    az login
    ```
2. Create a new service principal to grant permissions for managing Azure resources: 

    ```
    az ad sp create-for-rbac --name GithubAction--role owner --scopes /subscriptions/<your-subscriptions>
    ```

    Save the output, which looks like this:
    ```
    {
        "appId": "<app_if>",
        "displayName": "<display_name>",
        "password": "<password>",
        "tenant": "<tenant>"
    }
    ```

3. Fetch the object ID of the service principal:
    ```
    az ad sp show --id <appId_from_above_step> --query "id"
    ```
    Note the returned principal id as well.

4. In the terraform folder, create a file named terraform.tfvars and populate it with the following content:
    ```
    resource_group_name = "tf_aks_acr_rg"
    location            = "northeurope"
    cluster_name        = "aks-gen1-cluster"
    kubernetes_version  = "1.30.3"
    system_node_count   = 1
    acr_name            = "acrgen1env"
    law                 = "lawgen1env" 
    appId               = "<appId_from_step_2>"
    principalid         = "<principalId_from_step_3>"
    password            = "<password_from_step_2>"
    dns_prefix          = "aks-dns-prefix-k8s"
    ```
    In `appId`, `principalid`, `password` insert data from the previous steps

5. Add the following secrets to your GitHub Actions repository:

    ```
   AZURE_CLIENT_ID               	<appId_from_step_2>
   AZURE_CLIENT_SECRET              <password_from_step_2>
   AZURE_TENANT_ID	                <tenant_from_step_2>
    ```

Also, add a secret named AZURE_CREDENTIALS with this JSON content:

   {
      "clientId": "appId_from_step_2",
      "clientSecret": "appId_from_step_2",
      "subscriptionId": "put_your_value_subscriptionId",
      "tenantId": "appId_from_step_2"
   }
   

6. Obtain connection string for storing access_key value and put value into terraform provider block located /infra/terraform/provider.tf.
IMPORTANT! This approach using Service Principal is not used in the production environment.
     
      ```
       az storage account keys list \
          --resource-group $RESOURCE_GROUP_NAME \
          --account-name $STORAGE_ACCOUNT_NAME \
          --query "[0].value" -o tsv 
       ```
Make note of the outputs after all the resources are created. Especially `acr_login_server`, `acr_username` and `acr_password`.  
To see `acr_password`, use the command 

    ```
    az acr credential show  --name acrgen1env.azurecr.io --resource-group tf_aks_acr_rg  
    ```
Create new secrets for login to ACR and run the Application Deployment pipeline

      REGISTRY_USERNAME 
      REGISTRY_PASSWORD


7. The first thing to debug in your cluster is if your nodes are all registered correctly:
    
```
kubectl get pods: List all Pods.
kubectl get nodes: List all Nodes.
kubectl get services: List all Services.
kubectl get deployments: List all Deployment
```

Describe Resources:
```
kubectl describe pod <pod-name>: Detailed information about a Pod.
kubectl describe node <node-name>: Detailed information about a Node.
kubectl describe service <service-name>: Detailed information about a Service.
kubectl describe deployment <deployment-name>: Detailed information about a Deployment.
```

Logs:

```
kubectl logs <pod-name>: View logs of a Pod's primary container.
kubectl logs <pod-name> -c <container-name>: View logs of a specific container.
```

8. Clean up

To clean up the resources, locate and execute the provided rip-infra.sh script.
Ensure you verify the resources to avoid deleting unintended infrastructure.

**Important Notes**
Service Principal Usage: The approach described here uses a Service Principal for authentication. Avoid using this in production environments without additional safeguards. Consider managed identities for better security.

Terraform State File: Store the Terraform state file securely using Azure Blob Storage.
