# Create directory for PUCV theme
mkdir -p $(kpsewhich -var-value=TEXMFHOME)/tex/latex/PUCV

# Copy sty files
cp -r src/* $(kpsewhich -var-value=TEXMFHOME)/tex/latex/PUCV/