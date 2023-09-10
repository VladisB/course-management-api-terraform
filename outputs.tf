output "ec2_public_ip" {
    value = module.jumpbox.instance.public_ip
}

output "ecr_uri" {
    value = module.codepipeline.ecr.repository_url
}

output "db_host" {
    value = module.rds.db_host
}