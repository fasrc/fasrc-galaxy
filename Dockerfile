# galaxy for hutlab

FROM bgruening/galaxy-stable:dev

MAINTAINER FASRC, rchelp@rc.fas.harvard.edu

WORKDIR /galaxy-central

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 && \
    sh -c "echo deb http://archive.linux.duke.edu/cran/bin/linux/ubuntu trusty/ > /etc/apt/sources.list.d/r_cran.list" && \
    apt-get update -qq && apt-get upgrade -y && \
    apt-get install --no-install-recommends -y texlive-binaries libfreetype6-dev bowtie bowtie2 libhdf5-dev \
    r-base-core r-base-dev r-cran-mvtnorm r-cran-multcomp r-cran-sandwich r-cran-th.data r-cran-zoo r-cran-testthat \
    r-cran-vegan r-cran-gam r-cran-gbm r-cran-pscl r-cran-robustbase\
    ssh libopenmpi-dev openmpi-bin

ENV GALAXY_DB_HOST=localhost \
    GALAXY_DB_USER=galaxy \
    GALAXY_DB_PASSWORD=galaxy \
    GALAXY_DB_NAME=galaxy \
    GALAXY_DB_PORT=5432 \
    GALAXY_DATABASE_CONNECTION=postgresql://$GALAXY_DB_USER:"$GALAXY_DB_PASSWORD"@$GALAXY_DB_HOST:$GALAXY_DB_PORT/$GALAXY_DB_NAME

RUN . $GALAXY_ROOT/.venv/bin/activate && \
    pip install setuptools --upgrade && \
    pip install psutil numpy rpy2 matplotlib blist biom-format h5py cogent mlpy

COPY ./startup.sh /usr/bin/startup
COPY ./tools.yaml /tmp/tools.yaml
COPY ./install.R /galaxy-central/install.R
COPY ./job_conf.xml /galaxy-central/config/job_conf.xml
COPY ./dependency_resolvers_conf.xml /galaxy-central/config/dependency_resolvers_conf.xml

RUN R CMD BATCH /galaxy-central/install.R

RUN chmod +x /usr/bin/startup && \
    chmod g-w /var/log

RUN add-tool-shed --url 'http://testtoolshed.g2.bx.psu.edu/' --name 'Test Tool Shed'

RUN install-tools /tmp/tools.yaml

RUN apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV GALAXY_CONFIG_INTEGRATED_TOOL_PANEL_CONFIG /export/galaxy-central/integrated_tool_panel.xml

COPY ./integrated_tool_panel.xml /export/galaxy-central/integrated_tool_panel.xml
RUN mkdir -pv /export/galaxy-central/database/files

# Mark folders as imported from the host.
VOLUME ["/export/", "/data/", "/var/lib/docker"]

# Expose port 80 (webserver), 21 (FTP server), 8800 (Proxy), 9001 (Galaxy report app)
EXPOSE :80
EXPOSE :21
EXPOSE :8800
EXPOSE :9001

# Autostart script that is invoked during container start
CMD ["/usr/bin/startup"]

