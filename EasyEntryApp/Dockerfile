# STAGE 1: Build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Zuerst nur die Projektdateien kopieren, damit Restore unabhängig vom Code läuft
COPY EasyEntryApp/EasyEntryApp.csproj EasyEntryApp/
COPY EasyEntryLib/EasyEntryLib.csproj EasyEntryLib/

# Restore mit Lösung der Abhängigkeiten (auch Projektreferenzen)
RUN dotnet restore EasyEntryApp/EasyEntryApp.csproj

# Dann den Rest des Codes kopieren
COPY . .

# Build
WORKDIR /src/EasyEntryApp
RUN dotnet build EasyEntryApp.csproj -c Release -o /app/build

# STAGE 2: Publish
FROM build AS publish
RUN dotnet publish EasyEntryApp.csproj -c Release -o /app/publish

# STAGE 3: Runtime mit nginx
FROM nginx:alpine AS final
WORKDIR /usr/share/nginx/html

# Blazor WebAssembly wird als static files (wwwroot) veröffentlicht
COPY --from=publish /app/publish/wwwroot .

# Eigene nginx-Konfiguration kopieren
COPY EasyEntryApp/nginx.conf /etc/nginx/nginx.conf
