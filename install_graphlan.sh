#!/bin/bash
cd /galaxy-central/tools
hg clone https://bitbucket.org/nsegata/graphlan
hg clone https://bitbucket.org/biobakery/galaxy_graphlan
cp -r graphlan/pyphlan /galaxy-central/lib/
cp -r galaxy_graphlan/* graphlan/
chown -Rf galaxy:galaxy /galaxy-central/tools /galaxy-central/lib
