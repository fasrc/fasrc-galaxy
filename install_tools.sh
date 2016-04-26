#!/bin/bash
cd /galaxy-central/tools
hg clone https://bitbucket.org/biobakery/metaphlan2
hg clone https://bitbucket.org/biobakery/galaxy_metaphlan2
cp galaxy_metaphlan2/metaphlan2.xml metaphlan2

hg clone https://bitbucket.org/nsegata/graphlan
hg clone https://bitbucket.org/biobakery/galaxy_graphlan
cp -r graphlan/pyphlan /galaxy-central/lib/
cp -r galaxy_graphlan/* graphlan/

git clone git://github.com/picrust/picrust.git picrust
hg clone https://bitbucket.org/biobakery/galaxy_picrust
cp /galaxy-central/tools/galaxy_picrust/*.xml /galaxy-central/tools/picrust
cd /galaxy-central/tools/picrust/data
wget ftp://ftp.microbio.me/pub/picrust-references/picrust-1.0.0/16S_13_5_precalculated.tab.gz
wget ftp://ftp.microbio.me/pub/picrust-references/picrust-1.0.0/ko_13_5_precalculated.tab.gz
cd /galaxy-central/tools/picrust
python setup.py install

chown -Rf galaxy:galaxy /galaxy-central/tools /galaxy-central/lib
