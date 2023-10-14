# Packer configuration
source "nutanix" "demo_image" {
  nutanix_username  = "" # Prism Central username
  nutanix_password  = "" # Prism Central password
  nutanix_endpoint  = "x..x.x" # Prism central IP / Hostname
  cluster_name      = "POC" # Prism Cluster name
  os_type           = "Linux"   # "Linux" or "Windows"
  image_name        = "my-nutanix-image"  # Name for the output image
  image_description = "Description of the output image"
  shutdown_command  = "sudo shutdown -h now"  # Command line to shutdown your temporary VM
  shutdown_timeout  = "5m"  # Timeout for VM shutdown (format: 2m)
  vm_force_delete   = false  # Delete VM even if the build is not successful (default is false)
  communicator      = "ssh"  # Protocol used for Packer connection (e.g., "winrm" or "ssh"). Default is "ssh"
  ssh_username      = "centos"  # User for SSH connection initiated by Packer
  ssh_password      = "packer"  # Password for the SSH user
  nutanix_insecure  = true # Authorize connection to Prism Central without valid certificate
  user_data = base64encode(file("cloud-config.yaml"))

  # Configure VM disks
  vm_disks {
    image_type       = "DISK_IMAGE"  # Create disk from Nutanix image library
    source_image_uri = "https://yum.oracle.com/templates/OracleLinux/OL9/u2/x86_64/OL9U2_x86_64-kvm-b197.qcow"  # Name of the image used as disk source
    disk_size_gb     = 40      # Size of the disk (in gigabytes)
  }
    vm_nics {
    subnet_name = "VLAN23"
  }
}

variables {
  basearch = "x86_64"
}

build {
  sources = ["source.nutanix.demo_image"]
  provisioner "shell" {
    inline = [
      "sleep 30",
      "sudo yum update -y",
      "sudo yum install nginx -y",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx",
      "sudo systemctl status nginx",
      "sudo systemctl stop firewalld",
      "sudo systemctl disable firewalld"
    ]
  }
}

