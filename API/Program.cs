using API.Extentions;
using API.Filters;
using API.Middleware;
using Application;
using Application.Abstractions;
using Application.AppSettingConfigurations;
using Application.Mappers;
using Application.Repositories;
using Application.UnitOfWorks;
using Application.Validators.User;
using CloudinaryDotNet;
using DotNetEnv;
using FluentValidation;
using Infrastructure.Interceptor;
using Infrastructure.Repositories;
using Infrastructure.UnitOfWorks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;
using AutoMapper;

namespace API
{
    public class Program
    {
        public static async Task Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            Env.Load("../.env");

            // Frontend Url
            var frontendOrigin = Environment.GetEnvironmentVariable("FRONTEND_ORIGIN")
                ?? "http://localhost:3000";

            // Add services to the container.
            // Add services to the container.
            builder.Services.Configure<CloudinarySettings>(builder.Configuration.GetSection("CloudinarySettings"));
            var cloudinarySettings = builder.Configuration.GetSection("CloudinarySettings").Get<CloudinarySettings>();
            builder.Services.AddControllers();
            // Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
            builder.Services.AddEndpointsApiExplorer();
            builder.Services.AddSwaggerGen();

            //Cors frontEnd
            builder.Services.AddCors(options =>
            {
                options.AddPolicy("AllowFrontend",
                    policy =>
                    {
                        policy.WithOrigins(frontendOrigin) // FE origin
                              .AllowAnyHeader()
                              .AllowAnyMethod()
                              .AllowCredentials(); // nếu bạn gửi cookie (refresh_token)
                    });
            });
            //kết nối DB
            builder.Services.AddInfrastructue(Environment.GetEnvironmentVariable("MSSQL_CONNECTION_STRING")!);
            //Cache
            builder.Services.AddStackExchangeRedisCache(options =>
            {
                options.Configuration = Environment.GetEnvironmentVariable("REDIS_CONFIGURATION")!;
                options.InstanceName = builder.Configuration["Redis:InstanceName"];
            });
            //thêm httpcontextAccessor để lấy context trong service
            builder.Services.AddHttpContextAccessor();
            //Add repositories
            builder.Services.AddScoped(typeof(IGenericRepository<>), typeof(GenericRepository<>));
            builder.Services.AddScoped<IUserRepository, UserRepository>();
            builder.Services.AddScoped<IRefreshTokenRepository, RefreshTokenRepository>();
            builder.Services.AddScoped<IOTPRepository, OTPRepository>();
            builder.Services.AddScoped<IUserRoleRepository, UserRoleRepository>();
            builder.Services.AddScoped<IJwtBlackListRepository, JwtBlackListRepository>();
            builder.Services.AddScoped<IVehicleRepository, VehicleRepository>();
            builder.Services.AddScoped<IVehicleModelRepository, VehicleModelRepository>();
            builder.Services.AddScoped<ICitizenIdentityRepository, CitizenIdentityRepository>();
            builder.Services.AddScoped<IDriverLicenseRepository, DriverLicenseRepository>();
            builder.Services.AddScoped<IRentalContractRepository, RentalContractRepository>();
            builder.Services.AddScoped<IInvoiceRepository, InvoiceRepository>();
            builder.Services.AddScoped<IInvoiceItemRepository, InvoiceItemRepository>();
            builder.Services.AddScoped<IDepositRepository, DepositRepository>();
            builder.Services.AddScoped<IStationRepository, StationRepository>();
            builder.Services.AddScoped<IMomoPaymentLinkRepository, MomoPaymentRepository>();
            builder.Services.AddScoped<IModelImageRepository, ModelImageRepository>();
            builder.Services.AddScoped<IVehicleSegmentRepository, VehicleSegmentRepository>();
            builder.Services.AddScoped<ICloudinaryRepository, CloudinaryRepository>();
            builder.Services.AddScoped<ITicketRepository, TicketRepository>();
            builder.Services.AddScoped<IVehicleCheckListRepository, VehicleChecklistRepository>();
            builder.Services.AddScoped<IVehicleChecklistItemRepository, VehicleChecklistItemRepository>();
            builder.Services.AddScoped<IStationFeedbackRepository, StationFeedbackRepository>();
            //Add Services
            builder.Services.AddScoped<IVehicleChecklistService, VehicleChecklistService>();
            builder.Services.AddScoped<IVehicleSegmentService, VehicleSegmentService>();
            builder.Services.AddScoped<IInvoiceService, InvoiceService>();
            builder.Services.AddScoped<IUserService, UserService>();
            builder.Services.AddScoped<IGoogleCredentialService, GoogleCredentialService>();
            builder.Services.AddScoped<IVehicleModelService, VehicleModelService>();
            builder.Services.AddScoped<IVehicleService, VehicleService>();
            builder.Services.AddScoped<IRentalContractService, RentalContractService>();
            builder.Services.AddScoped<IStationService, StationService>();
            builder.Services.AddScoped<ICitizenIdentityService, CitizenIdentityService>();
            builder.Services.AddScoped<IDriverLicenseService, DriverLicenseService>();
            builder.Services.AddScoped<IModelImageService, ModelImageService>();
            builder.Services.AddScoped<IPhotoService, CloudinaryService>();
            builder.Services.AddScoped<ITicketService, TicketService>();
            builder.Services.AddScoped<IStationFeedbackService, StationFeedbackService>();
            builder.Services.AddScoped<IChecklistItemImageService, ChecklistItemImageService>();
            //Interceptor
            builder.Services.AddScoped<UpdateTimestampInterceptor>();
            //Add Client
            builder.Services.AddHttpClient<IMomoService, MomoService>();
            builder.Services.AddHttpClient<IGeminiService, GeminiService>();
            //UOW
            builder.Services.AddScoped<IRentalContractUow, RentalContractUow>();
            builder.Services.AddScoped<IInvoiceUow, InvoiceUow>();
            builder.Services.AddScoped<IMediaUow, MediaUow>();
            builder.Services.AddScoped<IModelImageUow, ModelImageUow>();
            builder.Services.AddScoped<IVehicleChecklistUow, VehicleChecklistUow>();
            //Mapper
            builder.Services.AddAutoMapper(typeof(UserProfile)); // auto mapper sẽ tự động scan hết assembly đó và xem tất cả thằng kết thừa Profile rồi tạo lun
                                                                 // mình chỉ cần truyền một thằng đại diện thoi
            builder.Services.AddAutoMapper(AppDomain.CurrentDomain.GetAssemblies());
            //configure <-> setting
            //Momo
            builder.Services.Configure<MomoSettings>(builder.Configuration.GetSection("MomoSettings"));
            //JWT
            builder.Services.Configure<JwtSettings>(builder.Configuration.GetSection("JwtSettings"));
            var _jwtSetting = builder.Configuration.GetSection("JwtSettings").Get<JwtSettings>();
            builder.Services.AddJwtTokenValidation(_jwtSetting!);
            //Email
            builder.Services.Configure<EmailSettings>(builder.Configuration.GetSection("EmailSettings"));
            //Otp
            builder.Services.Configure<OTPSettings>(builder.Configuration.GetSection("OTPSettings"));
            //Google
            builder.Services.Configure<GoogleAuthSettings>(builder.Configuration.GetSection("GoogleAuthSettings"));
            //Gemini
            builder.Services.Configure<GeminiSettings>(builder.Configuration.GetSection("Gemini"));
            //Cloudinary
            builder.Services.Configure<CloudinarySettings>(builder.Configuration.GetSection("CloudinarySettings"));
            //middleware
            builder.Services.AddScoped<GlobalErrorHandlerMiddleware>();
            //sử dụng cahce
            builder.Services.AddMemoryCache();

