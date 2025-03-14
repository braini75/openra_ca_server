[![Test Docker image CI](https://github.com/braini75/openra_ca_server/actions/workflows/commit-check.yaml/badge.svg)](https://github.com/braini75/openra_ca_server/actions/workflows/commit-check.yaml)

# Dedicated Docker Server for OpenRA Combined Arms Mod

This is a Docker image configuration for the awesome [OpenRA - Combined Arms Mod](https://www.moddb.com/mods/command-conquer-combined-arms).

The Dockerfile builds the image with [.NET 6 download page](https://dotnet.microsoft.com/download/dotnet/6.0).

## Quickstart

### Docker command
Run following docker command (minimal):
```
docker run -d -p 1234:1234 -v openra_data:/home/openra/.openra ghcr.io/braini75/openra_ca_server:latest
```

### Using Docker compose
Modify docker-compose.yml regarding your needs and run:
```
docker-compose up -d
```
