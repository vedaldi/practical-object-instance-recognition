function preprocess()
% PREPROCESS  Build vocabulary and compute histograms
%   PREPROCESS() download an image dataset into 'data/', VLFeat into
%   'vlfeat/', and precompute the histograms for the dataset.

% --------------------------------------------------------------------
%                                                      Download VLFeat
% --------------------------------------------------------------------

if ~exist('vlfeat', 'dir')
  from = 'http://www.vlfeat.org/download/vlfeat-0.9.15-bin.tar.gz' ;
  fprintf('Downloading vlfeat from %s\n', from) ;
  untar(from, 'data') ;
  movefile('data/vlfeat-0.9.15', 'vlfeat') ;
end

% --------------------------------------------------------------------
%                                                      Setup Oxford 5k
% --------------------------------------------------------------------

lite = true ;
imdb.dir = 'data/oxbuild_images' ;
imdb.numWords = 100 ;
names = dir(fullfile(imdb.dir, '*.jpg')) ;
imdb.images.name = {names.name} ;

if lite, imdb.images.name = imdb.images.name(1:10) ; end
imdb.images.id = 1:numel(imdb.images.name) ;

function i = toindex(x)
  [~,i] = ismember(x,imdb.images.name) ;
end

names = dir('data/oxbuild_gt/*_query.txt') ;
names = {names.name} ;
for i = 1:numel(names)
  [imageName,x0,y0,y1,x1] = textread(fullfile('data/oxbuild_gt/', names{i}), '%s %f %f %f %f') ;
  name = names{i} ;
  name = name(1:end-10) ;
  query(i).name = name ;
  query(i).imageName = imageName ;
  query(i).imageId = toindex(imageName) ;
  query(i).box = [x0;y0;x1;y1] ;
  query(i).good = toindex(textread(fullfile('data/oxbuild_gt/', sprintf('%s_good.txt',name)), '%s')) ;
  query(i).ok = toindex(textread(fullfile('data/oxbuild_gt/', sprintf('%s_ok.txt',name)), '%s')) ;
  query(i).junk = toindex(textread(fullfile('data/oxbuild_gt/', sprintf('%s_junk.txt',name)), '%s')) ;
end
save('data/oxbuild_query.mat', 'query') ;

% --------------------------------------------------------------------
%                                    Compute a large visual vocabulary
% --------------------------------------------------------------------

descrs = cell(1,numel(imdb.images.name)) ;
for i = 1:numel(imdb.images.name)
  [~,descrs{i}] = extractFeatures(imread(fullfile(imdb.dir, imdb.images.name{i})),false,false) ;
  randn('state',i) ;
  descrs{i} = vl_colsubset(descrs{i},10) ;
end

descrs = cat(2,descrs{:}) ;
[imdb.vocab, imdb.kdtree] = annkmeans(descrs, imdb.numWords, 'numtrees', 1, 'verbose', true) ;

% --------------------------------------------------------------------
%                                                 Compute the features
% --------------------------------------------------------------------

clear frames descrs ;
for i = 1:numel(imdb.images.name)
  [frames{i},descrs{i}] = extractFeatures(imread(fullfile(imdb.dir, imdb.images.name{i})),false,false) ;
  descrs{i} = vl_kdtreequery(imdb.kdtree, imdb.vocab, descrs{i}) ;
end

imdb.images.frames = frames ;
imdb.images.descrs = descrs ;

% --------------------------------------------------------------------
%                            Compute tf-idf weights and inverted index
% --------------------------------------------------------------------

for i = 1:numel(imdb.images.id)
  indexes{i} = i * ones(1,numel(imdb.images.descrs{i})) ;
end

imdb.index = sparse(double([imdb.images.descrs{:}]), ...
                    [indexes{:}], ...
                    1, ...
                    imdb.numWords, ...
                    numel(imdb.images.id)) ;

% idf weighting
imdb.idf = log(numel(imdb.images.id)) - log(sum(imdb.index > 0, 2)) ;
imdb.index = spdiags(imdb.idf, 0, imdb.numWords, imdb.numWords) * imdb.index ;

% sqrt and normalisation
mass = full(sum(imdb.index, 1))' ;
n = numel(imdb.images.id) ;
imdb.index = sqrt(imdb.index * spdiags(1./mass, 0, n, n)) ;

save('data/oxbuild_imdb.mat', '-STRUCT', 'imdb') ;
return

% --------------------------------------------------------------------
%                                     Compute a visual word vocabulary
% --------------------------------------------------------------------

setup ;

% from training images
names{1} = textread('data/background_train.txt','%s') ;
names{2} = textread('data/aeroplane_train.txt','%s') ;
names{3} = textread('data/motorbike_train.txt','%s') ;
names{4} = textread('data/person_train.txt','%s') ;
names{5} = textread('data/car_train.txt','%s') ;
names{6} = textread('data/horse_train.txt','%s') ;
names = cat(1,names{:})' ;
if ~exist('data/vocabulary.mat')
  vocabulary = computeVocabularyFromImageList(vl_colsubset(names,200,'uniform')) ;
  save('data/vocabulary.mat', '-STRUCT', 'vocabulary') ;
else
  vocabulary = load('data/vocabulary.mat') ;
end

% --------------------------------------------------------------------
%                                                   Compute histograms
% --------------------------------------------------------------------

for subset = {'background_train', ...
              'background_val', ...
              'aeroplane_train', ...
              'aeroplane_val', ...
              'motorbike_train', ...
              'motorbike_val', ...
              'person_train', ...
              'person_val', ...
              'car_train', ...
              'car_val', ...
              'horse_train', ...
              'horse_val'}
  fprintf('Processing %s\n', char(subset)) ;
  names = textread(fullfile('data', [char(subset) '.txt']), '%s') ;
  histograms = computeHistogramsFromImageList(vocabulary, names) ;
  save(fullfile('data',[char(subset) '_hist.mat']), 'names', 'histograms') ;
end
end
