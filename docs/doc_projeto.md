Fluxo Operacional
O fluxo operacional descreve como os componentes do sistema interagem quando uma requisição é feita ao API Gateway, processada pelas funções Lambda, e interage com a fila SQS. Abaixo está o processo passo a passo, desde a solicitação até a execução do comando.

Fluxo de Consulta (Query)
Recepção da Requisição: O cliente (usuário ou sistema) envia uma requisição HTTP para o endpoint /teste do API Gateway. Essa solicitação pode ser feita via GET, POST, etc.

Exemplo de requisição:

curl -X GET https://your-api-id.execute-api.us-east-1.amazonaws.com/teste

API Gateway Invoca Lambda: O API Gateway é configurado para invocar a função queryLambda quando a rota /teste for acessada. O API Gateway repassa os dados da requisição para a função Lambda, em formato de evento.

Execução da Função Lambda: A função queryLambda é executada, processando a requisição e gerando uma resposta. No exemplo da função, a resposta é simplesmente uma mensagem de sucesso:

Resposta da função:
json
Copiar código
{
  "statusCode": 200,
  "body": "\"Comando bem-sucedido\""
}
Resposta ao Cliente: A função Lambda retorna a resposta ao API Gateway, que por sua vez envia a resposta ao cliente que fez a requisição. O cliente recebe a resposta HTTP com o código de status 200 e a mensagem "Comando bem-sucedido".

Fluxo de Comando (Command)
Recepção do Comando: O cliente ou sistema envia uma requisição HTTP para o endpoint /teste do API Gateway. Essa solicitação pode ser, por exemplo, uma tentativa de enviar um comando para ser processado.

API Gateway Invoca Lambda: Similar ao fluxo de consulta, o API Gateway invoca a função commandLambda quando a rota /teste é acessada, passando os dados da requisição para a função Lambda.

Processamento do Comando pela Lambda:

A função commandLambda processa o comando e, em vez de retornar uma resposta direta, pode interagir com a fila SQS para registrar ou enfileirar o comando.
A função pode enviar uma mensagem à fila SQS para que outro processo (ou outra função Lambda) processe o comando posteriormente.
Mensagem Enviada à Fila SQS:

Caso a função commandLambda envie um comando para a fila SQS, uma mensagem é colocada na fila para posterior processamento.
A função pode incluir dados específicos sobre o comando ou dados adicionais para processamento posterior.
Processamento pelo Consumidor (se houver): Se houver outro componente ou função Lambda que consome mensagens da fila SQS, ele pode pegar a mensagem e processá-la conforme necessário. Por exemplo, outra função Lambda poderia ser configurada para "escutar" essa fila, buscar mensagens e realizar operações baseadas nas mensagens recebidas.

Resposta ao Cliente: Após o processamento do comando, a função commandLambda pode retornar uma resposta ao cliente com o status de sucesso ou falha. O API Gateway retransmite a resposta de volta para o cliente.

Fluxo Completo: Consulta + Comando
Requisição Inicial: O cliente envia uma requisição ao API Gateway, que pode ser uma solicitação de consulta (GET) ou comando (POST, PUT, DELETE, etc.).

Processamento pelo Lambda: O API Gateway invoca a função Lambda correspondente, seja queryLambda ou commandLambda, passando os dados da requisição para a função.

Interação com SQS (se aplicável): Se o comando enviado for uma interação com a fila SQS, a função Lambda coloca a mensagem na fila para processamento futuro.

Resposta ao Cliente: Após o processamento, o API Gateway retorna uma resposta HTTP ao cliente, informando o sucesso ou falha da operação.

Diagrama do Fluxo Operacional
Aqui está um diagrama básico para ilustrar o fluxo:

lua
Copiar código
+--------------+      +-------------------+       +--------------------+
|   Cliente    | ---> |   API Gateway     | ----> | Lambda (query/command) |
+--------------+      +-------------------+       +--------------------+
                        |
                        v
                 +----------------+
                 |   SQS Queue    |  <-- Se necessário
                 +----------------+




Cliente: Envia requisição HTTP ao API Gateway.
API Gateway: Invoca a função Lambda (consulta ou comando).
Lambda: Processa a requisição e interage com a fila SQS (se necessário).
SQS: Armazena comandos para posterior processamento (opcional).

"""Considerações Finais"""

Escalabilidade: A solução é escalável porque os serviços como Lambda e API Gateway podem lidar com um grande número de requisições simultâneas.
Segurança: O uso de funções Lambda com IAM Roles garante que os serviços tenham permissões limitadas e controladas, minimizando o risco de acesso indevido.
Futuras Expansões: O sistema pode ser expandido facilmente com novas funções Lambda, novas rotas no API Gateway e mais filas SQS para processar diferentes tipos de comandos.