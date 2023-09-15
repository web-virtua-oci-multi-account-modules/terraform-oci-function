output "application" {
  description = "Application"
  value       = try(oci_functions_application.create_application, null)
}

output "application_id" {
  description = "Application ID"
  value       = try(oci_functions_application.create_application[0].id, null)
}

output "application_name" {
  description = "Application name"
  value       = try(oci_functions_application.create_application[0].display_name, null)
}

output "functions" {
  description = "Functions"
  value       = try(oci_functions_function.create_functions, null)
}

output "invoke_functions" {
  description = "Invoke functions"
  value       = try(oci_functions_invoke_function.create_invoke_functions, null)
}
