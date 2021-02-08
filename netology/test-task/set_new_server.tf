resource "aws_key_pair" "server_admin" {
  key_name   = "server.admin"i
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDqG1R/RTkvnkcT9f1XuCSQN0K+sVVxRIQAg180oxmCA8lm1BD1+JhahrWoKNe7KiZuJYcWKdD61m6TzlJD6GiFmrzJG9Mu6nn/C+mv7ST4vv+oP4wjdfkBs63XODsVMwDXRcvAElnUZhA4eWeRXlZzzg8m/mIkVGXq3w4hqatAuLPHp+1HwrB09XgqjNlpTC31e+EhqnJluKdNqmLeciIJ8gaB39EJHCHSIUcqk8BevitYDwd2m/lvUOOJbiSRZmkaAhVADYiKfb7CxYsCahviNnAQvBIf6Wl3uKelni/Q9DV1JFWqjoctlzVSYdeWzkc5w2/Ypxj/lSeTMWf7rlNFBdFMqiNPSh+0U3cXd/VLqvdKrKefEebcfYODlQwbxqDl3CdlGOvPlKxpBmvbdq9vmzoqruKh8CDKKbKw/I8vONnLwfqByoUu46NIkG0AbMDmrfvgJPnotkyFcwxkp3c78vjXOd+GyoW8oRUR68w9BPzpGvsUDKBui/T7RJ9tC8aaS3lHru4WI26nuhYC3kaUeJJZB1Vj64EePGjj8vkAhhEc+zpszEw2bUaHL6NTW7z9PADqMctePnYHQgn594AYn25D4XX69hsSHfmcvV3ZR6C2dOZc+LecwEMASliHGrS/zTO6W2OjoS13bQkfTfKmtjQ8MQUmlLaiOhoDu5RazQ== server@admin"
}

resource "aws_security_group" "server_access_sg" {
  description = "Direct connection to mysql and ssh"
  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    },
  ]
  ingress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description = "mysql"
      from_port   = 3306
      ipv6_cidr_blocks = [
        "::/0",
      ]
      prefix_list_ids = []
      protocol        = "tcp"
      security_groups = []
      self            = false
      to_port         = 3306
    },
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description = "ssh"
      from_port   = 22
      ipv6_cidr_blocks = [
        "::/0",
      ]
      prefix_list_ids = []
      protocol        = "tcp"
      security_groups = []
      self            = false
      to_port         = 22
    },
  ]
  name   = "server_access_sg"
  tags   = {}
  vpc_id = "vpc-qwerty1"

  timeouts {}
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-20.04-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
resource "aws_instance" "db_server" {
  ami                     = "ami-0b418580298265d5c" # Ubuntu Server 20.04 LTS SSD
  instance_type           = "t2.micro"
  key_name                = "server.admin"
  security_groups         = ["server_access_sg"]
  ebs_optimized           = true
  disable_api_termination = false

  root_block_device {
    volume_size = "300"
    volume_type = "gp2"
  }

  tags = {
    "Name" = "db_server"
  }
}

