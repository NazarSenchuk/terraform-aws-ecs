data "aws_iam_policy_document" "github_actions" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.this[0].arn]
    }

    condition {
      test     = "StringEquals"
      values   = ["sts.amazonaws.com"]
      variable = "token.actions.githubusercontent.com:aud"
    }

    condition {
      test     = "StringLike"
      values   = ["repo:${var.cicd.github_organization}/*"]
      variable = "token.actions.githubusercontent.com:sub"
    }
  }
}

data "aws_iam_policy_document" "github_actions_policy" {
  statement {
    sid    = "ECRFullAccess"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
      "ecr:CreateRepository",
      "ecr:SetRepositoryPolicy",
      "ecr:DeleteRepository",
      "ecr:TagResource",
      "ecr:UntagResource",
      "ecr:DeleteLifecyclePolicy",
      "ecr:GetLifecyclePolicy",
      "ecr:PutLifecyclePolicy",
      "ecr:StartImageScan",
      "ecr:DescribeImageScanFindings",
      "ecr:GetRegistryPolicy",
      "ecr:PutRegistryPolicy"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "ECSDeployAccess"
    effect = "Allow"
    actions = [
      "ecs:DescribeTaskDefinition",
      "ecs:RegisterTaskDefinition",
      "ecs:DeregisterTaskDefinition",
      "ecs:UpdateService",
      "ecs:DescribeServices",
      "ecs:ListServices",
      "ecs:DescribeClusters",
      "ecs:ListClusters",
      "ecs:DescribeTasks",
      "ecs:ListTasks",
      "ecs:RunTask",
      "ecs:StopTask",
      "ecs:DescribeContainerInstances",
      "ecs:ListContainerInstances",
      "ecs:TagResource",
      "ecs:UntagResource"
    ]
    resources = ["*"]
  }
  statement {
  sid    = "AllowPassEcsTaskExecutionRole"
  effect = "Allow"

  actions = [
    "iam:PassRole"
  ]

  resources = [
    "arn:aws:iam::649636402385:role/ecs-task-execution-role"
  ]

  condition {
    test     = "StringEquals"
    variable = "iam:PassedToService"
    values   = ["ecs-tasks.amazonaws.com"]
  }
}
}


resource "aws_iam_policy" "github_actions" {
  name        = "ci-deploy-policy"
  description = "Policy used for deployments on CI"
  policy      = data.aws_iam_policy_document.github_actions_policy.json
}

resource "aws_iam_role_policy_attachment" "github_actions_role" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.github_actions.arn
}