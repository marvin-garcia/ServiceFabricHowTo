FROM microsoft/dotnet-framework:4.7.2-sdk AS build
WORKDIR /app

# copy csproj and restore as distinct layers
COPY *.sln .
COPY TodoWeb/*.csproj ./TodoWeb/
COPY TodoWeb/*.config ./TodoWeb/
RUN nuget restore

# copy everything else and build app
COPY TodoWeb/. ./TodoWeb/
WORKDIR /app/TodoWeb
RUN msbuild /p:Configuration=Release

FROM microsoft/aspnet:4.7.2-windowsservercore-1709 AS runtime
WORKDIR /inetpub/wwwroot
COPY --from=build /app/TodoWeb/. ./