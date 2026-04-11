#par ABK
FROM alpine:latest
# Installation de dialog, bash, coreutils (pour awk/grep robustes)
RUN apk add --no-cache dialog bash coreutils procps
WORKDIR /app
COPY visual_monitor.sh .
RUN chmod +x visual_monitor.sh
CMD ["./visual_monitor.sh"]