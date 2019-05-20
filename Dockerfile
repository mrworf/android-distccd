FROM ubuntu:18.04  
LABEL maintainer="henric@sensenet.nu"

ARG NDK_PLATFORM="x86_64"
ARG NDK_VERSION="r18b"

ENV \
    NDK_HOME=/opt/ndk \
    DISTCC_JOBS=12

RUN \
    mkdir -p \
        ${NDK_HOME} \
        /wrapper/bin \
    && \
	apt-get update \
	&& \
	apt-get install -y \
		curl \
		distcc \
		unzip \
		bash \
	&& \
    rm -rf /var/cache/apk/* /tmp/* \
    && \
    echo "Downloading https://dl.google.com/android/repository/android-ndk-${NDK_VERSION}-linux-${NDK_PLATFORM}.zip" \
    && \
	curl -o /tmp/ndk.zip -jS https://dl.google.com/android/repository/android-ndk-${NDK_VERSION}-linux-${NDK_PLATFORM}.zip \
	&& \
	unzip -qd ${NDK_HOME}/ /tmp/ndk.zip \
	&& \
	rm -rf /var/cache/apk/* /tmp/* \
    && \
    echo " NDK Version: ${NDK_VERSION}" >> /image.info \
    && \
    echo "NDK Platform: ${NDK_PLATFORM}" >> /image.info \
    && \
    echo "DONE!"

COPY distcc_launcher.sh /wrapper/
COPY distcc_wrapper.sh /wrapper/

EXPOSE 3632

CMD ["/wrapper/distcc_launcher.sh"]
