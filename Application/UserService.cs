using Application.Abstractions;
using Application.AppExceptions;
using Application.AppSettingConfigurations;
using Application.Constants;
using Application.Dtos.CitizenIdentity.Response;
using Application.Dtos.Common.Request;
using Application.Dtos.DriverLicense.Response;
using Application.Dtos.User.Request;
using Application.Dtos.User.Respone;
using Application.Helpers;
using Application.Repositories;
using Application.UnitOfWorks;
using AutoMapper;
using Domain.Entities;
using Google.Apis.Auth;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.JsonWebTokens;
using System.Security.Claims;

namespace Application
{
    public class UserService : IUserService
    {
        private readonly IUserRepository _userRepository;
        private readonly IRefreshTokenRepository _refreshTokenRepository;
        private readonly IOTPRepository _otpRepository;
        private readonly IJwtBlackListRepository _jwtBackListRepository;
        private readonly IHttpContextAccessor _contextAccessor;
        private readonly JwtSettings _jwtSettings;
        private readonly EmailSettings _emailSettings;
        private readonly OTPSettings _otpSettings;
        private readonly IMapper _mapper;
        private readonly IMemoryCache _cache;
        private readonly IPhotoService _photoService;
        private readonly ICitizenIdentityService _citizenService;
        private readonly IDriverLicenseService _driverService;
        private readonly IMediaUow _mediaUow;
        private readonly ITicketRepository _supportRepo;
        private readonly IRentalContractRepository _rentalContractRepository;
        private readonly ICitizenIdentityRepository _citizenIdentityRepository;
        private readonly IDriverLicenseRepository _driverLicenseRepository;

        public UserService(IUserRepository repository,
            IOptions<JwtSettings> jwtSettings,
            IRefreshTokenRepository refreshTokenRepository,
             IJwtBlackListRepository jwtBackListRepository,
             IOptions<EmailSettings> emailSettings,
             IOTPRepository otpRepository,
             IHttpContextAccessor httpContextAccessor,
             IOptions<OTPSettings> otpSetting,
             IMapper mapper,
             IMemoryCache cache,
             IPhotoService photoService,
             ICitizenIdentityService citizenService,
             IDriverLicenseService driverService,
             IMediaUow mediaUow,
             ITicketRepository supportRepo,
             IRentalContractRepository rentalContractRepository,
             ICitizenIdentityRepository citizenIdentityRepository,
             IDriverLicenseRepository driverLicenseRepository
            )
        {
            _userRepository = repository;
            _refreshTokenRepository = refreshTokenRepository;
            _otpRepository = otpRepository;
            _jwtBackListRepository = jwtBackListRepository;
            _jwtSettings = jwtSettings.Value;
            _emailSettings = emailSettings.Value;
            _contextAccessor = httpContextAccessor;
            _otpSettings = otpSetting.Value;
            _mapper = mapper;
            _cache = cache;
            _photoService = photoService;
            _citizenService = citizenService;
            _driverService = driverService;
            _mediaUow = mediaUow;
            _supportRepo = supportRepo;
            _rentalContractRepository = rentalContractRepository;
            _citizenIdentityRepository = citizenIdentityRepository;
            _driverLicenseRepository = driverLicenseRepository;
        }

        /*
         Login fuction
         this func receive UserLoginReq (dto) form controller incluce (user email and password)
         -> got user from Db by email
            -> null <=> wrong email or password => throw Unauthorize Exception (401)
            -> !null <=> correct email and password => generate refreshToken (set to cookie) and accessToken return to frontend
         */

        public async Task<string?> Login(UserLoginReq user)
        {
            User userFromDB = await _userRepository.GetByEmailAsync(user.Email);

            if (userFromDB != null)
            {
                if (userFromDB.IsGoogleLinked && userFromDB.Password == null)
                {
                    throw new ForbidenException(Message.UserMessage.NotHavePassword);
                }
                if (PasswordHelper.VerifyPassword(user.Password, userFromDB.Password))
                {
                    //tạo refreshtoken và lưu nó vào DB lẫn cookie
                    await GenerateRefreshToken(userFromDB.Id, null);
                    return GenerateAccessToken(userFromDB.Id);
                }
            }
            throw new UnauthorizedAccessException(Message.UserMessage.InvalidEmailOrPassword);
        }

