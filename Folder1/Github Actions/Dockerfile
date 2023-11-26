#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY ["Github Actions.csproj", "."]
RUN dotnet restore "./Github Actions.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "Github Actions.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Github Actions.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Github Actions.dll"]