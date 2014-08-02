#!/bin/sh

mkdir -p data/archives

if test ! -d data/graf
then
    wget -c -nc \
        http://www.robots.ox.ac.uk/~vgg/research/affine/det_eval_files/graf.tar.gz \
        -O data/archives/graf.tgz
    mkdir -p data/graf
    (cd data/graf ; tar xzvf ../archives/graf.tgz)
    (cd data/graf ; rm -f *.png ; mogrify -format png *.ppm)
    (cd data/graf ; rm -f *.ppm)
fi

cp -vr extra/queries data/

if test ! -d data/oxbuild_images
then
    wget -c -nc \
        http://www.robots.ox.ac.uk/~vgg/data/oxbuildings/oxbuild_images.tgz \
        -O data/archives/oxbuild_images.tgz
    mkdir -p data/oxbuild_images
    (cd data/oxbuild_images ; tar xvf ../archives/oxbuild_images.tgz)
fi

if test ! -d data/oxbuild_gt
then
    wget -c -nc \
        http://www.robots.ox.ac.uk/~vgg/data/oxbuildings/gt_files_170407.tgz \
        -O data/archives/gt_files_170407.tgz
    mkdir -p data/oxbuild_gt
    (cd data/oxbuild_gt ; tar xvf ../archives/gt_files_170407.tgz)
fi

if test ! -d data/oxbuild_compute_ap.cpp
then
    wget -c -nc \
        http://www.robots.ox.ac.uk/~vgg/data/oxbuildings/compute_ap.cpp \
        -O data/archives/compute_ap.cpp
    (cd data ; cp -vf archives/compute_ap.cpp oxbuild_compute_ap.cpp)
fi

# Create a lite version
if test ! -d data/oxbuild_lite
then
    mkdir -p data/oxbuild_lite
    (
        ls -1 data/oxbuild_gt/*_{good,ok}.txt | sort | xargs cat
        ls -1 data/oxbuild_gt/*_junk.txt | sort | xargs cat | head -n 300
    ) | sort | uniq > data/oxbuild_lite.txt
    cat data/oxbuild_lite.txt | sed "s/^\(.*\)$/data\/oxbuild_images\/\1.jpg/" | xargs -I % cp -v % data/oxbuild_lite
fi
