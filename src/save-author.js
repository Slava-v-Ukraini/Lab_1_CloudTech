const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, DeleteCommand } = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

exports.handler = async (event) => {
    // 1. Універсальне отримання ID (для Proxy та VTL режимів)
    const id = event.id || 
               (event.pathParameters ? event.pathParameters.id : null) || 
               (event.body ? (typeof event.body === 'string' ? JSON.parse(event.body).id : event.body.id) : null);

    // Перевірка на наявність ID
    if (!id) {
        return {
            statusCode: 400,
            headers: { "Access-Control-Allow-Origin": "*" },
            body: JSON.stringify({ message: "Missing author ID" }),
        };
    }

    const command = new DeleteCommand({
        TableName: "authors",
        Key: { id: id }
    });

    try {
        await docClient.send(command);
        return {
            statusCode: 200,
            headers: {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "OPTIONS,DELETE",
                "Access-Control-Allow-Headers": "Content-Type"
            },
            body: JSON.stringify({ message: "Author deleted successfully", id: id }),
        };
    } catch (error) {
        return {
            statusCode: 500,
            headers: { "Access-Control-Allow-Origin": "*" },
            body: JSON.stringify({ message: error.message }),
        };
    }
};