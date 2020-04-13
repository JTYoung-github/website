
variable "user" {
  description = "user required to log in"
  type        = string
  default     = "centos"
}

variable "hostname" {
  description = "hostname to connect to"
  type        = string
  default     = "<hostname to update>"
}


resource "null_resource" "example1" {

provisioner "file" {
        connection {
        type = "ssh"
        user = var.user
        host = var.hostname
        private_key = "${file("Linux.pem")}"
    }

        source      = "createadmin"
        destination = "/tmp/createadmin"
  }


  provisioner "remote-exec" {
     connection {
      type = "ssh"
      host = var.hostname
      user = var.user
      private_key = "${file("Linux.pem")}" 
    }
    inline = [

	"cd /website/"
	"sudo /usr/local/bin/docker-compose down &"
	"rm -rf /website/*",
	"sudo git clone https://github.com/stbotolphs/website.git /website/"

	"sudo /usr/local/bin/docker-compose build --pull",
        "sudo /usr/local/bin/docker-compose up &",

	#mechanism for getting the website up before terraform closes it
	"sleep 120"
        "sudo chmod +777 /tmp/createadmin",
        "sudo /tmp/createadmin",

        #mechanism for allowing script to run before it's deleted
        "sleep 10",
        "sudo rm -f /tmp/createadmin",
        "touch ./websiteup"	

       #"touch /home/centos/terraformtest.txt"
    ]
  }
}

