using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace FiapCloudGames.Notifications.Application.Configurations.Email;

public static class EmailConfig
{
    public static IServiceCollection AddEmailConfig(this IServiceCollection services, IConfiguration configuration)
    {
        services.Configure<EmailSettings>(configuration.GetSection("EmailSettings"));
        return services;
    }
}