        /*
         Generate Access Token Func
        this func recieve userId
        use jwtHelper and give userID, accesstoken secret secret, type: accesstoken, access token expired time, isser and audience
        to generate access token
         */

        public string GenerateAccessToken(Guid userId)
        {
            return JwtHelper.GenerateUserIDToken(userId, _jwtSettings.AccessTokenSecret, TokenType.AccessToken.ToString(), _jwtSettings.AccessTokenExpiredTime, _jwtSettings.Issuer, _jwtSettings.Audience, null);
        }

        /*
         Generate Refresh Token Func
         This func recieve userId and a ClaimsPrincipal if any
            - When we use refresh token to got a new access token, we will generate a new refresh
              token with expired time of old refresh token if it was not expired
              so that we will give a ClaimsPricipal for that func
        It use jwt helper to generate a token
        then verify this token to got a claimPricipal to take Iat (created time), Exp (expired time) to save this toke to DB

        Then set this token to cookie
         */

        public async Task<string> GenerateRefreshToken(Guid userId, ClaimsPrincipal? oldClaims)
        {
            var _context = _contextAccessor.HttpContext;
            string token = JwtHelper.GenerateUserIDToken(userId, _jwtSettings.RefreshTokenSecret, TokenType.RefreshToken.ToString(),
                _jwtSettings.RefreshTokenExpiredTime, _jwtSettings.Issuer, _jwtSettings.Audience, oldClaims);
            ClaimsPrincipal claims = JwtHelper.VerifyToken(token, _jwtSettings.RefreshTokenSecret, TokenType.RefreshToken.ToString(),
                _jwtSettings.Issuer, _jwtSettings.Audience);
            long.TryParse(claims.FindFirst(JwtRegisteredClaimNames.Iat).Value, out long iatSeconds);
            long.TryParse(claims.FindFirst(JwtRegisteredClaimNames.Exp).Value, out long expSeconds);
            Guid refreshTokenId;
            do
            {
                refreshTokenId = Guid.NewGuid();
            } while (await _refreshTokenRepository.GetByIdAsync(refreshTokenId) != null);
            await _refreshTokenRepository.AddAsync(new RefreshToken()
            {
                Id = refreshTokenId,
                UserId = userId,
                Token = token,
                IssuedAt = DateTimeOffset.FromUnixTimeSeconds(iatSeconds).UtcDateTime,
                CreatedAt = DateTimeOffset.FromUnixTimeSeconds(iatSeconds).UtcDateTime,
                UpdatedAt = DateTimeOffset.FromUnixTimeSeconds(iatSeconds).UtcDateTime,
                ExpiresAt = DateTimeOffset.FromUnixTimeSeconds(expSeconds).UtcDateTime,
                IsRevoked = false
            });
            //lưu vào cookie
            _context.Response.Cookies.Append(CookieKeys.RefreshToken, token, new CookieOptions
            {
                HttpOnly = true,
                Secure = true,         // chỉ gửi qua HTTPS
                SameSite = SameSiteMode.Strict, // tránh CSRF
                Expires = DateTime.UtcNow.AddDays(_jwtSettings.RefreshTokenExpiredTime) // hạn sử dụng
            });
            return token;
        }

        /*
         Send OTP Func
        This function recieve email from controller
        User can got 1 Otp per minutes
        if it func call > 1 turn per minutes -> throw Rate Limit Exceeded Exception (429)
        Remove old OTP in DB before save new Otp
        generate new otp -> save to DB
        send this otp to user email
         */

