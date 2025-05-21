FROM --platform=$BUILDPLATFORM rust:latest AS sqlx

ARG TARGETPLATFORM
ARG BUILDPLATFORM

RUN apt-get update
RUN apt-get install -y musl-tools

RUN if [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
        wget https://musl.cc/aarch64-linux-musl-cross.tgz && \
        tar -xzf aarch64-linux-musl-cross.tgz -C /usr/local && \
        export PATH="/usr/local/aarch64-linux-musl-cross/bin:$PATH" && \
        export CARGO_TARGET_AARCH64_UNKNOWN_LINUX_MUSL_LINKER=aarch64-linux-musl-gcc && \
        export TARGET=aarch64-unknown-linux-musl; \
    else \
        export TARGET=x86_64-unknown-linux-musl; \
    fi && \
    rustup target add $TARGET && \
    cargo install sqlx-cli --target $TARGET --no-default-features --features rustls,postgres

FROM alpine/git

COPY --from=sqlx /usr/local/cargo/bin/sqlx /usr/local/bin

ENV REV=HEAD
ENV MIGRATIONS_DIR=migrations

WORKDIR /app

COPY run-migrations.sh .
RUN chmod +x run-migrations.sh

ENTRYPOINT ["/app/run-migrations.sh"]
