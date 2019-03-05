# escape=`

FROM mcr.microsoft.com/windows/servercore:1709 AS installer-env

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Install NodeJS
ENV NODE_VERSION 10.15.2

RUN Invoke-WebRequest -OutFile nodejs.zip https://nodejs.org/dist/v$env:NODE_VERSION/node-v$env:NODE_VERSION-win-x64.zip; `
    Expand-Archive nodejs.zip -DestinationPath nodejs; `
    Remove-Item -Force nodejs.zip

FROM microsoft/dotnet:2.1-aspnetcore-runtime-nanoserver-1709

COPY --from=installer-env ["nodejs", "C:\\Program Files\\nodejs"]