
######################################################
# Generated SSH Key
######################################################

output "generated_ssh_key" {
  value     = tls_private_key.ssh
  sensitive = true
}

######################################################
# Front load balancer address
######################################################


output "lb_front" {
  value = "http://${ibm_is_lb.front.hostname}:8000"
}

######################################################
# Back load balancer address
######################################################


output "lb_back" {
  value = "http://${ibm_is_lb.back.hostname}:8000"
}

######################################################
# Front End Instances
######################################################


output "instances_front" {
  value = { for key, instance in ibm_is_instance.front : key => {
    name                 = instance.name
    primary_ipv4_address = instance.primary_network_interface[0].primary_ipv4_address
    fip                  = ibm_is_floating_ip.front[key].address
  } }
}

######################################################
# Back End Instances
######################################################

output "instances_back" {
  value = { for key, instance in ibm_is_instance.back : key => {
    name                 = instance.name
    primary_ipv4_address = instance.primary_network_interface[0].primary_ipv4_address
    fip                  = ibm_is_floating_ip.back[key].address
  } }
}