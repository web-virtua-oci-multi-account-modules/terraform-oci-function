resource "null_resource" "exec_oci_registry_login" {
  count = length(local.images_builds) > 0 ? 1 : 0

  provisioner "local-exec" {
    command = "echo '${var.oci_dockerhub_token}' | docker login ${var.oci_registry_endpoint} --username ${var.oci_tenancy_namespace}/${var.oci_dockerhub_username} --password-stdin"
  }
}

resource "null_resource" "exec_docker_builds_pushs" {
  count = length(local.images_builds)

  provisioner "local-exec" {
    command     = "image=$(docker images | grep ${lower(local.images_builds[count.index].function_name)} | awk -F ' ' '{print $3}') ; docker rmi -f $image &> /dev/null ; echo $image"
    working_dir = local.images_builds[count.index].application_data_source
  }

  provisioner "local-exec" {
    command     = "docker build -t ${lower(local.images_builds[count.index].function_name)} ."
    working_dir = local.images_builds[count.index].application_data_source
  }

  provisioner "local-exec" {
    command     = "image=$(docker images | grep ${lower(local.images_builds[count.index].function_name)} | awk -F ' ' '{print $3}') ; docker tag $image ${local.images_builds[count.index].registry_uri}"
    working_dir = local.images_builds[count.index].application_data_source
  }

  provisioner "local-exec" {
    command     = "docker push ${local.images_builds[count.index].registry_uri}"
    working_dir = local.images_builds[count.index].application_data_source
  }

  depends_on = [null_resource.exec_oci_registry_login]
}
