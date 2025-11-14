// © [2025] EDT&Partners. Licensed under CC BY 4.0.
exports.handler = async (event, context) => {
  console.log("Lambda function invoked!");

  const response = {
    statusCode: 200,
    body: JSON.stringify({
      message: "Hello from Lambda!",
      input: event,
    }),
  };

  return response;
};