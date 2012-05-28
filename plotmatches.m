function plotmatches(im1,im2,f1,f2,matches)
% PLOTMATCHES

dh1 = max(size(im2,1)-size(im1,1),0) ;
dh2 = max(size(im1,1)-size(im2,1),0) ;

cla ;
imagesc([padarray(im1,dh1,'post') padarray(im2,dh2,'post')]) ;
axis image off ;

o = size(im1,2) ;
i1 = find(matches) ;
i2 = matches(i1) ;

hold on ;
f2p = f2 ;
f2p(1,:) = f2p(1,:) + o ;
vl_plotframe(f1(:,i1)) ;
vl_plotframe(f2p(:,i2)) ;
line([f1(1,i1);f2p(1,i2)], [f1(2,i1);f2p(2,i2)]) ;


