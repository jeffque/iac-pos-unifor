terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

provider "aws" {
    region = "us-east-1"
}

data "aws_ami" "ubuntu" {
    most_recent = true
    owners = ["099720109477"] # owner indica que é a canonical

    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }
}

resource "aws_vpc" "main" {
    cidr_block = "192.168.10.0/24"
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
        Name = "vpc-aula-terraform"
    }
}

resource "aws_internet_gateway" "main" {
    # para herdar a rede para configurar o gateway
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "igw-aula"
    }
}

resource "aws_subnet" "public" {
    vpc_id = aws_vpc.main.id
    cidr_block = "192.168.10.0/24"

    map_public_ip_on_launch = true

    tags = {
        Name = "subnet-publica"
    }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }

    tags = {
        Name = "rota-publica-internet"
    }
}

resource "aws_route_table_association" "public" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.public.id

}

resource "aws_security_group" "webserver" {
    name = "sgp-webserver-aula"
    description = "Permitir trafego HTTP na porta 80 e SSH na 22"

    vpc_id = aws_vpc.main.id

    ingress {
        description = "HTTP feliz =D"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "SSH, vamos ser neurados or not"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] # isso é inseguro, só pq é um lab
    }

    egress {
        description = "permite tudo"
        from_port = 0
        to_port = 0
        protocol = "-1"

        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "sgp-webserver-aula"
    }
}

resource "aws_key_pair" "deployer" {
  key_name   = "aula-terraform-key"
  public_key = file("./id_ed25519.pub")
}

resource "aws_instance" "webserver" {
    ami = data.aws_ami.ubuntu.id
    instance_type = "t3.micro"

    # bora herdar as coisas dos recursos anteriores
    subnet_id = aws_subnet.public.id
    vpc_security_group_ids = [ aws_security_group.webserver.id ]

    key_name = aws_key_pair.deployer.key_name

    # eu poderia HIPOTETICAMENTE fazer isso abaixo, mas o ideal
    # seria deixar isso para a configuração (aka ansible)
    #

    #user_data = <<-EOF
    #        #!/bin/bash
    #        apt update
    #        apt upgrade -y
    #        apt install nginx -y
    #
    #        EOF
    tags = {
        Name = "ec2-webserver-aula-terraform"
    }
}

output "ansible_ini" {
    description = "arquivo .ini pronto para ser consumido pelo ansible"
    value = <<-EOF
        [servidores_web]
        ${aws_instance.webserver.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/terraform/id_ed25519
        EOF
}

output "url_servidor" {
    description = "URL para acesso ao Nginx na EC2"
    value = "http://${aws_instance.webserver.public_ip}"
}