        public async Task SendOTP(string email)
        {
            int count = await _otpRepository.CountRateLimitAsync(email);
            if (count > _otpSettings.OtpRateLimit)
            {
                throw new RateLimitExceededException(Message.UserMessage.RateLimitOtp);
            }
            await _otpRepository.RemoveOTPAsync(email); //xoá cũ trước khi lưu cái ms
            string otp = GenerateOtpHelper.GenerateOtp();
            await _otpRepository.SaveOTPAsyns(email, otp);
            string subject = "GreenWheel Verification Code";
            var basePath = AppContext.BaseDirectory;
            var templatePath = Path.Combine(basePath, "Templates", "SendOtpTemplate.html");
            var body = File.ReadAllText(templatePath);

            body = body.Replace("{OtpCode}", otp);
            await EmailHelper.SendEmailAsync(_emailSettings, email, subject, body);
        }

        /*
         Verify OTP function
         this function recieve verifyOTPDto from controller include OTP and email
            Token type (type of token to generate) and cookieKey (name of token to save to cookie

        First we use email to take otp from DB
            - Null => this email do not have OTP -> throw Unauthorize Exception (401)
            - !null => this email got a OTP

        Next check OTP & OTP form DB
            - if != => count number of times entered & throw Unauthorize Exception (401)
                       if count > number of entries allowed -> delete otp form DB

        Then generate token by email belong to token type and set it to cookie
            - Register token when register account
            - forgot password token when user forgot thier password
        */

        public async Task<string> VerifyOTP(VerifyOTPReq verifyOTPDto, TokenType type, string cookieKey)
        {
            string? otpFromRedis = await _otpRepository.GetOtpAsync(verifyOTPDto.Email);
            if (otpFromRedis == null)
            {
                throw new UnauthorizedAccessException(Message.UserMessage.InvalidOTP);
            }
            if (verifyOTPDto.OTP != otpFromRedis)
            {
                int count = await _otpRepository.CountAttemptAsync(verifyOTPDto.Email);
                if (count > _otpSettings.OtpAttempts)
                {
                    await _otpRepository.RemoveOTPAsync(verifyOTPDto.Email);
                    await _otpRepository.ResetAttemptAsync(verifyOTPDto.Email);
                    throw new UnauthorizedAccessException(Message.CommonMessage.TooManyRequest);
                }
                throw new UnauthorizedAccessException(Message.UserMessage.InvalidOTP);
            }
            var _context = _contextAccessor.HttpContext;
            await _otpRepository.RemoveOTPAsync(verifyOTPDto.Email);
            string secret = "";
            int expiredTime;
            if (type == TokenType.RegisterToken)
            {
                secret = _jwtSettings.RegisterTokenSecret;
                expiredTime = _jwtSettings.RegisterTokenExpiredTime;
            }
            else
            {
                secret = _jwtSettings.ForgotPasswordTokenSecret;
                expiredTime = _jwtSettings.ForgotPasswordTokenExpiredTime;
            }
            string token = JwtHelper.GenerateEmailToken(verifyOTPDto.Email, secret, type.ToString(), expiredTime, _jwtSettings.Issuer, _jwtSettings.Audience, null);
            _context.Response.Cookies.Append(cookieKey, token, new CookieOptions
            {
                HttpOnly = true,
                Secure = true,         // chỉ gửi qua HTTPS
                SameSite = SameSiteMode.Strict, // tránh CSRF
                Expires = DateTime.UtcNow.AddMinutes(expiredTime) // hạn sử dụng
            });
            return token;
        }

        /*
         Register account func
         This function receive token from controller ( register token ) => done verify otp And userRegisterReq
                                                                                            include user info
         it map userRegisterReq to user
         Then verify this token
            -   401 : invalid token
            - If success -> got claimsPricipal of this token
         got email form this claimPrincipal
         try got user form Db by email
            - != null -> throw Duplicate Exception (409)
            - == null -> create new account =>  generate refreshToken (set to cookie) and accessToken return to frontend
         */

