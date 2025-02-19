module "web_app" {
 source = "./modules/web_app"

 name_prefix = "arpita" 

 instance_type  = "t2.micro"
 instance_count = 2
 
 vpc_id        = "vpc-053666abf89648be2"
 public_subnet = true
}
module "DBDynamodb" {
 source = "./modules/DynamoDB"
 
}
