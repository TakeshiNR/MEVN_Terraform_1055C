# =============================================================================
# MODULO: networking
# -----------------------------------------------------------------------------
# Responsabilidad de este modulo:
#   1. Crear la VPC que va a contener toda la infraestructura del stack MEAN.
#   2. Crear 2 subredes PUBLICAS (una por AZ) donde viviran el ALB y el NAT GW.
#   3. Crear 3 grupos de subredes PRIVADAS (una por AZ cada uno) para:
#        - capa web    (Vue servido por Nginx)
#        - capa backend (Express / Node.js API)
#        - capa datos   (MongoDB)
#   4. Crear el Internet Gateway (salida/entrada de trafico publico).
#   5. Crear un NAT Gateway (en subred publica) + Elastic IP para dar salida a
#      Internet a las instancias privadas (por ejemplo, para que Mongo pueda
#      descargar paquetes/parches sin tener IP publica propia).
#   6. Crear las tablas de rutas publicas y privadas y asociarlas.
#
# Justificacion de por que este es un modulo independiente:
#   La red es la capa mas "estable" del proyecto: rara vez cambia una vez
#   definida, y es reutilizada por TODOS los demas modulos (compute,
#   security-groups, load-balancer). Separarla permite reutilizar este mismo
#   modulo en otros proyectos/entornos (dev, staging, prod) cambiando solo
#   las variables de entrada.
# =============================================================================

data "aws_availability_zones" "available" {
  state = "available"
}

# -----------------------------------------------------------------------------
# VPC principal
# -----------------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "${var.project_name}-vpc"
    Project = var.project_name
  }
}

# -----------------------------------------------------------------------------
# Internet Gateway (necesario para que las subredes publicas tengan salida
# directa a Internet: ALB y NAT Gateway lo usan)
# -----------------------------------------------------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# -----------------------------------------------------------------------------
# Subredes PUBLICAS (una por AZ) -> aqui van el ALB y el NAT Gateway
# -----------------------------------------------------------------------------
resource "aws_subnet" "public" {
  for_each = var.public_subnet_cidrs

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = element(var.availability_zones, tonumber(each.key))
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-${each.key}"
    Tier = "public"
  }
}

# -----------------------------------------------------------------------------
# Subredes PRIVADAS - capa WEB (Vue / Nginx)
# -----------------------------------------------------------------------------
resource "aws_subnet" "web" {
  for_each = var.web_subnet_cidrs

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = element(var.availability_zones, tonumber(each.key))

  tags = {
    Name = "${var.project_name}-web-${each.key}"
    Tier = "web"
  }
}

# -----------------------------------------------------------------------------
# Subredes PRIVADAS - capa BACKEND (Express / Node.js)
# -----------------------------------------------------------------------------
resource "aws_subnet" "backend" {
  for_each = var.backend_subnet_cidrs

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = element(var.availability_zones, tonumber(each.key))

  tags = {
    Name = "${var.project_name}-backend-${each.key}"
    Tier = "backend"
  }
}

# -----------------------------------------------------------------------------
# Subredes PRIVADAS - capa DATOS (MongoDB)
# -----------------------------------------------------------------------------
resource "aws_subnet" "db" {
  for_each = var.db_subnet_cidrs

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = element(var.availability_zones, tonumber(each.key))

  tags = {
    Name = "${var.project_name}-db-${each.key}"
    Tier = "db"
  }
}

# -----------------------------------------------------------------------------
# Elastic IP + NAT Gateway
# El NAT Gateway se ubica en la PRIMERA subred publica y da salida a Internet
# a todas las subredes privadas (web, backend, db) sin exponerlas directamente.
# Esta es la IP publica que se pide en el output para "instance MongoDB".
# -----------------------------------------------------------------------------
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = values(aws_subnet.public)[0].id

  tags = {
    Name = "${var.project_name}-nat-gw"
  }

  depends_on = [aws_internet_gateway.igw]
}

# -----------------------------------------------------------------------------
# Tabla de rutas PUBLICA -> sale directo por el Internet Gateway
# -----------------------------------------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# -----------------------------------------------------------------------------
# Tabla de rutas PRIVADA -> sale a Internet a traves del NAT Gateway
# Se comparte entre web, backend y db porque todas necesitan salida NAT
# (actualizaciones de paquetes, llamadas a APIs externas, etc.)
# -----------------------------------------------------------------------------
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

resource "aws_route_table_association" "web" {
  for_each       = aws_subnet.web
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "backend" {
  for_each       = aws_subnet.backend
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "db" {
  for_each       = aws_subnet.db
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
