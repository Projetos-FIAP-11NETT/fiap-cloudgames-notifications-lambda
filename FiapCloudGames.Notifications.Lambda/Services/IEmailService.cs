using FiapCloudGames.Notifications.Lambda.Models;

namespace FiapCloudGames.Notifications.Lambda.Services
{
    public interface IEmailService
    {
        Task SendAsync(EmailMessage message);
    }
}
