# ========================
# STAGE 1: Build & Publish
# ========================
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

# Install Python (optional, für AOT/wasm-tools)
RUN apt-get update && apt-get install -y python3 python3-pip && \
    ln -s /usr/bin/python3 /usr/bin/python

# Workload installieren
RUN dotnet workload install wasm-tools

# Projekte kopieren
COPY ["EasyEntryApp/EasyEntryApp.csproj", "EasyEntryApp/"]
COPY ["EasyEntryLib/EasyEntryLib.csproj", "EasyEntryLib/"]

# Restore
RUN dotnet restore "EasyEntryApp/EasyEntryApp.csproj"

# Restliche Dateien kopieren
COPY . .

# Publish direkt nach /app für einfaches COPY
RUN dotnet publish "EasyEntryApp/EasyEntryApp.csproj" -c $BUILD_CONFIGURATION -o /app /p:UseAppHost=false

# ========================
# STAGE 2: Runtime
# ========================
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime

# WORKDIR setzen
WORKDIR /app

# Dateien aus build-Stufe kopieren
COPY --from=build /app ./

# Optional: Debug-Ausgabe
RUN echo "Inhalt von /app im finalen Image:" && ls -la /app

# Portfreigabe (optional)
EXPOSE 8080
EXPOSE 8081

# Einstiegspunkt
ENTRYPOINT ["dotnet", "EasyEntryApp.dll"]