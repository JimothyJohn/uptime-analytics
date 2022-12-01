terraform {
  cloud {
    organization = "advinio"
    workspaces {
      name = "uptime-analytics"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.41"
    }
  }
  required_version = ">= 1.3"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_iot_thing" "uptime_analytics" {
  name = "uptime_analytics"

  attributes = {
    service_provider = "Python"
  }
}

resource "aws_iot_certificate" "analytics_cert" {
  active = true
}

data "aws_caller_identity" "current" {}

resource "aws_iot_policy_attachment" "att_analytics" {
  policy = "db_policy"
  target = aws_iot_certificate.analytics_cert.arn
}

resource "aws_iot_thing_principal_attachment" "att_analytics" {
  principal = aws_iot_certificate.analytics_cert.arn
  thing     = aws_iot_thing.uptime_analytics.name
}

resource "aws_instance" "uptime_analytics" {
  ami           = "ami-09a41e26df464c548"
  instance_type = "t2.small"

  tags = {
    Name = "uptime_analytics"
    }
}