        public async Task<string> RegisterAsync(string token, UserRegisterReq userRegisterReq)
        {
            if (await _userRepository.GetByPhoneAsync(userRegisterReq.Phone) != null)
            {
                throw new ConflictDuplicateException(Message.UserMessage.PhoneAlreadyExist);
            }
            //----check in black list
            if (await _jwtBackListRepository.CheckTokenInBlackList(token))
            {
                throw new UnauthorizedAccessException(Message.UserMessage.Unauthorized);
            }
            //------------------------
            var user = _mapper.Map<User>(userRegisterReq); //map từ một RegisterUserDto sang user
            var claims = JwtHelper.VerifyToken(token, _jwtSettings.RegisterTokenSecret,
                TokenType.RegisterToken.ToString(), _jwtSettings.Issuer, _jwtSettings.Audience);

            var email = claims.FindFirst(JwtRegisteredClaimNames.Sid).Value.ToString();
            var userFromDB = await _userRepository.GetByEmailAsync(email);

            if (userFromDB != null)
            {
                throw new ConflictDuplicateException(Message.UserMessage.EmailAlreadyExists); //email đã tồn tại
            }
            Guid id;
            do
            {
                id = Guid.NewGuid();
            } while (await _userRepository.GetByIdAsync(id) != null);
            //lấy ra list role trong cache
            var roles = _cache.Get<List<Role>>("AllRoles");

            user.Id = id;
            user.CreatedAt = user.UpdatedAt = DateTime.UtcNow;
            user.Email = email;
            user.RoleId = roles.FirstOrDefault(r => r.Name == "Customer").Id;
            user.DeletedAt = null;
            Guid userId = await _userRepository.AddAsync(user);
            string accesstoken = GenerateAccessToken(userId);
            string refreshToken = await GenerateRefreshToken(userId, null);

            //----save to black list
            long.TryParse(claims.FindFirst(JwtRegisteredClaimNames.Exp).Value, out long expSeconds);
            await _jwtBackListRepository.SaveTokenAsyns(token, expSeconds);

            return accesstoken;
        }

        /*
         Change password func
         This func use for change password use case
         IT recieve userClaims from token of accessToken, oldPassword and new password => verify => take user ID from claims
         got user from DB by id
            - null -> throw unauthorized exception (401) (invalid accesstoken)
            - != null  -> verify password in DB == old password ?
                - == -> set new passwrd
                - != return unauthorized (401) (old password is incorrect)

         */

        public async Task ChangePassword(ClaimsPrincipal userClaims, UserChangePasswordReq userChangePasswordReq)
        {
            var userID = userClaims.FindFirstValue(JwtRegisteredClaimNames.Sid)!.ToString();
            var userFromDB = await _userRepository.GetByIdAsync(Guid.Parse(userID));
            if (userFromDB == null)
            {
                throw new UnauthorizedAccessException(Message.UserMessage.Unauthorized);
            }
            if (userFromDB.Password != null && !PasswordHelper.VerifyPassword(userChangePasswordReq.OldPassword, userFromDB.Password))
            {
                throw new UnauthorizedAccessException(Message.UserMessage.OldPasswordIsIncorrect);
            }
            if (userFromDB.Password == null && !userFromDB.IsGoogleLinked)
            {
                throw new UnauthorizedAccessException(Message.UserMessage.OldPasswordIsIncorrect);
            }
            await _refreshTokenRepository.RevokeRefreshTokenByUserID(userID);
            userFromDB.Password = PasswordHelper.HashPassword(userChangePasswordReq.Password);
            await _userRepository.UpdateAsync(userFromDB);
        }

        /*
         Reset Password Func
         This function use for forgot password use case
         it recieve forgotPasswordToken (after verify email) and password from Controller
         verify this token
            - 401 : Invalid token

         if success -> got a claims -> take email form claim -> find user in DB by email
            - == null -> throw unAuthorized exception (401) : invalid token (hacker)
            - != null => revoke all refresh token of this account from DB and change password

         */

