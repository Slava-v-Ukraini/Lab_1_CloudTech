const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, UpdateCommand } = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

exports.handler = async (event) => {
  const body = typeof event.body === 'string' ? JSON.parse(event.body) : event.body;
  
  const command = new UpdateCommand({
    TableName: "courses",
    Key: { id: body.id },
    UpdateExpression: "set title = :t, authorId = :a",
    ExpressionAttributeValues: {
      ":t": body.title,
      ":a": body.authorId
    },
    ReturnValues: "ALL_NEW"
  });

  const response = await docClient.send(command);
  return {
    statusCode: 200,
    body: JSON.stringify({ message: "Course updated", updatedAttributes: response.Attributes }),
  };
};