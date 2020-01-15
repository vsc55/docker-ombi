FROM lsiobase/ubuntu:bionic

# set version label
ARG BUILD_DATE
ARG VERSION
ARG OMBI_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

# environment settings
ENV HOME="/config"

RUN \
 apt-get update && \
 apt-get install -y \
	jq \
	libicu60 \
	libssl1.0 \
	unzip && \
 echo "**** install ombi ****" && \
 mkdir -p \
	/opt/ombi && \
 if [ -z ${OMBI_RELEASE+x} ]; then \
	OMBI_RELEASE=$(curl -sX GET "https://api.github.com/repos/tidusjar/Ombi.Releases/releases" \
	| jq -r '.[0] | .tag_name'); \
 fi && \
 OMBI_DURL=$(curl -s https://api.github.com/repos/tidusjar/Ombi.Releases/releases/tags/"${OMBI_RELEASE}" \
	|jq -r '.assets[].browser_download_url' |grep 'linux-x64-') && \
 curl -o \
	/tmp/ombi-src.tar.gz -L \
	"${OMBI_DURL}" && \
 tar xzf /tmp/ombi-src.tar.gz -C \
	/tmp/ && \
 unzip /tmp/linux-64/Ombi.zip \
	-d /opt/ombi/ && \
 chmod +x /opt/ombi/Ombi && \
 echo "**** clean up ****" && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3579
