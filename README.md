# OCI Application Functions for multiples accounts with Terraform module
* This module simplifies creating and configuring of Application Functions across multiple accounts on OCI

* Is possible use this module with one account using the standard profile or multi account using multiple profiles setting in the modules.

## Actions necessary to use this module:

* Criate file provider.tf with the exemple code below:
```hcl
provider "oci" {
  alias   = "alias_profile_a"
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.ssh_private_key_path
  region           = var.region
}

provider "oci" {
  alias   = "alias_profile_b"
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.ssh_private_key_path
  region           = var.region
}
```


## Features enable of Application Functions configurations for this module:

- Application Function
- Function
- Invoke function
- Docker login
- Docker build
- Docker push

## Usage exemples


### Create Application Function with subnet and Network security group

```hcl
module "for_create_application_and_function" {
  source = "web-virtua-oci-multi-account-modules/function/oci"

  application_name       = "tf-test-application"
  oci_registry_endpoint  = var.oci_registry_endpoint
  oci_dockerhub_username = var.oci_dockerhub_username
  oci_dockerhub_token    = var.oci_dockerhub_token
  oci_tenancy_namespace  = var.oci_tenancy_namespace
  compartment_id         = var.compartment_id

  subnet_ids = [
    var.sububnet_id
  ]

  nsg_ids = [
    var.nsg_id
  ]

  functions = [
    {
      function_name           = "users"
      image_registry_version  = "9.0"
      memory_in_mbs           = "256"
      application_data_source = "code"
      invoke_function = {
        make_invoke = true
      }
    },
    {
      function_name           = "partners"
      image_registry_version  = "10.0"
      memory_in_mbs           = "128"
      application_data_source = "code"
    },
  ]

  providers = {
    oci = oci.alias_profile_a
  }
}
```


## Variables

| Name | Type | Default | Required | Description | Options |
|------|-------------|------|---------|:--------:|:--------|
| compartment_id | `string` | `-` | yes | Compartment ID | `-` |
| application_name | `string` | `-` | yes | Application name | `-` |
| application_config | `string` | `null` | no | Application configuration. These values are passed on to the function as environment variables, functions may override application configuration. Keys must be ASCII strings consisting solely of letters, digits, and the '_' (underscore) character, and must not begin with a digit. Values should be limited to printable unicode characters. Example: {"MY_FUNCTION_CONFIG": "ConfVal"} | `-` |
| subnet_ids | `list(string)` | `[]` | no | Subnet IDs | `-` |
| nsg_ids | `list(string)` | `null` | no | The OCIDs of the Network Security Groups to add the application to | `-` |
| shape | `string` | `""` | no | Valid values are GENERIC_X86, GENERIC_ARM and GENERIC_X86_ARM. Default is GENERIC_X86 | `-` |
| syslog_url | `string` | `null` | no | If active the Oracle Cloud will be logging for this app. A syslog URL to which to send all function logs. Supports tcp, udp, and tcp+tls. The syslog URL must be reachable from all of the subnets configured for the application | `-` |
| use_tags_default | `bool` | `true` | no | If true will be use the tags default to resources | `*`false <br> `*`true |
| tags_application | `map(any)` | `{}` | no | Tags to application | `-` |
| defined_tags_application | `map(any)` | `{}` | no | Defined tags to application | `-` |
| is_policy_enabled | `bool` | `false` | no | Define if image signature verification policy is enabled for the application | `*`false <br> `*`true |
| kms_key_id | `string` | `null` | no | The OCIDs of the KMS key that will be used to verify the image signature | `-` |
| trace_config_domain_id | `string` | `null` | no | The OCID of the collector (e.g. an APM Domain) trace events will be sent to | `-` |
| trace_config_is_enabled | `bool` | `false` | no | Define if tracing is enabled for the resource | `*`false <br> `*`true |
| application_id | `string` | `null` | no | If it's defined the function will be created using this application ID, else will be created a new application | `-` |
| compartment_name | `string` | `-` | no | Compartment name | `-` |
| oci_dockerhub_token | `string` | `null` | no | OCI Docker token | `-` |
| oci_dockerhub_username | `string` | `null` | no | Username for the OCIR repos | `-` |
| oci_registry_endpoint | `string` | `null` | no | Registry endpoint, ex: gru.ocir.io | `-` |
| oci_tenancy_namespace | `string` | `null` | no | OCI tenancy namespace for registry | `-` |
| functions | `list(object)` | `null` | no | Configuration to build any functions on the project | `-` |

* Model of functions variable
```hcl
variable "functions" {
  description = "Configuration to build any functions on the project"
  type = list(object({
    function_name                           = string
    application_data_source                 = optional(string)
    image_registry_version                  = optional(string, "1.0")
    registry_uri                            = optional(string)
    memory_in_mbs                           = optional(string, "128")
    function_config                         = optional(map(any))
    function_image_digest                   = optional(string)
    function_timeout_in_seconds             = optional(number, 30)
    function_provisioned_concurrency_config = optional(string)
    function_trace_config_is_enabled        = optional(bool, false)
    function_source_details = optional(object({
      pbf_listing_id = string
      source_type    = string
    }))
    invoke_function = optional(object({
      make_invoke                         = optional(bool, false)
      invoke_create_duration              = optional(string, "30s")
      invoke_function_body                = optional(any)
      fn_intent                           = optional(string, "httprequest")
      fn_invoke_type                      = optional(string, "sync")
      fn_invoke_base64_encode_content     = optional(bool, false)
      invoke_function_body_base64_encoded = optional(string)
      invoke_input_body_source_path       = optional(string)
    }))
    defined_tags = optional(map(any))
    tags         = optional(map(any))
  }))
  default = [
    {
      function_name           = "users"
      image_registry_version  = "9.0"
      memory_in_mbs           = "256"
      application_data_source = "code"
      invoke_function = {
        make_invoke = true
      }
    },
    {
      function_name           = "partners"
      image_registry_version  = "10.0"
      memory_in_mbs           = "128"
      application_data_source = "code"
    },
  ]
}
```


## Resources

| Name | Type |
|------|------|
| [oci_functions_application.create_application](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/functions_application.html) | resource |
| [oci_functions_function.create_functions](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/functions_function) | resource |
| [time_sleep.create_wait_functions_ready](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [oci_functions_invoke_function.create_invoke_functions](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/functions_invoke_function) | resource |
| [null_resource.exec_oci_registry_login](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.exec_docker_builds_pushs](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Outputs

| Name | Description |
|------|-------------|
| `application` | Application |
| `application_id` | Application ID |
| `application_name` | Application name |
| `functions` | Functions |
| `invoke_functions` | Invoke functions |
