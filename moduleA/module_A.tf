resource "null_resource" "module_a_example" {
  #triggers = {
  #  always_run = "${timestamp()}"
  #}

  provisioner "local-exec" {
    command = "echo MODULE A $FOO $TEST > env_vars_module_A.txt"

    environment = {
      FOO  = "bar"
      TEST = "${var.test}"
    }
  }
}
