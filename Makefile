# Makefile del tema beamer PUCV.
#
#   make             Compila la presentación de ejemplo (claro y oscuro, 16:9)
#   make examples    Compila todas las variantes del ejemplo (también 4:3)
#   make test        Compila las pruebas de estrés y falla ante cajas desbordadas
#   make covers      Regenera las imágenes de portada desde assets/ (ImageMagick)
#   make logos       Regenera los logos de la portada (claro y oscuro)
#   make install     Instala el tema en TEXMFHOME
#   make uninstall   Elimina el tema de TEXMFHOME
#   make clean       Elimina los archivos generados

SHELL      := /bin/bash
LATEXMK    ?= latexmk
MAGICK     ?= magick
TEXMFHOME  ?= $(shell kpsewhich -var-value=TEXMFHOME)
INSTALLDIR := $(TEXMFHOME)/tex/latex/beamertheme-pucv
# Carpeta usada por la versión 1 del tema; se elimina al instalar porque sus
# archivos tienen los mismos nombres y TeX podría seguir usándolos.
LEGACYDIR  := $(TEXMFHOME)/tex/latex/PUCV

THEME   := $(wildcard src/*.sty) $(wildcard src/*.png) $(wildcard src/*.jpg)
EXAMPLE := examples/presentacion.tex
OUTDIR  := examples/build

# Recoloreado del dibujo de la Casa Central. El fondo oscuro debe coincidir con
# pucv-bg en beamercolorthemePUCV.sty.
COVER_SRC   := assets/casa-central-sketch-straight.jpg
COVER_CROP  := 1560x1388+480+0
# Tinta y fondo del modo oscuro: el logo usa la misma tinta que el dibujo.
DARK_INK    := \#8ea4bf
DARK_BG     := \#101824
COVER_LIGHT := '\#1d3a5f,white'
COVER_DARK  := '$(DARK_INK),$(DARK_BG)'
# Recorta, amplía 1.5x y enfoca los trazos de tinta; luego aumenta el contraste
# para que el papel quede blanco puro antes de recolorear.
COVER_PROCESS := -crop $(COVER_CROP) +repage -colorspace gray \
  -filter Lanczos -resize 150% -unsharp 0x3+1.5+0.01 -level 10%,78% \
  -white-threshold 97%

# Llamada a latexmk: $(call build,<nombre>,<opciones del tema>,<proporción>)
define build
	$(LATEXMK) -interaction=nonstopmode -halt-on-error -outdir=$(OUTDIR) -jobname=$(1) \
	  -usepretex='\PassOptionsToPackage{$(2)}{beamerthemePUCV}\def\proporcion{$(3)}' \
	  $(EXAMPLE)
endef

.PHONY: all examples test covers logos install uninstall clean

all: $(OUTDIR)/presentacion-claro.pdf $(OUTDIR)/presentacion-oscuro.pdf

examples: all $(OUTDIR)/presentacion-claro-43.pdf $(OUTDIR)/presentacion-oscuro-43.pdf

$(OUTDIR)/presentacion-claro.pdf: $(EXAMPLE) $(THEME)
	$(call build,presentacion-claro,mode=light,169)

$(OUTDIR)/presentacion-oscuro.pdf: $(EXAMPLE) $(THEME)
	$(call build,presentacion-oscuro,mode=dark,169)

$(OUTDIR)/presentacion-claro-43.pdf: $(EXAMPLE) $(THEME)
	$(call build,presentacion-claro-43,mode=light,43)

$(OUTDIR)/presentacion-oscuro-43.pdf: $(EXAMPLE) $(THEME)
	$(call build,presentacion-oscuro-43,mode=dark,43)

# Pruebas de estrés: cada archivo de tests/ (salvo el cuerpo común) se compila
# en modo claro y oscuro, en 16:9 y 4:3.
TESTS := $(filter-out tests/cuerpo.tex,$(wildcard tests/*.tex))

test:
	@set -e; for t in $(TESTS); do for m in light dark; do for a in 169 43; do \
	  j=$$(basename $$t .tex)-$$m-$$a; \
	  $(LATEXMK) -interaction=nonstopmode -halt-on-error -silent -outdir=tests/build \
	    -jobname=$$j -usepretex="\\def\\modo{$$m}\\def\\proporcion{$$a}" $$t \
	    >/dev/null || { echo "FALLA $$j (error de compilación)"; exit 1; }; \
	  if grep -aq 'Overfull' tests/build/$$j.log; then \
	    echo "FALLA $$j (caja desbordada)"; exit 1; fi; \
	  echo "ok    $$j"; \
	done; done; done

covers: $(COVER_SRC)
	$(MAGICK) $< $(COVER_PROCESS) +level-colors $(COVER_LIGHT) -strip -quality 90 \
	  src/beamerthemePUCV-cover-light.jpg
	$(MAGICK) $< $(COVER_PROCESS) +level-colors $(COVER_DARK) -strip -quality 90 \
	  src/beamerthemePUCV-cover-dark.jpg

# Logos de la portada, a partir de las versiones oficiales horizontales:
# a color para el modo claro y calado para el modo oscuro. El calado viene en
# blanco sobre un rectángulo azul (rojo = 40); la opacidad se obtiene del canal
# rojo y el logo se tiñe con la tinta del dibujo de la portada.
LOGO_SRC_COLOR  := assets/logo-pucv-color-h.png
LOGO_SRC_CALADO := assets/logo-pucv-calado-h.png

logos: $(LOGO_SRC_COLOR) $(LOGO_SRC_CALADO)
	$(MAGICK) $(LOGO_SRC_COLOR) -trim +repage -strip \
	  -define png:compression-level=9 src/beamerthemePUCV-logo-light.png
	$(MAGICK) $(LOGO_SRC_CALADO) -alpha off -channel R -separate +channel \
	  -level 15.69%,100% \( +clone -fill '$(DARK_INK)' -colorize 100 \) \
	  +swap -alpha off -compose CopyOpacity -composite -trim +repage -strip \
	  -define png:compression-level=9 src/beamerthemePUCV-logo-dark.png

install:
	@if [ -d "$(LEGACYDIR)" ]; then \
	  echo "Eliminando la instalación de la versión 1 en $(LEGACYDIR)"; \
	  rm -rf "$(LEGACYDIR)"; \
	fi
	install -d "$(INSTALLDIR)"
	install -m 644 $(THEME) "$(INSTALLDIR)"
	-mktexlsr "$(TEXMFHOME)" >/dev/null 2>&1

uninstall:
	rm -rf "$(INSTALLDIR)" "$(LEGACYDIR)"
	-mktexlsr "$(TEXMFHOME)" >/dev/null 2>&1

clean:
	rm -rf $(OUTDIR) tests/build
