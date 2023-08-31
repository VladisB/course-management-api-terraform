output "ec2_public_ip" {
    value = module.jumpbox.instance.public_ip
}