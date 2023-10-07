data "aws_instances" "night" {
  instance_tags = {
    Stop = "*Night*"
  }
}

data "aws_instances" "weekend" {
  instance_tags = {
    Stop = "*Weekend*"
  }
}

output "instance" {
  value = data.aws_instances.night
}

module "night" {
  source = "../.."
  name   = "ars"
  period = "night"
  type   = "ec2"
  target = data.aws_instances.night.ids
}

module "weekend" {
  source = "../.."
  name   = "ars"
  period = "weekend"
  type   = "ec2"
  target = data.aws_instances.weekend.ids
}

# debug

output "target" {
  value = module.weekend.target
}