# Makefile del tema beamer PUCV.
#
#   make             Compila la presentación de ejemplo (claro, oscuro e
#                    institucional, 16:9)
#   make examples    Compila todas las variantes del ejemplo (también 4:3 y el
#                    modo institucional con las normas 2023)
#   make test        Compila las pruebas de estrés y falla ante cajas desbordadas
#   make covers      Regenera las imágenes de portada desde assets/ (ImageMagick)
#   make logos       Regenera los logos de la portada (claro, oscuro y blanco)
#   make centenario  Regenera los recursos del logo de los 100 años (pdfcrop)
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

THEME   := $(wildcard src/*.sty) $(wildcard src/*.png) $(wildcard src/*.jpg) \
           $(wildcard src/*.pdf)
EXAMPLE := examples/presentacion.tex
OUTDIR  := examples/build

# Recoloreado del dibujo de la Casa Central. El fondo oscuro debe coincidir con
# pucv-bg en beamercolorthemePUCV.sty.
# El recorte se centra en la torre de la esquina, de modo que el panel derecho
# de la portada (que muestra el centro de la imagen) la incluya.
COVER_SRC   := assets/pucv_sketch.jpeg
COVER_CROP  := 1850x1684+75+0
# Tinta y fondo del modo oscuro: el logo usa la misma tinta que el dibujo.
DARK_INK    := \#8ea4bf
DARK_BG     := \#101824
# Tinta y fondo del modo institucional con las normas 2023 (portada a sangre en
# azul). El fondo debe coincidir con pucv-navy (pucv-hero-bg) en
# beamercolorthemePUCV.sty.
BRAND_INK   := \#a9bdd6
BRAND_BG    := \#24588d
COVER_LIGHT := '\#1d3a5f,white'
COVER_DARK  := '$(DARK_INK),$(DARK_BG)'
COVER_BRAND := '$(BRAND_INK),$(BRAND_BG)'
# Recorta y enfoca los trazos de tinta; luego aumenta el contraste para que el
# papel (crudo y con textura) quede blanco puro antes de recolorear.
COVER_PROCESS := -crop $(COVER_CROP) +repage -colorspace gray \
  -unsharp 0x3+1.5+0.01 -level 10%,78% \
  -white-threshold 97%

COMMA := ,

# Llamada a latexmk: $(call build,<nombre>,<opciones del tema>,<proporción>)
define build
	$(LATEXMK) -interaction=nonstopmode -halt-on-error -outdir=$(OUTDIR) -jobname=$(1) \
	  -usepretex='\PassOptionsToPackage{$(2)}{beamerthemePUCV}\def\proporcion{$(3)}' \
	  $(EXAMPLE)
endef

.PHONY: all examples test covers logos centenario install uninstall clean

all: $(OUTDIR)/presentacion-claro.pdf $(OUTDIR)/presentacion-oscuro.pdf \
     $(OUTDIR)/presentacion-institucional.pdf

examples: all $(OUTDIR)/presentacion-claro-43.pdf $(OUTDIR)/presentacion-oscuro-43.pdf \
          $(OUTDIR)/presentacion-institucional-43.pdf \
          $(OUTDIR)/presentacion-institucional-2023.pdf

$(OUTDIR)/presentacion-claro.pdf: $(EXAMPLE) $(THEME)
	$(call build,presentacion-claro,mode=light,169)

$(OUTDIR)/presentacion-oscuro.pdf: $(EXAMPLE) $(THEME)
	$(call build,presentacion-oscuro,mode=dark,169)

$(OUTDIR)/presentacion-claro-43.pdf: $(EXAMPLE) $(THEME)
	$(call build,presentacion-claro-43,mode=light,43)

$(OUTDIR)/presentacion-oscuro-43.pdf: $(EXAMPLE) $(THEME)
	$(call build,presentacion-oscuro-43,mode=dark,43)

$(OUTDIR)/presentacion-institucional.pdf: $(EXAMPLE) $(THEME)
	$(call build,presentacion-institucional,mode=institutional,169)

$(OUTDIR)/presentacion-institucional-43.pdf: $(EXAMPLE) $(THEME)
	$(call build,presentacion-institucional-43,mode=institutional,43)

$(OUTDIR)/presentacion-institucional-2023.pdf: $(EXAMPLE) $(THEME)
	$(call build,presentacion-institucional-2023,mode=institutional$(COMMA)centenary=false,169)

# Pruebas de estrés: cada archivo de tests/ (salvo el cuerpo común) se compila
# en modo claro, oscuro, institucional (Centenario) e institucional con las
# normas 2023 (`institutional-2023'), en 16:9 y 4:3.
TESTS := $(filter-out tests/cuerpo.tex,$(wildcard tests/*.tex))

test:
	@set -e; for t in $(TESTS); do for m in light dark institutional institutional-2023; do for a in 169 43; do \
	  j=$$(basename $$t .tex)-$$m-$$a; \
	  case $$m in institutional-2023) o='mode=institutional,centenary=false';; *) o="mode=$$m";; esac; \
	  $(LATEXMK) -interaction=nonstopmode -halt-on-error -silent -outdir=tests/build \
	    -jobname=$$j -usepretex="\\def\\opciones{$$o}\\def\\proporcion{$$a}" $$t \
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
	$(MAGICK) $< $(COVER_PROCESS) +level-colors $(COVER_BRAND) -strip -quality 90 \
	  src/beamerthemePUCV-cover-brand.jpg

# Logos de la portada, a partir de las versiones oficiales horizontales:
# a color para el modo claro y calado para el modo oscuro y el institucional
# con las normas 2023. El calado viene en blanco sobre un rectángulo azul
# (rojo = 40); la opacidad se obtiene del canal rojo y el logo se tiñe con la
# tinta del dibujo de la portada (oscuro) o de blanco (institucional).
LOGO_SRC_COLOR  := assets/logo-pucv-color-h.png
LOGO_SRC_CALADO := assets/logo-pucv-calado-h.png

logos: $(LOGO_SRC_COLOR) $(LOGO_SRC_CALADO)
	$(MAGICK) $(LOGO_SRC_COLOR) -trim +repage -strip \
	  -define png:compression-level=9 src/beamerthemePUCV-logo-light.png
	$(MAGICK) $(LOGO_SRC_CALADO) -alpha off -channel R -separate +channel \
	  -level 15.69%,100% \( +clone -fill '$(DARK_INK)' -colorize 100 \) \
	  +swap -alpha off -compose CopyOpacity -composite -trim +repage -strip \
	  -define png:compression-level=9 src/beamerthemePUCV-logo-dark.png
	$(MAGICK) $(LOGO_SRC_CALADO) -alpha off -channel R -separate +channel \
	  -level 15.69%,100% \( +clone -fill white -colorize 100 \) \
	  +swap -alpha off -compose CopyOpacity -composite -trim +repage -strip \
	  -define png:compression-level=9 src/beamerthemePUCV-logo-white.png

# Recursos del logo de los 100 años, recortados (en vectorial) de los archivos
# oficiales del manual del Centenario (assets/centenario/, versiones "Grilla
# arriba" y "Grilla abajo"). Las cajas están en puntos PostScript con origen en
# la esquina inferior izquierda:
#   - logo a color y blanco: el logo sin la grilla de "Grilla arriba";
#   - franja: la grilla horizontal de "Grilla arriba";
#   - filas superior e inferior de las dos últimas columnas de la grilla de
#     "Grilla abajo" (columna de la portada).
# gs reescribe cada PDF y elimina los datos privados de Illustrator.
CENT_UP    := assets/centenario/logo-grilla-arriba-color.ai
CENT_UPW   := assets/centenario/logo-grilla-arriba-blanco.ai
CENT_DOWN  := assets/centenario/logo-grilla-abajo-color.ai
GS         ?= gs
PDFCROP    ?= pdfcrop

# $(call crop,<origen>,<caja>,<destino>)
define crop
	$(PDFCROP) --bbox "$(2)" "$(1)" $(OUTDIR)/recorte.pdf >/dev/null
	$(GS) -q -sDEVICE=pdfwrite -dCompatibilityLevel=1.5 -dNOPAUSE -dBATCH \
	  -sOutputFile=$(3) $(OUTDIR)/recorte.pdf
endef

centenario:
	@mkdir -p $(OUTDIR)
	$(call crop,$(CENT_UP),148.5 9.5 455.5 144.5,src/beamerthemePUCV-centenario-logo.pdf)
	$(call crop,$(CENT_UPW),148.5 9.5 455.5 144.5,src/beamerthemePUCV-centenario-logo-white.pdf)
	$(call crop,$(CENT_UP),5 172.5 602.5 204,src/beamerthemePUCV-centenario-strip.pdf)
	$(call crop,$(CENT_DOWN),178.3 122.33 292.5 179.5,src/beamerthemePUCV-centenario-grid-top.pdf)
	$(call crop,$(CENT_DOWN),178.3 8 292.5 65.17,src/beamerthemePUCV-centenario-grid-bottom.pdf)
	@rm -f $(OUTDIR)/recorte.pdf

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
