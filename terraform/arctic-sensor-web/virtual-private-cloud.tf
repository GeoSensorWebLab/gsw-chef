# Virtual Private Cloud
resource "aws_vpc" "sensorthings-vpc" {
    assign_generated_ipv6_cidr_block = true
    cidr_block                       = "172.30.0.0/16"
    enable_classiclink               = false
    enable_classiclink_dns_support   = false
    enable_dns_hostnames             = true
    enable_dns_support               = true
    instance_tenancy                 = "default"
    tags                             = {
        "Name"          = "SensorThings VPC"
        "arcticconnect" = "arcticsensorweb"
    }
}

resource "aws_route_table" "route-table" {
  propagating_vgws = []
  route            = [
      {
          cidr_block                = "0.0.0.0/0"
          egress_only_gateway_id    = ""
          gateway_id                = "igw-062fecebe92e03dc2"
          instance_id               = ""
          ipv6_cidr_block           = ""
          nat_gateway_id            = ""
          network_interface_id      = ""
          transit_gateway_id        = ""
          vpc_peering_connection_id = ""
      },
  ]
  tags             = {}
  vpc_id           = aws_vpc.sensorthings-vpc.id
}

resource "aws_subnet" "subnet-a" {
  assign_ipv6_address_on_creation = false
  cidr_block                      = "172.30.1.0/24"
  ipv6_cidr_block                 = "2600:1f14:19e:ed06::/64"
  map_public_ip_on_launch         = true
  tags                            = {}
  vpc_id                          = aws_vpc.sensorthings-vpc.id

  timeouts {}
}

resource "aws_subnet" "subnet-b" {
  assign_ipv6_address_on_creation = false
  cidr_block                      = "172.30.3.0/24"
  ipv6_cidr_block                 = "2600:1f14:19e:ed04::/64"
  map_public_ip_on_launch         = true
  tags                            = {}
  vpc_id                          = aws_vpc.sensorthings-vpc.id

  timeouts {}
}

resource "aws_subnet" "subnet-c" {
  assign_ipv6_address_on_creation = false
  cidr_block                      = "172.30.2.0/24"
  ipv6_cidr_block                 = "2600:1f14:19e:ed02::/64"
  map_public_ip_on_launch         = true
  tags                            = {}
  vpc_id                          = aws_vpc.sensorthings-vpc.id

  timeouts {}
}

resource "aws_subnet" "subnet-d" {
  assign_ipv6_address_on_creation = false
  cidr_block                      = "172.30.0.0/24"
  ipv6_cidr_block                 = "2600:1f14:19e:ed00::/64"
  map_public_ip_on_launch         = true
  tags                            = {}
  vpc_id                          = aws_vpc.sensorthings-vpc.id

  timeouts {}
}

resource "aws_network_acl" "sensorthings-acl" {
    egress     = [
        {
            action          = "allow"
            cidr_block      = ""
            from_port       = 0
            icmp_code       = 0
            icmp_type       = 0
            ipv6_cidr_block = "::/0"
            protocol        = "-1"
            rule_no         = 101
            to_port         = 0
        },
        {
            action          = "allow"
            cidr_block      = "0.0.0.0/0"
            from_port       = 0
            icmp_code       = 0
            icmp_type       = 0
            ipv6_cidr_block = ""
            protocol        = "-1"
            rule_no         = 100
            to_port         = 0
        },
    ]
    ingress    = [
        {
            action          = "allow"
            cidr_block      = ""
            from_port       = 0
            icmp_code       = 0
            icmp_type       = 0
            ipv6_cidr_block = "::/0"
            protocol        = "-1"
            rule_no         = 101
            to_port         = 0
        },
        {
            action          = "allow"
            cidr_block      = "0.0.0.0/0"
            from_port       = 0
            icmp_code       = 0
            icmp_type       = 0
            ipv6_cidr_block = ""
            protocol        = "-1"
            rule_no         = 100
            to_port         = 0
        },
    ]
    subnet_ids = [
        aws_subnet.subnet-a.id,
        aws_subnet.subnet-b.id,
        aws_subnet.subnet-c.id,
        aws_subnet.subnet-d.id
    ]
    tags       = {}
    vpc_id     = aws_vpc.sensorthings-vpc.id
}
