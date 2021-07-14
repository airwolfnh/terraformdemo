resource "local_file" "foo" {
  content = " Blah \n aaaa"

  filename = "${path.module}/foo.bar"
}

data "template_file" "init" {
  template = "${file("${path.module}/init.tpl")}"

  vars = {
    consul_address = "${var.address}"
  }
}

resource "null_resource" "wait_test" {
  triggers = {
    version = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<EOT
        i="0" ; while [ $i -lt 4 ] ;do sleep 1 ; echo Counter:$i ; i=$[$i+1] ; done
    EOT
  }
}


resource "null_resource" "example1" {
  depends_on = [null_resource.wait_test]

  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "echo $FOO $TEST > env_vars.txt"

    environment = {
      FOO  = "bar"
      TEST = upper("${var.test}")
    }
  }
}

module "moduleA" {
  source = "./moduleA"
}

#module "AzureVirtualMachine" {
#  source = "./azure"
#}
