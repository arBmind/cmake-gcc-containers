ARG DISTRO=focal
ARG GCC_MAJOR=11
ARG CMAKE_VERSION=3.21.4
ARG CMAKE_URL=https://github.com/Kitware/CMake/releases/download/v3.21.4/cmake-3.21.4-linux-x86_64.tar.gz
ARG QT_MAJOR=515
ARG QT_VERSION=5.15.2

FROM ubuntu:${DISTRO} AS cmake-gcc
ARG DISTRO
ARG GCC_MAJOR
ARG CMAKE_URL
ARG CMAKE_VERSION
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1
ARG DEBIAN_FRONTEND=noninteractive

LABEL Description="Ubuntu ${DISTRO} - Gcc${GCC_MAJOR} + CMake ${CMAKE_VERSION}"

ENV \
  TZ=Europe/Berlin \
  LANG=C.UTF-8 \
  LC_ALL=C.UTF-8

# install GCC
RUN apt-get update --quiet \
  && apt-get upgrade --yes --quiet \
  && apt-get install --yes --quiet --no-install-recommends \
    wget \
    gnupg \
    apt-transport-https \
    ca-certificates \
    tzdata \
  && wget -qO - "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x60c317803a41ba51845e371a1e9377a2ba9ef27f" | apt-key add - \
  && echo "deb http://ppa.launchpad.net/ubuntu-toolchain-r/test/ubuntu ${DISTRO} main" > /etc/apt/sources.list.d/gcc.list \
  && apt-get update --quiet \
  && apt-get install --yes --quiet --no-install-recommends \
    git \
    ninja-build \
    libstdc++-${GCC_MAJOR}-dev \
    gcc-${GCC_MAJOR} \
    g++-${GCC_MAJOR} \
  && update-alternatives --install /usr/bin/cc cc /usr/bin/gcc-${GCC_MAJOR} 100 \
  && update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++-${GCC_MAJOR} 100 \
  && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-${GCC_MAJOR} 100 \
  && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-${GCC_MAJOR} 100 \
  && c++ --version \
  && apt-get --yes autoremove \
  && apt-get clean autoclean \
  && rm -rf /var/lib/apt/lists/{apt,dpkg,cache,log} /tmp/* /var/tmp/*

RUN wget -qO - ${CMAKE_URL} | tar --strip-components=1 -xz -C /usr/local

WORKDIR /project

# final qbs-gcc-qt (with Qt)
FROM cmake-gcc AS cmake-gcc-qt
ARG DISTRO
ARG GCC_MAJOR
ARG CMAKE_VERSION
ARG QT_MAJOR
ARG QT_VERSION

LABEL Description="Ubuntu ${DISTRO} - Gcc${GCC_MAJOR} + Qt ${QT_VERSION} + CMake ${CMAKE_VERSION}"

ENV \
  QTDIR=/opt/qt${QT_MAJOR} \
  PATH=/opt/qt${QT_MAJOR}/bin:${PATH} \
  LD_LIBRARY_PATH=/opt/qt${QT_MAJOR}/lib/x86_64-linux-gnu:/opt/qt${QT_MAJOR}/lib:${LD_LIBRARY_PATH} \
  PKG_CONFIG_PATH=/opt/qt${QT_MAJOR}/lib/pkgconfig:${PKG_CONFIG_PATH}

RUN \
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C65D51784EDC19A871DBDBB710C56D0DE9977759 \
  && echo "deb http://ppa.launchpad.net/beineri/opt-qt-${QT_VERSION}-${DISTRO}/ubuntu ${DISTRO} main" > /etc/apt/sources.list.d/qt.list \
  && apt-get update --quiet \
  && if [ "${RUNTIME_APT}" != "" ] ; then export "RUNTIME_APT2=${RUNTIME_APT}" ; \
    elif [ "${DISTRO}" = "xenial" ] ; then export "RUNTIME_APT2=${RUNTIME_XENIAL}" ; \
    else export "RUNTIME_APT2=${RUNTIME_FOCAL}" ; \
    fi \
  && apt-get install --yes --quiet --no-install-recommends \
    git \
    make \
    libgl1-mesa-dev \
    qt${QT_MAJOR}script \
    qt${QT_MAJOR}base \
    qt${QT_MAJOR}tools \
    ${RUNTIME_APT2} \
  && apt-get --yes autoremove \
  && apt-get clean autoclean \
  && rm -rf /var/lib/apt/lists/{apt,dpkg,cache,log} /tmp/* /var/tmp/*
