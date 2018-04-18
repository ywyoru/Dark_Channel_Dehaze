function output = CLAHE(rgbimg)
hsvimg = rgb2hsv (rgbimg);
img_org_v=uint8(hsvimg(:,:,3)*2^8);
% VÕ®µ¿»•ŒÌ
img_ahe_v = adapthisteq(img_org_v,'NumTiles',[8 8],'ClipLimit',0.01,'NBins',256);
hsvimg1=cat(3, hsvimg(:,:,1),hsvimg(:,:,2) , double(img_ahe_v)/2^8);
rgbimg_HE=hsv2rgb(hsvimg1);
output=round(uint8(rgbimg_HE*256));

