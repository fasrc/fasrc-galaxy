#!/bin/bash
cd /galaxy-central/tools
hg clone https://bitbucket.org/biobakery/metaphlan2
hg clone https://bitbucket.org/biobakery/galaxy_metaphlan2
cp galaxy_metaphlan2/metaphlan2.xml metaphlan2
chown -Rf galaxy:galaxy /galaxy-central/tools /galaxy-central/lib
