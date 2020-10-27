# Run mattermost client in a container
# podman build -t jose/mattermost .
#
# podman run --rm -it \
#	-v /etc/localtime:/etc/localtime:ro \
#	-v /tmp/.X11-unix:/tmp/.X11-unix \
#	-e DISPLAY=unix$DISPLAY \
#	--device /dev/snd \
#	--device /dev/dri \
#	--device /dev/video0 \
#	--group-add audio \
#	--group-add video \
#	-v "${HOME}/Downloads:/root/Downloads" \
#	--ipc="host" \
#	--name mattermost \
#	jose/mattermost "$@"

podman run --rm  \
-v /etc/localtime:/etc/localtime:ro \
-v /tmp/.X11-unix:/tmp/.X11-unix \
-e DISPLAY=unix$DISPLAY \
--device /dev/snd \
--device /dev/dri \
--device /dev/video0 \
--group-add audio \
--group-add video \
-v "${HOME}/Downloads:/root/Downloads" \
-v "${HOME}/Downloads/resources:/opt/Mattermost/resources" \
--ipc="host" \
--name mattermost \
jose/mattermost "$@"

FROM debian:bullseye-slim

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

RUN apt-get update && apt-get install -y \
	apt-transport-https \
	ca-certificates \
	curl \
	gnupg \
	locales \
	libasound2 \
	libgtk-3-0 \
	libx11-xcb1 \
	libxkbfile1 \
	libnotify4 \
	libnss3 \
	libxss1 \
	libxtst6 \
	xdg-utils \
	libappindicator3-1 \ 
	libsecret-1-0 \ 
	--no-install-recommends \
	&& rm -rf /var/lib/apt/lists/*

RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& locale-gen en_US.utf8 \
	&& /usr/sbin/update-locale LANG=en_US.UTF-8

# Add the slack debian repo
RUN curl -sSL https://releases.mattermost.com/desktop/4.4.1/mattermost-desktop-4.4.1-linux-amd64.deb -o mattermost-desktop-4.4.1-linux-amd64.deb
RUN dpkg -i mattermost-desktop-4.4.1-linux-amd64.deb
ENV PATH=/opt/Mattermost 

ENTRYPOINT ["mattermost-desktop", "--no-sandbox"]


