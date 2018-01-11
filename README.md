Object instance recognition practical
=====================================

> A computer vision practical by the Oxford Visual Geometry group,
> authored by Andrea Vedaldi and Andrew Zisserman.

Start from `doc/instructions.html`.

Package contents
----------------

The practical consists of four exercies, organized in the following
files:

* `exercise1.m` -- Part I: Sparse features for matching specific
  objects in images
* `exercise2.m` -- Part II: Affine co-variant detectors
* `exercise3.m` -- Part III: Towards large scale retrieval
* `exercise4.m` -- Part IV: Large scale retrieval

The computer vision algorithms are implemented by
[VLFeat](http://www.vlfeat.org). This package contains the following
MATLAB functions:

* `findNeighbours.m`: Match features based on their descriptors.
* `geometricVerification.m`: Geometrically verify feature matches.
* `getFeatures.m`: Extract features from an image.
* `getHistogramFromImage.m`: Get a feature hisotgram from an image.
* `getHistogram.m`: Get a feature histogram from quantised features.
* `loadIndex.m`: Load an image datbase with an inverted index.
* `plotbox.m`: Plot boxes.
* `plotMatches.m`: Plot feature matches.
* `plotRetrievedImages.m`: Plot search results.
* `plotQueryImage.m`: Plot the query image for a set of search results.
* `search.m`: Search an image database.
* `setup.m`: Setup MALTAB to use the required libraries.

Appendix: Installing from scratch
---------------------------------

1. From Bash, run `./extras/bootstrap.sh`. This will download the
   Oxford 5k practical data.
2. From MATLAB, run `addpath extras ; preprocess`. This will download
   the VLFeat library (http://www.vlfeat.org) and compute a visual
   index for the Oxford 5k data.
3. From MATALB, run `addpath extras ; preprocess_paintings`. This will
   download and index a number of painting images from Wikipedia.
4. From Bash, run `make -f extra/Makefile pack`. This will pack the
   practical in archives that can be redestributed to students.

Changes
-------

* *2018a* - Updated VLFeat.
* *2015a* - Compatibility with MATLAB 2014b.
* *2014a* - Improves documentation and packing.
* *2013a* - Improves documentation, uses last version of VLFeat, bugfixes.
* *2012*  - Adds co-varaint feature detectors
* *2011*  - Initial edition

License
-------

    Copyright (c) 2011-13 Andrea Vedaldi and Andrew Zisserman

    Permission is hereby granted, free of charge, to any person
    obtaining a copy of this software and associated documentation
    files (the "Software"), to deal in the Software without
    restriction, including without limitation the rights to use, copy,
    modify, merge, publish, distribute, sublicense, and/or sell copies
    of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
    HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
    DEALINGS IN THE SOFTWARE.

