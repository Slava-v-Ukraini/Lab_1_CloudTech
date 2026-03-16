const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, GetCommand } = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

exports.handler = async (event) => {
  const id = event.pathParameters ? event.pathParameters.id : (event.body ? JSON.parse(event.body).id : null);

  if (!id) {
    return { statusCode: 400, body: JSON.stringify({ message: "Missing course ID" }) };
  }

  const command = new GetCommand({
    TableName: "courses",
    Key: { id: id }
  });

  const response = await docClient.send(command);
  
  if (!response.Item) {
    return { statusCode: 404, body: JSON.stringify({ message: "Course not found" }) };
  }

  return {
    statusCode: 200,
    body: JSON.stringify(response.Item),
  };
};