        public async Task ResetPassword(string forgotPasswordToken, string password)
        {
            //----check in black list
            if (await _jwtBackListRepository.CheckTokenInBlackList(forgotPasswordToken))
            {
                throw new UnauthorizedAccessException(Message.UserMessage.Unauthorized);
            }
            //------------------------
            var claims = JwtHelper.VerifyToken(forgotPasswordToken, _jwtSettings.ForgotPasswordTokenSecret,
                                                TokenType.ForgotPasswordToken.ToString(), _jwtSettings.Issuer, _jwtSettings.Audience);

            //------------------------
            string email = claims.FindFirstValue(JwtRegisteredClaimNames.Sid)!.ToString();
            var userFromDB = await _userRepository.GetByEmailAsync(email);
            if (userFromDB == null)
            {
                throw new UnauthorizedAccessException(Message.UserMessage.Unauthorized);
            }
            await _refreshTokenRepository.RevokeRefreshTokenByUserID(userFromDB.Id.ToString());
            userFromDB.Password = PasswordHelper.HashPassword(password);
            await _userRepository.UpdateAsync(userFromDB);
            //---- save to black list
            long.TryParse(claims.FindFirst(JwtRegisteredClaimNames.Exp).Value, out long expSeconds);
            await _jwtBackListRepository.SaveTokenAsyns(forgotPasswordToken, expSeconds);
        }

        /*
         Logout func
         this function got refresh token from controller (cookie)
         -> revoke this token
         */

        public async Task<int> Logout(string refreshToken)
        {
            JwtHelper.VerifyToken(refreshToken, _jwtSettings.RefreshTokenSecret, TokenType.RefreshToken.ToString(), _jwtSettings.Issuer, _jwtSettings.Audience);
            return await _refreshTokenRepository.RevokeRefreshToken(refreshToken);
        }

        /*
         Refresh token func
         this function use to got new accesstoken by refresh token
         it receive refreshToken from controller, and a bool variable (want to be got a revoked token)
         verify this token
            - 401 : invalid token
         if success got a claim, got it token form BD by token
            - == null => 401 exception
           - != null -> generate new access token and refresh token with expired time = old refresh token expired time (use old claims)
         */

        public async Task<string> RefreshToken(string refreshToken, bool getRevoked)
        {
            ClaimsPrincipal claims = JwtHelper.VerifyToken(refreshToken,
                                                            _jwtSettings.RefreshTokenSecret,
                                                            TokenType.RefreshToken.ToString(),
                                                            _jwtSettings.Issuer,
                                                            _jwtSettings.Audience);

            if (claims != null)
            {
                RefreshToken refreshTokenFromDB = await _refreshTokenRepository.GetByRefreshToken(refreshToken, getRevoked);
                if (refreshTokenFromDB == null)
                {
                    throw new UnauthorizedAccessException(Message.UserMessage.InvalidRefreshToken);
                }
                string newAccessToken = GenerateAccessToken(refreshTokenFromDB.UserId);
                string newRefreshToken = await GenerateRefreshToken(refreshTokenFromDB.UserId, claims);
                await _refreshTokenRepository.RevokeRefreshToken(refreshTokenFromDB.Token);

                return newAccessToken;
            }

            throw new UnauthorizedAccessException(Message.UserMessage.InvalidRefreshToken);
        }

