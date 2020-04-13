provider "aws" {
  access_key = ""
  secret_key = ""
  region = "eu-west-1"
}


variable "key_pair" {
  description = "key pair used for this deployment"
  type        = string
  default     = "Linux"
}

variable "user" {
  description = "user required to log in"
  type        = string
  default     = "centos"
}

resource "aws_security_group" "instance" {
  name = "cms-dev-sg"
  ingress {
    description = "Application ports"
    from_port   = 8000
    to_port     = 8003
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    description = "ssh ports"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    egress {
    description = "general"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


}


resource "aws_instance" "webserver" {
  ami                    = "ami-0b850cf02cc00fdc8"
  instance_type          = "t2.micro"
  key_name               = var.key_pair  #  "Linux"
  vpc_security_group_ids = [aws_security_group.instance.id]
  
  #need to upload a file with some of the commands, because it doesn't work using Terraform's syntax. This file contains the command to create a new Admin
    provisioner "file" {
        connection {
        type = "ssh"
        user = var.user
        host = self.public_ip
        private_key = "${file("Linux.pem")}"
    }

        source      = "createadmin"
        destination = "/tmp/createadmin"
  }
	


    provisioner "remote-exec" {
    	connection {
      	type = "ssh"
      	user = var.user
      	host = self.public_ip
      	private_key = "${file("Linux.pem")}"
    }
    
    inline = [
      
        "sudo yum install -y yum-utils device-mapper-persistent-data lvm2 git python3 vim",
        "sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo",
        "sudo yum install -y docker-ce",
        "sudo systemctl start docker",
        "sudo systemctl enable docker",
	"sudo gpasswd -a $(whoami) docker",

        "sudo curl -L https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose",
        "sudo chmod +x /usr/local/bin/docker-compose",

        "sudo mkdir /website",
        "sudo chmod +777 /website",

        "sudo git clone https://github.com/stbotolphs/website.git /website/",

        "cd /website",
        "sudo /usr/local/bin/docker-compose build --pull",
        "sudo /usr/local/bin/docker-compose up &",
	#mechanism for getting the website up before terraform closes it
	"sleep 120",
	"sudo chmod +777 /tmp/createadmin",
	"sudo /tmp/createadmin",
	#mechanism for allowing script to run before it's deleted
   	"sleep 10",
	"sudo rm -f /tmp/createadmin",
	"touch ./websiteup"
        ]
  }
	
  tags = {
    	Name = "cms-dev-vm"
  }

}

