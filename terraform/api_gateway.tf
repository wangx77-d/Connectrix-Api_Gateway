# WEBSOCKET API GATEWAY
resource "aws_apigatewayv2_api" "websocket_gw" {
    name = "${var.app_name}-websocket"
    protocol_type = "WEBSOCKET"
    route_selection_expression = "$request.body.action"
}

# INTEGRATIONS
resource "aws_apigatewayv2_integration" "connect" {
  api_id = aws_apigatewayv2_api.websocket_gw.id
  integration_uri = aws_lambda_function.connect.invoke_arn
  integration_type = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_integration" "disconnect" {
  api_id = aws_apigatewayv2_api.websocket_gw.id
  integration_uri = aws_lambda_function.disconnect.invoke_arn
  integration_type = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_integration" "sendnotification" {
  api_id = aws_apigatewayv2_api.websocket_gw.id
  integration_uri = aws_lambda_function.sendnotification.invoke_arn
  integration_type = "AWS_PROXY"
  integration_method = "POST"
}

# ROUTES
resource "aws_apigatewayv2_route" "_connect" {
    api_id = aws_apigatewayv2_api.websocket_gw.id
    route_key = "$connect"
    target = "integrations/${aws_apigatewayv2_integration.connect.id}"
}

resource "aws_apigatewayv2_route" "_disconnect" {
    api_id = aws_apigatewayv2_api.websocket_gw.id
    route_key = "$disconnect"
    target = "integrations/${aws_apigatewayv2_integration.disconnect.id}"
}

resource "aws_apigatewayv2_route" "_sendnotification" {
    api_id = aws_apigatewayv2_api.websocket_gw.id
    route_key = "sendnotification"
    target = "integrations/${aws_apigatewayv2_integration.sendnotification.id}"
}

# STAGE
resource "aws_apigatewayv2_stage" "primary_websocket" {
    api_id = aws_apigatewayv2_api.websocket_gw.id
    name = var.api_gateway_stage_name
    auto_deploy = true
}