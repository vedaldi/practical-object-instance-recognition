function matches = matchWords(a, b)
% MATCHWORDS Matches sets of visual words
%   MATCHES = MATCHWORDS(A, B) finds occurences in B of each element
%   of A. Each matched pair is stored as a row of the 2xN matrix A,
%   such that A(MATCHES(1,i)) == B(MATCHES(2,i)).

% Author: Andrea Vedaldli

for i=1:4
  [ok, m] = ismember(a, b) ;
  matches{i} = [find(ok) ; m(ok)] ;
  b(m(ok)) = NaN ;
end
matches = cat(2, matches{:}) ;
