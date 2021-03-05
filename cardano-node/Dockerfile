FROM debian:10

RUN apt update && apt install -y curl
RUN curl -s wget https://hydra.iohk.io/build/5721733/download/1/cardano-node-1.25.0-linux.tar.gz | tar -v -C /usr/local/bin -xzf - ./cardano-cli ./cardano-node 
RUN chmod +x /usr/local/bin/cardano-cli && \
    chmod +x /usr/local/bin/cardano-node
EXPOSE 3001
CMD ["cardano-node"]
