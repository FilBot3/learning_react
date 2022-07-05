# Build Argument for the FROM statements.
# Thse are above the FROM statements because they're used with the FROM
# statements. If the ARG is going to be used with normal RUN statements, put it
# after the FROM statement they're used in.
ARG NODE_VERSION=16
ARG NGINX_VERSION=1.21.6

# Multi-Stage Build Stage 1
# Pull official base image for NodeJS
FROM docker.io/library/node:${NODE_VERSION} as build

# Set working directory
WORKDIR /app

# Add `/app/node_modules/.bin` to $PATH
ENV PATH /app/node_modules/.bin:$PATH

# Install app dependencies and build.
COPY . .

# Install the project dependencies, then install react-scripts.
# THEN build the files for React to be run in an Nginx container.
RUN npm install
RUN npm run build:prod

# Multi-Stage Build Stage 2
# This is where we put the static files from React into Nginx to be served.
FROM docker.io/library/nginx:${NGINX_VERSION}

# Copy from our build stage into our final container image.
COPY --from=build /app/dist/ /app/

# Copy the container_entrypoint that will perform startup and run steps.
COPY containers/container_entrypoint.sh /container_entrypoint.sh

# You need to make the script executable.
RUN chmod +x /container_entrypoint.sh

# Provide an nginx config
COPY containers/nginx.conf /etc/nginx/nginx.conf

# This is what the container will execute without providing any arguments.
ENTRYPOINT ["/container_entrypoint.sh"]
