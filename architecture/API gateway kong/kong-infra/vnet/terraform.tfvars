subscription        = "5645f4b2-db38-4326-b7a6-98d374ebdd9c"
resource_group_name = "kong-demo"
region              = "UK South"

vnet = {
  name = "kong-yinyang-vnet"
  cidr = ["10.0.0.0/16"]
}

subnet1 = {
  name = "kong"
  cidr = ["10.0.1.0/24"]
}

subnet2 = {
  name = "yin-yang"
  cidr = ["10.0.2.0/24"]
}

