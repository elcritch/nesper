FROM mcr.microsoft.com/vscode/devcontainers/cpp:debian-11
# FROM espressif/idf:release-v4.0

ARG DEBIAN_FRONTEND=noninteractive

RUN : \
  && sudo apt-get update \
  && sudo apt-get install -y \
    apt-utils \
    bison \
    ca-certificates \
    ccache \
    check \
    curl \
    flex \
    git \
    git-lfs \
    gperf \
    lcov \
    libbsd-dev \
    libffi-dev \
    libncurses-dev \
    libusb-1.0-0-dev \
    make \
    ninja-build \
    python3 \
    python3-venv \
    python3-pip \
    ruby \
    unzip \
    wget \
    xz-utils \
    zip \
  && sudo apt-get autoremove -y \
  && sudo rm -rf /var/lib/apt/lists/* \
  && sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 10 \
  && :

# To build the image for a branch or a tag of IDF, pass --build-arg IDF_CLONE_BRANCH_OR_TAG=name.
# To build the image with a specific commit ID of IDF, pass --build-arg IDF_CHECKOUT_REF=commit-id.
# It is possibe to combine both, e.g.:
#   IDF_CLONE_BRANCH_OR_TAG=release/vX.Y
#   IDF_CHECKOUT_REF=<some commit on release/vX.Y branch>.
# Use IDF_CLONE_SHALLOW=1 to peform shallow clone (i.e. --depth=1 --shallow-submodules)
# Use IDF_INSTALL_TARGETS to install tools only for selected chip targets (CSV)

ARG IDF_CLONE_URL=https://github.com/espressif/esp-idf.git
ARG IDF_CLONE_BRANCH_OR_TAG=master
ARG IDF_CHECKOUT_REF=
ARG IDF_CLONE_SHALLOW=
ARG IDF_INSTALL_TARGETS=all

ENV IDF_PATH=/opt/esp/idf
ENV IDF_TOOLS_PATH=/opt/esp

RUN echo IDF_CHECKOUT_REF=$IDF_CHECKOUT_REF IDF_CLONE_BRANCH_OR_TAG=$IDF_CLONE_BRANCH_OR_TAG && \
    git clone --recursive \
      ${IDF_CLONE_SHALLOW:+--depth=1 --shallow-submodules} \
      ${IDF_CLONE_BRANCH_OR_TAG:+-b $IDF_CLONE_BRANCH_OR_TAG} \
      $IDF_CLONE_URL $IDF_PATH && \
    if [ -n "$IDF_CHECKOUT_REF" ]; then \
      cd $IDF_PATH && \
      if [ -n "$IDF_CLONE_SHALLOW" ]; then \
        git fetch origin --depth=1 --recurse-submodules ${IDF_CHECKOUT_REF}; \
      fi && \
      git checkout $IDF_CHECKOUT_REF && \
      git submodule update --init --recursive; \
    fi

# Install all the required tools
RUN : \
  && update-ca-certificates --fresh \
  && $IDF_PATH/tools/idf_tools.py --non-interactive install required \
  && $IDF_PATH/tools/idf_tools.py --non-interactive install cmake \
  && $IDF_PATH/tools/idf_tools.py --non-interactive install-python-env \
  && rm -rf $IDF_TOOLS_PATH/dist \
  && :

# The constraint file has been downloaded and the right Python package versions installed. No need to check and
# download this at every invocation of the container.
ENV IDF_PYTHON_CHECK_CONSTRAINTS=no

# Ccache is installed, enable it by default
# ENV IDF_CCACHE_ENABLE=1

# Install QEMU runtime dependencies
RUN : \
  && apt-get update && apt-get install -y -q \
    libglib2.0-0 \
    libpixman-1-0 \
  && rm -rf /var/lib/apt/lists/* \
  && :


# Install QEMU
ARG QEMU_VER=esp-develop-20220919
ARG QEMU_DIST=qemu-${QEMU_VER}.tar.bz2
ARG QEMU_SHA256=f6565d3f0d1e463a63a7f81aec94cce62df662bd42fc7606de4b4418ed55f870
RUN : \
  && wget --no-verbose https://github.com/espressif/qemu/releases/download/${QEMU_VER}/${QEMU_DIST} \
  && echo "${QEMU_SHA256} *${QEMU_DIST}" | sha256sum --check --strict - \
  && tar -xf ${QEMU_DIST} -C /opt \
  && rm ${QEMU_DIST} \
  && :
ENV PATH=/opt/qemu/bin:${PATH}

# Call idf_tools.py to export tool paths
ENV IDF_TOOLS_EXPORT_CMD=${IDF_PATH}/export.sh
ENV IDF_TOOLS_INSTALL_CMD=${IDF_PATH}/install.sh
# Allow calling some IDF python tools without specifying the full path
# ${IDF_PATH}/tools is already added by 'idf_tools.py export'
ENV IDF_ADD_PATHS_EXTRAS="${IDF_PATH}/components/esptool_py/esptool"
ENV IDF_ADD_PATHS_EXTRAS="${IDF_ADD_PATHS_EXTRAS}:${IDF_PATH}/components/espcoredump"
ENV IDF_ADD_PATHS_EXTRAS="${IDF_ADD_PATHS_EXTRAS}:${IDF_PATH}/components/partition_table"
ENV IDF_ADD_PATHS_EXTRAS="${IDF_ADD_PATHS_EXTRAS}:${IDF_PATH}/components/app_update"

RUN : \
    && echo 'source /opt/esp/idf/export.sh' >> /etc/bash.bashrc \
    && echo 'source /opt/esp/idf/export.sh' >> /etc/zsh/zshrc

USER vscode

RUN : \
    && printf '[safe]\n       directory = /opt/esp/idf\n' >> /home/vscode/.gitconfig


ARG TARGETPLATFORM
ARG TARGETOS
ARG TARGETARCH
ARG BUILDPLATFORM
ARG BUILDOS
ARG BUILDARCH

# COPY idf-env.sh /etc/profile.d/idf-env.sh
RUN : \
  && cd $HOME/ \
    && case ${TARGETARCH} in \
         "arm64")        TARCH=arm64  ;; \
         "amd64")        TARCH=x64  ;; \
         "arm")          TARCH=arm  ;; \
         "386")          TARCH=x32  ;; \
         *)              TARCH=${TARGETARCH} ;; \
       esac \
    && env \
    && NIM_PLATFORM=${TARGETOS}_${TARCH} \
    && wget https://github.com/nim-lang/nightlies/releases/download/latest-version-1-6/${NIM_PLATFORM}.tar.xz \
    && tar xf ${NIM_PLATFORM}.tar.xz \
    && sudo mv nim-* /usr/local/ \
    && for b in atlas nim nimble nim_dbg nim-gdb nimgrep nimpretty nimsuggest testament; \
      do sudo ln -sf /usr/local/nim-*/bin/$b /usr/local/bin/; \
    done
