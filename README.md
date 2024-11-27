# **Projeto SRE - Terraform**

## **Descrição**

Este projeto tem como objetivo demonstrar o uso de **Infraestrutura como Código (IaC)** na AWS, utilizando **Terraform** para provisionar recursos como **API Gateway**, **Lambda Functions** e **SQS**. O sistema é composto por dois principais fluxos:

- **Consulta (Query)**: Um endpoint que retorna uma mensagem de sucesso.
- **Comando (Command)**: Um endpoint que processa comandos, enviando-os para uma fila **SQS** para processamento posterior.

A solução utiliza o **Terraform** para provisionamento e configuração de toda a infraestrutura e **AWS Lambda** para executar a lógica de consulta e comandos.

## **Arquitetura**

A arquitetura do sistema é composta pelos seguintes componentes:

1. **API Gateway**: Um gateway HTTP que expõe rotas para interação com os usuários.
2. **AWS Lambda**: Funções para processamento de comandos e consultas.
3. **SQS**: Fila para armazenamento e processamento assíncrono de comandos.
4. **IAM**: Funções de permissão para garantir que os serviços tenham acesso apropriado aos recursos.

## **Fluxo Operacional**

1. **Consulta (Query)**: O cliente faz uma requisição ao endpoint `/teste` do **API Gateway**, que invoca a função **Lambda** `queryLambda`. A função retorna uma resposta de sucesso.

2. **Comando (Command)**: O cliente envia um comando ao endpoint `/teste`, que invoca a função **Lambda** `commandLambda`. A função pode enfileirar a mensagem em uma fila **SQS** para processamento posterior.

## **Tecnologias Utilizadas**

- **Terraform**: Para provisionamento de infraestrutura como código.
- **AWS API Gateway**: Para criação de APIs RESTful.
- **AWS Lambda**: Para execução de funções serverless.
- **AWS SQS**: Para filas de mensagens.
- **IAM**: Para gerenciamento de permissões.

## **Pré-requisitos**

Antes de rodar o projeto, verifique se você tem as seguintes ferramentas instaladas:

- [Terraform](https://www.terraform.io/) (versão 0.14 ou superior)
- [AWS CLI](https://aws.amazon.com/cli/)
- Conta na **AWS** com permissões adequadas para criar os recursos necessários (IAM, Lambda, API Gateway, SQS).

## **Como Rodar o Projeto**

### **1. Configuração do Terraform**

1. Clone o repositório:

   ```bash
   git clone https://github.com/MuriloOrtega/Projeto-SRE.git
   cd Projeto-SRE

Navegue até o diretório do Terraform:

```bash
cd terraform
```
Inicialize o Terraform:

```bash
terraform init
```
Verifique o plano de execução do Terraform:

```bash
terraform plan
```
Aplique a configuração para criar os recursos na AWS:

```bash
terraform apply
```

2. Configuração da AWS
Configure suas credenciais da AWS utilizando o AWS CLI:

```bash
aws configure
```
Defina a região da AWS que será utilizada (por exemplo, us-east-1).

3. Subir Código para AWS Lambda
Para que as funções Lambda funcionem corretamente, é necessário empacotar os arquivos Python e enviar para o S3. Isso já está configurado no Terraform, então não é necessário realizar essa etapa manualmente se o código já foi subido para o repositório.

4. Testando o Sistema
Após a aplicação do Terraform, você pode testar os endpoints da API diretamente no API Gateway.

Consulta (Query): Envie uma requisição GET para o endpoint /teste.

```bash
curl -X GET https://your-api-id.execute-api.us-east-1.amazonaws.com/teste
```

A resposta será:

json
```bash
{
  "statusCode": 200,
  "body": "\"Comando bem-sucedido\""
}
```
Comando (Command): Envie uma requisição POST para o endpoint /teste com o comando desejado.

```bash
curl -X POST https://your-api-id.execute-api.us-east-1.amazonaws.com/teste -d '{"command": "doSomething"}'
```
A função commandLambda processa o comando e o envia para a fila SQS.

5. Destruição dos Recursos
Se você quiser destruir todos os recursos criados para esse projeto, basta executar o seguinte comando dentro do diretório do Terraform:

```bash
terraform destroy
```
Estrutura de Arquivos
kotlin

```bash
Projeto-SRE/
│
├── lambdas/
│   ├── command_lambda.zip    # Código para a função Lambda de comando
│   └── query_lambda.zip      # Código para a função Lambda de consulta
│
├── terraform/
│   ├── main.tf               # Arquivo principal do Terraform, define os recursos
│   ├── outputs.tf            # Saídas do Terraform
│   ├── providers.tf          # Definição do provedor AWS
│   └── variables.tf          # Variáveis para o Terraform
│
└── README.md                 # Documentação do projeto
```

Considerações Finais
Este projeto serve como exemplo de como usar Infraestrutura como Código para criar uma solução escalável, segura e eficiente utilizando a AWS. Ele pode ser facilmente expandido com novos recursos e funções conforme as necessidades do sistema aumentam.

