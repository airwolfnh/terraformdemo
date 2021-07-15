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
        i="0" ; while [ $i -lt 2 ] ;do sleep 1 ; echo Counter:$i ; i=$[$i+1] ; done
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

data "local_file" "whitelist-ips" {
    filename = "${path.module}/ips.txt"
}

resource "null_resource" "example_data_use" {
  depends_on = [null_resource.wait_test]
  
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "echo IP: $TEST > white_list.txt"
    environment = {
      FOO  = "bar"
      TEST = "${data.local_file.whitelist-ips.content}"
    }
  }
}

module "moduleA" {
  source = "./moduleA"
}

#module "AzureVirtualMachine" {
#  source = "./azure"
#}

output "data_test" {
  description = "Data test"
  value       = data.template_file.init
}

