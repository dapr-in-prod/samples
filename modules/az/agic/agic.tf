# samples
# https://raw.githubusercontent.com/Azure/application-gateway-kubernetes-ingress/master/deploy/azuredeploy.json
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway
# https://learn.microsoft.com/en-us/azure/application-gateway/ingress-controller-install-new
# --
# https://github.com/denniszielke/container_demos/blob/master/terraform_agic/agic.tf

data "azurerm_client_config" "current" {}

resource "helm_release" "ingress-azure" {
  name         = "agic"
  chart        = "ingress-azure"
  repository   = "https://appgwingress.blob.core.windows.net/ingress-azure-helm-package"
  timeout      = 1200
  force_update = true

  set {
    name  = "appgw.name"
    value = var.gateway_name
  }

  set {
    name  = "appgw.resourceGroup"
    value = var.resource_group_name
  }

  set {
    name  = "appgw.subscriptionId"
    value = data.azurerm_client_config.current.subscription_id
  }

  set {
    name  = "appgw.usePrivateIP"
    value = false
  }

  set {
    name  = "appgw.shared"
    value = false
  }

  set {
    name  = "armAuth.type"
    value = "aadPodIdentity"
  }

  set {
    name  = "armAuth.identityClientID"
    value = azurerm_user_assigned_identity.agicidentity.client_id
  }

  set {
    name  = "armAuth.identityResourceID"
    value = azurerm_user_assigned_identity.agicidentity.id
  }

  set {
    name  = "rbac.enabled"
    value = "true"
  }
}

resource "azurerm_user_assigned_identity" "agicidentity" {
  name                = "${var.resource_prefix}-agic-id"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_role_assignment" "agicidentityappgw" {
  scope                = var.gateway_id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.agicidentity.principal_id
}

resource "azurerm_role_assignment" "agicidentityappgwgroup" {
  scope                = var.resource_group_id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.agicidentity.principal_id
}
