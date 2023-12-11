# In Terraform, the term "backend" refers to the system or service 
# that manages the storage and retrieval of Terraform state files.

terraform {
  backend "s3" {
    bucket         = "terraform-state-sadawap"
    key            = "Jenkins/terraform.tfstate"
    region         = "ap-south-1"
  }
}