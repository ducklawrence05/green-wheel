using Infrastructure.ApplicationDbContext;
using Microsoft.EntityFrameworkCore;

namespace API.Extentions
{
    public static class InfrastructureRegistration
    {
        public static void AddInfrastructue(this IServiceCollection services, string connectionString)
        {
            services.AddDbContext<IGreenWheelDbContext, GreenWheelDbContext>(options =>
            {
                // Đổi từ UseSqlServer sang UseNpgsql
                options.UseNpgsql(connectionString);
            });
        }
    }
}