const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, PutCommand } = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

exports.handler = async (event) => {
  const body = typeof event.body === 'string' ? JSON.parse(event.body) : event.body;
  const command = new PutCommand({
    TableName: "courses",
    Item: body
  });
  await docClient.send(command);
  return {
    statusCode: 201,
    body: JSON.stringify({ message: "Course saved successfully" }),
  };
};