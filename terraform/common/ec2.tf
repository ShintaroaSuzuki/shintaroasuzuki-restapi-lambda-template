resource "aws_instance" "ec2_bastion" {
  ami                         = "ami-011facbea5ec0363b"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.private_1a.id
  associate_public_ip_address = false
  key_name                    = aws_key_pair.ec2_bastion.key_name
  vpc_security_group_ids      = [aws_security_group.ec2_bastion.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_bastion.name
}

resource "aws_key_pair" "ec2_bastion" {
  key_name   = "common-ssh"
  public_key = tls_private_key.ec2_bastion.public_key_openssh
}

resource "tls_private_key" "ec2_bastion" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_security_group" "ec2_bastion" {
  name        = "ec2_bastion"
  description = "EC2 service security group"
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// RDS ClusterのセキュリティグループにEC2から3306ポートで通信出来る設定を後追いで追加
resource "aws_security_group_rule" "rds_from_ec2_bastion" {
  security_group_id        = aws_security_group.sonawaru_app_db.id
  type                     = "ingress"
  from_port                = "3306"
  to_port                  = "3306"
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2_bastion.id
}
