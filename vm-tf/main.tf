resource "google_service_account" "default" {
  account_id   = "my-custom-sa"
  display_name = "Custom SA for VM Instance"
}

resource "google_compute_instance" "default" {
  name =  "hola"
  machine_type = "n2-standard-2"
  zone         = "us-central1-a"

  tags = ["foo", "bar"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        my_label = "value"
      }
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "NVME"
  }

  network_interface {
    network = "default"
    subnetwork = "default"

    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    foo = "bar"
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y git
    sudo git clone https://github.com/LDGA45/Practica1_SA.git /github
    sudo apt-get install -y ansible
    sudo ansible-playbook /github/ansible/playbook.yml
  EOF

  service_account {
    scopes = ["cloud-platform"]
  }

}

resource "google_compute_firewall" "allow-http" {
  name    = "allow-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
}
#########################################################################
#
  #provisioner "remote-exec" {
   # inline = [
      #"sudo apt-get update -y",
     # "Sudo apt-get software-properties-common",
    #  "echo | sudo apt-add-repository-yes-update ppa:ansible/ansible",
   #   "sudo apt install ansible -y",
  #    "sudo apt install nginx -y",
 #    "sudo apt install git -y",
#    ]



