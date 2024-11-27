***Descrição da Arquitetura com Fluxo Operacional***

Visão Geral
A arquitetura do projeto foi projetada para ser escalável, modular e segura, utilizando os principais serviços da AWS: API Gateway, AWS Lambda e Amazon SQS. O objetivo é permitir o processamento de solicitações HTTP com suporte a dois tipos de operações: consultas (query) e comandos (command), onde os comandos podem ser processados de forma assíncrona por meio de uma fila de mensagens.

Componentes da Arquitetura
API Gateway

Responsável por receber as requisições HTTP e encaminhá-las para as funções Lambda apropriadas, com base na rota e no tipo da operação.
Configurado para dois endpoints principais:
/teste: Mapeado para a função queryLambda.
/teste: Mapeado para a função commandLambda.
Funções Lambda

queryLambda: Processa consultas simples e retorna uma resposta imediata ao cliente.
commandLambda: Processa comandos e interage com a SQS para enviar mensagens para processamento assíncrono.
Amazon SQS

Utilizada para enfileirar comandos enviados pela função commandLambda.
Garante a durabilidade e a entrega das mensagens, permitindo que consumidores (como outras funções Lambda) processem os comandos posteriormente.
IAM Roles

Configuradas para garantir que as funções Lambda tenham permissões limitadas e específicas para interagir com o API Gateway e a SQS, garantindo a segurança do sistema.
Fluxo Operacional
O fluxo operacional detalha como os componentes interagem para processar as solicitações do cliente.

Fluxo de Consulta (Query)
Recepção da Requisição

O cliente envia uma requisição HTTP para o endpoint /teste do API Gateway.
Exemplo de requisição:

```bash
curl -X GET https://your-api-id.execute-api.us-east-1.amazonaws.com/teste
``` 
API Gateway Invoca Lambda

O API Gateway repassa a requisição à função queryLambda, com os dados da solicitação encapsulados em um evento.
Processamento pela queryLambda

A função processa os dados e retorna uma resposta simples.
Exemplo de resposta da queryLambda:

```json
{
  "statusCode": 200,
  "body": "\"Consulta processada com sucesso\""
}
```

Resposta ao Cliente

O API Gateway entrega a resposta da função Lambda ao cliente, concluindo o fluxo.
Fluxo de Comando (Command)
Recepção do Comando

O cliente envia uma requisição HTTP para o endpoint /teste do API Gateway para executar um comando.
Exemplo de requisição:

```bash
curl -X POST -d '{"comando":"atualizar-dados"}' https://your-api-id.execute-api.us-east-1.amazonaws.com/teste
```
API Gateway Invoca Lambda

O API Gateway encaminha a solicitação para a função commandLambda.
Processamento pela commandLambda

A função processa o comando recebido.
Se o comando exige processamento posterior, uma mensagem é enviada à SQS com os detalhes do comando.
Exemplo de mensagem na fila SQS:

```json
{
  "comando": "atualizar-dados",
  "timestamp": "2024-11-27T10:00:00Z",
  "dados": {...}
}
```
Resposta ao Cliente

A função commandLambda retorna uma resposta ao cliente indicando o status do envio do comando.
Exemplo de resposta da commandLambda:

```json
{
  "statusCode": 200,
  "body": "\"Comando recebido e enfileirado com sucesso\""
}
```

Processamento Posterior (Opcional)

Caso exista um consumidor para a fila SQS (por exemplo, outra função Lambda), ele processará as mensagens enfileiradas.
Fluxo Completo
Requisição Inicial
O cliente envia uma solicitação ao API Gateway.
Processamento pela Função Lambda
Dependendo do endpoint, o API Gateway invoca a função Lambda correta:

queryLambda: Processa a consulta e retorna a resposta.

commandLambda: Processa o comando e, se necessário, interage com a SQS.

**Interação com a SQS**

No caso de comandos que requerem processamento posterior, a mensagem é enviada à SQS.
Resposta ao Cliente
Após o processamento pela Lambda, o API Gateway retorna a resposta ao cliente.
Processamento Assíncrono
Caso configurado, outro componente ou Lambda consome e processa as mensagens da fila SQS.
Diagrama do Fluxo Operacional
Abaixo está o diagrama representando o fluxo:

```lua
+--------------+      +-------------------+       +--------------------+
|   Cliente    | ---> |   API Gateway     | ----> | Lambda (query/command) |
+--------------+      +-------------------+       +--------------------+
                        |
                        v
                 +----------------+
                 |   SQS Queue    |  <-- (Se necessário)
                 +----------------+
```
Considerações Finais
Escalabilidade

O uso de serviços serverless, como Lambda e API Gateway, garante que o sistema seja capaz de lidar com altas demandas de requisições, escalando automaticamente conforme necessário.
Segurança

Todas as permissões são gerenciadas via IAM Roles, garantindo que cada componente tenha acesso apenas aos recursos que realmente precisa.
Flexibilidade e Expansão

Novos endpoints podem ser adicionados ao API Gateway com facilidade.
Outras funções Lambda podem ser implementadas para lidar com operações mais complexas.
Novas filas SQS podem ser integradas ao sistema para atender a diferentes fluxos de comandos.
