# Build according to a specified version of R
ARG R_VERSION
ARG R_VERSION=${R_VERSION:-4.5.2}

############# Build Stage: base ##################

# Start from a container that has tidyverse from rocker image
FROM rocker/tidyverse:${R_VERSION} AS base

ENV DEBIAN_FRONTEND=noninteractive

COPY ./odbc/*.deb /tmp/

# Install system libraries of general use
RUN apt-get update --allow-releaseinfo-change --fix-missing \
  && apt-get install -y --no-install-recommends \
  autoconf \
  automake \
  ca-certificates \
  build-essential \
  libssl-dev \
  libtool \
  pkg-config \
  librsvg2-dev \
  libudunits2-dev \
  libv8-dev \
  libbz2-dev \
  liblzma-dev \
  tcl8.6-dev \
  tk8.6-dev \
  unixodbc-dev \
  unixodbc \
  debhelper \
  dpkg \
  dos2unix \
  openssh-server \
  openssl \
  sshpass \
  rsync \
  git \ 
  && dpkg -i /tmp/clouderaimpalaodbc_2.8.4.1010-2_amd64.deb \
  && apt clean autoclean \
  && apt autoremove --yes \
  && rm -rf /var/lib/{apt,dpkg,cache,log}/

# copy configuration files for the driver
COPY ./odbc/odbc.ini /etc/odbc.ini
COPY ./odbc/odbcinst.ini /etc/odbcinst.ini
COPY ./odbc/cloudera.impalaodbc.ini /opt/cloudera/impalaodbc/lib/64/cloudera.impalaodbc.ini

# set env variables
ENV ODBCINI=/etc/odbc.ini
ENV ODBCSYSINI=/etc
ENV CLOUDERAIMPALAINI=/opt/cloudera/impalaodbc/lib/64/cloudera.impalaodbc.ini
ENV LD_LIBRARY_PATH=/opt/cloudera/impalaodbc/lib/64:$LD_LIBRARY_PATH

# copy certs
COPY ./certs/bundle-ca.crt /etc/ssl/certs
COPY ./certs/bundle-ca.crt /usr/local/share/ca-certificates/

RUN update-ca-certificates

############# Setting Volumes and Working Directory ##################
  
# Create directory 
ENV PACKAGE_DIR=surv_nextstrain

# Set working directory
WORKDIR ${PACKAGE_DIR}

############# Install R Packages ##################

# Copy python requirements file to docker images
COPY install_r_packages.R "${PACKAGE_DIR}/install_r_packages.R"

# Install all package dependencies
RUN Rscript "${PACKAGE_DIR}/install_r_packages.R"

################# Define Entrypoint #################
ENTRYPOINT ["/bin/bash"]





