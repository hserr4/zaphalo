# Base image for common dependencies
FROM node:22-alpine as common-deps

WORKDIR /app

# Copy only the necessary files for dependency resolution
COPY ./package.json ./yarn.lock ./tsconfig.base.json ./nx.json /app/

COPY ./.prettierrc /app/
COPY ./packages/server/package.json /app/packages/server/
COPY ./packages/frontend/package.json /app/packages/frontend/

# Install all dependencies
RUN yarn && yarn cache clean && npx nx reset


# Build the back
FROM common-deps as server-build

# Copy sourcecode after installing dependences to accelerate subsequents builds
COPY ./packages/server /app/packages/server

RUN NX_DAEMON=false npx nx run server:build
RUN mv /app/packages/server/dist /app/packages/server/build
RUN NX_DAEMON=false npx nx run server:build:packageJson
RUN rm -rf /app/packages/server/dist && mv /app/packages/server/build /app/packages/server/dist


# Build the front
FROM common-deps as frontend-build

ARG VITE_BACKEND_URL

COPY ./packages/frontend /app/packages/frontend
RUN NX_DAEMON=false npx nx build frontend


# Final stage: Run the application
FROM node:22-alpine as zaphalo

# Used to run healthcheck in docker
RUN apk add --no-cache curl jq postgresql-client

RUN npm install -g tsx

COPY packages/server/entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh
WORKDIR /app/packages/server

ARG VITE_BACKEND_URL
ENV VITE_BACKEND_URL $VITE_BACKEND_URL

ARG APP_VERSION
ENV APP_VERSION $APP_VERSION

# Default environment variables for api.avynt.com.br
ENV PORT=3000
ENV WEBSOCKET_PORT=4000
ENV SERVER_URL=api.avynt.com.br
ENV BACKEND_URL=https://api.avynt.com.br

# Copy built applications from previous stages
COPY --chown=1000 --from=server-build /app /app
COPY --chown=1000 --from=server-build /app/packages/server /app/packages/server
# Ensure frontend build is copied to the correct location for the server to serve (if needed)
COPY --chown=1000 --from=frontend-build /app/packages/frontend/build /app/packages/server/dist/frontend

# Set metadata and labels
LABEL org.opencontainers.image.source=https://github.com/hserr4/zaphalo
LABEL org.opencontainers.image.description="Zaphalo production image for Coolify/OCI"

RUN mkdir -p /app/.local-storage /app/packages/server/.local-storage && \
    chown -R 1000:1000 /app

# Use non root user with uid 1000
USER 1000

# Healthcheck for Coolify
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

EXPOSE 3000 4000

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["node", "dist/src/main"]
