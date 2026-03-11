FROM mcr.microsoft.com/dotnet/sdk:8.0 AS development
WORKDIR /src

# Thiết lập biến môi trường
ENV ASPNETCORE_ENVIRONMENT=Development
ENV ASPNETCORE_URLS=http://+:5160
EXPOSE 5160

# Dùng dotnet watch để tự động reload (Hot Reload) khi có code thay đổi
ENTRYPOINT ["dotnet", "watch", "run", "--project", "API/API.csproj", "--non-interactive", "--no-launch-profile"]