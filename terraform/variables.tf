variable "container_apps" {
  type = list(object({
    name = string
    image_name = string
    tag = string
    revision_mode = string
    containerPort = number
    ingress_enabled = bool
    min_replicas = number
    max_replicas = number
    cpu = number
    memory = string
    keda_rules = list(object({
      name = string
      type = string
      topic_name = string
      message_count = number
    }))
  }))

  default = [ {
    name = "nginx"
    image_name = "nginx"
    tag = "latest"
    revision_mode = "Single"
    containerPort = 80
    ingress_enabled = true
    min_replicas = 1
    max_replicas = 2
    cpu = 0.5
    memory = "1.0Gi"
    keda_rules = [{
        name = "az-sample-rule"
        type = "azure-servicebus"
        topic_name = "sample-topic"
        message_count = 1
    }]
  },
    {
      name = "hello-world"
      image_name = "hello-world"
      tag = "latest"
      revision_mode = "Single"
      containerPort = 80
      ingress_enabled = true
      min_replicas = 1
      max_replicas = 2
      cpu = 0.5
      memory = "1.0Gi"
      keda_rules = [{
        name = "az-sample-rule"
        type = "azure-servicebus"
        topic_name = "sample-topic"
        message_count = 1
      }]
    }]
}