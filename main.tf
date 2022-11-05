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
    
// create security group
resource "azurerm_network_security_group" "test-sg" {
    name = "test-security-group"
    location = azurerm_resource_group.test-rg.location
    resource_group_name = azurerm_resource_group.test-rg.name

    tags = {
        environment = "dev"
    }
}

// create network security rule
resource "azurerm_network_security_rule" "test-dev-rule" {
    name = "test-dev-rule"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "*"
    source_port_range = "*"
    destination_port_range = "*"
    source_address_prefix = "*" // add IP address 
    destination_address_prefix = "*"
    resource_group_name = azurerm_resource_group.test-rg.name
    network_security_group_name = azurerm_network_security_group.test-sg.name
}

// run terraform plan & apply 
// run terraform state list to check for success & check Azure console

// associate subnet with security group
resource "azurerm_subnet_network_security_group_association" "test-sga" {
    subnet_id = azurerm_subnet.test-subnet.id
    network_security_group_id = azurerm_network_security_group.test-sg.id
}

// run terraform plan & apply 
// run terraform state list, then state show + ip resource, & check Azure console
    
// create a public ip
resource "azurerm_public_ip" "test-ip" {
    name                = "test-IP"
    resource_group_name = azurerm_resource_group.test-rg.name
    location            = azurerm_resource_group.test-rg.location
    allocation_method   = "Dynamic"

    tags = {
        environment = "dev"
    }
}
    
// create network interface
resource "azurerm_network_interface" "test-nic" {
    name = "test-NIC"
    location = azurerm_resource_group.test-rg.location
    resource_group_name = azurerm_resource_group.test-rg.name

    ip_configuration {
        name = "internal"
        subnet_id = azurerm_subnet.test-subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.test-ip.id
    }

    tags = {
        environment = "dev"
    }
}
    
// create linux virtual machine
resource "azurerm_linux_virtual_machine" "test-linuxVM" {
    name = "test-LNUXVM"
    resource_group_name = azurerm_resource_group.test-rg.name
    location = azurerm_resource_group.test-rg.location
    size = "Standard_B1s" // free tier
    admin_username = "admin-user"
    network_interface_ids = [azurerm_network_interface.test-nic.id]
    
    custom_data =filebase64("customdata.tpl") 

    admin_ssh_key {
        username = "admin-user"
        public_key = file("~/.ssh/testazurekey.pub")
    }
        
    os_disk {
        caching = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer = "UbuntuServer"
        sku = "18.04-LTS"
        version = "latest"
    }
    
    provisioner "local-exec" {
        command = templatefile("windows-ssh-script.tpl", {
            hostname = self.public_ip_address,
            user = "admin-user",
            identityfile = "~/.ssh/testazurekey"
        })
        interpreter = ["Powershell", "-Command"]
    }

    tags = {
        environment = "dev"
    }
}
    
data "azurerm_public_ip" "test-ip-data" {
    name = azurerm_public_ip.test-ip.name
    resource_group_name = azurerm_resource_group.test-rg.name
}


