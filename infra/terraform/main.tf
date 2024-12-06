resource "azurerm_resource_group" "aks-tf-gen1-rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_container_registry" "aks-container-registry" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.aks-tf-gen1-rg.name
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = true
}

resource "azurerm_kubernetes_cluster" "aks-kubernetes-cluster" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = azurerm_resource_group.aks-tf-gen1-rg.name
  kubernetes_version  = var.kubernetes_version
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name            = "defaultpool"
    node_count      = var.system_node_count
    vm_size         = "Standard_D2s_v3"
    os_disk_size_gb = 30
  }


  service_principal {
    client_id     = var.appId
    client_secret = var.password
  }


  role_based_access_control_enabled = true
}

resource "azurerm_role_assignment" "container_registry_role-assignment" {
  principal_id         = var.principalid
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.aks-container-registry.id
}

# Create Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "insights" {
  name                = var.law
  location            = var.location
  resource_group_name = azurerm_resource_group.aks-tf-gen1-rg.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
}

resource "azurerm_monitor_diagnostic_setting" "monitor" {
  name                       = "audit"
  target_resource_id         = azurerm_kubernetes_cluster.aks-kubernetes-cluster.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.insights.id

  enabled_log {
    category = "kube-apiserver"
  }

  enabled_log {
    category = "kube-controller-manager"
  }

  enabled_log {
    category = "cluster-autoscaler"
  }

  enabled_log {
    category = "kube-scheduler"
  }

  enabled_log {
    category = "kube-audit"
  }

  metric {
    category = "AllMetrics"
  }

}