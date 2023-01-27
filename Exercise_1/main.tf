# TODO: Designate a cloud provider, region, and credentials
provider "aws" {
  region     = "us-west-2"
  access_key = "my-access-key"
  secret_key = "my-secret-key"
}

# TODO: provision 4 AWS t2.micro EC2 instances named Udacity T2
resource "aws_instance" "web-server-instance" {

  count = 4

  ami               = var.AMI_ID
  instance_type     = "t2.micro"
  availability_zone = "us-east-1b"
  key_name          = "udaterform	"
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.web-server-nic.id
  }
  root_block_device {
    volume_size = "8"
  }
  iam_instance_profile = aws_iam_instance_profile.training_profile.name
  depends_on = [aws_eip.one]
  user_data = <<-EOF
                #!/bin/bash
                python3 /home/ubuntu/setting_instance.py
                EOF
  tags = {
    Name = var.INSTANCE_NAME
  }
}


# TODO: provision 2 m4.large EC2 instances named Udacity M4
