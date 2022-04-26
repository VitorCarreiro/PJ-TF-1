resource "aws_vpc" "vpc-automation" {
  cidr_block = "10.0.0.0/16"
tags = {
    Name = "vpc-automation"
  }
}

resource "aws_subnet" "subnet-automation-1" {
  vpc_id = "${aws_vpc.vpc-automation.id}"
  availability_zone = "us-east-1a"
  cidr_block = "10.0.1.0/24"
tags = {
    Name = "subnet-automation-1"
   }
}

resource "aws_subnet" "subnet-automation-2" {
  vpc_id = "${aws_vpc.vpc-automation.id}"
  availability_zone = "us-east-1b"
  cidr_block = "10.0.2.0/24"
tags = {
    Name = "subnet-automation-2"
   }
}

resource "aws_security_group" "automation-sg-loadbalancer" {
  name        = "automation-sg-loadbalancer"
  description = "HTTP IP PUB MEU E JURADOS"
  vpc_id      = "${aws_vpc.vpc-automation.id}"

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["85.243.7.219/32", "0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "automation-sg-loadbalancer"
  }
}

resource "aws_security_group" "automation-sg-instances" {
  name        = "automation-sg-instances"
  vpc_id      = "${aws_vpc.vpc-automation.id}"

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "automation-sg-instances"
  }
}

resource "aws_elb" "aws-elb" {
  name               = "aws-elb"
  availability_zones = ["us-east-1a", "us-east-1b"]
}

resource "aws_autoscaling_group" "bar" {
  name                      = "bar"
  max_size                  = 3
  min_size                  = 2
  health_check_grace_period = 30
  health_check_type         = "ELB"
  force_delete              = true
  launch_configuration      = aws_launch_configuration.foo.name
  vpc_zone_identifier       = [aws_subnet.subnet-automation-1, aws_subnet.subnet-automation-2]

}

resource "aws_launch_configuration" "foo" {
  name = "web_config"
  image_id = 
  instance_type = "t2.micro"
}

resource "aws_autoscaling_policy" "bat" {
  name                   = "foobar3-terraform-test"
  scaling_adjustment     = 4
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.bar.name
}
