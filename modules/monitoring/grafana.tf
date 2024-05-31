## Grafana workspace

resource "aws_grafana_workspace" "monitoring" {
  account_access_type      = "CURRENT_ACCOUNT"
  authentication_providers = ["AWS_SSO"]
  permission_type          = "SERVICE_MANAGED"
  role_arn                 = aws_iam_role.assume.arn
  # grafana_version          = 9.4
  name        = "${var.deployment_name}-monitoring"
  description = "Grafana workspace for monitoring ${var.deployment_name}"

  data_sources = ["PROMETHEUS", "CLOUDWATCH"]
  vpc_configuration {
    security_group_ids = [var.security_group_default_id, var.sg_all_node_id, var.sg_open_rpc_id]
    subnet_ids         = var.devnet_private_subnet_ids
  }
}

resource "aws_iam_role" "assume" {
  name = "grafana-assume-testnet"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "grafana.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "grafana_policy" {
  name        = format("%s-%s_grafana_policy", var.deployment_name, var.network_type)
  path        = "/"
  description = "Policy to provide permission to grafana"
  policy      = <<BLADE
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricData",
                "cloudwatch:DescribeAlarmsForMetric",
                "cloudwatch:DescribeAlarmHistory",
                "cloudwatch:DescribeAlarms",
                "cloudwatch:ListMetrics",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:GetMetricData",
                "cloudwatch:GetInsightRuleReport"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstanceStatus",
                "ec2:DescribeTags",
                "ec2:DescribeInstances",
                "ec2:DescribeREgions"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "tag:GetResources"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "aps:ListWorkspaces",
                "aps:DescribeWorkspace",
                "aps:QueryMetrics",
                "aps:GetLabels",
                "aps:GetSeries",
                "aps:GetMetricMetadata"
            ],
            "Resource": "*"
        }
    ]
}
BLADE
}

resource "aws_iam_role_policy_attachment" "grafana_policy_role" {
  role       = aws_iam_role.assume.name
  policy_arn = aws_iam_policy.grafana_policy.arn
}

## Adding the grafana user created manually in IAM  as the admin
resource "aws_grafana_role_association" "admin" {
  role         = "ADMIN"
  user_ids     = ["48a1c310-1051-70e1-146d-e703747811eb"]
  workspace_id = aws_grafana_workspace.monitoring.id
}
