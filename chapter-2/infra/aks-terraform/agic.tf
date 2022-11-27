# samples
# https://raw.githubusercontent.com/Azure/application-gateway-kubernetes-ingress/master/deploy/azuredeploy.json
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway
# https://learn.microsoft.com/en-us/azure/application-gateway/ingress-controller-install-new
# --
# https://github.com/denniszielke/container_demos/blob/master/terraform_agic/agic.tf

resource "helm_release" "ingress-azure" {
  name       = "agic"
  chart      = "ingress-azure"
  repository = "https://appgwingress.blob.core.windows.net/ingress-azure-helm-package"
  timeout    = 1200

  set {
    name  = "appgw.name"
    value = azurerm_application_gateway.gw.name
  }

  set {
    name  = "appgw.resourceGroup"
    value = azurerm_resource_group.rg.name
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

#   set {
#     name  = "kubernetes.watchNamespace"
#     value = ""
#   }

  depends_on = [
    helm_release.aad-pod-identity
  ]
}

resource "azurerm_user_assigned_identity" "agicidentity" {
  name                = "${var.resource_prefix}-agic-id"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  tags = local.tags

}

resource "azurerm_role_assignment" "agicidentityappgw" {
  scope                = azurerm_application_gateway.gw.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.agicidentity.principal_id
}

resource "azurerm_role_assignment" "agicidentityappgwgroup" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.agicidentity.principal_id
}
