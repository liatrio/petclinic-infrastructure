resource "aws_security_group" "web" {
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "dev" {
  ami                    = "${data.aws_ami.latest_ami.id}"  # Amazon Linux
  instance_type          = "t2.micro"
  key_name               = "${var.aws_key_pair}"
  vpc_security_group_ids = ["${aws_security_group.web.id}"]

  tags {
    Name   = "dev-petclinic.liatr.io"
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
    source      = "./traefik.toml"
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
}

resource "aws_instance" "qa" {
  ami                    = "${data.aws_ami.latest_ami.id}"  # Amazon Linux
  instance_type          = "t2.micro"
  key_name               = "${var.aws_key_pair}"
  vpc_security_group_ids = ["${aws_security_group.web.id}"]

  tags {
    Name   = "qa-petclinic.liatr.io"
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
    source      = "./traefik.toml"
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
}

resource "aws_instance" "prod" {
  ami                    = "${data.aws_ami.latest_ami.id}"  # Amazon Linux
  instance_type          = "t2.micro"
  key_name               = "${var.aws_key_pair}"
  vpc_security_group_ids = ["${aws_security_group.web.id}"]

  tags {
    Name   = "prod-petclinic.liatr.io"
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
    source      = "./traefik.toml"
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
}

resource "aws_route53_record" "dev" {
  zone_id = "${data.aws_route53_zone.liatrio.zone_id}"
  name    = "dev-petclinic.liatr.io"
  type    = "A"
  ttl     = 300
  records = ["${aws_instance.dev.public_ip}"]
}

resource "aws_route53_record" "qa" {
  zone_id = "${data.aws_route53_zone.liatrio.zone_id}"
  name    = "qa-petclinic.liatr.io"
  type    = "A"
  ttl     = 300
  records = ["${aws_instance.qa.public_ip}"]
}

resource "aws_route53_record" "prod" {
  zone_id = "${data.aws_route53_zone.liatrio.zone_id}"
  name    = "petclinic.liatr.io"
  type    = "A"
  ttl     = 300
  records = ["${aws_instance.prod.public_ip}"]
}

resource "aws_route53_record" "prod-1" {
  zone_id = "${data.aws_route53_zone.liatrio.zone_id}"
  name    = "petclinic-1.liatr.io"
  type    = "A"
  ttl     = 300
  records = ["${aws_instance.prod.public_ip}"]
}

resource "aws_route53_record" "prod-2" {
  zone_id = "${data.aws_route53_zone.liatrio.zone_id}"
  name    = "petclinic-2.liatr.io"
  type    = "A"
  ttl     = 300
  records = ["${aws_instance.prod.public_ip}"]
}
