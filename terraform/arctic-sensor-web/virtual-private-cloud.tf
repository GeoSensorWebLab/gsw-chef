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

resource "aws_vpc_dhcp_options" "dns_resolver" {
  domain_name         = "us-west-2.compute.internal"
  domain_name_servers = [
      "AmazonProvidedDNS",
  ]
  tags                = {}
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  dhcp_options_id = aws_vpc_dhcp_options.dns_resolver.id
  vpc_id          = aws_vpc.sensorthings-vpc.id
}

resource "aws_internet_gateway" "gw" {
  tags   = {}
  vpc_id = aws_vpc.sensorthings-vpc.id
}

resource "aws_route_table" "route-table" {
  propagating_vgws = []
  route            = [
      {
          cidr_block                = "0.0.0.0/0"
          egress_only_gateway_id    = ""
          gateway_id                = aws_internet_gateway.gw.id
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

resource "aws_security_group" "frost-server-group" {
  description = "Allows internal HTTP access to Tomcat running on port 8080 on these instances"
  egress      = [
      {
          cidr_blocks      = [
              "0.0.0.0/0",
          ]
          description      = ""
          from_port        = 0
          ipv6_cidr_blocks = [
              "::/0",
          ]
          prefix_list_ids  = []
          protocol         = "-1"
          security_groups  = []
          self             = false
          to_port          = 0
      },
  ]
  ingress     = [
      {
          cidr_blocks      = [
              "172.30.1.20/32",
          ]
          description      = "Access from Frost Server Load Balancer"
          from_port        = 0
          ipv6_cidr_blocks = []
          prefix_list_ids  = []
          protocol         = "-1"
          security_groups  = []
          self             = false
          to_port          = 0
      },
      {
          cidr_blocks      = [
              "174.0.241.136/32",
          ]
          description      = "James Badger remote access"
          from_port        = 0
          ipv6_cidr_blocks = []
          prefix_list_ids  = []
          protocol         = "-1"
          security_groups  = []
          self             = false
          to_port          = 0
      },
      {
          cidr_blocks      = []
          description      = "Access from other instances/services in this SG"
          from_port        = 0
          ipv6_cidr_blocks = []
          prefix_list_ids  = []
          protocol         = "-1"
          security_groups  = []
          self             = true
          to_port          = 0
      },
  ]
  name        = "Frost-Server-Group"
  tags        = {
      "arcticconnect" = "arcticsensorweb"
  }
  vpc_id      = aws_vpc.sensorthings-vpc.id

  timeouts {}
}

# aws_security_group_rule.frost-server-group:
resource "aws_security_group_rule" "frost-server-group" {
    cidr_blocks       = [
        "0.0.0.0/0",
    ]
    from_port         = 0
    ipv6_cidr_blocks  = []
    prefix_list_ids   = []
    protocol          = "-1"
    security_group_id = aws_security_group.frost-server-group.id
    self              = false
    to_port           = 0
    type              = "egress"
}

# aws_security_group_rule.frost-server-group-1:
resource "aws_security_group_rule" "frost-server-group-1" {
    cidr_blocks       = []
    from_port         = 0
    ipv6_cidr_blocks  = [
        "::/0",
    ]
    prefix_list_ids   = []
    protocol          = "-1"
    security_group_id = aws_security_group.frost-server-group.id
    self              = false
    to_port           = 0
    type              = "egress"
}

# aws_security_group_rule.frost-server-group-2:
resource "aws_security_group_rule" "frost-server-group-2" {
    cidr_blocks       = [
        "174.0.241.136/32",
        "172.30.1.20/32",
    ]
    description       = "James Badger remote access"
    from_port         = 0
    ipv6_cidr_blocks  = []
    prefix_list_ids   = []
    protocol          = "-1"
    security_group_id = aws_security_group.frost-server-group.id
    self              = false
    to_port           = 0
    type              = "ingress"
}

# aws_security_group_rule.frost-server-group-3:
resource "aws_security_group_rule" "frost-server-group-3" {
    cidr_blocks              = []
    description              = "Access from other instances/services in this SG"
    from_port                = 0
    ipv6_cidr_blocks         = []
    prefix_list_ids          = []
    protocol                 = "-1"
    security_group_id        = aws_security_group.frost-server-group.id
    self                     = true
    to_port                  = 0
    type                     = "ingress"
}

resource "aws_security_group" "load-balancer-group" {
  description = "LB created for FROST-Server on EC2"
  egress      = [
      {
          cidr_blocks      = [
              "0.0.0.0/0",
          ]
          description      = ""
          from_port        = 0
          ipv6_cidr_blocks = [
              "::/0",
          ]
          prefix_list_ids  = []
          protocol         = "-1"
          security_groups  = []
          self             = false
          to_port          = 0
      },
  ]
  ingress     = [
      {
          cidr_blocks      = [
              "0.0.0.0/0",
          ]
          description      = ""
          from_port        = 8080
          ipv6_cidr_blocks = [
              "::/0",
          ]
          prefix_list_ids  = []
          protocol         = "tcp"
          security_groups  = []
          self             = false
          to_port          = 8080
      },
  ]
  name        = "load-balancer-wizard-1"
  tags        = {}
  vpc_id      = aws_vpc.sensorthings-vpc.id

  timeouts {}
}

# aws_security_group_rule.load-balancer-group:
resource "aws_security_group_rule" "load-balancer-group" {
    cidr_blocks       = [
        "0.0.0.0/0",
    ]
    from_port         = 8080
    ipv6_cidr_blocks  = []
    prefix_list_ids   = []
    protocol          = "tcp"
    security_group_id = aws_security_group.load-balancer-group.id
    self              = false
    to_port           = 8080
    type              = "ingress"
}

# aws_security_group_rule.load-balancer-group-1:
resource "aws_security_group_rule" "load-balancer-group-1" {
    cidr_blocks       = []
    from_port         = 8080
    ipv6_cidr_blocks  = [
        "::/0",
    ]
    prefix_list_ids   = []
    protocol          = "tcp"
    security_group_id = aws_security_group.load-balancer-group.id
    self              = false
    to_port           = 8080
    type              = "ingress"
}

# aws_security_group_rule.load-balancer-group-2:
resource "aws_security_group_rule" "load-balancer-group-2" {
    cidr_blocks       = [
        "0.0.0.0/0",
    ]
    from_port         = 0
    ipv6_cidr_blocks  = []
    prefix_list_ids   = []
    protocol          = "-1"
    security_group_id = aws_security_group.load-balancer-group.id
    self              = false
    to_port           = 0
    type              = "egress"
}

# aws_security_group_rule.load-balancer-group-3:
resource "aws_security_group_rule" "load-balancer-group-3" {
    cidr_blocks       = []
    from_port         = 0
    ipv6_cidr_blocks  = [
        "::/0",
    ]
    prefix_list_ids   = []
    protocol          = "-1"
    security_group_id = aws_security_group.load-balancer-group.id
    self              = false
    to_port           = 0
    type              = "egress"
}

resource "aws_security_group" "airflow-group-1" {
  description = "Group for Airflow and ETL services"
  egress      = [
      {
          cidr_blocks      = [
              "0.0.0.0/0",
          ]
          description      = ""
          from_port        = 0
          ipv6_cidr_blocks = [
              "::/0",
          ]
          prefix_list_ids  = []
          protocol         = "-1"
          security_groups  = []
          self             = false
          to_port          = 0
      },
  ]
  ingress     = [
      {
          cidr_blocks      = [
              "174.0.241.136/32",
          ]
          description      = "Access for James Badger"
          from_port        = 0
          ipv6_cidr_blocks = []
          prefix_list_ids  = []
          protocol         = "-1"
          security_groups  = []
          self             = false
          to_port          = 0
      },
      {
          cidr_blocks      = []
          description      = "Access in this security group"
          from_port        = 0
          ipv6_cidr_blocks = []
          prefix_list_ids  = []
          protocol         = "-1"
          security_groups  = []
          self             = true
          to_port          = 0
      },
  ]
  name        = "airflow-group-1"
  tags        = {}
  vpc_id      = aws_vpc.sensorthings-vpc.id

  timeouts {}
}

# aws_security_group_rule.airflow-group-1:
resource "aws_security_group_rule" "airflow-group-1" {
    cidr_blocks       = [
        "174.0.241.136/32",
    ]
    description       = "Access for James Badger"
    from_port         = 0
    ipv6_cidr_blocks  = []
    prefix_list_ids   = []
    protocol          = "-1"
    security_group_id = aws_security_group.airflow-group-1.id
    self              = false
    to_port           = 0
    type              = "ingress"
}

# aws_security_group_rule.airflow-group-1-1:
resource "aws_security_group_rule" "airflow-group-1-1" {
    cidr_blocks              = []
    description              = "Access in this security group"
    from_port                = 0
    ipv6_cidr_blocks         = []
    prefix_list_ids          = []
    protocol                 = "-1"
    security_group_id        = aws_security_group.airflow-group-1.id
    self                     = true
    to_port                  = 0
    type                     = "ingress"
}

# aws_security_group_rule.airflow-group-1-2:
resource "aws_security_group_rule" "airflow-group-1-2" {
    cidr_blocks       = [
        "0.0.0.0/0",
    ]
    from_port         = 0
    ipv6_cidr_blocks  = []
    prefix_list_ids   = []
    protocol          = "-1"
    security_group_id = aws_security_group.airflow-group-1.id
    self              = false
    to_port           = 0
    type              = "egress"
}

# aws_security_group_rule.airflow-group-1-3:
resource "aws_security_group_rule" "airflow-group-1-3" {
    cidr_blocks       = []
    from_port         = 0
    ipv6_cidr_blocks  = [
        "::/0",
    ]
    prefix_list_ids   = []
    protocol          = "-1"
    security_group_id = aws_security_group.airflow-group-1.id
    self              = false
    to_port           = 0
    type              = "egress"
}
