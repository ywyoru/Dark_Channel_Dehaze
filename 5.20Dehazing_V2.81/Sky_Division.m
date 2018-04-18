function [A,issky] = Sky_Division(img,minAtomsLight,dc_filtered)%
%%
%test of sky_division
%img = imread('D:\心韵\复旦\科研\去雾\视频去雾\test\cross\input_frame\1.png');
% 
% 


%%

%img = im2double(img);
img1=double(im2double(img));
img_gray2=rgb2gray(img);
img_gray1=img_gray2;
[h,w]=size(img_gray2);
agv=mean(mean(double(img_gray2)));
Gma = imgradient(img_gray2,'Prewitt'); 
B2= medfilt2(Gma,[5,5]);
agv1=mean(mean(B2));


for a=1:1:h
    for b=1:1:w
        if B2(a,b)<agv1&&(img_gray2(a,b)>1.3*agv)           
            H(a,b)=1;
        else
            H(a,b)=0;
        end  
    end
end
[L,num]=bwlabel(H,4);
for i=1:1:h
    for j=1:1:w
        if L(i,j)==1;
        else
            L(i,j)=0;
        end
    end
end
H0=1-L(:,:);
[H1,num]=bwlabel(H0,4);
%imLabel = bwlabel(imBw);                %对各连通域进行标记
stats = regionprops(H1,'Area');    %求各连通域的大小
area = cat(1,stats.Area);
index = find(area == max(area));        %求最大连通域的索引
H2 = ismember(H1,index);
L1=1-H2(:,:);
W=sum(sum(L1));
if W<0.05*h*w;
    L1(:,:)=0;
end
Q=L1;
for i=1:1:h
    for j=1:1:w
        if Q(i,j)==1;
        else
            img_gray1(i,j)=0;
        end
    end
end
[x0,y0]=find(img_gray1==max(max(img_gray1)));%得到亮度最大值的坐标
if img_gray1(x0(1),y0(1))==0 
    %我组求A方法
    A0 = min([minAtomsLight, max(max(dc_filtered))]);
    A=[A0, A0, A0];
    issky=0;
 
else
   
A=[img1(x0(1),y0(1),1),img1(x0(1),y0(1),2),img1(x0(1),y0(1),3)]*255;
issky=1;

end 

end



