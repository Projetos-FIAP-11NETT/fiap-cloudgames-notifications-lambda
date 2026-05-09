using Amazon.Lambda.Core;
using Amazon.Lambda.SQSEvents;
using FiapCloudGames.Notifications.Lambda.Models;
using FiapCloudGames.Notifications.Lambda.Services;
using System.Text.Json;


// Assembly attribute to enable the Lambda function's JSON input to be converted into a .NET class.
[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.SystemTextJson.DefaultLambdaJsonSerializer))]

namespace FiapCloudGames.Notifications.Lambda;

public class EmailFunction
{
    private readonly IEmailService _emailService;

    /// <summary>
    /// Default constructor. This constructor is used by Lambda to construct the instance. When invoked in a Lambda environment
    /// the AWS credentials will come from the IAM role associated with the function and the AWS region will be set to the
    /// region the Lambda function is executed in.
    /// </summary>
    public EmailFunction()
    {
        _emailService = new SesEmailService();
    }


    /// <summary>
    /// This method is called for every Lambda invocation. This method takes in an SQS event object and can be used 
    /// to respond to SQS messages.
    /// </summary>
    /// <param name="evnt">The event for the Lambda function handler to process.</param>
    /// <param name="context">The ILambdaContext that provides methods for logging and describing the Lambda environment.</param>
    /// <returns></returns>
    public async Task FunctionHandler(SQSEvent evnt, ILambdaContext context)
    {
        foreach(var message in evnt.Records)
        {
            await ProcessMessageAsync(message, context);
        }
    }

    private async Task ProcessMessageAsync(SQSEvent.SQSMessage message, ILambdaContext context)
    {
        context.Logger.LogInformation($"Processed message {message.Body}");

        var emailMessage = JsonSerializer.Deserialize<EmailMessage>(message.Body);

        //try
        //{
            await _emailService.SendAsync(emailMessage!);
        //}
        //catch (Exception ex)
        //{
            //context.Logger.LogError($"Erro inesperado ao enviar mensagem {message.MessageId}: {ex}");
        //}

        //await Task.CompletedTask;
    }
}