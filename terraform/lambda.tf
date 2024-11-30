# Connect
resource "aws_lambda_function" "connect" {
  function_name = "${var.app_name}-connect"
  role = aws_iam_role.lambda_main.arn
  image_uri = "${local.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/connect:${var.image_tag}"
  package_type = "Image"
  timeout = 30
  environment {
    variables = {
        AWS_TABLE_NAME = "${var.websocket_table_name}"
    }
  }
}

resource "aws_lambda_permission" "connect_permission" {
    statement_id = "AllowExecutionFromAPIGateway"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.connect.function_name
    principal = "apigateway.amazonaws.com"
    source_arn = "${aws_apigatewayv2_api.websocket_gw.execution_arn}/*/*"
}

# Disconnect
resource "aws_lambda_function" "disconnect" {
  function_name = "${var.app_name}-disconnect"
  role = aws_iam_role.lambda_main.arn
  image_uri = "${local.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/disconnect:${var.image_tag}"
  package_type = "Image"
  timeout = 30
  environment {
    variables = {
        AWS_TABLE_NAME = "${var.websocket_table_name}"
    }
  }
}

resource "aws_lambda_permission" "disconnect_permission" {
    statement_id = "AllowExecutionFromAPIGateway"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.disconnect.function_name
    principal = "apigateway.amazonaws.com"
    source_arn = "${aws_apigatewayv2_api.websocket_gw.execution_arn}/*/*"
}

# sendnotification
resource "aws_lambda_function" "sendnotification" {
  function_name = "${var.app_name}-sendnotification"
  role = aws_iam_role.lambda_main.arn
  image_uri = "${local.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/sendnotification:${var.image_tag}"
  package_type = "Image"
  timeout = 30
  environment {
    variables = {
        AWS_TABLE_NAME = "${var.websocket_table_name}"
        AWS_SQS_URL = "https://sqs.us-east-1.amazonaws.com/050451396195/connectrix-studio-notification"
        AWS_WEBSOCKET_URL = "${aws_apigatewayv2_api.websocket_gw.api_endpoint}/${var.api_gateway_stage_name}"
    }
  }
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
    event_source_arn = "arn:aws:sqs:${var.aws_region}:${local.account_id}:${var.sqs_queue_name}"
    function_name = aws_lambda_function.sendnotification.arn
}

resource "aws_lambda_permission" "sendnotification_permission" {
    statement_id = "AllowExecutionFromSQS"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.sendnotification.function_name
    principal = "sqs.amazonaws.com"
     source_arn = "arn:aws:sqs:${var.aws_region}:${local.account_id}:${var.sqs_queue_name}"
}