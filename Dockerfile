# galaxy for hutlab

FROM bgruening/galaxy-stable:dev

MAINTAINER FASRC, rchelp@rc.fas.harvard.edu

WORKDIR /galaxy-central

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 && \
    sh -c "echo deb http://archive.linux.duke.edu/cran/bin/linux/ubuntu trusty/ > /etc/apt/sources.list.d/r_cran.list"

RUN apt-get update -qq && apt-get upgrade -y && \
    apt-get install --no-install-recommends -y texlive-binaries libfreetype6-dev bowtie bowtie2 libhdf5-dev \
    r-base-core r-base-dev r-cran-mvtnorm r-cran-multcomp r-cran-sandwich r-cran-th.data r-cran-zoo \
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

ADD ./startup.sh /usr/bin/startup

ADD ./tools.yaml /tmp/tools.yaml

RUN chmod +x /usr/bin/startup

#ADD ./Rprofile /galaxy-central/.Rprofile

#RUN R CMD INSTALL --clean coin agricolae modeltools
ADD ./install.R /galaxy-central/install.R

RUN R CMD BATCH /galaxy-central/install.R

ADD ./job_conf.xml /galaxy-central/config/job_conf.xml

ADD ./dependency_resolvers_conf.xml /galaxy-central/config/dependency_resolvers_conf.xml

RUN chown -v galaxy:galaxy /galaxy-central/config/dependency_resolvers_conf.xml

RUN chmod g-w /var/log

# do we need this? postgresql complained upon start.
#RUN chmod 700 /export/postgresql/9.3/main


RUN add-tool-shed --url 'http://testtoolshed.g2.bx.psu.edu/' --name 'Test Tool Shed'

RUN install-tools /tmp/tools.yaml

ADD ./integrated_tool_panel.xml /export/galaxy-central/integrated_tool_panel.xml

ENV GALAXY_CONFIG_INTEGRATED_TOOL_PANEL_CONFIG /export/galaxy-central/integrated_tool_panel.xml

# Mark folders as imported from the host.
VOLUME ["/export/", "/data/", "/var/lib/docker"]

# Expose port 80 (webserver), 21 (FTP server), 8800 (Proxy), 9001 (Galaxy report app)
EXPOSE :80
EXPOSE :21
EXPOSE :8800
EXPOSE :9001

# Autostart script that is invoked during container start
CMD ["/usr/bin/startup"]

