variable "aws_region" {
  default = env("AWS_REGION")
}

variable "ubuntu_version" {
  type    = string
  default = "focal-20.04"
}

variable "sysbox_version" {
  type    = string
  default = "0.4.1"
}

data "amazon-ami" "ubuntu" {
  filters = {
    virtualization-type = "hvm"
    name                = "ubuntu-minimal/images/hvm-ssd/*ubuntu-${var.ubuntu_version}-amd64-minimal-*"
    root-device-type    = "ebs"
  }
  owners      = ["099720109477"]
  most_recent = true
  region      = var.aws_region
}

source "amazon-chroot" "ubuntu" {
  region     = var.aws_region
  source_ami = data.amazon-ami.ubuntu.id
  ami_name   = "sysbox-${var.sysbox_version}"

  # enable for m5+ instance types with NVMe
  # nvme_device_path = "/dev/nvme1n1p"
  # device_path      = "/dev/sdf"

  tags = {
    os_version    = "Ubuntu"
    release       = "${var.ubuntu_version}"
    base_ami_name = "{{ .SourceAMIName }}"
  }
}

build {
  sources = [
    "source.amazon-chroot.ubuntu"
  ]

  provisioner "file" {
    destination = "/tmp/"
    source      = "./conf"
  }

  provisioner "shell" {
    execute_command = "sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
    ]
    inline = [
      "cp /tmp/conf/apt/* /etc/apt/apt.conf.d/",
      "sed -i 's|archive.ubuntu.com|${var.aws_region}.ec2.archive.ubuntu.com|g' /etc/apt/sources.list",
      "apt-get clean -yq",
      "apt-get update -yq",
      "apt-get upgrade -yq",
    ]
  }

  provisioner "shell" {
    execute_command = "sudo -S bash -c '{{ .Vars }} {{ .Path }}'"
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
    ]
    scripts = [
      "provisioners/install-utils.sh",
      "provisioners/install-dns-fix.sh",
      "provisioners/install-ssm-manager.sh",
      "provisioners/install-cloudwatch-agent.sh",
      "provisioners/install-docker-and-sysbox.sh",
      "provisioners/cleanup.sh",
    ]
  }

  post-processor "manifest" {
    output = "base.manifest.json"
  }
}
