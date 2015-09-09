INSTALL_PATH ?= /usr/local

install:
	mkdir -p ${INSTALL_PATH}/bin ${INSTALL_PATH}/lib/project-core ${INSTALL_PATH}/etc/project
	cp -r bin/project ${INSTALL_PATH}/bin/project
	cp -r bin/utils.sh bin/project-*.sh ${INSTALL_PATH}/lib/project-core
	cp -r skel ${INSTALL_PATH}/etc/project/skel
