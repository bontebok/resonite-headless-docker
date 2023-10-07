#!/bin/sh

if [ "$PROCMON" = true ]; then
	node ${STEAMAPPDIR}/procmon &
fi

cd ${STEAMAPPDIR}/Headless

if [ "$RML" = true ]; then
  LD_LIBRARY_PATH=${STEAMAPPDIR}/Headless exec mono ${STEAMAPPDIR}/Headless/Resonite.exe -LoadAssembly "Libraries/ResoniteModLoaderHeadless.dll"
else
  LD_LIBRARY_PATH=${STEAMAPPDIR}/Headless exec mono ${STEAMAPPDIR}/Headless/Resonite.exe
fi
