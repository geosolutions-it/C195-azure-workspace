# See CKAN docs on installation from Docker Compose on usage
FROM debian:buster
LABEL Open Knowledge

EXPOSE 5000

# Install required system packages
RUN apt-get -q -y update \
    && DEBIAN_FRONTEND=noninteractive apt-get -q -y upgrade \
    && apt-get -q -y install \
        crudini \
        tcpdump \
        python3-dev \
        python3-pip \
        python3-virtualenv \
        python3-venv \
        python3-wheel \
        libpq-dev \
        libxml2-dev \
        libxslt-dev \
        libgeos-dev \
        libssl-dev \
        libffi-dev \
        postgresql-client \
        build-essential \
        git-core \
        vim \
        wget \
        gdb python3-dbg \
        procps \
        swig \
    && apt-get -q clean \
    && rm -rf /var/lib/apt/lists/*
RUN wget https://raw.githubusercontent.com/pixelb/crudini/0.9.3/crudini -O /usr/bin/crudini \
    && chmod a+x /usr/bin/crudini

# Define environment variables
ENV CKAN_HOME /usr/lib/ckan
ENV CKAN_VENV $CKAN_HOME/venv
ENV CKAN_CONFIG /etc/ckan
ENV CKAN_STORAGE_PATH=/var/lib/ckan
ENV TENANT_ID 00000000-0000-0000-0000-000000000000
ENV CLIENT_ID 00000000-0000-0000-0000-000000000000
ENV CLIENT_SECRET pKf_0000000_00000-0000-0000

# Build-time variables specified by docker-compose.yml / .env
ARG TENANT_ID
ARG CLIENT_ID
ARG CLIENT_SECRET
ARG CKAN_SITE_URL

# Create ckan user
RUN useradd -r -u 900 -m -c "ckan account" -d $CKAN_HOME -s /bin/bash ckan

# Setup virtual environment for CKAN
RUN mkdir -p $CKAN_VENV $CKAN_CONFIG $CKAN_STORAGE_PATH && \
    python3 -m venv $CKAN_VENV

COPY ./ckan_copy $CKAN_VENV/src/ckan/

RUN $CKAN_VENV/bin/pip install -U pip && \
    $CKAN_VENV/bin/pip install --upgrade --no-cache-dir -r $CKAN_VENV/src/ckan/requirement-setuptools.txt && \
    $CKAN_VENV/bin/pip install --upgrade --no-cache-dir -r $CKAN_VENV/src/ckan/requirements.txt && \
    $CKAN_VENV/bin/pip install --upgrade --no-cache-dir -r $CKAN_VENV/src/ckan/dev-requirements.txt && \
    $CKAN_VENV/bin/pip install -e $CKAN_VENV/src/ckan/ && \
    ln -s $CKAN_VENV/src/ckan/ckan/config/who.ini $CKAN_CONFIG/who.ini && \
    chown -R ckan:ckan $CKAN_HOME $CKAN_VENV $CKAN_CONFIG $CKAN_STORAGE_PATH

RUN $CKAN_VENV/bin/pip install -e git+https://github.com/geosolutions-it/ckanext-c195.git@main#egg=ckanext-c195
RUN $CKAN_VENV/bin/pip install -e git+https://github.com/ckan/ckanext-dcat.git@master#egg=ckanext-dcat && \
    $CKAN_VENV/bin/pip install -r $CKAN_VENV/src/ckanext-dcat/requirements.txt 
RUN $CKAN_VENV/bin/pip install -e git+https://github.com/geosolutions-it/ckanext-azure-auth.git@main#egg=ckanext-azure-auth && \
    $CKAN_VENV/bin/pip install -r $CKAN_VENV/src/ckanext-azure-auth/requirements.txt
RUN $CKAN_VENV/bin/pip install -e git+https://github.com/geosolutions-it/ckanext-grace-period.git@main#egg=ckanext-grace-period
RUN $CKAN_VENV/bin/pip install -e git+https://github.com/ckan/ckanext-harvest.git@v1.3.3#egg=ckanext-harvest && \
    $CKAN_VENV/bin/pip install -r $CKAN_VENV/src/ckanext-harvest/pip-requirements.txt
RUN $CKAN_VENV/bin/pip install -e git+https://github.com/ckan/ckanext-spatial.git@v1.0.0#egg=ckanext-spatial && \
    $CKAN_VENV/bin/pip install -r $CKAN_VENV/src/ckanext-spatial/requirements.txt
RUN $CKAN_VENV/bin/pip install -e git+https://github.com/TIBHannover/ckanext-tif-imageview.git@main#egg=ckanext_tif_imageview && \
    $CKAN_VENV/bin/pip install -r $CKAN_VENV/src/ckanext-tif-imageview/requirements.txt
RUN $CKAN_VENV/bin/pip install -e git+https://github.com/ckan/ckanext-pdfview@master#egg=ckanext_pdfview

# Setup CKAN custom scripts

COPY ./ckan-entrypoint.sh /ckan-entrypoint.sh
COPY ./ckan-run.sh /ckan-run.sh
COPY ./gdb.commands /gdb.commands
COPY ./capture_gdb.sh /capture_gdb.sh
RUN chmod +x /ckan-entrypoint.sh /capture_gdb.sh /ckan-run.sh

#USER ckan

SHELL ["/bin/bash", "-c"]

ENTRYPOINT ["/ckan-entrypoint.sh"]
CMD ["/ckan-run.sh"]

# CMD ["$CKAN_VENV/bin/python3", "$CKAN_VENV/bin/ckan","-c","/etc/ckan/production.ini", "run", "--host", "0.0.0.0"]
