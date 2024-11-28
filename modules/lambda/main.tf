resource "aws_sns_topic" "autoscale_handling" {
  name = "${var.deployment_name}-${var.autoscale_handler_unique_identifier}"
}

resource "aws_iam_role_policy" "autoscale_handling" {
  name = "${var.deployment_name}-${var.autoscale_handler_unique_identifier}"
  role = aws_iam_role.autoscale_handling.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Action":[
        "autoscaling:DescribeTags",
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:CompleteLifecycleAction",
        "ec2:DescribeInstances",
        "route53:GetHostedZone",
        "ec2:CreateTags",
        "ec2:DescribeTags"
      ],
      "Effect":"Allow",
      "Resource":"*"
    },
    {
      "Action":[
        "route53:ChangeResourceRecordSets",
        "route53:ListResourceRecordSets"
      ],
      "Effect":"Allow",
      "Resource":"${var.autoscale_route53zone_arn}"
    },
     {
      "Action":[
        "route53:ChangeResourceRecordSets",
        "route53:ListResourceRecordSets"
      ],
      "Effect":"Allow",
      "Resource":"${var.autoscale_route53reverse_zone_arn}"
    },
    {
      "Action":[
        "dynamodb:GetItem",
        "dynamodb:BatchGetItem",
        "dynamodb:Query",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "dynamodb:BatchWriteItem"
      ],
      "Effect":"Allow",
      "Resource":"*"
    },
    {
      "Action":[
        "ssm:SendCommand",
        "ssm:GetCommandInvocation"
      ],
      "Effect":"Allow",
      "Resource":"*"
    }
  ]
}
EOF

}

resource "aws_iam_role" "autoscale_handling" {
  name = "${var.deployment_name}-${var.autoscale_handler_unique_identifier}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_role" "lifecycle" {
  name               = "${var.deployment_name}-${var.autoscale_handler_unique_identifier}-lifecycle"
  assume_role_policy = data.aws_iam_policy_document.lifecycle.json
}

data "aws_iam_policy_document" "lifecycle" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["autoscaling.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "lifecycle_policy" {
  name   = "${var.deployment_name}-${var.autoscale_handler_unique_identifier}-lifecycle"
  role   = aws_iam_role.lifecycle.id
  policy = data.aws_iam_policy_document.lifecycle_policy.json
}

data "aws_iam_policy_document" "lifecycle_policy" {
  statement {
    effect    = "Allow"
    actions   = ["sns:Publish", "autoscaling:CompleteLifecycleAction"]
    resources = [aws_sns_topic.autoscale_handling.arn]
  }
}

data "archive_file" "autoscale" {
  type        = "zip"
  source_file = "${path.module}/scripts/autoscale/autoscale.py"
  output_path = "${path.module}/scripts/dist/autoscale.zip"
}

resource "aws_lambda_function" "autoscale_handling" {
  depends_on = [aws_sns_topic.autoscale_handling, aws_iam_role_policy.autoscale_handling]

  filename         = data.archive_file.autoscale.output_path
  function_name    = "${var.deployment_name}-${var.autoscale_handler_unique_identifier}"
  role             = aws_iam_role.autoscale_handling.arn
  handler          = "autoscale.lambda_handler"
  runtime          = "python3.11"
  source_code_hash = filebase64sha256(data.archive_file.autoscale.output_path)
  description      = "Handles DNS for autoscaling groups by receiving autoscaling notifications and setting/deleting records from route53"

  timeout = 600
  environment {
    variables = {
      "USE_PUBLIC_IP" = var.use_public_ip
      "ROUTE53_TTL"   = var.route53_record_ttl
    }
  }
  # vpc_config {
  #   subnet_ids = var.private_subnet_ids
  #   security_group_ids = var.security_group_default_id
  # }
}

resource "aws_lambda_permission" "autoscale_handling" {
  depends_on = [aws_lambda_function.autoscale_handling]

  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.autoscale_handling.arn
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.autoscale_handling.arn
}

resource "aws_sns_topic_subscription" "autoscale_handling" {
  depends_on = [aws_lambda_permission.autoscale_handling]

  topic_arn = aws_sns_topic.autoscale_handling.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.autoscale_handling.arn
}

####################################################################

