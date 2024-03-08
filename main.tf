terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.39.1"
    }
  }

  backend "s3" {
    bucket = "tf-backend-06-20240308"
    key    = "terraform.tfstate"
    region = "ap-east-1"
    # dynamodb_table = "terraform-lock"
  }
}



# Configure the AWS Provider
provider "aws" {
  region = "ap-east-1"
}

# Create a VPC


variable "envs" {
  type    = list(string)
  default = ["dev", "prd", ""]

}

module "vpc_list" {
  for_each = toset([for s in var.envs : s if s != ""])
  source   = "./custom_vpc"
  env      = each.key
}

resource "aws_s3_bucket" "tf_backend" {
  bucket = "tf-backend-06-20240308"
  tags = {
    Name = "tf_backend"
  }
  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_ownership_controls" "tf_backend_ownership" {
  bucket = aws_s3_bucket.tf_backend.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "tf_backend_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.tf_backend_ownership]
  bucket     = aws_s3_bucket.tf_backend.id
  acl        = "private"
}

resource "aws_s3_bucket_versioning" "tf_backend_versioning" {
  bucket = aws_s3_bucket.tf_backend.id
  versioning_configuration {
    status = "Enabled"
  }
}

#	16.162.78.82
# resource "aws_eip" "eip_test" {

#   provisioner "local-exec" {
#     command = "echo ${aws_eip.eip_test.public_ip}"
#   }
#   tags = {
#     Name = "Test"

#   }
# }
resource "aws_instance" "web-ec2" {
  ami           = "ami-047c2b27e29f3093e"
  instance_type = "t3.micro"
  key_name      = "moonkey"
  tags = {
    Name = "my-00-web"
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("moonkey.pem")
    host        = self.public_ip

  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt -y install nginx",
      "sudo systemctl start nginx"
    ]
  }

  provisioner "local-exec" {
    command = "echo ${self.public_ip}"
  }
}


