FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
USER $APP_UID
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

# Installiere Python (z. B. für AOT-kompilierung in WASM)
RUN apt-get update && apt-get install -y python3 python3-pip

# Optional: Verlinke python3 zu python, falls .NET das erwartet
RUN ln -s /usr/bin/python3 /usr/bin/python


# Debug: Inhalt anzeigen
RUN echo "Inhalt von /src vor COPY:" && ls -la /src

# Projekte einzeln kopieren
COPY ["EasyEntryApp/EasyEntryApp.csproj", "EasyEntryApp/"]
COPY ["EasyEntryLib/EasyEntryLib.csproj", "EasyEntryLib/"]

# Restore & Workload
RUN dotnet workload install wasm-tools
RUN dotnet restore "EasyEntryApp/EasyEntryApp.csproj"

# Restliche Dateien kopieren
COPY . .

# Build
WORKDIR "/src/EasyEntryApp"
RUN dotnet build "EasyEntryApp.csproj" -c $BUILD_CONFIGURATION -o /src/build

# Publish
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
WORKDIR /src/EasyEntryApp
RUN dotnet publish "EasyEntryApp.csproj" -c $BUILD_CONFIGURATION -o /src/publish /p:UseAppHost=false

# Final Image
FROM base AS final
WORKDIR /app
COPY --from=publish /src/publish .
ENTRYPOINT ["dotnet", "EasyEntryApp.dll"]
