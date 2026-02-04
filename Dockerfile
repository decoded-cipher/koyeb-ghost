# -------- Build stage: install S3 adapter --------
FROM ghost:5-alpine as s3

RUN apk add --no-cache g++ make python3 su-exec
RUN su-exec node yarn add ghost-storage-s3


# -------- Runtime stage --------
FROM ghost:alpine

RUN apk add --no-cache git su-exec


# Install Ruby theme
RUN git clone https://github.com/TryGhost/Ruby.git \
    /var/lib/ghost/content/themes/ruby


# Copy node modules + adapter
COPY --chown=node:node --from=s3 \
    $GHOST_INSTALL/node_modules \
    $GHOST_INSTALL/node_modules

COPY --chown=node:node --from=s3 \
    $GHOST_INSTALL/node_modules/ghost-storage-s3 \
    $GHOST_INSTALL/content/adapters/storage/ghost-storage-s3


# Activate theme
RUN chown -R node:node /var/lib/ghost/content/themes/ruby
RUN su-exec node ghost config theme "ruby"


# Mail (optional, keep if you use Gmail SMTP)
RUN set -ex; \
    su-exec node ghost config mail.transport "SMTP"; \
    su-exec node ghost config mail.options.service "Gmail";


# -------- Runtime bootstrap --------
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
