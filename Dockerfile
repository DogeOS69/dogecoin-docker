FROM ubuntu:22.04

ARG VERSION=1.14.9
RUN apt-get update && apt-get install --no-install-recommends -y \
  ca-certificates \
  wget \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /wowmuchdocker

RUN wget https://github.com/dogecoin/dogecoin/releases/download/v${VERSION}/dogecoin-${VERSION}-x86_64-linux-gnu.tar.gz && \
  mkdir x86_64 && \
  tar -xvzf ./dogecoin-${VERSION}-x86_64-linux-gnu.tar.gz -C ./x86_64 --strip-components=1 && \
  rm ./dogecoin-${VERSION}-x86_64-linux-gnu.tar.gz

CMD ["/wowmuchdocker/x86_64/bin/dogecoind", "-printtoconsole"]