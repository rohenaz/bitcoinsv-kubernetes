# FROM heroku/heroku:16-build as build



# COPY . /app
# WORKDIR /app

# # Setup buildpack
# RUN mkdir -p /tmp/buildpack/heroku/go /tmp/build_cache /tmp/env
# RUN curl https://codon-buildpacks.s3.amazonaws.com/buildpacks/heroku/go.tgz | tar xz -C /tmp/buildpack/heroku/go

# #Execute Buildpack
# RUN STACK=heroku-16 /tmp/buildpack/heroku/go/bin/compile /app /tmp/build_cache /tmp/env

# # Prepare final, minimal image
# FROM heroku/heroku:16

# COPY --from=build /app /app
# ENV HOME /app
# WORKDIR /app
# RUN useradd -m heroku
# USER heroku
# CMD /app/bin/allaboard-go









# Stable slim version of debian linux
FROM debian:stable-slim

# Set the home directory
ENV HOME /bitcoinsv

# Set environment variables
ENV USER_ID 1000
ENV GROUP_ID 1000
ENV BSV_VERSION=0.1.1

# Update all operating system dependencies
RUN groupadd -g ${GROUP_ID} bitcoinsv \
  && useradd -u ${USER_ID} -g bitcoinsv -s /bin/bash -m -d /bitcoinsv bitcoinsv \
  && set -x \
  && apt-get update -y \
  && apt-get install -y curl gosu \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Download the bsv node and extract
RUN curl -sL https://download.bitcoinsv.io/bitcoinsv/${BSV_VERSION}/bitcoin-sv-${BSV_VERSION}-x86_64-linux-gnu.tar.gz | tar xz --strip=2 -C /usr/local/bin

# Add the application deploy folder
ADD ./bin /usr/local/bin
RUN chmod +x /usr/local/bin/bsv_oneshot

# Set the volume (from previous step)
VOLUME ["/bitcoinsv"]

# Expose the ports for use
EXPOSE 8332 8333

# Set the working directory
WORKDIR /bitcoinsv

# make the config dir
RUN mkdir -p /bitcoinsv/.bitcoin

# Copy the configuration into the volume
COPY bitcoin.conf /bitcoinsv/.bitcoin/bitcoin.conf

# Copy and set the entrypoint
COPY /entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Run the application (from usr/local/bin/)
CMD ["bsv_oneshot"]
