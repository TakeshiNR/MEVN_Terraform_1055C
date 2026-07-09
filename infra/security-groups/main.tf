# =============================================================================
# MODULO: security-groups
# -----------------------------------------------------------------------------
# Responsabilidad de este modulo:
#   Definir el firewall (Security Groups) de cada capa siguiendo el principio
#   de menor privilegio: cada capa SOLO acepta trafico de la capa
#   inmediatamente "superior" (o de Internet en el caso del ALB), nunca de
#   forma directa desde el exterior.
#
#   Flujo de trafico permitido (multicapa):
#     Internet  --(80/443)-->  ALB
#     ALB       --(80)     -->  capa WEB   (Vue + Nginx)
#     WEB       --(3000)   -->  capa BACKEND (Express API)
#     BACKEND   --(27017)  -->  MongoDB (SG propio, ver ../mongodb)
#     SSH (22)  --(solo IP admin)--> cualquier capa, para mantenimiento
#
# Nota: el SG de la capa de datos (MongoDB) NO se define aqui. El modulo
# ../mongodb ya trae su propio security group (solo abre 27017 hacia el SG
# que se le pase como "app_sg_id"), asi que este modulo solo cubre ALB, web
# y backend para no duplicar esa regla.
#
# Justificacion de por que este es un modulo independiente:
#   Los security groups son "politica de seguridad" pura; separarlos de las
#   instancias (compute) permite auditarlos/revisarlos de forma aislada y
#   reutilizarlos en distintos entornos sin tocar la logica de computo.
# =============================================================================

# -----------------------------------------------------------------------------
# SG del ALB (Application Load Balancer) - unico punto de entrada publico
# -----------------------------------------------------------------------------
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-sg-alb"
  description = "Permite HTTP/HTTPS desde Internet hacia el balanceador"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP publico"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS publico"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Todo el trafico saliente permitido (hacia la capa web)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg-alb"
  }
}

# -----------------------------------------------------------------------------
# SG capa WEB (Vue servido por Nginx) - solo recibe trafico del ALB
# -----------------------------------------------------------------------------
resource "aws_security_group" "web" {
  name        = "${var.project_name}-sg-web"
  description = "Solo permite HTTP desde el ALB y SSH desde la IP de administracion"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP unicamente desde el ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description = "SSH solo desde la IP/rango de administracion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg-web"
  }
}

# -----------------------------------------------------------------------------
# SG capa BACKEND (Express API) - solo recibe trafico de la capa web
# -----------------------------------------------------------------------------
resource "aws_security_group" "backend" {
  name        = "${var.project_name}-sg-backend"
  description = "Solo permite el puerto de la API desde la capa web y SSH desde admin"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Puerto API Express unicamente desde la capa web"
    from_port       = var.backend_port
    to_port         = var.backend_port
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  ingress {
    description = "SSH solo desde la IP/rango de administracion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg-backend"
  }
}
