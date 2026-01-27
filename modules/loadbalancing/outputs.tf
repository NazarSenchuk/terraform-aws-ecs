output "target_groups" {
    value  = aws_lb_target_group.groups
}
output "url" {
    value = aws_lb.main.dns_name
} 

output "listener_rules" {
    value = aws_lb_listener_rule.services
}

