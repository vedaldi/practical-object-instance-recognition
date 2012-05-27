#!/bin/sh

mkdir -p data/archives

if test ! -e data/oxbuild_images
then
    wget -c -nc \
        http://www.robots.ox.ac.uk/~vgg/data/oxbuildings/oxbuild_images.tgz \
        -O data/archives/oxbuild_images.tgz
    mkdir -p data/oxbuild_images
    (cd data/oxbuild_images ; tar xvf ../archives/oxbuild_images.tgz)
fi

if test ! -e data/oxbuild_gt
then
    wget -c -nc \
        http://www.robots.ox.ac.uk/~vgg/data/oxbuildings/gt_files_170407.tgz \
        -O data/archives/gt_files_170407.tgz
    mkdir -p data/oxbuild_gt
    (cd data/oxbuild_gt ; tar xvf ../archives/gt_files_170407.tgz)
fi

if test ! -e data/oxbuild_compute_ap.cpp
then
    wget -c -nc \
        http://www.robots.ox.ac.uk/~vgg/data/oxbuildings/compute_ap.cpp \
        -O data/archives/compute_ap.cpp
    (cd data ; cp -vf archives/compute_ap.cpp oxbuild_compute_ap.cpp)
fi
