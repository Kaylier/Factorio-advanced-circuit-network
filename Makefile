
FILES += info.json
FILES += changelog.txt
FILES += thumbnail.png
#FILES += settings.lua
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

all:
	git tag v${VERSION} -m "Release v${VERSION}"
	zip -r advanced-circuit-network_${VERSION}.zip ${FILES} ${DIRS}

clean:
	rm advanced-circuit-network_*.zip

