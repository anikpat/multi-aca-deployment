resource "azapi_resource" "aca" {
  for_each = { for ca in var.container_apps: ca.name => ca}
  type      = "Microsoft.App/containerApps@2022-10-01"
  parent_id = azurerm_resource_group.resource_group.id
  location  = azurerm_resource_group.resource_group.location
  name      = each.value.name

  body = jsonencode({
    properties : {
      managedEnvironmentId = azurerm_container_app_environment.container_app_environment.id
      configuration        = {
        secrets = [
          {
            name  = "service-bus-connection-string"
            value = azurerm_servicebus_namespace.service_bus.default_primary_connection_string
          }]
        registries = [
          {
            server            = "myregistery.azurecr.io"
            username          = "myregistery"
            passwordSecretRef = "container-registry-password"
          }
        ]
      }
      template = {
        containers = [
          {
            name  = each.value.name
            image = "myregistery.azurecr.io/samples/${each.value.image_name}:${each.value.tag}"
            env   = []
          }
        ],
        scale = {
          minReplicas = each.value.min_replicas
          maxReplicas = each.value.max_replicas
          rules       = [
            {
              name   = each.value.keda_rules.name
              custom = {
                type     = each.value.keda_rules.type
                metadata = {
                  topicName        = each.value.keda_rules.topic_name
                  subscriptionName = each.value.keda_rules.subscription_name
                  namespace        = azurerm_servicebus_namespace.service_bus.name
                  messageCount     = each.value.keda_rules.message_count
                }
                auth = [
                  {
                    secretRef        = "service-bus-connection-string"
                    triggerParameter = "connection"
                  }
                ]
              }
            },
            {
              name   = "azure-service-bus-topic-rule"
              custom = {
                type     = "azure-servicebus"
                metadata = {
                  topicName        = "topic"
                  subscriptionName = "subscription"
                  namespace        = azurerm_servicebus_namespace.service_bus.name
                  messageCount     = "1"
                }
                auth = [
                  {
                    secretRef        = "service-bus-connection-string"
                    triggerParameter = "connection"
                  }
                ]
              }
            }
          ]
        }
      }
    }
  })

  ignore_missing_property = true
  response_export_values  = ["*"]
}


