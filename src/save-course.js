const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, PutCommand } = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

exports.handler = async (event) => {
    // Парсимо тіло запиту (фронтенд присилає рядок)
    const body = typeof event.body === 'string' ? JSON.parse(event.body) : event.body;

    const command = new PutCommand({
        TableName: "courses",
        Item: {
            id: body.id || Date.now().toString(),
            title: body.title,
            authorId: body.authorId,
            category: body.category,
            length: body.length
        }
    });

    try {
        await docClient.send(command);
        return {
            statusCode: 201,
            headers: {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "OPTIONS,POST",
                "Access-Control-Allow-Headers": "Content-Type"
            },
            body: JSON.stringify({ message: "Course created successfully" }),
        };
    } catch (error) {
        return {
            statusCode: 500,
            headers: { "Access-Control-Allow-Origin": "*" },
            body: JSON.stringify({ message: error.message }),
        };
    }
};