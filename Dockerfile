FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    cmake \
    wget \
    sudo \
    libcap2-bin \
    python3-dev \
    libssl-dev \
    libffi-dev \
    libsqlite3-dev \
    nasm \
    mingw-w64 \
    net-tools \
    iproute2 \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://go.dev/dl/go1.23.5.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.23.5.linux-amd64.tar.gz && \
    rm go1.23.5.linux-amd64.tar.gz

ENV GOROOT=/usr/local/go
ENV GOPATH=/go
ENV PATH=/usr/local/go/bin:/go/bin:$PATH

RUN sed -i 's/#ifndef _WIN32_WINNT/#define _WIN32_WINNT 0x0A00\n#ifndef _WIN32_WINNT/g' /usr/x86_64-w64-mingw32/include/winnt.h && \
    sed -i '/typedef struct _IMAGE_POLICY_ENTRY/i \
typedef struct _CFG_CALL_TARGET_INFO {\n    ULONG_PTR Offset;\n    ULONG_PTR Flags;\n} CFG_CALL_TARGET_INFO, *PCFG_CALL_TARGET_INFO;\n' /usr/x86_64-w64-mingw32/include/winnt.h && \
    sed -i 's/#if _WIN32_WINNT >= 0x0600/#if 1/g' /usr/x86_64-w64-mingw32/include/securitybaseapi.h

RUN sed -i 's/#if _WIN32_WINNT >= 0x0600/#if 1/g' /usr/x86_64-w64-mingw32/include/processthreadsapi.h



WORKDIR /opt/Havoc
RUN git clone https://github.com/HavocFramework/Havoc.git .

RUN make ts-build

EXPOSE 40056 443
ENTRYPOINT ["/bin/bash"]
CMD []
