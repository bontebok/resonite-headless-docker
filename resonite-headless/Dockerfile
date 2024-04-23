ARG	HOSTUSERID=1000 \
	HOSTGROUPID=1000 \
	STEAMBETA=__CHANGEME__ \
	STEAMBETAPASSWORD=__CHANGEME__ \
	STEAMLOGIN=__CHANGEME__ \
	RML=false \
	PROCMON=false

FROM mono as build

LABEL name=resonite-headless maintainer="panther.ru@gmail.com"

ARG	HOSTUSERID=1000 \
	HOSTGROUPID=1000 \
	STEAMBETA=__CHANGEME__ \
	STEAMBETAPASSWORD=__CHANGEME__ \
	STEAMLOGIN=__CHANGEME__ \
	RML=false \
	PROCMON=false

ENV	STEAMAPPID=2519830 \
	STEAMAPP=resonite \
	STEAMCMDURL="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" \
	STEAMCMDDIR=/opt/steamcmd \
	USER=resonite \
	HOMEDIR=/home/${USER} \
	RMLLIBURL="https://github.com/resonite-modding-group/ResoniteModLoader/releases/download/2.6.0/0Harmony.dll" \
	RMLURL="https://github.com/resonite-modding-group/ResoniteModLoader/releases/download/2.6.0/ResoniteModLoader.dll" \
	STEAMAPPDIR=/opt/resonite \
	CLEANASSETS=false \
	CLEANLOGS=false \
	HOSTUSERID=${HOSTUSERID} \
	HOSTGROUPID=${HOSTGROUPID} \
	STEAMBETA=${STEAMBETA} \
	STEAMBETAPASSWORD=${STEAMBETAPASSWORD} \
	STEAMLOGIN=${STEAMLOGIN} \
	RML=${RML} \
	PROCMON=${PROCMON} \
	AUTOUPDATE=${AUTOUPDATE}

# Prepare the basic environment
RUN	set -x && \
        dpkg --add-architecture i386 && \
	apt-get -y update && \
	apt-get --no-install-recommends -y install curl lib32gcc1 libopus0 && \
	apt-get -y dist-upgrade
	#rm -rf /var/lib/{apt,dpkg,cache}

# Add locales
RUN	DEBIAN_FRONTEND=noninteractive apt-get install -y locales

RUN	sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
	sed -i -e 's/# en_GB.UTF-8 UTF-8/en_GB.UTF-8 UTF-8/' /etc/locale.gen && \
	dpkg-reconfigure --frontend=noninteractive locales && \
	update-locale LANG=en_US.UTF-8 && \
	update-locale LANG=en_GB.UTF-8

ENV	LANG en_GB.UTF-8

# Fix the LetsEncrypt CA cert
RUN	sed -i 's#mozilla/DST_Root_CA_X3.crt#!mozilla/DST_Root_CA_X3.crt#' /etc/ca-certificates.conf && update-ca-certificates

# Create user, install SteamCMD
RUN	addgroup --gid ${HOSTGROUPID} ${USER}

RUN	adduser --disabled-login \
		--shell /bin/bash \
		--gecos "" \
		--gid ${HOSTGROUPID} \
		--uid ${HOSTUSERID} \
		${USER}

RUN	mkdir -p ${STEAMCMDDIR} ${HOMEDIR} ${STEAMAPPDIR} ${STEAMAPPDIR}/Config ${STEAMAPPDIR}/Logs ${STEAMAPPDIR}/scripts ${STEAMAPPDIR}/patches && \
	chown -R ${USER}:${USER} ${STEAMCMDDIR} ${HOMEDIR} ${STEAMAPPDIR}

# Copy any custom patches
COPY	--chown=${USER}:${USER} patches ${STEAMAPPDIR}/patches

# Copy setup and startup scripts
COPY	--chown=${USER}:${USER} scripts ${STEAMAPPDIR}/scripts
#RUN	chmod +x ${STEAMAPPDIR}/scripts/*.sh