        public async Task<Dictionary<string, string>> LoginWithGoogle(GoogleJsonWebSignature.Payload req)
        {
            var _context = _contextAccessor.HttpContext;
            User user = await _userRepository.GetByEmailAsync(req.Email);
            if (user == null)
            {
                Guid id;
                do
                {
                    id = Guid.NewGuid();
                } while (await _userRepository.GetByIdAsync(id) != null);
                var roles = _cache.Get<List<Role>>("AllRoles");
                user = new User
                {
                    Id = id,
                    FirstName = req.GivenName,
                    LastName = req.FamilyName,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow,
                    Email = req.Email,
                    Password = null,
                    DateOfBirth = null,
                    RoleId = roles.FirstOrDefault(r => r.Name == RoleName.Customer)!.Id,
                    IsGoogleLinked = true,
                    DeletedAt = null,
                };
                await _userRepository.AddAsync(user);
            }

            if (user.IsGoogleLinked == false) user.IsGoogleLinked = true;
            string accessToken = GenerateAccessToken(user.Id);
            await GenerateRefreshToken(user.Id, null);
            return new Dictionary<string, string>
            {
                { TokenType.AccessToken.ToString() , accessToken}
            };
        }

        public async Task<UserProfileViewRes> GetMeAsync(ClaimsPrincipal userClaims)
        {
            Guid userID = Guid.Parse(userClaims.FindFirst(JwtRegisteredClaimNames.Sid).Value.ToString());
            //User userFromDb = await _userRepository.GetByIdAsync(userID);
            // Lấy hồ sơ người dùng KÈM theo thông tin Role (Phúc thêm)
            // Mục đích: khi trả về UserProfileViewRes cần có tên/quyền của vai trò (vd: "Customer", "Staff")
            // Lý do: tránh phải query thêm để lấy Role, đồng thời đảm bảo mapping có đủ dữ liệu quyền hạn
            // added: include role data when retrieving staff profile
            // Mục đích:  response /api/users/me trả về đầy đủ thông tin role,
            // giúp useAuth ở frontend biết chắc user có role “staff”.
            User? userFromDb = await _userRepository.GetByIdWithFullInfoAsync(userID)
                ?? throw new NotFoundException(Message.UserMessage.UserNotFound);
            return _mapper.Map<UserProfileViewRes>(userFromDb);
        }

        public async Task UpdateMeAsync(ClaimsPrincipal userClaims, UserUpdateReq userUpdateReq)
        {
            if (!string.IsNullOrEmpty(userUpdateReq.Phone))
            {
                if (await _userRepository.GetByPhoneAsync(userUpdateReq.Phone) != null)
                {
                    throw new ConflictDuplicateException(Message.UserMessage.PhoneAlreadyExist);
                }
            }
            Guid userID = Guid.Parse(userClaims.FindFirst(JwtRegisteredClaimNames.Sid).Value.ToString());
            User userFromDb = await _userRepository.GetByIdAsync(userID);
            if (userFromDb == null)
            {
                throw new DirectoryNotFoundException(Message.UserMessage.UserNotFound);
            }
            if (userUpdateReq.FirstName != null) userFromDb.FirstName = userUpdateReq.FirstName;
            if (userUpdateReq.LastName != null) userFromDb.LastName = userUpdateReq.LastName;
            if (!string.IsNullOrEmpty(userUpdateReq.Phone)) userFromDb.Phone = userUpdateReq.Phone;
            if (userUpdateReq.DateOfBirth != null) userFromDb.DateOfBirth = userUpdateReq.DateOfBirth;
            if (userUpdateReq.Sex != null) userFromDb.Sex = userUpdateReq.Sex;
            if (!string.IsNullOrEmpty(userUpdateReq.AvatarUrl)) userFromDb.AvatarUrl = userUpdateReq.AvatarUrl;
            await _userRepository.UpdateAsync(userFromDb);
        }

        public async Task<User?> GetUserByIdAsync(Guid id)
        {
            return await _userRepository.GetByIdAsync(id);
        }

