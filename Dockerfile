FROM debian:bookworm AS builder

ARG OPENRA_CA_VERSION
ARG OPENRA_CA_RELEASE
ARG OPENRA_CA_MOD=CAmod

# https://github.com/Inq8/CAmod/releases
ENV OPENRA_CA_VERSION=${OPENRA_CA_VERSION:-1.05.1}
ENV OPENRA_CA_RELEASE=${OPENRA_CA_RELEASE:-https://github.com/Inq8/CAmod/archive/refs/tags/${OPENRA_CA_VERSION}.tar.gz}

RUN set -xe; \
  echo "=================================================================="; \
  echo "Building OpenRA CAMod:"; \
  echo "  version:\t${OPENRA_CA_VERSION}"; \
  echo "  source: \t${OPENRA_CA_RELEASE}"; \
  echo "=================================================================="; \
  \
  apt-get update; \
  apt-get -y upgrade; \
  apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        liblua5.1 \
#                    libsdl2-2.0-0 \
#                    libopenal1 \
        make \
        patch \
        unzip \
        wget \
        python3-minimal \
      ;
ADD https://builds.dotnet.microsoft.com/dotnet/Sdk/6.0.428/dotnet-sdk-6.0.428-linux-x64.tar.gz /tmp/
RUN mkdir -p /opt/dotnet && tar zxf /tmp/dotnet-sdk-6.0.428-linux-x64.tar.gz -C /opt/dotnet && rm /tmp/*; 

ENV DOTNET_ROOT=/opt/dotnet
ENV PATH=$PATH:/opt/dotnet

RUN  useradd -d /home/openra -m -s /sbin/nologin openra; \
  mkdir /home/openra/source; \
  cd /home/openra/source; \
  curl -L $OPENRA_CA_RELEASE | tar xz; \        
  mkdir -p /home/openra/lib; \
  mv /home/openra/source/${OPENRA_CA_MOD}-${OPENRA_CA_VERSION} /home/openra/lib/openra; \ 
  cd /home/openra/lib/openra; \
  make engine; \        
  make version VERSION=${OPENRA_CA_VERSION}; \
  make all; \
  apt-get purge -y curl make patch unzip; \
  rm -rf /var/lib/apt/lists/* \
         /var/cache/apt/archives/*;

# Define the final image
FROM debian:bookworm-slim

ARG OPENRA_CA_VERSION
ENV OPENRA_CA_VERSION=${OPENRA_CA_VERSION}

ENV DOTNET_ROOT=/opt/dotnet
ENV PATH=$PATH:/opt/dotnet

RUN useradd -d /home/openra -m -s /sbin/nologin openra

COPY --from=builder /home/openra/lib/openra /home/openra/lib/openra
RUN  mkdir /home/openra/.openra \
    /home/openra/.openra/Logs \
    /home/openra/.openra/maps \
    ; \
    chown -R openra:openra /home/openra;

ADD https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/6.0.36/aspnetcore-runtime-6.0.36-linux-x64.tar.gz /tmp/
RUN mkdir -p /opt/dotnet && tar zxf /tmp/aspnetcore-runtime-6.0.36-linux-x64.tar.gz -C /opt/dotnet && rm /tmp/*; 

RUN apt-get update; \
    apt-get -y upgrade; \
    apt-get install -y --no-install-recommends \
    liblua5.1 \
    python3-minimal \
    ca-certificates \
        ; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* \
      /var/cache/apt/archives/*;

EXPOSE 1234

USER openra

WORKDIR /home/openra/lib/openra
VOLUME ["/home/openra/.openra"]

CMD [ "/home/openra/lib/openra/launch-dedicated.sh" ]

# annotation labels according to
# https://github.com/opencontainers/image-spec/blob/v1.0.1/annotations.md#pre-defined-annotation-keys
LABEL org.opencontainers.image.title="OpenRA - Combined Arms Server"
LABEL org.opencontainers.image.description="Image to run a dedicated server instance for OpenRA CAmod"
LABEL org.opencontainers.image.url="https://github.com/braini75/openra_ca_server/Dockerfile"
LABEL org.opencontainers.image.source="https://github.com/braini75/openra_ca_server"
LABEL org.opencontainers.image.documentation="https://github.com/braini75/openra_ca_server/README.md"
LABEL org.opencontainers.image.version=${OPENRA_CA_VERSION}
LABEL org.opencontainers.image.licenses="GPL-3.0"
LABEL org.opencontainers.image.authors="Thomas Koch"