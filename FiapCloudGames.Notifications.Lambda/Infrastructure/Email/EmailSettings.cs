namespace FiapCloudGames.Notifications.Application.Configurations.Email;

public class EmailSettings
{
    public string SmtpHost { get; set; }
    public int SmtpPort { get; set; }
    public string SmtpUser { get; set; }
    public string SmtpPass { get; set; }
    public string FromEmail { get; set; }
    public string FromName { get; set; }
    public bool UseMailHog { get; set; }
}