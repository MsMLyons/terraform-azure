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

