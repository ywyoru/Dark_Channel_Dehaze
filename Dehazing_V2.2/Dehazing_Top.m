%TopFile
%Haze removal using dark channel prior and fast guided filter
% - version 2.2 ,3/30/2016
% - 参数选取：
%   - kenlRatio = .01，图片尺寸自适应选择最小值滤波窗口大小;
%   - windowsz = floor(max([3, w*kenlRatio, h*kenlRatio])),最小窗口3*3;
%   - minAtomsLight = 240，可行区间［230，255］最小大气光，避免大气光取值过小;
%   - omega = 0.95，可行区间[0,1]避免除雾过度;
%   - s = r/4,可行区间[r/4,r] ，快速引导滤波下采样率;
%   
%   - [R,G,B] =[1.2,1.2,1.2],可行区间 [1,4],调整图像亮度
% - version 1.1 ,1/17/2015
%   - r = windowsz*halo,halo可行区间[12,16],增大halo，解决halo效应，但整体除雾程度降低
% 
%
%---------------------------
clear

clc

close all

tic%counting time

kenlRatio = .01;%图片尺寸自适应选择最小值滤波窗口大小;
minAtomsLight = 240;%可行区间［230，255］最小大气光，避免大气光取值过小;
omega = 0.95;%可行区间[0,1]避免除雾过度;

testamount = 32;%选择一次测试的图片量

%将图库所有文件统一命名1_input.png 格式
%跑一次可以仿真多张

for testnumber = 1:1:testamount 
    
inputname = num2str(testnumber);
%输入图片格式
filetype = 'png';
%输出图片格式
outputtype = 'png';
%测试输入文件夹路径
inputpath ='C:\Users\ZhangChendi\Desktop\去雾效果图\';
%测试输出文件夹路径
outputpath = 'C:\Users\ZhangChendi\Desktop\去雾效果图\330\';
img=imread([inputpath,inputname,'_input.',filetype]);

%figure,imshow(uint8(img)), title('1 Before Dehazing');

%Entropy of Image  图像熵
img_gray = rgb2gray(img);
p = imhist(img_gray(:));
p(p==0) = [];
p = p./numel(img_gray);
Air_H = -sum(p.*log2(p));

%Average Gray Value
agv=mean2(img_gray);

sz=size(img);

w=sz(2);

h=sz(1);


%count pixels with value under 50



%judge whether haze-free

%if(percent>0.1)  
%    error('This image does not need a haze removal.');   
%end


%obtain dark channel

dc = zeros(h,w);

for y=1:h

    for x=1:w

        dc(y,x) = min(img(y,x,:));

    end

end

%window size estimation

windowsz = floor(max([3, w*kenlRatio, h*kenlRatio]));

%using minimum filter

dc_filtered = minfilt2(dc, [windowsz,windowsz]);
dc_filtered(h,w)=0;
%estimate atmospheric light 
[COUNT, a]= imhist(dc_filtered);
under_50=0;  
for i=0:50  
    under_50=under_50+COUNT(a==i);  
end  
total=size(img,1)*size(img,2);  
percent=under_50/total ;


%adaptively decide atmospheric light
%haven't finished yet :(
%if (agv>133) && (Air_H>7.1) 
%         a_ratio = 1;
%elseif ((agv>133) && (Air_H<7.1)) || ((agv<133) && (Air_H>7.1)) 
%         a_ratio=1.1;
%elseif agv>131 && Air_H>6.5
%         a_ratio = 0.70;
%else a_ratio = 0.65;
%end

%A = a_ratio.*max(max(dc_filtered));



A = min([minAtomsLight, max(max(dc_filtered))]);

t = 1 - omega.*(dc_filtered/A);

t_d=double(t);

%sum(sum(t_d))/(h*w)


J = zeros(h,w,3);

img_d = double(img);

%using fast guided filter,halo=[12,16],control halo effect

halo = 10;

r = halo*windowsz;% guided filter: local window radius

% * one feasible adaptive way: r=min(0.1*h,0.1*w);

% r=min(h*0.1,w*0.1);

eps = 10^-6;%guided filter:regularization parameter
s = r/4;%subsampling ratio: try r/4 to r

filtered = fastguidedfilter(double(rgb2gray(img))/255, t_d, r, eps,s);

t_d = filtered;%??? 为什么 filtered 要写两遍？


%R,G,B = [1,4],enhance luminance 

R=1.1;
G=1.1;
B=1.1;

J(:,:,1) = R*((img_d(:,:,1) - (1-t_d)*A)./t_d);

J(:,:,2) = G*((img_d(:,:,2) - (1-t_d)*A)./t_d);

J(:,:,3) = B*((img_d(:,:,3) - (1-t_d)*A)./t_d);


%J_B = (B*((img_d(:,:,3) - (1-t_d)*A)./t_d));

%J_B_contrast = histeq(J_B);

%J(:,:,3) = J_B_contrast;


time=toc
output = CLAHE(uint8(J));
imwrite(uint8(img),[outputpath,inputname,'_input.',filetype]);
imwrite(uint8(J),[outputpath,inputname,'_output.',outputtype]);
imwrite(output,[outputpath,inputname,'_output_CLAHE.',outputtype]);

%imwrite(uint8(J),'/Users/ClaireHe/Documents/MATLAB/defog/defogoutput/'outname'.png');


%saturation calibration

J_saturated = saturation1(output);
imwrite(uint8((J_saturated)*2^8),[outputpath,inputname,'_saturated.',outputtype]);

%figure,imshow(uint8(J)), title('2 After Dehazing');
%figure,imshow(uint8(J_saturated)), title('3 After Saturation');

end



