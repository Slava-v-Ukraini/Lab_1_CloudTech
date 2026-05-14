const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, ScanCommand } = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

exports.handler = async () => {
  try {
    const command = new ScanCommand({ TableName: "authors" });
    const response = await docClient.send(command);
    
    const formattedAuthors = (response.Items || []).map(author => {
      const nameParts = author.name ? author.name.split(' ') : ["Unknown", "Author"];
      
      return {
        id: author.id,
        firstName: nameParts[0],            
        lastName: nameParts.slice(1).join(' ') 
      };
    });

    return {
      statusCode: 200,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "OPTIONS,GET,POST,PUT,DELETE",
        "Access-Control-Allow-Headers": "Content-Type"
      },
      body: JSON.stringify(formattedAuthors), 
    };
  } catch (error) {
    return {
      statusCode: 500,
      headers: { "Access-Control-Allow-Origin": "*" },
      body: JSON.stringify({ message: error.message }),
    };
  }
};