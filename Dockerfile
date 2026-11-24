# syntax=docker/dockerfile:1
# Restxcel - Linux image
#
#   docker build -t restxcel:<tag> .
#
# Permanent templates are stored in /home/data/templates (see appsettings.json); mount a volume there to keep them.

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
# Version (GitHub Action: 1.1.0.<days since 2010-01-01>); ends up in AssemblyVersion/FileVersion
ARG BUILD_VERSION=1.1.0.0
WORKDIR /src
COPY Invim.Restxcel/Invim.Restxcel.csproj Invim.Restxcel/
RUN dotnet restore Invim.Restxcel/Invim.Restxcel.csproj
COPY Invim.Restxcel/ Invim.Restxcel/
RUN dotnet publish Invim.Restxcel/Invim.Restxcel.csproj -c Release -o /app --no-restore -p:UseAppHost=false \
    -p:Version=$BUILD_VERSION -p:AssemblyVersion=$BUILD_VERSION -p:FileVersion=$BUILD_VERSION

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final

ENV ASPNETCORE_HTTP_PORTS=8080

# Template directory must exist and be writable for the unprivileged user
RUN mkdir -p /home/data/templates && chown $APP_UID /home/data/templates
VOLUME /home/data/templates

WORKDIR /app
COPY --from=build /app .

# Unprivileged user of the base image (UID 1654)
USER $APP_UID
EXPOSE 8080
ENTRYPOINT ["dotnet", "Invim.Restxcel.dll"]
