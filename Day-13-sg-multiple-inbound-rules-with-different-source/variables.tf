variable "allowed_ports" {
  type = map(string)
  default = {
    #key = "value" value we can give CIDR also SG-ID also and IP also.
    22   = "203.0.113.0/24" # SSH (Restrict to office IP)
    80   = "0.0.0.0/0"      # HTTP (Public)
    443  = "0.0.0.0/0"      # HTTPS (Public)
    8080 = "10.0.0.0/16"    # Internal App (Restrict to VPC)
    9000 = "192.168.1.0/24" # Sonarqube/Jenkins (Restrict to VPN)
    3389 = "10.0.1.0/24"
    3000 = "10.0.2.0/24"
  }

}

# variable "sgrule" {
#     type = list(string)
#     default = [ "22", "80", "443", "8080", "9000", "3000", "8082" ]

# }