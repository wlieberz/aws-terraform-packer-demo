
variable "ami_name" {
  type    = string
  default = "front-end-server-wl-3tier"
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "amazon-ebs" "front-end-server-wl-3tier-src" {
  ami_name      = "front-end-server-wl-${local.timestamp}"
  instance_type = "t2.micro"
  region        = "us-east-2"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"] # Canonical
  }
  ssh_username = "ubuntu"
}

build {
  sources = ["source.amazon-ebs.front-end-server-wl-3tier-src"]
  provisioner "ansible" {
    playbook_file = "./front-end-server.yml"
  }

}