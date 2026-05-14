const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, PutCommand } = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

exports.handler = async (event) => {
    const body = typeof event.body === 'string' ? JSON.parse(event.body) : event.body;

    const command = new PutCommand({
        TableName: "authors",
        Item: {
            id: body.id,
            name: body.name
        }
    });

    try {
        await docClient.send(command);
        return {
            statusCode: 201,
            headers: { "Access-Control-Allow-Origin": "*" },
            body: JSON.stringify({ message: "Author saved successfully" }),
        };
    } catch (error) {
        return {
            statusCode: 500,
            body: JSON.stringify({ message: error.message }),
        };
    }
};