# escape=`

FROM mcr.microsoft.com/windows/servercore:1709 AS installer-env

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ENV NODE_VERSION 10.15.2

RUN Invoke-WebRequest https://nodejs.org/dist/v$env:NODE_VERSION/node-v$env:NODE_VERSION-win-x64.zip -OutFile nodejs.zip; `
    Expand-Archive nodejs.zip -DestinationPath nodejs; `
    Remove-Item -Force nodejs.zip

FROM microsoft/dotnet:2.1-aspnetcore-runtime-nanoserver-1709 AS base
WORKDIR /app
EXPOSE 80

FROM microsoft/dotnet:2.1-sdk-nanoserver-1709 AS build

COPY --from=installer-env ["nodejs", "C:\\Program Files\\nodejs"]

WORKDIR /src

# Copy files
COPY ["src/QuickApp/QuickApp.csproj", "src/QuickApp/"]
COPY ["src/DAL/DAL.csproj", "src/DAL/"]
RUN dotnet restore "src/QuickApp/QuickApp.csproj"
COPY . .
WORKDIR "/src/src/QuickApp"
RUN dotnet build "QuickApp.csproj" -c Release -o /app

FROM build AS publish
RUN dotnet publish "QuickApp.csproj" -c Release -o /app

FROM base AS final
WORKDIR /app
COPY --from=publish /nodejs /nodejs
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "QuickApp.dll"]