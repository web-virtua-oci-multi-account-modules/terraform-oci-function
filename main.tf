locals {
  tags_application = {
    "tf-name"        = var.application_name
    "tf-type"        = "application"
    "tf-compartment" = var.compartment_name
  }

  tags_function = {
    "tf-name"        = var.application_name
    "tf-type"        = "function"
    "tf-compartment" = var.compartment_name
  }

  functions = flatten([
    for index, item in var.functions != null ? var.functions : [] : [
      merge(item, {
        index               = index
        has_build           = item.registry_uri == null
        has_invoke_function = item.invoke_function != null
        registry_uri        = item.registry_uri != null ? item.registry_uri : "${var.oci_registry_endpoint}/${var.oci_tenancy_namespace}/${var.application_name}/${lower(item.function_name)}:${item.image_registry_version}"
      })
    ]
  ])

  images_builds    = [for item in local.functions : item if item.has_build]
  invoke_functions = [for item in local.functions : item if item.has_invoke_function]
}

resource "oci_functions_application" "create_application" {
  count = var.application_id == null ? 1 : 0

  compartment_id             = var.compartment_id
  display_name               = var.application_name
  config                     = var.application_config
  subnet_ids                 = var.subnet_ids
  network_security_group_ids = var.nsg_ids
  shape                      = var.shape
  syslog_url                 = var.syslog_url
  defined_tags               = var.defined_tags_application
  freeform_tags              = merge(var.tags_application, var.use_tags_default ? local.tags_application : {})

  image_policy_config {
    is_policy_enabled = var.is_policy_enabled

    dynamic "key_details" {
      for_each = var.kms_key_id != null ? [1] : []

      content {
        kms_key_id = var.kms_key_id
      }
    }
  }

  trace_config {
    domain_id  = var.trace_config_domain_id
    is_enabled = var.trace_config_is_enabled
  }
}

resource "oci_functions_function" "create_functions" {
  count = length(local.functions)

  application_id = var.application_id != null ? var.application_id : oci_functions_application.create_application[0].id

  display_name       = local.functions[count.index].function_name
  memory_in_mbs      = local.functions[count.index].memory_in_mbs
  config             = local.functions[count.index].function_config
  defined_tags       = local.functions[count.index].defined_tags
  freeform_tags      = merge(local.functions[count.index].tags, var.use_tags_default ? merge(local.tags_function, { tf-function = local.functions[count.index].function_name }) : {})
  image              = local.functions[count.index].registry_uri
  image_digest       = local.functions[count.index].function_image_digest
  timeout_in_seconds = local.functions[count.index].function_timeout_in_seconds

  dynamic "provisioned_concurrency_config" {
    for_each = local.functions[count.index].function_provisioned_concurrency_config != null ? [1] : []

    content {
      strategy = local.functions[count.index].function_provisioned_concurrency_config.strategy
      count    = local.functions[count.index].function_provisioned_concurrency_config.count
    }
  }

  dynamic "source_details" {
    for_each = local.functions[count.index].function_source_details != null ? [1] : []

    content {
      pbf_listing_id = local.functions[count.index].function_source_details.pbf_listing_id
      source_type    = local.functions[count.index].function_source_details.source_type
    }
  }

  trace_config {
    is_enabled = local.functions[count.index].function_trace_config_is_enabled
  }

  depends_on = [null_resource.exec_docker_builds_pushs]
}

resource "time_sleep" "create_wait_functions_ready" {
  count = length(local.invoke_functions)

  create_duration = local.invoke_functions[local.invoke_functions[count.index].index].invoke_function.invoke_create_duration
  depends_on      = [oci_functions_function.create_functions]
}

resource "oci_functions_invoke_function" "create_invoke_functions" {
  count = length(local.invoke_functions)

  function_id           = oci_functions_function.create_functions[local.invoke_functions[count.index].index].id
  invoke_function_body  = try(local.invoke_functions[count.index].invoke_function_body != null ? local.invoke_functions[count.index].invoke_function_body : "{\"name\": \"${var.application_name}\"}", null)
  fn_intent             = try(local.invoke_functions[count.index].fn_intent, null)
  fn_invoke_type        = try(local.invoke_functions[count.index].fn_invoke_type, null)
  base64_encode_content = try(local.invoke_functions[count.index].fn_invoke_base64_encode_content, null)

  invoke_function_body_base64_encoded = try(local.invoke_functions[count.index].invoke_function_body_base64_encoded, null)
  input_body_source_path              = try(local.invoke_functions[count.index].invoke_input_body_source_path, null)

  depends_on = [time_sleep.create_wait_functions_ready]
}
