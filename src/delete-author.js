const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, DeleteCommand } = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

exports.handler = async (event) => {
    const id = event.id || (event.pathParameters ? event.pathParameters.id : null);

    const command = new DeleteCommand({
        TableName: "authors",
        Key: { id: id }
    });

    try {
        await docClient.send(command);
        return {
            statusCode: 200,
            body: JSON.stringify({ message: "Author deleted successfully" }),
        };
    } catch (error) {
        return {
            statusCode: 500,
            body: JSON.stringify({ message: error.message }),
        };
    }
};