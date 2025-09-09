# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy solution file first
COPY ["eShopOnWeb.sln", "."]

# Copy all project files
COPY ["src/Web/Web.csproj", "src/Web/"]
COPY ["src/ApplicationCore/ApplicationCore.csproj", "src/ApplicationCore/"]
COPY ["src/Infrastructure/Infrastructure.csproj", "src/Infrastructure/"]
COPY ["src/BlazorAdmin/BlazorAdmin.csproj", "src/BlazorAdmin/"]
COPY ["src/BlazorShared/BlazorShared.csproj", "src/BlazorShared/"]

# Restore packages
RUN dotnet restore "eShopOnWeb.sln" --packages /root/.nuget/packages

# Copy remaining source code
COPY . .

# Build
RUN dotnet build "eShopOnWeb.sln" -c Release -o /app/build

# Publish
RUN dotnet publish "eShopOnWeb.sln" -c Release -o /app/publish

# Runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .

ENTRYPOINT ["dotnet", "Web.dll"]
