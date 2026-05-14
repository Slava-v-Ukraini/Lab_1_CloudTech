const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, GetCommand } = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

exports.handler = async (event) => {
  const id = event.id || 
               (event.pathParameters ? event.pathParameters.id : null) || 
               (event.body ? (typeof event.body === 'string' ? JSON.parse(event.body).id : event.body.id) : null);
  if (!id) {
    return { statusCode: 400, body: JSON.stringify({ message: "Missing course ID" }) };
  }

  const command = new GetCommand({
    TableName: "courses",
    Key: { id: id }
  });

  try {
        const response = await docClient.send(command);
        
        if (!response.Item) {
            throw new Error("Course not found");
        }

        return response.Item; 

      } catch (error) {
        throw new Error(error.message);
        }
};