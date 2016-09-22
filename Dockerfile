# galaxy for hutlab

FROM fasrc/fasrc-galaxy:latest

MAINTAINER FASRC, rchelp@rc.fas.harvard.edu

WORKDIR /galaxy-central


ENV GALAXY_DB_HOST=localhost \
    GALAXY_DB_USER=galaxy \
    GALAXY_DB_PASSWORD=galaxy \
    GALAXY_DB_NAME=galaxy \
    GALAXY_DB_PORT=5432 \
    GALAXY_VIRTUAL_ENV=/galaxy_venv \
    GALAXY_DATABASE_CONNECTION=postgresql://$GALAXY_DB_USER:"$GALAXY_DB_PASSWORD"@$GALAXY_DB_HOST:$GALAXY_DB_PORT/$GALAXY_DB_NAME \
    GALAXY_CONFIG_INTEGRATED_TOOL_PANEL_CONFIG=/export/galaxy-central/integrated_tool_panel.xml \
    ENABLE_TTS_INSTALL=True

COPY ./install.R /galaxy-central/install.R
COPY ./dependency_resolvers_conf.xml /galaxy-central/config/dependency_resolvers_conf.xml
COPY ./integrated_tool_panel.xml.lefse_fixed_order /galaxy-central/integrated_tool_panel.xml.lefse_fixed_order
COPY ./welcome.html $GALAXY_CONFIG_DIR/web/welcome.html
COPY ./datatypes_conf.xml /galaxy-central/config/datatypes_conf.xml
COPY ./tool_conf.xml /galaxy-central/config/tool_conf.xml
COPY ./install_tools.sh /usr/local/bin/install_tools.sh
COPY ./run_cron.sh /usr/local/bin/run_cron.sh
COPY ./run_db_backups.sh /usr/local/bin/run_db_backups.sh

RUN R CMD BATCH -q /galaxy-central/install.R /galaxy-central/r_deps_installed.log && \
    chmod +x /usr/bin/startup /usr/local/bin/install_* && \
    chmod g-w /var/log && \
    ln -s /galaxy-central /usr/local/galaxy-dist

RUN touch galaxy_install.log && chown galaxy:galaxy galaxy_install.log && \
    add-tool-shed --u 'http://testtoolshed.g2.bx.psu.edu/' --name 'Test Tool Shed' && sleep 5 && \
    install-repository "-u https://testtoolshed.g2.bx.psu.edu/ -o george-weingart -n lefse --panel-section-name LEfSe -r a6284ef17bf3" && sleep 5 && \
    install-repository "-u https://testtoolshed.g2.bx.psu.edu/ -o george-weingart --name metaphlan --panel-section-name MetaPhlAn -r d31b701b44ee" && sleep 5 && \
    install-repository "-u https://testtoolshed.g2.bx.psu.edu/ -o george-weingart --name micropita --panel-section-name microPITA -r 61e311c4d2d0" && sleep 5 && \
    install-repository "-u https://testtoolshed.g2.bx.psu.edu/ -o george-weingart --name maaslin --panel-section-name MaAsLin -r 4450aa4ecc84" && \
    /usr/local/bin/install_tools.sh && \
    chown -Rf galaxy:galaxy /galaxy-central/

RUN apt-get update \
    && apt-get remove -y nginx-common nginx-extras \
    && apt-get install -y nginx-common=1.4.6-1ubuntu3.4ppa1 nginx-extras=1.4.6-1ubuntu3.4ppa1\
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Mark folders as imported from the host.
VOLUME ["/export/", "/data/", "/var/lib/docker"]

# Expose port 80 (webserver), 21 (FTP server), 8800 (Proxy), 9001 (Galaxy report app)
EXPOSE :80
EXPOSE :21
EXPOSE :8800
EXPOSE :9001

# Autostart script that is invoked during container start
CMD ["/usr/bin/startup"]
