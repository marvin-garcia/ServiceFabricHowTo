#Depending on the operating system of the host machines(s) that will build or run the containers, the image specified in the FROM statement may need to be changed.
#For more information, please see https://aka.ms/containercompat

FROM microsoft/dotnet:2.1-aspnetcore-runtime-nanoserver-1709 AS base
WORKDIR /app
EXPOSE 80

FROM marvacr.azurecr.io/dotnet:2.1-sdk-nanoserver-1709-nodejs AS build
WORKDIR /src
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
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "QuickApp.dll"]