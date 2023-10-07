#!/bin/sh

if [ "$AUTOUPDATE" = true ]; then
	${STEAMAPPDIR}/scripts/install_resonite.sh
fi

if [ "$CLEANASSETS" = true ]; then
	find ${STEAMAPPDIR}/Headless/Data/Assets -type f -atime +7 -delete
	find ${STEAMAPPDIR}/Headless/Cache/Cache -type f -atime +7 -delete
fi
if [ "$CLEANLOGS" = true ]; then
	find ${STEAMAPPDIR}/Logs -type f -name *.log -atime +30 -delete
fi

exec $*
