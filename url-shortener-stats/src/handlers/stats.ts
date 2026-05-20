import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";

import { StatsService } from "../services/stats.service";

const service = new StatsService();

export const handler = async (
  event: APIGatewayProxyEvent,
): Promise<APIGatewayProxyResult> => {
  try {
    const codigo = event.pathParameters?.codigo;

    const fecha = event.queryStringParameters?.fecha;

    const data = await service.getStats(codigo!, fecha);

    return {
      statusCode: 200,

      body: JSON.stringify(data),
    };
  } catch (error: any) {
    console.log(error);

    return {
      statusCode: 500,

      body: JSON.stringify({
        message: "Error",

        details: error.message,
      }),
    };
  }
};
