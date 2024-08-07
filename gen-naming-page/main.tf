# Run:
# 1) terraform apply -target module.gen-resource
# 2) terraform apply
# 3) Change
/*
### Virtual Network Peering
 
- **Restrictions**:
  - length: 1-80
  - regex: `^[a-zA-Z0-9][a-zA-Z0-9-._]+[a-zA-Z0-9_]$`
- **Example**:
    - vpeer-vnet-source-az-asse-prd-001-vnet-remote-az-asse-prd-001
    - vpeer-vnet-source-az-asse-prd-002-vnet-remote-az-asse-prd-002
*/

terraform {
  required_providers {}
}

module "gen-resource" {
  source = "../modules/get-resources/"
}

module "naming" {
  source = "../"

  resource_cp     = "az"
  resource_region = "southeastasia"
  resource_env    = "prd"
  resource_list   = module.gen-resource.data

  depends_on = [
    module.gen-resource,
  ]
}

locals {
  data = [for z in [for x in module.naming.result : merge(x, [for y in module.gen-resource.conf_resource : y if y.name == x.resource_type][0])] : {
    name : title(replace(z.name, "_", " ")),
    length_max : z.length.max,
    length_min : z.length.min,
    regex : replace(z.regex, "/\\(\\?=.*\\)/", ""),
    example : try(slice(z.names, 0, 2), slice(z.names, 0, 1))
  }]
  rendered_data = templatefile(
    "${path.module}/naming-page.tftpl",
    {
      inputs = "${local.data}"
    }
  )
}

resource "local_file" "readme" {
  content  = local.rendered_data
  filename = "${path.module}/azure-naming-and-tagging.md"
}

# output "rendered-result" {
#   value = local.rendered_data
# }