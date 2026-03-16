const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, ScanCommand } = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

exports.handler = async () => {
  const command = new ScanCommand({ TableName: "authors" });
  const response = await docClient.send(command);
  return {
    statusCode: 200,
    body: JSON.stringify(response.Items),
  };
};