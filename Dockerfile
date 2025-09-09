# ==========================
# Stage 1: Build
# ==========================
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

# Argument for NuGet cache
ARG NUGET_CACHE=/root/.nuget/packages

# Set workdir
WORKDIR /src

# Copy solution file first (helps cache restore)
COPY eShopOnWeb.sln ./

# Copy project files individually to leverage Docker cache
COPY src/Web/Web.csproj src/Web/
COPY src/ApplicationCore/ApplicationCore.csproj src/ApplicationCore/
COPY src/Infrastructure/Infrastructure.csproj src/Infrastructure/

# Restore packages with cache
RUN dotnet restore "src/Web/Web.csproj" --packages $NUGET_CACHE

# Copy all source code
COPY . .

# Build the project
RUN dotnet publish "src/Web/Web.csproj" -c Release -o /app/publish

# ==========================
# Stage 2: Runtime
# ==========================
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime

WORKDIR /app

# Copy published output from build stage
COPY --from=build /app/publish .

# Expose port 80
EXPOSE 80

# Set entry point
ENTRYPOINT ["dotnet", "Web.dll"]