            //thêm filter cho validation
            builder.Services.AddControllers(options =>
            {
                // Thêm ValidationFilter vào pipeline
                options.Filters.Add<ValidationFilter>();
            });
            //Fluentvalidator
            builder.Services.AddValidatorsFromAssemblyContaining(typeof(UserLoginReqValidator));
            //tắt validator tự ném lỗi
            builder.Services.Configure<ApiBehaviorOptions>(options =>
            {
                options.SuppressModelStateInvalidFilter = true;
            });

            //khai báo sử dụng DI cho cloudinary

            //Cấu hình request nhận request, nó tự chuyển trường của các đối tượng trong
            //DTO thành snakeCase để binding giá trị, và lúc trả ra
            //thì các trường trong respone cũng sẽ bị chỉnh thành snake case
            //Ảnh hưởng khi map từ json sang object và object về json : json <-> object
            // builder.Services.AddControllers()
            // .AddJsonOptions(options =>
            // {
            //     options.JsonSerializerOptions.PropertyNamingPolicy = new SnakeCaseNamingPolicy();
            //     options.JsonSerializerOptions.PropertyNameCaseInsensitive = true;
            // });

            // đk cloudinary
            var account = new Account(
                cloudinarySettings.CloudName,
                cloudinarySettings.ApiKey,
                cloudinarySettings.ApiSecret
            );
            var cloudinary = new Cloudinary(account)
            {
                Api = { Secure = true }
            };
            builder.Services.AddSingleton(cloudinary);

            var app = builder.Build();
            //accept frontend
            app.UseCors("AllowFrontend");
            //run cache and add list roll to cache
            using (var scope = app.Services.CreateScope())
            {
                var roleRepo = scope.ServiceProvider.GetRequiredService<IUserRoleRepository>();
                var roles = await roleRepo.GetAllAsync();

                var cache = scope.ServiceProvider.GetRequiredService<IMemoryCache>();
                //set cache và đảm bảo nó chạy xuyên suốt app
                cache.Set("AllRoles", roles, new MemoryCacheEntryOptions
                {
                    //cache này sẽ tồn tại suốt vòng đời của cache
                    Priority = CacheItemPriority.NeverRemove
                });
            }
            // Configure the HTTP request pipeline.
            if (app.Environment.IsDevelopment())
            {
                app.UseSwagger();
                app.UseSwaggerUI();
            }
            app.UseMiddleware<GlobalErrorHandlerMiddleware>();
            //app.UseHttpsRedirection();

            app.UseAuthentication();
            app.UseAuthorization();

            app.MapControllers();

            app.Run();
        }
    }
}