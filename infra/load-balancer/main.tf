# =============================================================================
# MODULO: load-balancer  (Ejercicio 2)
# -----------------------------------------------------------------------------
# Responsabilidad de este modulo:
#   Crear un Application Load Balancer (ALB) publico que reparte el trafico
#   HTTP entrante entre todas las instancias de la capa WEB (Vue + Nginx),
#   con su Target Group y health checks correspondientes.
#
# Justificacion de por que este es un modulo independiente:
#   El balanceador es un componente "transversal" que depende de la red
#   (subredes publicas), de seguridad (SG del ALB) y del compute (instancias
#   web) pero no pertenece a ninguno de ellos: es la capa de "entrada" del
#   sistema. Aislarlo permite, por ejemplo, sustituirlo por un NLB o añadir
#   HTTPS/ACM sin tocar el resto de la infraestructura.
# =============================================================================

resource "aws_lb" "web_alb" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = values(var.public_subnet_ids)

  tags = {
    Name = "${var.project_name}-alb"
  }
}

# -----------------------------------------------------------------------------
# Target Group: agrupa las instancias web y define el health check
# -----------------------------------------------------------------------------
resource "aws_lb_target_group" "web_tg" {
  name     = "${var.project_name}-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 15
    matcher             = "200-399"
  }

  tags = {
    Name = "${var.project_name}-web-tg"
  }
}

# -----------------------------------------------------------------------------
# Listener HTTP :80 -> reenvia al target group de la capa web
# (Para HTTPS bastaria con añadir un listener 443 + certificate_arn de ACM)
# -----------------------------------------------------------------------------
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

# -----------------------------------------------------------------------------
# Registro de cada instancia web en el Target Group
# -----------------------------------------------------------------------------
resource "aws_lb_target_group_attachment" "web" {
  for_each = var.web_instance_ids

  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = each.value
  port             = 80
}
