# TODO: Designate a cloud provider, region, and credentials
provider "aws" {
  region     = "us-west-2"
  access_key = "my-access-key"
  secret_key = "my-secret-key"
}
provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "tfstate"
     
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
    bucket = aws_s3_bucket.terraform_state.id

    versioning_configuration {
      status = "Enabled"
    }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "app-state"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
# TODO: provision 4 AWS t2.micro EC2 instances named Udacity T2
resource "aws_instance" "web-server-instance" {

  count = 4

  ami               = ami-00874d747dde814fa
  subnet_id         = subnet-0028e2904543048cc
  vpc_id            = vpc-038aa9684d3a97d7b
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
