# Minimal goclaw runtime - binary mounted from RELEASES
FROM alpine:3.23

RUN apk add --no-cache ca-certificates

WORKDIR /app

# Data directories
RUN mkdir -p /app/workspace /app/data /app/skills /app/.goclaw

COPY docker-entrypoint.sh /app/docker-entrypoint.sh
RUN chmod +x /app/docker-entrypoint.sh

ENV GOCLAW_CONFIG=/app/config.json \
    GOCLAW_WORKSPACE=/app/workspace \
    GOCLAW_DATA_DIR=/app/data \
    GOCLAW_HOST=0.0.0.0 \
    GOCLAW_PORT=18790

EXPOSE 18790

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["serve"]
