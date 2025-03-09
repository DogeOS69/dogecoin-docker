FROM ubuntu:22.04

ARG VERSION=1.14.9
RUN apt-get update && apt-get install --no-install-recommends -y \
  ca-certificates \
  wget \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /dogecoin

RUN wget https://github.com/dogecoin/dogecoin/releases/download/v${VERSION}/dogecoin-${VERSION}-x86_64-linux-gnu.tar.gz && \
  tar -xvzf ./dogecoin-${VERSION}-x86_64-linux-gnu.tar.gz -C . --strip-components=1 && \
  rm ./dogecoin-${VERSION}-x86_64-linux-gnu.tar.gz

CMD ["/dogecoin/bin/dogecoind", "-printtoconsole"]