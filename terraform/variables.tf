variable "region" {
  description = "Região AWS"
  default     = "us-east-1" 
}

variable "queue_name" {
  description = "Nome da fila SQS"
  default     = "command-queue"
}

variable "lambda_runtime" {
  description = "Tempo de execução da função Lambda"
  default     = "python3.9"
}

variable "api_gateway_name" {
  description = "Nome da API do API Gateway"
  default     = "query-api"
}
