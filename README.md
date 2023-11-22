# course-management-api-terraform
Terraform scripts for Course Management API

example how to connect to DB via jumpbox from local machine

ssh -i ~/.ssh/id_rsa -f -N -L 5432:[db_host]:5432 ec2-user@[public_ip] -v

NOTE: Check security groups of jump box before usage