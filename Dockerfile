# galaxy for hutlab

FROM fasrc/fasrc-galaxy:latest

MAINTAINER FASRC, rchelp@rc.fas.harvard.edu

WORKDIR /galaxy-central

ENV GALAXY_VIRTUAL_ENV /galaxy_venv

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 && \
    sh -c "echo deb http://archive.linux.duke.edu/cran/bin/linux/ubuntu trusty/ > /etc/apt/sources.list.d/r_cran.list" && \
    apt-get update -qq && apt-get upgrade -y && \
    apt-get install --no-install-recommends -y texlive-binaries libfreetype6-dev \
    r-base-core r-base-dev r-cran-mvtnorm r-cran-multcomp r-cran-sandwich r-cran-th.data r-cran-zoo && \
    . $GALAXY_VIRTUAL_ENV/bin/activate && \
    pip install setuptools --upgrade && \
    pip install psutil scipy numpy rpy2 matplotlib blist && \
    chmod g-w /var/log && \
    add-tool-shed --u 'http://testtoolshed.g2.bx.psu.edu/' --name 'Test Tool Shed' ; sleep 5 && \
    install-repository "-u https://testtoolshed.g2.bx.psu.edu/ -o george-weingart -n lefse --panel-section-name LEfSe -r a6284ef17bf3" ; sleep 5 && \
    install-repository "-u https://testtoolshed.g2.bx.psu.edu/ -o george-weingart --name metaphlan --panel-section-name MetaPhlAn -r d31b701b44ee" ; sleep 5 && \
    install-repository "-u https://testtoolshed.g2.bx.psu.edu/ -o george-weingart --name micropita --panel-section-name microPITA -r 61e311c4d2d0" ; sleep 5 && \
    install-repository "-u https://testtoolshed.g2.bx.psu.edu/ -o george-weingart --name maaslin --panel-section-name MaAsLin -r 4450aa4ecc84"

# Mark folders as imported from the host.
VOLUME ["/export/", "/data/", "/var/lib/docker"]

# Expose port 80 (webserver), 21 (FTP server), 8800 (Proxy), 9001 (Galaxy report app)
EXPOSE :80
EXPOSE :21
EXPOSE :8800
EXPOSE :9001

# Autostart script that is invoked during container start
CMD ["/usr/bin/startup"]
