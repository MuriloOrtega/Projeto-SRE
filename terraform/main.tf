# API Gateway para consultas síncronas
resource "aws_api_gateway_rest_api" "query_api" {
  name        = var.api_gateway_name
  description = "API para consultas"
}

# Fila SQS para comandos assíncronos
resource "aws_sqs_queue" "command_queue" {
  name = var.queue_name
}

# Função Lambda para consulta
resource "aws_lambda_function" "query_lambda" {
  function_name = "queryLambda"
  runtime       = var.lambda_runtime
  handler       = "queryLambda.handler"  
  s3_bucket     = "murilomack"  
  s3_key        = "query_lambda.zip"  
  role          = aws_iam_role.lambda_exec_role.arn
}

# Função Lambda para comandos
resource "aws_lambda_function" "command_lambda" {
  function_name = "commandLambda"
  runtime       = var.lambda_runtime
  handler       = "commandLambda.handler"  
  s3_bucket     = "murilomack"  
  s3_key        = "command_lambda.zip"  
  role          = aws_iam_role.lambda_exec_role.arn
}

# Role do IAM para as funções Lambda
resource "aws_iam_role" "lambda_exec_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Política do IAM para permitir que Lambda acesse SQS e CloudWatch (caso necessário)
resource "aws_iam_policy" "lambda_sqs_cloudwatch_policy" {
  name        = "lambda_sqs_cloudwatch_policy"
  description = "Permissões para Lambda acessar SQS e CloudWatch"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["sqs:SendMessage", "sqs:ReceiveMessage", "sqs:DeleteMessage"]
        Effect   = "Allow"
        Resource = aws_sqs_queue.command_queue.arn
      },
      {
        Action   = ["logs:*"]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Anexando a política à Role do Lambda
resource "aws_iam_role_policy_attachment" "lambda_sqs_cloudwatch_attachment" {
  policy_arn = aws_iam_policy.lambda_sqs_cloudwatch_policy.arn
  role       = aws_iam_role.lambda_exec_role.name
}
