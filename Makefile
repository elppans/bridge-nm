SHELL=/bin/bash
DESTDIR=
BINDIR=${DESTDIR}/usr/bin
INFODIR=${DESTDIR}/usr/share/doc/bridge-nm
MODE=664
DIRMODE=755

.PHONY: build

install:
	@echo "            Script bridge-set"
	@echo ":: Aguarde, instalando software bridge-set em: ${BINDIR}"
	@install -Dm755 "usr/bin/bridge-nm" "/usr/bin/bridge-nm"
	@install -d ${INFODIR}/
	@cp Makefile README.md ${INFODIR}/
	@echo ":: Feito! bridge-nm software instalado em: ${BINDIR}"
	@echo
uninstall:
	@rm ${BINDIR}/bridge-nm
	@rm -rf ${INFODIR}
	@echo "bridge-nm foi removido."
