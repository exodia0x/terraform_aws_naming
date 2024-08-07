terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~>3.1.0"
    }
  }
}

resource "random_string" "random" {
  length  = 5
  special = false
}

locals {
  conf_resource = jsondecode(file("../config/resourceDefinition.json"))
  data = [for x in local.conf_resource : {
    resource_type  = x.name
    resource_name  = lower(random_string.random.result)
    instance_start = 1
    instance_count = 3
    }
  ]
}

output "data" {
  value = local.data
}

output "conf_resource" {
  value = local.conf_resource
}