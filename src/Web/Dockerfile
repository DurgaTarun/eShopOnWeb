# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy solution and project files
COPY eShopOnWeb.sln .
COPY src/Web/Web.csproj src/Web/
COPY src/ApplicationCore/ApplicationCore.csproj src/ApplicationCore/
COPY src/Infrastructure/Infrastructure.csproj src/Infrastructure/

# Restore packages
RUN dotnet restore "src/Web/Web.csproj"

# Copy the rest of the source code
COPY . .

# Build
RUN dotnet publish "src/Web/Web.csproj" -c Release -o /app/publish

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .
EXPOSE 80
ENTRYPOINT ["dotnet", "Web.dll"]
