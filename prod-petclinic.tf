resource "aws_vpc" "prod" {
  cidr_block = "10.0.0.0/16"

  tags {
    Name = "prod-petclinic"
  }
}

resource "aws_subnet" "proda" {
  vpc_id            = "${aws_vpc.prod.id}"
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-west-2a"

  tags {
    Name = "proda-petclinic"
  }
}

resource "aws_subnet" "prodb" {
  vpc_id            = "${aws_vpc.prod.id}"
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2b"

  tags {
    Name = "prodb-petclinic"
  }
}

resource "aws_internet_gateway" "prod" {
  vpc_id = "${aws_vpc.prod.id}"

  tags {
    Name = "prod-petclinic"
  }
}

resource "aws_route_table" "prod" {
  vpc_id = "${aws_vpc.prod.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.prod.id}"
  }

  tags {
    Name = "prod-petclinic"
  }
}

resource "aws_route_table_association" "proda" {
  subnet_id      = "${aws_subnet.proda.id}"
  route_table_id = "${aws_route_table.prod.id}"
}

resource "aws_route_table_association" "prodb" {
  subnet_id      = "${aws_subnet.prodb.id}"
  route_table_id = "${aws_route_table.prod.id}"
}

resource "aws_security_group" "prod_webserver" {
  vpc_id = "${aws_vpc.prod.id}"

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

resource "aws_security_group" "prod_alb" {
  vpc_id = "${aws_vpc.prod.id}"

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

resource "aws_instance" "proda" {
  ami                         = "${var.ami}"
  instance_type               = "t2.micro"
  key_name                    = "${var.aws_key_pair}"
  subnet_id                   = "${aws_subnet.proda.id}"
  vpc_security_group_ids      = ["${aws_security_group.prod_webserver.id}"]
  associate_public_ip_address = true
  availability_zone           = "us-west-2a"

  tags {
    Name   = "proda.petclinic.liatr.io"
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
    source      = "./traefik-http.toml"
    destination = "/home/ec2-user/traefik.toml"

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

resource "aws_instance" "prodb" {
  ami                         = "${var.ami}"
  instance_type               = "t2.micro"
  key_name                    = "${var.aws_key_pair}"
  subnet_id                   = "${aws_subnet.prodb.id}"
  vpc_security_group_ids      = ["${aws_security_group.prod_webserver.id}"]
  associate_public_ip_address = true
  availability_zone           = "us-west-2b"

  tags {
    Name   = "prodb.petclinic.liatr.io"
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
    source      = "./traefik-http.toml"
    destination = "/home/ec2-user/traefik.toml"

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

resource "aws_s3_bucket" "prod_alb_log" {
  bucket = "liatrio-petclinic-access-log"
  acl    = "private"

  tags = {
    Name = "liatrio-petclinic-access-log"
  }
}

resource "aws_alb" "prod" {
  name            = "prod-petclinic"
  internal        = false
  security_groups = ["${aws_security_group.prod_alb.id}"]
  subnets         = ["${aws_subnet.proda.id}", "${aws_subnet.prodb.id}"]
}

resource "aws_alb_target_group" "prod_petclinic" {
  name     = "prod-petclinic"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.prod.id}"
}

resource "aws_route53_record" "prod" {
  zone_id = "${data.aws_route53_zone.liatrio.zone_id}"
  name    = "petclinic.liatr.io"
  type    = "A"

  alias {
    name                   = "${aws_alb.prod.dns_name}"
    zone_id                = "${aws_alb.prod.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "proda" {
  zone_id = "${data.aws_route53_zone.liatrio.zone_id}"
  name    = "proda-petclinic.liatr.io"
  type    = "A"
  ttl     = 300
  records = ["${aws_instance.proda.public_ip}"]
}

resource "aws_route53_record" "prodb" {
  zone_id = "${data.aws_route53_zone.liatrio.zone_id}"
  name    = "prodb-petclinic.liatr.io"
  type    = "A"
  ttl     = 300
  records = ["${aws_instance.prodb.public_ip}"]
}
