# Tema beamer PUCV

Tema moderno de [beamer](https://ctan.org/pkg/beamer) para presentaciones
académicas de la Pontificia Universidad Católica de Valparaíso (PUCV). Los
colores y la fuente (Roboto) siguen las
[normas gráficas de la PUCV](https://www.pucv.cl/uuaa/normas-graficas-pucv).

Tiene tres modos:

- **Claro** y **oscuro**, pensados para la legibilidad: la paleta institucional
  se usa solo en acentos (títulos, viñetas, líneas, bloques), y todo el texto
  cumple el contraste WCAG AA, también en proyectores con poco contraste.
- **Institucional**, que aplica el manual del logo de los 100 años: fondo crudo
  en la portada y el cierre, grilla del Centenario, separadores a sangre en
  azul y bloques con banda sólida. Con `centenary=false` aplica las normas
  gráficas 2023: azul institucional y la banda con los tres colores de la
  marca.

| Claro | Oscuro |
|:---:|:---:|
| ![Modo claro](docs/preview-light.png) | ![Modo oscuro](docs/preview-dark.png) |

| Institucional |
|:---:|
| ![Modo institucional](docs/preview-institutional.png) |

## Instalación

Instale el tema en su árbol TeX personal (`TEXMFHOME`):

```bash
make install        # o bien ./install.sh
```

Para desinstalarlo use `make uninstall`. Alternativamente, copie el contenido
de `src/` junto a su archivo `.tex`.

## Uso

```latex
\documentclass[aspectratio=169]{beamer}
\usepackage[spanish,es-noshorthands]{babel}
\usetheme{PUCV}                       % modo claro
% \usetheme[mode=dark]{PUCV}          % modo oscuro
% \usetheme[mode=institutional]{PUCV} % modo institucional

\title{Título}
\subtitle{Subtítulo}
\author[Nombre corto]{Nombre completo}
\institute{Escuela de Ingeniería Eléctrica\\
  Pontificia Universidad Católica de Valparaíso}

\begin{document}
\maketitle                             % portada a sangre y sin numerar
\section{Introducción}                 % agrega una diapositiva separadora
\begin{frame}{Título de la diapositiva}{Subtítulo opcional}
  Contenido
\end{frame}
\makeclosing[correo@pucv.cl]{¡Muchas gracias!}  % diapositiva de cierre
\end{document}
```

Con `babel` en español se recomienda la opción `es-noshorthands`, ya que los
atajos del español interfieren con las especificaciones de overlays de beamer
(`<2->`, etc.). El tema traduce al español los nombres de los entornos de
beamer (Teorema, Definición, Ejemplo, Demostración, etc.).

La portada usa el logo oficial horizontal de la PUCV: a color en modo claro y
en su versión calada en modo oscuro, teñida con el mismo tono de las líneas
del dibujo de la Casa Central.

### Títulos largos y muchos autores

- La portada se adapta a su contenido: primero reduce el tamaño del título,
  luego ensancha la columna de texto (desplazando la imagen de portada a la
  derecha) y, como último recurso, reduce el bloque de texto completo.
- Los autores separados con `\and` se listan con comas; se admiten las marcas
  `\inst{}` y varias instituciones.
- El pie de página muestra `autor corto · título corto`, truncados con puntos
  suspensivos si no caben. Para listas de autores o títulos largos, indique
  versiones cortas: `\author[Mella et al.]{...}` y `\title[Título corto]{...}`.

### Cierre, tablas y código

- `\makeclosing[<contacto>]{<mensaje>}` agrega una diapositiva de cierre sin
  numerar, con el logo, el mensaje y el contacto opcional.
- El color `pucv-table-head` sirve para destacar el encabezado de una tabla
  con `\rowcolor{pucv-table-head}`; para usarlo, cargue beamer con la opción
  `xcolor=table`.
- Si el documento carga `listings`, el código usa Roboto Mono y los colores
  del modo: palabras clave con el acento, cadenas con el color de ejemplo y
  comentarios atenuados.

Vea [`examples/presentacion.tex`](examples/presentacion.tex) para un ejemplo
completo (listas, bloques, matemáticas, tablas, figuras, código, overlays,
cierre y apéndice).

## Opciones

Las opciones se indican como `\usetheme[<clave>=<valor>, ...]{PUCV}`.

| Opción        | Valores                              | Por defecto | Descripción                                                  |
|---------------|--------------------------------------|-------------|--------------------------------------------------------------|
| `mode`        | `light`, `dark`, `institutional`     | `light`     | Modo de color (claro, oscuro o institucional).               |
| `centenary`   | `true`, `false`                      | `true`      | En modo institucional: gráfica del Centenario o normas 2023. |
| `accent`      | `blue`, `red`, `gold`                | `blue`      | Color principal; los otros dos se usan en alertas y ejemplos. |
| `progressbar` | `foot`, `head`, `none`               | `foot`      | Posición de la barra de progreso.                            |
| `sectionpage` | `true`, `false`                      | `true`      | Inserta una diapositiva separadora en cada `\section`.       |
| `numbering`   | `fraction`, `counter`, `none`        | `fraction`  | Formato del número de diapositiva en el pie.                 |
| `titleimage`  | `default`, `none`, *nombre de archivo* | `default` | Imagen a la derecha de la portada.                           |

El manual del logo de los 100 años fija su uso entre marzo de 2025 y diciembre
de 2028; después de esa fecha, use `mode=institutional, centenary=false`.

El tema define los colores institucionales `pucv-blue`, `pucv-navy`,
`pucv-red`, `pucv-gold` y `pucv-gray` (normas 2023), la paleta del Centenario
(`pucv-c-navy`, `pucv-c-blue`, `pucv-c-cerulean`, `pucv-c-sky`, `pucv-c-ice`,
`pucv-c-red`, `pucv-c-coral`, `pucv-c-violet`, `pucv-c-yellow`,
`pucv-c-teal` y el fondo crudo `pucv-c-cream`), y los colores que dependen del
modo `pucv-bg`, `pucv-fg`, `pucv-muted`, `pucv-accent`, `pucv-alert`,
`pucv-example` y `pucv-table-head`. Prefiera estos últimos en sus diapositivas
para que funcionen en los tres modos.

## Estructura

| Archivo                        | Contenido                                                  |
|--------------------------------|------------------------------------------------------------|
| `src/beamerthemePUCV.sty`      | Punto de entrada: opciones, portada, separadores, traducciones. |
| `src/beamercolorthemePUCV.sty` | Paleta institucional y colores semánticos de cada modo.    |
| `src/beamerfontthemePUCV.sty`  | Roboto, Roboto Mono y jerarquía tipográfica.               |
| `src/beamerinnerthemePUCV.sty` | Portada, separadores de sección, cierre, listas, bloques, índice y código. |
| `src/beamerouterthemePUCV.sty` | Título de diapositiva, pie de página y barra de progreso.  |
| `assets/`                      | Dibujo de la portada y logos oficiales originales (`make covers`, `make logos`, `make centenario`). |
| `examples/`                    | Presentación de ejemplo.                                   |
| `tests/`                       | Pruebas de estrés (títulos largos, muchos autores).        |

## Desarrollo

```bash
make            # compila examples/build/presentacion-{claro,oscuro,institucional}.pdf
make examples   # compila también las variantes 4:3 y la institucional 2023
make test       # pruebas de estrés en los tres modos, 16:9 y 4:3
make covers     # regenera las imágenes de portada (requiere ImageMagick)
make logos      # regenera los logos de la portada desde assets/ (requiere ImageMagick)
make centenario # recorta los recursos del logo de los 100 años (pdfcrop y gs)
make clean
```

El archivo `latexmkrc` del repositorio agrega `src/` a `TEXINPUTS`, por lo que
los ejemplos compilan sin instalar el tema. El tema funciona con pdfLaTeX,
LuaLaTeX y XeLaTeX.

## Contacto

Hernán Mella (PUCV) — hernan.mella@pucv.cl
