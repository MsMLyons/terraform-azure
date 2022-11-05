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
    // check Azure console resource groups

// create virtual network
// format of resource group name creates a dependency
// which means the virtual network will not deploy before the resource group
// with destroy, the inverse is true; the vn is destroyed before the rg
// can add multiple addresses (subnets)
resource "azurerm_virtual_network" "test-vn" {
    name = "test-network"
    resource_group_name = azurerm_resource_group.test-rg.name
    location = azurerm_resource_group.test-rg.location
    address_space = ["10.123.0.0/16"] 

    tags = {
        "environment" = "dev"
    }
}

// run terraform plan
// then terraform apply or terraform apply --auto-approve
// check Azure console virtual networks

// create subnet
resource "azurerm_subnet" "test-subnet" {
    name = "test-sub"
    resource_group_name = azurerm_resource_group.test-rg.name
    virtual_network_name = azurerm_virtual_network.test-vn.name
    address_prefixes = ["10.123.1.0/24"]
}

// run terraform plan, then apply

