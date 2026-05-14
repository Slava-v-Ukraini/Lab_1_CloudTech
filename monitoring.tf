resource "aws_sns_topic" "alerts" {
  name = "${var.namespace}-${var.stage}-alerts-topic"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "myroslav.holub.ri.2024@lpnu.ua" 
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${var.namespace}-${var.stage}-lambda-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "60" 
  statistic           = "Sum"
  threshold           = "0" 
  alarm_description   = "This alarm triggers if any error occurs in the Lambda function"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    FunctionName = module.lambdas["get-all-courses"].function_name
  }
}

resource "aws_cloudwatch_log_metric_filter" "error_pattern_filter" {
  name           = "ErrorPatternFilter"
  pattern        = "?Error ?Critical ?Fail" # Шукаємо ці слова
  log_group_name = "/aws/lambda/${module.lambdas["get-all-courses"].function_name}"

  metric_transformation {
    name      = "CriticalErrorCount"
    namespace = "MyCustomMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "billing_alarm" {
  alarm_name          = "BillingAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = "21600" # 6 годин
  statistic           = "Maximum"
  threshold           = "5" 
  alarm_description   = "Alarm if estimated charges exceed $5"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    Currency = "USD"
  }
}