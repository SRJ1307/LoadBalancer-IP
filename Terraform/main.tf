# main.tf
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}
# Define provider
provider "azurerm" {
  features {}
}

# Create resource group
resource "azurerm_resource_group" "lb" {
  name     = "lb"
  location = "westus2"
}

# Create virtual network
resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.lb.location
  resource_group_name = azurerm_resource_group.lb.name

}
resource "azurerm_network_security_group" "example" {
  name                = "acceptanceTestSecurityGroup1"
  location            = azurerm_resource_group.lb.location
  resource_group_name = azurerm_resource_group.lb.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

# Create subnet
resource "azurerm_subnet" "example" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.lb.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create public IP address
resource "azurerm_public_ip" "example" {
  name                = "example-lb-ip"
  location            = azurerm_resource_group.lb.location
  resource_group_name = azurerm_resource_group.lb.name
  allocation_method   = "Static"
}

# Create load balancer
resource "azurerm_lb" "example" {
  name                = "example-lb"
  location            = azurerm_resource_group.lb.location
  resource_group_name = azurerm_resource_group.lb.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.example.id
  }
}

# Create backend pool
resource "azurerm_lb_backend_address_pool" "example" {
  name = "example-lb-backend-pool"


  loadbalancer_id = azurerm_lb.example.id
}

# Create health probe
resource "azurerm_lb_probe" "example" {
  name = "http-probe"

  loadbalancer_id = azurerm_lb.example.id
  protocol        = "Http"
  port            = 80
  request_path    = "/"
}

# Create load balancer rule
resource "azurerm_lb_rule" "example" {
  name = "http-rule"

  loadbalancer_id                = azurerm_lb.example.id
  frontend_ip_configuration_name = azurerm_lb.example.frontend_ip_configuration[0].name
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.example.id]


  protocol      = "Tcp"
  frontend_port = 80
  backend_port  = 80
}

# Create virtual machine scale set
resource "azurerm_linux_virtual_machine_scale_set" "example" {
  name                = "example-vmss"
  resource_group_name = azurerm_resource_group.lb.name
  location            = azurerm_resource_group.lb.location
  sku                 = "Standard_F2"
  instances           = 2
  admin_username      = "adminuser"
  custom_data         = base64encode(templatefile("${path.module}/cloud-init.yaml", {}))

admin_password = "ThePlayer007"
disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"

  }



  network_interface {
    name    = "example"
    primary = true

    ip_configuration {
      name                                   = "internal"
      subnet_id                              = azurerm_subnet.example.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.example.id]

    }
  }





}

