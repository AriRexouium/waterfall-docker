# Fetch Image
# Using alpine over openjdk for a much smaller image.
FROM alpine:latest
LABEL maintainer="jarrett.aiken@achl.fr"

# Set Build Variables
ARG JAVA_VERSION="openjdk11-jre-headless"

# Set Environment Variables
# Default Java args are from Aikar. https://mcflags.emc.gs
ENV \
  MINECRAFT_VERSION="latest" \
  WATERFALL_BUILD="latest" \
  MIN_MEMORY="128M" \
  MAX_MEMORY="512M" \
  RESTART_ON_CRASH="true" \
  JAVA_ARGS=" \
    -XX:+UseG1GC \
    -XX:G1HeapRegionSize=4M \
    -XX:+UnlockExperimentalVMOptions \
    -XX:+ParallelRefProcEnabled \
    -XX:+AlwaysPreTouch \
    -Dusing.aikars.flags=https://mcflags.emc.gs \
    -Daikars.new.flags=true"

# Upgrade System and Install Dependencies
# Since Alpine comes with Busybox, wget is not needed
# since Busybox has its own version of wget.
# Also setup waterfall user.
RUN \
  apk update \
  && apk upgrade --no-cache \
  && apk add --no-cache ${JAVA_VERSION} jq tini libstdc++ \
  && adduser -D waterfall waterfall

# Post Project Setup
# Switch to waterfall user, move to home directory, and create server directory.
# Copy files last to help with caching since they change the most.
USER waterfall
WORKDIR /home/waterfall
RUN mkdir proxy
COPY init.sh ./

# Container Setup
ENTRYPOINT ["tini", "--"]
CMD ["sh", "init.sh"]
VOLUME /home/waterfall/proxy
EXPOSE 25577/tcp
