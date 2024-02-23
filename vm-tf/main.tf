resource "google_compute_network" "hashicat" {
  name                    = "hashicat-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "hashicat" {
  name          = "dany-subnet"
  region        = "us-central1"
  network       = google_compute_network.hashicat.self_link
  ip_cidr_range = "10.0.0.0/24"
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

resource "google_compute_firewall" "internal-allow" {
  name    = "allow-internal-traffic"
  network = google_compute_network.hashicat.self_link

  allow {
    protocol = "tcp"
  }

  source_ranges = [google_compute_subnetwork.hashicat.ip_cidr_range]
  target_tags   = ["http-server"]
}

resource "tls_private_key" "ssh-key" {
  algorithm = "ED25519"
}

resource "google_compute_instance" "hashicat" {
  count        = 2
  name         = count.index == 0 ? "production" : "worker"
  machine_type = "n2-standard-2"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.hashicat.self_link
    access_config {
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${chomp(tls_private_key.ssh-key.public_key_openssh)} terraform"
   
  }

  tags = ["http-server"]

  labels = {
    name = "hashicat-${count.index + 1}"
  }
}

resource "null_resource" "configure-cat-app" {
  count = 1

  depends_on = [
    google_compute_instance.hashicat,
  ]

  triggers = {
    build_number = timestamp()
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "echo | sudo apt-add-repository ppa:ansible/ansible",
      "sudo apt install ansible -y",
      "sudo apt install nginx -y",
      "sudo apt install git -y",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      timeout     = "300s"
      private_key = tls_private_key.ssh-key.private_key_pem
      host        = google_compute_instance.hashicat[count.index].network_interface.0.access_config.0.nat_ip
    }
  }
}

resource "null_resource" "configure-ansible" {
  count = 1

  depends_on = [
    null_resource.configure-cat-app,
  ]

  triggers = {
    build_number = timestamp()
  }

  provisioner "remote-exec" {
    inline = [
      "sudo git clone https://github.com/LDGA45/Practica1_SA.git",
      "sudo ansible-playbook -i ./Practica1_SA/Ansible/inventario.ini ./Practica1_SA/Ansible/comando1.yml",
      "sudo service nginx reload"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      timeout     = "300s"
      private_key = tls_private_key.ssh-key.private_key_pem
      host        = google_compute_instance.hashicat[count.index].network_interface.0.access_config.0.nat_ip
    }
  }
}
