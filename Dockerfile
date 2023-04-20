FROM dart:latest

RUN apt-get update && apt-get install ca-certificates libsqlite3-dev zip git llvm curl gnupg \
    build-essential pkg-config libssl-dev libclang-dev apt-transport-https wget -y

# RUN wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/dart.gpg
# RUN echo 'deb [signed-by=/usr/share/keyrings/dart.gpg arch=amd64] https://storage.googleapis.com/download.dartlang.org/linux/debian \ 
#     stable main' | tee /etc/apt/sources.list.d/dart_stable.list
# RUN apt-get update && apt-get install dart
# ENV PATH="/usr/lib/dart/bin:$PATH"
# RUN echo 'export PATH="/usr/lib/dart/bin:$PATH"' >> ~/.profile

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:$PATH"
RUN echo 'export PATH="/root/.cargo/bin:$PATH"' >> ~/.profile

WORKDIR /app

COPY . .

RUN dart pub get && \
    cd rust && cargo build --release && cd .. && mkdir -p bin && \
    cp rust/target/release/librust.so /bin/librust.so && \
    dart compile exe bin/s5_server.dart && \
    chmod +x bin/s5_server.exe

ENV DOCKER=TRUE

EXPOSE 5050

ENTRYPOINT ["/app/bin/s5_server.exe"]
