resource "aws_iam_openid_connect_provider" "this" {
  count = var.cicd.github == true ? 1 : 0
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

}

resource "aws_iam_role" "this" {
  name               = "github_oidc_role"
  assume_role_policy = data.aws_iam_policy_document.github_actions.json
}

resource "local_file" "example_script" {
  for_each = var.services
  
  filename = "${path.module}/generated/${each.key}-workflow.yml"
  content  = templatefile("${path.module}/templates/actions.yaml.tpl", {
    
    role           = aws_iam_role.this.arn
    session        = "${each.key}-session"
    registry       = var.cicd.registry
    registry_region =  var.cicd.registry_region
    region         = var.general.region
    container_name = each.key
    service_name   = each.key
    cluster_name   = var.cluster_name
    task_defenition = "${var.general.environment}-${var.general.project}-${each.key}"
  })
}