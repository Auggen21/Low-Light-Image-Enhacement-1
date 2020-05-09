function [ imgout ] = pyr_reduce( img )
%PYR_REDUCE  Image pyramid reduction
%   B = PYR_REDUCE( A )  If A is M-by-N, then the size of B 
%	is ceil(M/2)-by-ceil(N/2). Support gray or rgb image.
%	B will be transformed to double class.

% 
kernelWidth = 5; % default
cw = .375; % kernel centre weight, 
ker1d = [.25-cw/2 .25 cw .25 .25-cw/2];
kernel = kron(ker1d,ker1d');

% sig=1.082;
% kernel = fspecial('gaussian',[5,5],sig);

img = im2double(img);
sz = size(img);
imgout = [];

for p = 1:size(img,3)
	img1 = img(:,:,p);
	imgFiltered = imfilter(img1,kernel,'replicate','same');
	imgout(:,:,p) = imgFiltered(1:2:sz(1),1:2:sz(2));
end

end