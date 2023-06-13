terraform {
  required_providers {
    aws ={
        source = "hashicorp/aws"
        version = "~> 4.0"
    }
  }
}

variable "aws_access_key" {}
variable "aws_secret_key" {}

provider "aws" {
  region = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
provider "aws" {
  region = "us-west-1"
  alias = "West"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_vpc" "Deployment-vpc_East" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}
resource "aws_vpc" "Deployment-vpc_West" {
  cidr_block           = "172.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  provider = aws.West
}

data "aws_availability_zones" "available_zones_East" {
  state = "available"
}
data "aws_availability_zones" "available_zones_West" {
  state = "available"
  provider = aws.West
}
resource "aws_subnet" "public-subnet-1_East" {
  cidr_block        = var.public_subnet_1_cidr_region1
  map_public_ip_on_launch = "true"
  vpc_id            = aws_vpc.Deployment-vpc_East.id
  availability_zone = data.aws_availability_zones.available_zones_East.names[0]
}

resource "aws_subnet" "public-subnet-2_East" {
  cidr_block        = var.public_subnet_2_cidr_region1
  map_public_ip_on_launch = "true"
  vpc_id            = aws_vpc.Deployment-vpc_East.id
  availability_zone = data.aws_availability_zones.available_zones_East.names[1]
}

resource "aws_subnet" "public-subnet-1_West" {
  cidr_block        = var.public_subnet_1_cidr_region2
  map_public_ip_on_launch = "true"
  vpc_id            = aws_vpc.Deployment-vpc_West.id
  availability_zone = data.aws_availability_zones.available_zones_West.names[0]
  provider = aws.West
}

resource "aws_subnet" "public-subnet-2_West" {
  cidr_block        = var.public_subnet_2_cidr_region2
  map_public_ip_on_launch = "true"
  vpc_id            = aws_vpc.Deployment-vpc_West.id
  availability_zone = data.aws_availability_zones.available_zones_West.names[1]
  provider = aws.West
}
resource "aws_internet_gateway" "East_igw" {
  vpc_id = aws_vpc.Deployment-vpc_East.id

  tags = {
    Name = "Eastern Deployment Internet Gate Way"
  }
}
resource "aws_internet_gateway" "West_igw" {
  vpc_id = aws_vpc.Deployment-vpc_West.id
  provider = aws.West
  tags = {
    Name = "Western Deployment Internet Gate Way"
  }
}

resource "aws_route_table" "public-route-table_East" {
  vpc_id = aws_vpc.Deployment-vpc_East.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.East_igw.id
  }
}
resource "aws_route_table" "public-route-table_West" {
  vpc_id = aws_vpc.Deployment-vpc_West.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.West_igw.id
  }
  provider = aws.West
}

resource "aws_route_table_association" "public-route-1-association_East" {
  route_table_id = aws_route_table.public-route-table_East.id
  subnet_id      = aws_subnet.public-subnet-1_East.id
}
resource "aws_route_table_association" "public-route-2-association_East" {
  route_table_id = aws_route_table.public-route-table_East.id
  subnet_id      = aws_subnet.public-subnet-2_East.id
}

resource "aws_route_table_association" "public-route-1-association_West" {
  route_table_id = aws_route_table.public-route-table_West.id
  subnet_id      = aws_subnet.public-subnet-1_West.id
  provider = aws.West
}
resource "aws_route_table_association" "public-route-2-association_West" {
  route_table_id = aws_route_table.public-route-table_West.id
  subnet_id      = aws_subnet.public-subnet-2_West.id
  provider = aws.West
}
resource "aws_security_group" "Deployment_Application_instance_East_SG" {
  name        = "ssh-access"
  description = "open ssh traffic"
  vpc_id = aws_vpc.Deployment-vpc_East.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 5000
    to_port = 5000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" : "Application_SGE"
    "Terraform" : "true"
  } 
}

resource "aws_security_group" "Deployment_Application_instance_West_SG" {
  name        = "ssh-access"
  description = "open ssh traffic"
  vpc_id = aws_vpc.Deployment-vpc_West.id
  provider = aws.West

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 5000
    to_port = 5000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" : "Application_SGW"
    "Terraform" : "true"
  }
  
}

resource "aws_security_group" "load-balancer_East" {
  name        = "load_balancer_security_group"
  description = "Controls access to the ALB"
  vpc_id      = aws_vpc.Deployment-vpc_East.id

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "load-balancer_West" {
  name        = "load_balancer_security_group"
  description = "Controls access to the ALB"
  vpc_id      = aws_vpc.Deployment-vpc_West.id
  provider = aws.West

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_route53_zone" "Deployment_zone" {
  name = "deployment.com"

}
resource "aws_lb" "Elb_East" {
  name               = "elbeast"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load-balancer_East.id]
  subnets            = [aws_subnet.public-subnet-1_East.id,aws_subnet.public-subnet-2_East.id]
depends_on = [
    aws_internet_gateway.East_igw
  ]
}
resource "aws_lb" "Elb_West" {
  name               = "elbwest"
  internal           = false
  load_balancer_type = "application"
  provider = aws.West
  security_groups    = [aws_security_group.load-balancer_West.id]
  subnets            = [aws_subnet.public-subnet-1_West.id,aws_subnet.public-subnet-2_West.id]
depends_on = [
    aws_internet_gateway.West_igw
  ]
}
resource "aws_instance" "appInstance_East1" {
  ami           = "ami-0557a15b87f6559cf"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public-subnet-1_East.id
  vpc_security_group_ids = [aws_security_group.Deployment_Application_instance_East_SG.id]

  tags = {
    Name = "appInstance_East-1"
  }
  user_data = "${file("config.sh")}"
}
resource "aws_instance" "appInstance_East2" {
  ami           = "ami-0557a15b87f6559cf"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public-subnet-2_East.id
  vpc_security_group_ids = [aws_security_group.Deployment_Application_instance_East_SG.id]

  tags = {
    Name = "appInstance_East-2"
  }
  user_data = "${file("config.sh")}"
}

