function matches = matchWords(a, b)
% MATCHWORDS Matches sets of visual words
%   MATCHES = MATCHWORDS(A, B) finds occurences in B of each element
%   of A. Each matched pair is stored as a row of the 2xN matrix A,
%   such that A(MATCHES(1,i)) == B(MATCHES(2,i)).
%
%   By default, if an element of A matches to more than one element of
%   B, only one of the possible matches is generated.

% Author: Andrea Vedaldi

a = single(a) ;
b = single(b) ;

% Exclude words which are too common
a(count(a) > 5) = NaN ;
b(count(b) > 5) = NaN ;

% Now establish matches between the remaining features
maxNumMatches = 1 ;

for i=1:maxNumMatches
  [ok, m] = ismember(a, b) ;
  matches{i} = [find(ok) ; m(ok)] ;
  b(m(ok)) = NaN ;
end
matches = cat(2, matches{:}) ;

function c = count(a)
[values,~,map] = unique(a) ;
c = hist(a, values) ;
c = c(map) ;
