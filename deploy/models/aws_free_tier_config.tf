### Configure AWS provider

### credentials config

provider "aws" {
    access_key = "ACCESS_KEY"
    secret_key = "SECRET_ACCESS_KEY"
    region = "eu-west-1"
}

resource "aws_instance" "cooptchain-miner" {
	count = "2"
	ami = "ami-70edb016"
	instance_type = "t2.micro"
	key_name = "SSH_KEY"
	availability_zone = "eu-west-1a"
	associate_public_ip_address = "true"
	tags {

		Name = "cooptchain_miner_${count.index}"
		Group = "cooptchain_miner"
	}
}

resource "aws_instance" "cooptchain-admin" {
	count = "1"
	ami = "ami-70edb016"
	instance_type = "t2.micro"
	key_name = "SSH_KEY"
	availability_zone = "eu-west-1a"
	associate_public_ip_address = "true"
	tags {
		Name = "cooptchain_admin_${count.index}"
		Group = "cooptchain_admin"
	}
}

resource "aws_instance" "cooptchain-database" {
	count = "1"
	ami = "ami-70edb016"
	instance_type = "t2.micro"
	key_name = "SSH_KEY"
	availability_zone = "eu-west-1a"
	associate_public_ip_address = "true"
	tags {
		Name = "cooptchain_database_${count.index}"
		Group = "cooptchain_database"
	}
}

resource "aws_instance" "cooptchain-mix" {
	count = "0"
	ami = "ami-70edb016"
	instance_type = "t2.micro"
	key_name = "SSH_KEY"
	availability_zone = "eu-west-1a"
	associate_public_ip_address = "true"
	tags {
		Name = "cooptchain_mix_${count.index}"
		Group = "cooptchain_mix"
	}
}