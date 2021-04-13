
FILES += info.json
FILES += changelog.txt
FILES += thumbnail.png
FILES += settings.lua
#FILES += settings-updates.lua
#FILES += settings-final-fixes.lua
FILES += data.lua
#FILES += data-updates.lua
#FILES += data-final-fixes.lua
FILES += control.lua

DIRS += locale
DIRS += migrations
DIRS += graphics
DIRS += prototypes
DIRS += scripts

VERSION = $(shell awk "NR==2" changelog.txt | cut -d ' ' -f 2)
PACKAGE_NAME = advanced-circuit-network_${VERSION:%-beta=%}

all:
	git tag v${VERSION} -m "Release v${VERSION}"
	mkdir -p /tmp/${PACKAGE_NAME}
	cp -r ${FILES} ${DIRS} /tmp/${PACKAGE_NAME}/
	(cd /tmp && zip -r ${PACKAGE_NAME}.zip ${PACKAGE_NAME})
	mv /tmp/${PACKAGE_NAME}.zip ./

clean:
	rm advanced-circuit-network_*.zip

