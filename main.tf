terraform {
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "=2.97.0"
        }
    }
}

// required, regardless of the inclusion of features - can remain empty
provider "azurerm" {
    features {}
}

// run terraform init

// create a new resource group
resource "azurerm_resource_group" "test-rg" {
    name = "test-resources" 
    location = "East US"
    tags = {
        "environment" = "dev"
    }
}

// run terraform plan
// then terraform apply

