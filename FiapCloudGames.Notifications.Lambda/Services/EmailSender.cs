using FiapCloudGames.Notifications.Application.Configurations.Email;
using Microsoft.Extensions.Options;
using System.Net;
using System.Net.Mail;

namespace FiapCloudGames.Notifications.Application.Services.Email;

public class EmailSender
    (
// IOptions<EmailSettings> emailSettings
    )
    : IEmailSender
{
    //private readonly EmailSettings _emailSettings = emailSettings.Value;

    public async Task SendEmailAsync(string to, string subject, string body)
    {
        using var message = new MailMessage();
        message.From = new MailAddress("no-reply@fiapcloudgames.local", "FiapCloudGames - Notifications");
        message.To.Add(to);
        message.Subject = subject;
        message.Body = body;
        message.IsBodyHtml = true;

        using var client = new SmtpClient("mailhog.apps.svc.cluster.local", 1025); //8025 = Interface Web 

        client.EnableSsl = false; // MailHog não usa SSL
        client.Credentials = new NetworkCredential("test", "test");

        await client.SendMailAsync(message);
    }
}