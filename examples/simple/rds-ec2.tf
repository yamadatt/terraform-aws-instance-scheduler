# vpc
resource "aws_vpc" "poc-schedule-vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = "yamada-schedule-poc"
  }
}


## private subnet
resource "aws_subnet" "private-subnet-1a" {
  vpc_id            = aws_vpc.poc-schedule-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "private-subnet-1a"
  }
}

resource "aws_subnet" "private-subnet-1c" {
  vpc_id            = aws_vpc.poc-schedule-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-1c"
  tags = {
    Name = "private-subnet-1c"
  }
}


# ---------------------------
# RDS
# ---------------------------
resource "aws_db_subnet_group" "private-db" {
  name       = "private-db"
  subnet_ids = ["${aws_subnet.private-subnet-1a.id}", "${aws_subnet.private-subnet-1c.id}"]
  tags = {
    Name = "private-db-subnet-group"
  }
}

resource "aws_db_instance" "test-db" {
  identifier        = "test-db"
  allocated_storage = 20
  storage_type      = "gp3"
  engine            = "postgres"
  engine_version    = "12.12"
  instance_class    = "db.t4g.micro"
  db_name           = "staging"
  # username             = "staginguser"
  # password             = "stagingpass"
  # vpc_security_group_ids  = [aws_security_group.praivate-db-sg.id]
  db_subnet_group_name = aws_db_subnet_group.private-db.name
  skip_final_snapshot  = true
  publicly_accessible  = false
  tags = {
    Stop = "Night"
    Stop = "Weekend"
  }

}

resource "aws_security_group" "praivate-db-sg" {
  name   = "praivate-db-sg"
  vpc_id = aws_vpc.poc-schedule-vpc.id
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.poc-schedule-vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "private-db-sg"
  }
}


# ---------------------------
# EC2
# ---------------------------
# Amazon Linux 2023 の最新版AMIを取得
data "aws_ami" "amzlinux2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-arm64"] #armを受ける
    # values = ["amzn2-ami-hvm-*-x86_64-gp2"] #intel用
  }
}

# EC2作成（スケジュールでの起動・停止対象）
resource "aws_instance" "yamada-schedule-ec2" {
  ami                         = data.aws_ami.amzlinux2.id
  instance_type               = "t4g.nano"
  availability_zone           = "ap-northeast-1a"
  subnet_id                   = aws_subnet.private-subnet-1a.id
  associate_public_ip_address = false
  tags = {
    Name = "yamada-poc-ec2"
    Stop = "Night"
    Stop = "Weekend"
  }
}


# EC2作成（スケジュールでの非起動・停止対象。差はtagの有無）
resource "aws_instance" "yamada-schedule-ec2-not" {
  ami                         = data.aws_ami.amzlinux2.id
  instance_type               = "t4g.nano"
  availability_zone           = "ap-northeast-1a"
  subnet_id                   = aws_subnet.private-subnet-1a.id
  associate_public_ip_address = false
  tags = {
    Name = "yamada-poc-ec2-not"
  }
}



output "db_id" {
  value = aws_db_instance.test-db.identifier
}
