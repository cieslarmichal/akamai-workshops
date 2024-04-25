terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "1.29.4"
    }
  }
}
//Use the Linode Provider
provider "linode" {
  token = var.token
}
