import { DynamoDBClient } from "@aws-sdk/client-dynamodb";

import { DynamoDBDocumentClient, QueryCommand } from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({});

const documentClient = DynamoDBDocumentClient.from(client);

export class StatsRepository {
  async getVisits(codigo: string) {
    const response = await documentClient.send(
      new QueryCommand({
        TableName: process.env.VISITS_TABLE,

        KeyConditionExpression: "codigo = :codigo",

        ExpressionAttributeValues: {
          ":codigo": codigo,
        },
      }),
    );

    return response.Items || [];
  }
}
