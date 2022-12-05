variable "vm_name" {
    type        = list(string)
    description = "Name of the VM"
    default     = ["frontend", "rabbitmq", "mysql", "cart", "catalogue" ] 
}