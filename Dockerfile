# ==========================================
# STAGE 1: BUILD (Dùng SDK nặng để compile code)
# ==========================================
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy cấu hình NuGet chuẩn của bạn vào trước
COPY NuGet.Config ./

# Chỉ copy các file .csproj vào trước để restore package
# (Kỹ thuật này giúp Docker cache lại layer này, build lần sau cực nhanh)
COPY API/API.csproj API/
COPY Application/Application.csproj Application/
COPY Domain/Domain.csproj Domain/
COPY Infrastructure/Infrastructure.csproj Infrastructure/

# Chạy restore với cấu hình từ NuGet.Config
RUN dotnet restore API/API.csproj --verbosity minimal

# Copy toàn bộ code còn lại vào và Publish
COPY . .
WORKDIR /src/API
RUN dotnet publish API.csproj -c Release -o /app/publish /p:UseAppHost=false

# ==========================================
# STAGE 2: RUNTIME (Dùng bản AspNet cực nhẹ chỉ để chạy code)
# ==========================================
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS runtime
WORKDIR /app

# Expose port chuẩn
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

# Copy file đã compile từ Stage 1 sang Stage 2
COPY --from=build /app/publish .

# Định nghĩa điểm chạy của ứng dụng
ENTRYPOINT ["dotnet", "API.dll"]