resource "aws_instance" "appInstance_West1" {
  ami           = "ami-014d05e6b24240371"
  instance_type = "t2.micro"
  provider = aws.West
  subnet_id     = aws_subnet.public-subnet-1_West.id
  vpc_security_group_ids = [aws_security_group.Deployment_Application_instance_West_SG.id]

  tags = {
    Name = "appInstance_West-1"
  }
  user_data = "${file("config.sh")}"
}
resource "aws_instance" "appInstance_West2" {
  ami           = "ami-014d05e6b24240371"
  instance_type = "t2.micro"
  provider = aws.West
  subnet_id     = aws_subnet.public-subnet-2_West.id
  vpc_security_group_ids = [aws_security_group.Deployment_Application_instance_West_SG.id]

  tags = {
    Name = "appInstance_West-2"
  }
  user_data = "${file("config.sh")}"
}

resource "aws_lb_target_group" "Tg_East" {
  name     = "East-lb-tg"
  port     = 80
  protocol = "HTTP"
  target_type="instance"
  vpc_id   = aws_vpc.Deployment-vpc_East.id
}

resource "aws_lb_target_group" "Tg_West" {
  name     = "West-lb-tg"
  port     = 80
  protocol = "HTTP"
  target_type="instance"
  vpc_id   = aws_vpc.Deployment-vpc_West.id
  provider = aws.West
}
resource "aws_lb_listener" "Deployment_Listener_East" {
  load_balancer_arn = aws_lb.Elb_East.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.Tg_East.arn

    }
}
resource "aws_lb_listener" "Deployment_Listener_West" {
  load_balancer_arn = aws_lb.Elb_West.arn
  port              = "80"
  protocol          = "HTTP"
  provider = aws.West

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.Tg_West.arn

    }
}
resource "aws_lb_target_group_attachment" "Attach_East1" {
  target_group_arn = aws_lb_target_group.Tg_East.arn
  target_id        = aws_instance.appInstance_East1.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "Attach_East2" {
  target_group_arn = aws_lb_target_group.Tg_East.arn
  target_id        = aws_instance.appInstance_East2.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "Attach_West1" {
  target_group_arn = aws_lb_target_group.Tg_West.arn
  target_id        = aws_instance.appInstance_West1.id
  port             = 80
  provider = aws.West
}
resource "aws_lb_target_group_attachment" "Attach_West2" {
  target_group_arn = aws_lb_target_group.Tg_West.arn
  target_id        = aws_instance.appInstance_West2.id
  port             = 80
  provider = aws.West
}

resource "aws_security_group" "East_DB_SG" {
  name = "East_DB_SG"
  description = "Secruity group for RDS instance"
  vpc_id = aws_vpc.Deployment-vpc_East.id
  ingress {
    description = "Allow MSQL traffic."
    from_port = "3306"
    to_port = "3306"
    protocol = "tcp"
    security_groups = [aws_security_group.Deployment_Application_instance_East_SG.id]
  }
  tags = {
    Name = "East_DB_SG"
  }
}
resource "aws_security_group" "West_DB_SG" {
  name = "West_DB_SG"
  description = "Secruity group for RDS instance"
  vpc_id = aws_vpc.Deployment-vpc_West.id
  provider = aws.West
  ingress {
    description = "Allow MSQL traffic."
    from_port = "3306"
    to_port = "3306"
    protocol = "tcp"
    security_groups = [aws_security_group.Deployment_Application_instance_West_SG.id]
  }
  tags = {
    Name = "West_DB_SG"
  }
}
resource "aws_db_subnet_group" "East_DB_Subnet_Group" {
  name="east_db_subnet_group"
  description = "Subnet group for east region"
  subnet_ids = [aws_subnet.public-subnet-1_East.id,aws_subnet.public-subnet-2_East.id]
}
resource "aws_db_subnet_group" "West_DB_Subnet_Group" {
  name="west_db_subnet_group"
  description = "Subnet group for east region"
  provider = aws.West
  subnet_ids = [aws_subnet.public-subnet-1_West.id,aws_subnet.public-subnet-2_West.id]
}
resource "aws_db_instance" "East_DB" {
  allocated_storage           = 10
  db_subnet_group_name = aws_db_subnet_group.East_DB_Subnet_Group.name
  db_name                     = "East_db"
  engine                      = "mysql"
  engine_version              = "5.7"
  instance_class              = "db.t3.micro"
  username                    = "admin"
  password                    = "adminPass"
  parameter_group_name        = "default.mysql5.7"
  skip_final_snapshot         = true
  vpc_security_group_ids = [aws_security_group.East_DB_SG.id]
}

resource "aws_db_instance" "West_DB" {
  allocated_storage           = 10
  db_name                     = "West_db"
  db_subnet_group_name = aws_db_subnet_group.West_DB_Subnet_Group.name
  engine                      = "mysql"
  engine_version              = "5.7"
  instance_class              = "db.t3.micro"
  username                    = "admin"
  password                    = "adminPass"
  parameter_group_name        = "default.mysql5.7"
  skip_final_snapshot         = true
  provider                    = aws.West
  vpc_security_group_ids = [aws_security_group.West_DB_SG.id]
}