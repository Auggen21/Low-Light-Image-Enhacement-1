% clc
clear all
close all
im=imread('test images\8.jpg'); %test 3,4,5,8,9
figure,
imshow(im), title('Original Image')
im=double(im);
R=im(:,:,1);
G=im(:,:,2);
B=im(:,:,3);
[row,col,dim]=size(im);
for i=1:row
    for j=1:col
        first=R(i,j);
        second=G(i,j);
        third=B(i,j);
        L(i,j)=max(first,max(second,third));
    end
end
figure,
imshow(L), title('Image Lightness')

%illumination estimation
r=7;
n=0;
SE = strel('disk',r,n);
Ilm = imclose(L,SE);
Ilm=Ilm/255;
figure,
imshow(Ilm), title('Morphologically Closing Operation')

guidedimg=rgb2hsv(im);
g=guidedimg(:,:,3);
I = imguidedfilter(Ilm,g);

figure 
imshow(I),title('Iluminance')

%reflectance
rf1=R./I;
rf2=G./I;
rf3=B./I;


rel(:,:,1)=rf1;
rel(:,:,2)=rf2;
rel(:,:,3)=rf3;
figure;
imshow(rel,[]), title('Reflectance')

%inputs
I1=I;
Imean=mean(I(:));
lambda=10+(1-Imean)/Imean;

I2=2/pi*atan(lambda*I);

% mm=5;
% nn=5;
%I3=blkproc(I,[mm nn], @histeq);
I3 = adapthisteq(I);
%weights

alpha=2;
phi=250;
[imhue imsat imlum]=rgb2hsv(im);

Wb1=exp(-((I1-0.5).^2)/(2*.25*.25));
Wb2=exp(-((I2-0.5).^2)/(2*.25*.25));
Wb3=exp(-((I3-0.5).^2)/(2*.25*.25));

Wc1=I1.*(1+cos(alpha*imhue+phi).*imsat);
Wc2=I2.*(1+cos(alpha*imhue+phi).*imsat);
Wc3=I3.*(1+cos(alpha*imhue+phi).*imsat);

W1=Wb1.*Wc1;
W2=Wb2.*Wc2;
W3=Wb3.*Wc3;

W1=W1./(W1+W2+W3);
W2=W2./(W1+W2+W3);
W3=W3./(W1+W2+W3);

figure,
subplot(3,4,1),imshow(I1,[])
subplot(3,4,2),imshow(I2,[])
subplot(3,4,3),imshow(I3,[])
subplot(3,4,4),imshow(Wb1,[])
subplot(3,4,5),imshow(Wb2,[])
subplot(3,4,6),imshow(Wb3,[])
subplot(3,4,7),imshow(Wc1,[])
subplot(3,4,8),imshow(Wc2,[])
subplot(3,4,9),imshow(Wc3,[])
subplot(3,4,10),imshow(W1,[])
subplot(3,4,11),imshow(W2,[])
subplot(3,4,12),imshow(W3,[])

Ifinal1=I1.*W1+I2.*W2+I3.*W3;
figure;
imshow(Ifinal1);title('Adjusted Illuminace ')

%generate pyramid

level=6;
Lap_pyr_image1=genPyr(I1,'laplace',level);
Gauss_pyr_weight1=genPyr(W1,'gauss',level);

Lap_pyr_image2=genPyr(I2,'laplace',level);
Gauss_pyr_weight2=genPyr(W2,'gauss',level);
     
Lap_pyr_image3=genPyr(I3,'laplace',level);
Gauss_pyr_weight3=genPyr(W3,'gauss',level);  


%Upsampling
for j=1:level
        Lap_pyr_image1{j}=imresize(Lap_pyr_image1{j},[row,col]);
        Gauss_pyr_weight1{j}=imresize(Gauss_pyr_weight1{j},[row,col]);
        
         Lap_pyr_image2{j}=imresize(Lap_pyr_image2{j},[row,col]);
        Gauss_pyr_weight2{j}=imresize(Gauss_pyr_weight2{j},[row,col]);
        
         Lap_pyr_image3{j}=imresize(Lap_pyr_image3{j},[row,col]);
        Gauss_pyr_weight3{j}=imresize(Gauss_pyr_weight3{j},[row,col]);
        
end
Ifinal2=0;
for j=1:level
    Ifinal2=Ifinal2 + Lap_pyr_image1{j}.*Gauss_pyr_weight1{j} + Lap_pyr_image2{j}.*Gauss_pyr_weight2{j}  + Lap_pyr_image3{j}.*Gauss_pyr_weight3{j};
end

figure;
imshow(Ifinal2), title('Adjusted Illuminance with pyramid')
% Ifinal2=(2^level-1)*Ifinal2;
enhanced1=rf1.*Ifinal2;
enhanced2=rf2.*Ifinal2;
enhanced3=rf3.*Ifinal2;

% enhanced1=255*enhanced1/max(enhanced1(:));
% enhanced2=255*enhanced2/max(enhanced2(:));
% enhanced3=255*enhanced3/max(enhanced3(:));

enhanced_color(:,:,1)=enhanced1;
enhanced_color(:,:,2)=enhanced2;
enhanced_color(:,:,3)=enhanced3;

figure;
imshow(uint8(enhanced_color),[]), title('Enhanced Image')

piqe(uint8(enhanced_color))