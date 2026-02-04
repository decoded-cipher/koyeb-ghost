FROM ghost:5-alpine as r2
RUN apk add --no-cache g++ make python3 su-exec
RUN su-exec node yarn add ghost-storage-adapter-s3

FROM ghost:alpine

RUN apk add --no-cache git su-exec

# Install Ruby theme
RUN git clone https://github.com/TryGhost/Ruby.git \
    /var/lib/ghost/content/themes/ruby


# Copy node modules + adapter
COPY --chown=node:node --from=r2 \
    $GHOST_INSTALL/node_modules \
    $GHOST_INSTALL/node_modules

COPY --chown=node:node --from=r2 \
    $GHOST_INSTALL/node_modules/ghost-storage-adapter-s3 \
    $GHOST_INSTALL/content/adapters/storage/ghost-storage-adapter-s3


# Configure Ghost
RUN set -ex; \
    su-exec node ghost config storage.active ghost-storage-adapter-s3; \
    \
    su-exec node ghost config storage.ghost-storage-adapter-s3.accessKeyId "$R2_ACCESS_KEY_ID"; \
    su-exec node ghost config storage.ghost-storage-adapter-s3.secretAccessKey "$R2_SECRET_ACCESS_KEY"; \
    su-exec node ghost config storage.ghost-storage-adapter-s3.region "auto"; \
    su-exec node ghost config storage.ghost-storage-adapter-s3.bucket "$R2_BUCKET"; \
    su-exec node ghost config storage.ghost-storage-adapter-s3.endpoint "https://$R2_ACCOUNT_ID.r2.cloudflarestorage.com"; \
    su-exec node ghost config storage.ghost-storage-adapter-s3.pathStyle true; \
    su-exec node ghost config storage.ghost-storage-adapter-s3.assetHost "$R2_PUBLIC_URL"; \
    \
    su-exec node ghost config mail.transport "SMTP"; \
    su-exec node ghost config mail.options.service "Gmail";


# Fix permissions
RUN chown -R node:node /var/lib/ghost/content/themes/ruby

# Activate theme
RUN su-exec node ghost config theme "ruby"
