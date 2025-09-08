# ===== Build stage =====
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# copy everything
COPY . .

# restore and publish the Web project (adjust path if different)
WORKDIR /src/src/Web
RUN dotnet restore
RUN dotnet publish -c Release -o /app/publish

# ===== Runtime stage =====
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app/publish ./

# Listen on 8080 internally; we'll map 80->8080 on the host
ENV ASPNETCORE_URLS=http://0.0.0.0:8080
EXPOSE 8080
ENTRYPOINT ["dotnet", "Web.dll"]