        public async Task<string> UploadAvatarAsync(Guid userId, IFormFile file)
        {
            if (file == null || file.Length == 0)
                throw new ArgumentException(Message.CloudinaryMessage.NotFoundObjectInFile);

            // 1. Upload ảnh mới
            var uploadReq = new UploadImageReq { File = file };
            var uploaded = await _photoService.UploadPhotoAsync(uploadReq, $"users/{userId}");
            if (string.IsNullOrEmpty(uploaded.Url))
                throw new InvalidOperationException(Message.CloudinaryMessage.UploadFailed);

            // 2. Lấy user và nhớ avatar cũ
            var user = await _mediaUow.Users.GetByIdAsync(userId)
                ?? throw new KeyNotFoundException(Message.UserMessage.UserNotFound);
            var oldPublicId = user.AvatarPublicId;
            var result = await _photoService.UploadPhotoAsync(uploadReq, $"users/{userId}");

            if (string.IsNullOrEmpty(result.Url))
                throw new InvalidOperationException(Message.CloudinaryMessage.UploadFailed);

            // 3. Transaction DB
            await using var trx = await _mediaUow.BeginTransactionAsync();
            try
            {
                user.AvatarUrl = uploaded.Url;
                user.AvatarPublicId = uploaded.PublicID;
                user.UpdatedAt = DateTime.UtcNow;

                await _mediaUow.Users.UpdateAsync(user);
                await _mediaUow.SaveChangesAsync();
                await trx.CommitAsync();
            }
            catch
            {
                await trx.RollbackAsync();
                // rollback cloud nếu DB lỗi
                try { await _photoService.DeletePhotoAsync(uploaded.PublicID); } catch { }
                throw;
            }

            // 4. Sau commit: xóa ảnh cũ (best-effort)
            if (!string.IsNullOrEmpty(oldPublicId))
            {
                try { await _photoService.DeletePhotoAsync(oldPublicId); } catch { }
            }

            return user.AvatarUrl!;
        }

        public async Task DeleteAvatarAsync(Guid userId)
        {
            var user = await _userRepository.GetByIdAsync(userId)
                ?? throw new Exception(Message.UserMessage.UserNotFound);

            if (string.IsNullOrEmpty(user.AvatarPublicId))
                throw new Exception(Message.UserMessage.NotFoundAvatar);

            await _photoService.DeletePhotoAsync(user.AvatarPublicId);

            user.AvatarUrl = null;
            user.AvatarPublicId = null;
            await _userRepository.UpdateAsync(user);
        }

        public async Task CheckDupEmailAsync(string email)
        {
            if (await _userRepository.GetByEmailAsync(email) != null)
            {
                throw new ConflictDuplicateException(Message.UserMessage.EmailAlreadyExists);
            }
        }

        public async Task<CitizenIdentityRes> UploadCitizenIdAsync(Guid userId, IFormFile file)
        {
            var uploadReq = new UploadImageReq { File = file };
            var uploaded = await _photoService.UploadPhotoAsync(uploadReq, "citizen-ids");
            if (string.IsNullOrEmpty(uploaded.Url))
                throw new InvalidOperationException(Message.CloudinaryMessage.UploadFailed);

            // Lấy bản ghi cũ (nếu có)
            var old = await _mediaUow.CitizenIdentities.GetByUserIdAsync(userId);

            await using var trx = await _mediaUow.BeginTransactionAsync();
            try
            {
                var entity = await _citizenService.ProcessCitizenIdentityAsync(userId, uploaded.Url, uploaded.PublicID)
                    ?? throw new BusinessException(Message.UserMessage.InvalidLicenseData);

                await _mediaUow.SaveChangesAsync();
                await trx.CommitAsync();

                // Sau commit: xóa ảnh cũ
                if (!string.IsNullOrEmpty(old?.ImagePublicId))
                {
                    try { await _photoService.DeletePhotoAsync(old.ImagePublicId); } catch { }
                }

                return _mapper.Map<CitizenIdentityRes>(entity);
            }
            catch
            {
                await trx.RollbackAsync();
                try { await _photoService.DeletePhotoAsync(uploaded.PublicID); } catch { }
                throw;
            }
        }

