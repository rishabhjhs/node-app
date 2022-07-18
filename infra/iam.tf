data "aws_iam_policy_document" "app_task_execution_assume_role_policy" {
  statement {
    sid = "assume"
    effect = "Allow"
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "app_task_execution_role" {
  name = "app_task_execution_role"
  assume_role_policy = data.aws_iam_policy_document.app_task_execution_assume_role_policy.json
}


data "aws_iam_policy" "AmazonECSTaskExecutionRolePolicy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "app_task_execution_policy" {
  policy_arn = data.aws_iam_policy.AmazonECSTaskExecutionRolePolicy.arn
  role = aws_iam_role.app_task_execution_role.name
}


data "aws_iam_policy_document" "cloudwatch_log_policy" {
  statement {
    effect = "Allow"
    resources = ["arn:aws:logs:*:*:*"]
    actions = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogStreams"]
  }
}


resource "aws_iam_policy" "log_policy" {
  name = "log_policy"
  policy = data.aws_iam_policy_document.cloudwatch_log_policy.json
}

resource "aws_iam_role_policy_attachment" "app_task_log_policy" {
  policy_arn = aws_iam_policy.log_policy.arn
  role = aws_iam_role.app_task_execution_role.name
}