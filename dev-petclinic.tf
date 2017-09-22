resource "aws_instance" "dev" {
  ami                    = "${var.ami}"
  instance_type          = "t2.micro"
  key_name               = "${var.aws_key_pair}"
  vpc_security_group_ids = ["${aws_security_group.web.id}"]

  tags {
    Name   = "dev.petclinic.liatr.io"
    Uptime = "critical"
  }

  provisioner "remote-exec" {
    script = "${path.module}/provision.sh"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file("${var.private_key_path}")}"
    }
  }

  provisioner "file" {
    source      = "./traefik-https.toml"
    destination = "/home/ec2-user/traefik.toml"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file("${var.private_key_path}")}"
    }
  }

  provisioner "remote-exec" {
    script = "${path.module}/launch-traefik.sh"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file("${var.private_key_path}")}"
    }
  }

  provisioner "remote-exec" {
    script = "${path.module}/update_keys.sh"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file("${var.private_key_path}")}"
    }
  }
}

resource "aws_route53_record" "dev-petclinic" {
  zone_id = "${data.aws_route53_zone.liatrio.zone_id}"
  name    = "dev.petclinic.liatr.io"
  type    = "A"
  ttl     = 300
  records = ["${aws_instance.dev.public_ip}"]
}

resource "aws_route53_record" "dev-gameoflife" {
  zone_id = "${data.aws_route53_zone.liatrio.zone_id}"
  name    = "dev.gameoflife.liatr.io"
  type    = "A"
  ttl     = 300
  records = ["${aws_instance.dev.public_ip}"]
}
