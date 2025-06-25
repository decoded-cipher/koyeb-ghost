FROM ghost:5-alpine as cloudinary
RUN apk add g++ make python3
RUN su-exec node yarn add ghost-storage-cloudinary-v2

FROM ghost:5-alpine

RUN apk add --no-cache git
RUN git clone https://github.com/TryGhost/Ruby.git /var/lib/ghost/content/themes/ruby


COPY --chown=node:node --from=cloudinary $GHOST_INSTALL/node_modules $GHOST_INSTALL/node_modules
COPY --chown=node:node --from=cloudinary $GHOST_INSTALL/node_modules/ghost-storage-cloudinary-v2 $GHOST_INSTALL/content/adapters/storage/ghost-storage-cloudinary-v2

RUN set -ex; \
    su-exec node ghost config storage.active ghost-storage-cloudinary-v2; \
    su-exec node ghost config storage.ghost-storage-cloudinary-v2.upload.use_filename false; \
    su-exec node ghost config storage.ghost-storage-cloudinary-v2.upload.unique_filename true; \
    su-exec node ghost config storage.ghost-storage-cloudinary-v2.upload.overwrite true; \
    su-exec node ghost config storage.ghost-storage-cloudinary-v2.fetch.quality auto; \
    su-exec node ghost config storage.ghost-storage-cloudinary-v2.upload.folder "ghost"; \
    su-exec node ghost config storage.ghost-storage-cloudinary-v2.fetch.cdn_subdomain true; \
    su-exec node ghost config storage.ghost-storage-cloudinary-v2.fetch.secure true; \
    su-exec node ghost config mail.transport "SMTP"; \
    su-exec node ghost config mail.options.service "Gmail";

RUN chown -R node:node /var/lib/ghost/content/themes/ruby

RUN su-exec node ghost config theme "ruby"
