# outputs.tf

output "load_balancer_ip" {
  value = azurerm_public_ip.example.ip_address
}
