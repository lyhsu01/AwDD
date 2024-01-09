[WM]=imread('WM.bmp');
[Y]=imread('198054.jpg');
[Y]=imread('32lena.ppm');
% [Y]=imread('06baboon.ppm');
% [Y]=imread('AI1.jpg');

Key1=0.369;
Key2=33; 
Delta=18.78;
selidxs=[18	10	17	2 19 9 11 3];
Y=imresize(Y,[floor(size(Y,1)/8)*8,floor(size(Y,2)/8)*8]);
WM=uint8(imresize(WM,[max(size(Y,1,2),max(size(Y,1,2)))]/8));

[Yb,WM]=AwDDEmbed(Y,WM,Key1,Key2,Delta,selidxs);
figure(1);imshow(Yb);title('Watermarked image') 
figure(2);imshow(WM*255);title('Embedded watermark image') 
imwrite(Yb,'Watermarked.png'); 
imwrite(WM*255,'EmbeddedWatermark.png'); 
double_Yb=double(Yb);
double_Y =double(Y );    
SE=(double_Yb-double_Y).^2;
MSE=mean(SE(:));
PSNR=10*log10(255*255/MSE);
mSSIM=ssim(double_Yb, double_Y);

% Key3='01d02f4d1emsh7c27856ee3b5db3p181873jsn0789b5ecd180';
% Yb=Deepfake(Yb,Key3);% 
imwrite(Yb,'a.jp2','CompressionRatio',5); 
Yb=imread('a.jp2');
figure(3);imshow(Yb);title('deepfake watermark image') 

[Ym,WMb]=AwDDExtract(Yb,Key1,Key2,Delta,selidxs); 
figure(4);imshow(Ym);title('Masked watermarked image') 
figure(5);imshow(WMb*255);title('Extracted watermark image') 
imwrite(Ym,'MaskedWatermarked.png'); 
imwrite(WMb*255,'ExtractedWatermark.png'); 
error_rate=sum(sum(WM~=WMb))/numel(WM);
NCC=sum(sum(WM.*WMb))/sqrt(sum(sum(WM.*WM))*sum(sum(WMb.*WMb)));


fprintf('MSE=%5.3f; PSNR=%5.3fdB; mSSIM=%5.3f dB; error_rate=%5.3f%%; NC=%5.3f\n',MSE,PSNR,mSSIM,error_rate*100,NCC);
