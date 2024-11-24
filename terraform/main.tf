resource "aws_vpc" "VPC-MAIN" {
  cidr_block = "10.0.0.0/16"
  assign_generated_ipv6_cidr_block = true
}



# Publica

resource "aws_subnet" "subnet_publica" {
  vpc_id     = aws_vpc.VPC-MAIN.id
  cidr_block = "10.0.1.0/24"
  availability_zone = var.Regi_sub
}

resource "aws_internet_gateway" "gw_publico" {
  vpc_id = aws_vpc.VPC-MAIN.id
}


resource "aws_route_table" "Public_RTB" {
  vpc_id = aws_vpc.VPC-MAIN.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw_publico.id
  }

}

resource "aws_route_table_association" "Publica_Assoc" {
  subnet_id      = aws_subnet.subnet_publica.id
  route_table_id = aws_route_table.Public_RTB.id
}



# Privada

resource "aws_subnet" "subnet_privada" {
  vpc_id     = aws_vpc.VPC-MAIN.id
  cidr_block = "10.0.2.0/24"
  availability_zone = var.Regi_sub
}


resource "aws_route_table" "Privada_RTB" {
  vpc_id = aws_vpc.VPC-MAIN.id

}

resource "aws_route_table_association" "privada_Assoc" {
  subnet_id      = aws_subnet.subnet_privada.id
  route_table_id = aws_route_table.Privada_RTB.id
}



# EC2

resource "aws_security_group" "secure_good" {
  name        = "HTTP/HTTPS"
  vpc_id      = aws_vpc.VPC-MAIN.id
}

#* Security Group rules for ssh ipv4 and ipv6
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.secure_good.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv6" {
  security_group_id = aws_security_group.secure_good.id
  cidr_ipv6         = "::/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.secure_good.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv6" {
  security_group_id = aws_security_group.secure_good.id
  cidr_ipv6         = "::/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

#* Security Group rules for https ipv4 and ipv6
resource "aws_vpc_security_group_ingress_rule" "allow_https_ipv4" {
  security_group_id = aws_security_group.secure_good.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_ipv6" {
  security_group_id = aws_security_group.secure_good.id
  cidr_ipv6         = "::/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

#* Security Group eggress rules for ssh ipv4 and ipv6
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.secure_good.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.secure_good.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
}

resource "aws_instance" "terraform-ec2-1" {
  ami           = "ami-0866a3c8686eaeeba"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subnet_publica.id
  availability_zone = var.Regi_sub
  vpc_security_group_ids = [aws_security_group.secure_good.id]
  associate_public_ip_address = true
  key_name = var.key_pair_name

  depends_on = [
    aws_subnet.subnet_publica,
    aws_security_group.secure_good,
    aws_route_table_association.Publica_Assoc
  ]
}



#RDS
resource "aws_subnet" "subnet_privada_2" {
  vpc_id     = aws_vpc.VPC-MAIN.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_db_subnet_group" "subnet_rds" {
  name       = "rds-subnet-group"
  subnet_ids = [
    aws_subnet.subnet_privada.id,
    aws_subnet.subnet_privada_2.id
  ]
}

resource "aws_security_group" "rds" {
  name        = "rds-security-group"
  vpc_id      = aws_vpc.VPC-MAIN.id

  ingress {
    from_port       = 3306 # Puerto para MySQL
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.secure_good.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "RDS_DB" {
  allocated_storage = 20
  engine = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  db_name = "RDS_REDI"
  username = "admin"
  password = "12345678"
  parameter_group_name = "default.mysql8.0"
  db_subnet_group_name = aws_db_subnet_group.subnet_rds.name
  publicly_accessible  = false

  vpc_security_group_ids = [aws_security_group.rds.id]
}