        public async Task<DriverLicenseRes> UploadDriverLicenseAsync(Guid userId, IFormFile file)
        {
            var uploadReq = new UploadImageReq { File = file };
            var uploaded = await _photoService.UploadPhotoAsync(uploadReq, "driver-licenses");
            if (string.IsNullOrEmpty(uploaded.Url))
                throw new InvalidOperationException(Message.CloudinaryMessage.UploadFailed);

            var old = await _mediaUow.DriverLicenses.GetByUserId(userId);

            await using var trx = await _mediaUow.BeginTransactionAsync();
            try
            {
                var entity = await _driverService.ProcessDriverLicenseAsync(userId, uploaded.Url, uploaded.PublicID)
                    ?? throw new BusinessException(Message.UserMessage.InvalidLicenseData);

                await _mediaUow.SaveChangesAsync();
                await trx.CommitAsync();

                if (!string.IsNullOrEmpty(old?.ImagePublicId))
                {
                    try { await _photoService.DeletePhotoAsync(old.ImagePublicId); } catch { }
                }

                return _mapper.Map<DriverLicenseRes>(entity);
            }
            catch
            {
                await trx.RollbackAsync();
                try { await _photoService.DeletePhotoAsync(uploaded.PublicID); } catch { }
                throw;
            }
        }

        public async Task<CitizenIdentityRes?> GetMyCitizenIdentityAsync(Guid userId)
        {
            var entity = await _citizenService.GetByUserId(userId);
            if (entity == null) 
                throw new NotFoundException(Message.UserMessage.CitizenIdentityNotFound);

            return _mapper.Map<CitizenIdentityRes>(entity);
        }

        public async Task<DriverLicenseRes?> GetMyDriverLicenseAsync(Guid userId)
        {
            var entity = await _driverService.GetByUserIdAsync(userId);
            if (entity == null) 
                throw new NotFoundException(Message.UserMessage.LicenseNotFound);

            return _mapper.Map<DriverLicenseRes>(entity);
        }

        public async Task<Guid> CreateAnounymousAccount(CreateUserReq req)
        {
            var user = await _userRepository.GetByPhoneAsync(req.Phone);
            if (user != null)
            {
                var rentalContract = _rentalContractRepository.GetByCustomerAsync(user.Id);
                if (rentalContract != null)
                {
                    throw new BusinessException(Message.RentalContractMessage.UserAlreadyHaveContract);
                }
                throw new ConflictDuplicateException(Message.UserMessage.PhoneAlreadyExist);
            }
            user = _mapper.Map<User>(req);
            Guid userId;
            do
            {
                userId = Guid.NewGuid();
            } while (await _userRepository.GetByIdAsync(userId) != null);
            user.Id = userId;
            await _userRepository.AddAsync(user);
            return userId;
        }

        public async Task<UserProfileViewRes> GetUserByPhoneAsync(string phone)
        {
            var user = await _userRepository.GetByPhoneAsync(phone);
            if (user == null)
            {
                throw new NotFoundException(Message.UserMessage.UserNotFound);
            }
            var userViewRes = _mapper.Map<UserProfileViewRes>(user);
            return userViewRes;
        }

        public async Task<IEnumerable<User>> GetAllUsersAsync()
        {
            var users = await _userRepository.GetAllAsync();
            return users;
        }

        public async Task<UserProfileViewRes> GetByCitizenIdentityAsync(string idNumber)
        {
            var citizenIdentity = await _citizenIdentityRepository.GetByIdNumberAsync(idNumber);
            if (citizenIdentity == null)
            {
                throw new NotFoundException(Message.UserMessage.CitizenIdentityNotFound);
            }
            var userView = _mapper.Map<UserProfileViewRes>(citizenIdentity.User);
            return userView;
        }

        public async Task<UserProfileViewRes> GetByDriverLicenseAsync(string number)
        {
            var driverLicense = await _driverLicenseRepository.GetByLicenseNumber(number);
            if (driverLicense == null)
            {
                throw new NotFoundException(Message.UserMessage.CitizenIdentityNotFound);
            }
            var userView = _mapper.Map<UserProfileViewRes>(driverLicense.User);
            return userView;
        }
    }
}