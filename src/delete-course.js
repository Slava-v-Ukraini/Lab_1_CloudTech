const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, DeleteCommand } = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

exports.handler = async (event) => {
  const id = event.pathParameters ? event.pathParameters.id : JSON.parse(event.body).id;
  const command = new DeleteCommand({
    TableName: "courses",
    Key: { id: id }
  });
  await docClient.send(command);
  return {
    statusCode: 200,
    body: JSON.stringify({ message: "Course deleted" }),
  };
};