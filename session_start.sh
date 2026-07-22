#!/bin/sh
# im-old-greg session start hook
# autoinstalls dependencies for development
# idempotent: runs once per session, skips if already done
set -e

MARKER="/.imoldgreg-deps-installed"

if [ -f "$MARKER" ]; then
  echo "[im-old-greg] dependencies already installed this session"
  exit 0
fi

echo "[im-old-greg] installing dependencies..."

# system libs for GHC linking + hmatrix (BLAS/LAPACK/GSL)
# libgmp-dev is not optional: every GHC link step fails without it
apt-get update -qq 2>/dev/null || true
apt-get install -y -qq \
  libgmp-dev \
  zlib1g-dev \
  libgsl-dev \
  libblas-dev \
  liblapack-dev \
  libatlas-base-dev \
  libffi-dev \
  pkg-config \
  rlwrap \
  make \
  gcc \
  g++ \
  2>/dev/null || true
echo "[im-old-greg] system libs done"

# ensure curl and wget
command -v curl  > /dev/null 2>&1 || apt-get install -y -qq curl  2>/dev/null || true
command -v wget  > /dev/null 2>&1 || apt-get install -y -qq wget  2>/dev/null || true
echo "[im-old-greg] curl/wget confirmed"

# ghcup (GHC + cabal)
if ! command -v ghc > /dev/null 2>&1; then
  export BOOTSTRAP_HASKELL_NONINTERACTIVE=1
  export BOOTSTRAP_HASKELL_GHC_VERSION=9.6.4
  export BOOTSTRAP_HASKELL_CABAL_VERSION=3.10.2.1
  export BOOTSTRAP_HASKELL_INSTALL_NO_STACK=1
  curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
  export PATH="$HOME/.ghcup/bin:$PATH"
  echo "[im-old-greg] GHC $(ghc --numeric-version) + cabal $(cabal --numeric-version) installed"
else
  export PATH="$HOME/.ghcup/bin:$PATH"
  echo "[im-old-greg] GHC $(ghc --numeric-version) already present"
fi

# haskell geometry libraries
cabal update -v0 2>/dev/null || cabal update
cabal install --lib \
  hmatrix \
  manifolds \
  manifolds-core \
  algebraic-graphs \
  cborg \
  serialise \
  2>/dev/null || {
    echo "[im-old-greg] cabal install --lib failed, trying one at a time..."
    for pkg in hmatrix manifolds manifolds-core algebraic-graphs cborg serialise; do
      cabal install --lib "$pkg" 2>/dev/null || echo "[im-old-greg] WARN: $pkg failed"
    done
  }
echo "[im-old-greg] haskell libs done"

# KiCS2
if ! command -v kics2 > /dev/null 2>&1; then
  KICS2_DIR="$HOME/.kics2"
  mkdir -p "$KICS2_DIR"

  # try prebuilt tarball first (debian12 build; see
  # www-ps.informatik.uni-kiel.de/kics2/download.html for others)
  KICS2_URL="https://www-ps.informatik.uni-kiel.de/kics2/download/kics2-3.1.0-x86_64-linux-debian12.tar.gz"
  echo "[im-old-greg] fetching KiCS2 prebuilt..."
  if curl -fSL -o /tmp/kics2.tar.gz "$KICS2_URL" 2>/dev/null; then
    tar xzf /tmp/kics2.tar.gz -C "$KICS2_DIR" --strip-components=1
    rm /tmp/kics2.tar.gz
    echo "[im-old-greg] KiCS2 prebuilt installed"
  elif wget -q -O /tmp/kics2.tar.gz "$KICS2_URL" 2>/dev/null; then
    tar xzf /tmp/kics2.tar.gz -C "$KICS2_DIR" --strip-components=1
    rm /tmp/kics2.tar.gz
    echo "[im-old-greg] KiCS2 prebuilt installed (wget)"
  else
    # fetch source via tarball (not git)
    echo "[im-old-greg] prebuilt not available, fetching source tarball..."
    KICS2_SRC="https://github.com/curry-language/kics2/archive/refs/heads/master.tar.gz"
    curl -fSL -o /tmp/kics2-src.tar.gz "$KICS2_SRC" 2>/dev/null || \
      wget -q -O /tmp/kics2-src.tar.gz "$KICS2_SRC"
    mkdir -p /tmp/kics2-src
    tar xzf /tmp/kics2-src.tar.gz -C /tmp/kics2-src --strip-components=1
    cd /tmp/kics2-src
    make KICS2INSTALLDIR="$KICS2_DIR" 2>&1 | tail -5
    make install KICS2INSTALLDIR="$KICS2_DIR" 2>&1 | tail -3
    cd /
    rm -rf /tmp/kics2-src /tmp/kics2-src.tar.gz
    echo "[im-old-greg] KiCS2 built from source"
  fi

  export PATH="$KICS2_DIR/bin:$PATH"
else
  echo "[im-old-greg] KiCS2 already present"
fi

# .greg inspection is greg-geom's job (no Python in this house):
#   greg-geom validate < data.greg
#   greg-geom bin2hex  < data.greg
# curry-frontend (typecheck without full KiCS2), best effort:
if ! command -v curry-frontend > /dev/null 2>&1; then
  ( cd /tmp && \
    git clone --depth 1 \
      https://github.com/cau-placc/curry-frontend.git cf 2>/dev/null && \
    cd cf && \
    cabal install exe:curry-frontend \
      --overwrite-policy=always \
      --installdir="$HOME/.local/bin" 2>/dev/null ) || \
    echo "[im-old-greg] WARN: curry-frontend install failed"
fi

# write PATH export for session
cat > /tmp/.imoldgreg-env << ENVEOF
export PATH="$HOME/.ghcup/bin:$HOME/.kics2/bin:\$PATH"
ENVEOF

echo "[im-old-greg] verifying..."
echo "  ghc:   $(ghc --numeric-version 2>/dev/null || echo 'NOT FOUND')"
echo "  cabal: $(cabal --numeric-version 2>/dev/null || echo 'NOT FOUND')"
echo "  kics2: $(kics2 --version 2>/dev/null || echo 'NOT FOUND')"
echo "  curry-frontend: $("$HOME/.local/bin/curry-frontend" --numeric-version 2>/dev/null || echo 'NOT FOUND')"
echo "[im-old-greg] ready"
echo "[im-old-greg] source /tmp/.imoldgreg-env to set PATH"

touch "$MARKER"
