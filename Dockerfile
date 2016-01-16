# galaxy for hutlab

FROM bgruening/galaxy-stable:dev

MAINTAINER FASRC, rchelp@rc.fas.harvard.edu

WORKDIR /galaxy-central

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 && \
    sh -c "echo deb http://archive.linux.duke.edu/cran/bin/linux/ubuntu trusty/ > /etc/apt/sources.list.d/r_cran.list"

RUN apt-get update -qq && apt-get upgrade -y && \
    apt-get install --no-install-recommends -y texlive-binaries libfreetype6-dev \
    r-base-core r-base-dev r-cran-mvtnorm r-cran-multcomp r-cran-sandwich r-cran-th.data r-cran-zoo

RUN . $GALAXY_ROOT/.venv/bin/activate && \
    pip install setuptools --upgrade && \
    pip install psutil numpy rpy2 matplotlib

ADD ./tools.yaml /tmp/tools.yaml

RUN install-tools /tmp/tools.yaml

RUN chmod g-w /var/log

#ADD ./integrated_tool_panel.xml /galaxy-central/integrated_tool_panel.xml

RUN add-tool-shed --url 'http://testtoolshed.g2.bx.psu.edu/' --name 'Test Tool Shed'
RUN install-repository \
    "--url https://testtoolshed.g2.bx.psu.edu/ -o george-weingart --name lefse" \
    "--url https://testtoolshed.g2.bx.psu.edu/ -o george-weingart --name metaphlan" \
    "--url https://testtoolshed.g2.bx.psu.edu/ -o george-weingart --name graphlan" \
    "--url https://testtoolshed.g2.bx.psu.edu/ -o george-weingart --name micropita" \
    "--url https://testtoolshed.g2.bx.psu.edu/ -o george-weingart --name maaslin" \

# Mark folders as imported from the host.
VOLUME ["/export/", "/data/", "/var/lib/docker"]

# Expose port 80 (webserver), 21 (FTP server), 8800 (Proxy), 9001 (Galaxy report app)
EXPOSE :80
EXPOSE :21
EXPOSE :8800
EXPOSE :9001

# Autostart script that is invoked during container start
CMD ["/usr/bin/startup"]

