resource "aws_db_subnet_group" "default" {
  name       = "rds-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "rds-subnet-group"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow MySQL access"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [var.lambda_sg_id]  ####aded new line
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#resource "aws_security_group_rule" "allow_lambda_to_rds" {
#  type                     = "ingress"
#  from_port                = 3306
#  to_port                  = 3306
#  protocol                 = "tcp"
#  security_group_id        = aws_security_group.rds_sg.id
#  source_security_group_id = var.lambda_sg_id
#  description              = "Allow Lambda to connect to MySQL"
#}

resource "aws_db_instance" "mysql" {
  identifier              = "mysql-db"
  allocated_storage       = var.allocated_storage
  engine                  = "mysql"
  engine_version          = var.engine_version
  instance_class          = var.db_instance_class
  #name                    = var.db_name
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.default.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  skip_final_snapshot     = true
  publicly_accessible     = false
  apply_immediately       = true
}