# Switch user context
USER ${USER}

# Install steamcmd and update
RUN	cd ${STEAMCMDDIR} && \
	curl -sqL ${STEAMCMDURL} | tar zxfv -

# Install Resonite
RUN	${STEAMAPPDIR}/scripts/install_resonite.sh

# Apply patches and tweaks to fix the headless release
RUN	cp -R ${STEAMAPPDIR}/patches/. ${STEAMAPPDIR} && \
	ln -sf /usr/lib/x86_64-linux-gnu/libopus.so.0 ${STEAMAPPDIR}/Resonite_Data/Plugins/libopus.so && \
	ln -sf /usr/lib/x86_64-linux-gnu/libopus.so.0 ${STEAMAPPDIR}/Headless/libopus.so && \
	ln -sf /lib/x86_64-linux-gnu/libdl.so.2 ${STEAMAPPDIR}/Headless/libdl.so && \
	mkdir -p ${STEAMAPPDIR}/Headless/Config && \
	ln -sf ${STEAMAPPDIR}/Config/Config.json ${STEAMAPPDIR}/Headless/Config && ln -s ${STEAMAPPDIR}/Logs ${STEAMAPPDIR}/Headless/Logs && \
	ln -sf ${STEAMAPPDIR}/Resonite_Data/Plugins/libsteam_api.so ${STEAMAPPDIR}/Headless/libsteam_api64.so
#	ln -sf ${STEAMAPPDIR}/RuntimeData ${STEAMAPPDIR}/Headless/.

# ResoniteModLoader
FROM build as rml-true

RUN	mkdir -p ${STEAMAPPDIR}/rml_libs ${STEAMAPPDIR}/rml_mods ${STEAMAPPDIR}/rml_config ${STEAMAPPDIR}/Headless/Libraries && \
	ln -sf ${STEAMAPPDIR}/rml_libs ${STEAMAPPDIR}/Headless/rml_libs && \
	ln -sf ${STEAMAPPDIR}/rml_mods ${STEAMAPPDIR}/Headless/rml_mods && \
	ln -sf ${STEAMAPPDIR}/rml_config ${STEAMAPPDIR}/Headless/rml_config && \
	curl -sqLo ${STEAMAPPDIR}/Headless/Libraries/ResoniteModLoaderHeadless.dll ${RMLURL} &&\
	curl -sqLo ${STEAMAPPDIR}/rml_libs/0Harmony.dll ${RMLLIBURL}

# Do nothing
FROM build as rml-false

FROM rml-${RML} as rml

# Procmon
FROM rml as procmon-true

# Install node, npm and procmon and copy process monitoring tool
USER root

RUN	apt-get --no-install-recommends -y install ca-certificates gnupg procps && \
	mkdir -p /etc/apt/keyrings && \
	curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
	echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_18.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
	apt-get -y update && \
	apt-get --no-install-recommends -y install nodejs

COPY	--chown=${USER}:${USER} procmon ${STEAMAPPDIR}/procmon

# Switch back to user & install dependancies
USER ${USER}

WORKDIR ${STEAMAPPDIR}/procmon
RUN	npm install --unsafe-perm --no-update-notifier --no-audit --no-fund --omit=dev

# Do nothing
FROM rml as procmon-false

FROM procmon-${PROCMON} AS prod

# Clean up
USER root
RUN	rm -rf /var/lib/{apt,dpkg,cache}

# Switch back to user
USER ${USER}

WORKDIR ${STEAMAPPDIR}

VOLUME	["${STEAMAPPDIR}", "/Config", "/Logs", "/rml_mods", "/rml_libs", "/rml_config"]

STOPSIGNAL SIGINT

ENTRYPOINT	["/opt/resonite/scripts/setup_resonite.sh"]
CMD		["/opt/resonite/scripts/start_resonite.sh"]
