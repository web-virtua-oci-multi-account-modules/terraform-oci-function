variable "compartment_id" {
  description = "Compartment ID"
  type        = string
}

variable "application_name" {
  description = "Application name"
  type        = string
}

variable "application_config" {
  description = "Application configuration. These values are passed on to the function as environment variables, functions may override application configuration. Keys must be ASCII strings consisting solely of letters, digits, and the '_' (underscore) character, and must not begin with a digit. Values should be limited to printable unicode characters. Example: {\"MY_FUNCTION_CONFIG\": \"ConfVal\"}"
  type        = map(any)
  default     = null
}

variable "subnet_ids" {
  description = "Subnet IDs"
  type        = list(string)
  default     = []
}

variable "nsg_ids" {
  description = "The OCIDs of the Network Security Groups to add the application to"
  type        = list(string)
  default     = null
}

variable "shape" {
  description = "Valid values are GENERIC_X86, GENERIC_ARM and GENERIC_X86_ARM. Default is GENERIC_X86"
  type        = string
  default     = ""
}

variable "syslog_url" {
  description = "If active the Oracle Cloud will be logging for this app. A syslog URL to which to send all function logs. Supports tcp, udp, and tcp+tls. The syslog URL must be reachable from all of the subnets configured for the application"
  type        = string
  default     = null
}

variable "use_tags_default" {
  description = "If true will be use the tags default to resources"
  type        = bool
  default     = true
}

variable "tags_application" {
  description = "Tags to application"
  type        = map(any)
  default     = {}
}

variable "defined_tags_application" {
  description = "Defined tags to application"
  type        = map(any)
  default     = null
}

variable "is_policy_enabled" {
  description = "Define if image signature verification policy is enabled for the application"
  type        = bool
  default     = false
}

variable "kms_key_id" {
  description = "The OCIDs of the KMS key that will be used to verify the image signature"
  type        = string
  default     = null
}

variable "trace_config_domain_id" {
  description = "The OCID of the collector (e.g. an APM Domain) trace events will be sent to"
  type        = string
  default     = null
}

variable "trace_config_is_enabled" {
  description = "Define if tracing is enabled for the resource"
  type        = bool
  default     = false
}

variable "application_id" {
  description = "If it's defined the function will be created using this application ID, else will be created a new application"
  type        = string
  default     = null
}

variable "compartment_name" {
  description = "Compartment name"
  type        = string
  default     = null
}

#-----------------------------------------#
#-------------Exec resources--------------#
variable "oci_dockerhub_token" {
  description = "OCI Docker token"
  type        = string
  default     = null
}

variable "oci_dockerhub_username" {
  description = "Username for the OCIR repos"
  type        = string
  default     = null
}

variable "oci_registry_endpoint" {
  description = "Registry endpoint, ex: gru.ocir.io"
  type        = string
  default     = null
}

variable "oci_tenancy_namespace" {
  description = "OCI tenancy namespace for registry"
  type        = string
  default     = null
}

variable "functions" {
  description = "Configuration to build any functions on the project"
  type = list(object({
    function_name                           = string                  # Function name also give the name to image
    application_data_source                 = optional(string)        # Application data source with the code to build
    image_registry_version                  = optional(string, "1.0") # Function image version
    registry_uri                            = optional(string)        # If defined this image will be used to create the function, else will be make a buil and push of image to OCI registry and used a new image
    memory_in_mbs                           = optional(string, "128") # Maximum usable memory for the function (MiB)
    function_config                         = optional(map(any))      # These values are passed on to the function as environment variables, this overrides application configuration values. Keys must be ASCII strings consisting solely of letters, digits, and the '_' (underscore) character, and must not begin with a digit. Values should be limited to printable unicode characters. Example: {\"MY_FUNCTION_CONFIG\": \"ConfVal\"}
    function_image_digest                   = optional(string)        # The image digest for the version of the image that will be pulled when invoking this function. If no value is specified, the digest currently associated with the image in the Oracle Cloud Infrastructure Registry will be used. This field must be updated if image is updated. Example: sha256:ca0eeb6fb05351dfc8759c20733c91def84cb8007aa89a5bf606bc8b315b9fc7
    function_timeout_in_seconds             = optional(number, 30)    # Function timeout in seconds limits
    function_provisioned_concurrency_config = optional(string)        # Function timeout in seconds limits
    function_trace_config_is_enabled        = optional(bool, false)   # Define if tracing is enabled for the resource
    function_source_details = optional(object({                       # The source details for the Function. The function can be created from various sources. (Required) The OCID of the PbfListing this function is sourced from. (Required) Type of the Function Source. Possible values: PRE_BUILT_FUNCTIONS
      pbf_listing_id = string
      source_type    = string
    }))
    invoke_function = optional(object({
      make_invoke                         = optional(bool, false)
      invoke_create_duration              = optional(string, "30s")         # Time to wait the function became ready, ex: 30s
      invoke_function_body                = optional(any)                   # The body of the function invocation. Note: The maximum size of the request is limited. This limit is currently 6MB and the endpoint will not accept requests that are bigger than this limit
      fn_intent                           = optional(string, "httprequest") # An optional intent header that indicates to the FDK the way the event should be interpreted, can be httprequest or cloudevent
      fn_invoke_type                      = optional(string, "sync")        # Indicates whether Oracle Functions should execute the request and return the result ('sync') of the execution, or whether Oracle Functions should return as soon as processing has begun ('detached') and leave result handling to the function
      fn_invoke_base64_encode_content     = optional(bool, false)           # Encodes the response returned, if any, in base64. It is recommended to set this to true to avoid corrupting the returned response, if any, in Terraform state. The default value is false
      invoke_function_body_base64_encoded = optional(string)                # The Base64 encoded body of the function invocation. Base64 encoded input avoids corruption in Terraform state. Cannot be defined if invoke_function_body or input_body_source_path is defined. Note: The maximum size of the request is limited. This limit is currently 6MB and the endpoint will not accept requests that are bigger than this limit
      invoke_input_body_source_path       = optional(string)                # An absolute path to a file on the local system that contains the input to be provided to the function. Cannot be defined if invoke_function_body or invoke_function_body_base64_encoded is defined. Note: The maximum size of the request is limited. This limit is currently 6MB and the endpoint will not accept requests that are bigger than this limit
    }))
    defined_tags = optional(map(any))
    tags         = optional(map(any))
  }))
  default = null
}
