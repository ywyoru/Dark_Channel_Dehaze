% TopFile
% Haze removal using dark channel prior and fast guided filter
% - version 2.6 ,5/19/2016
%   
%   更新：fade输入变量需要规定在0 - 255内; 加入tolerance K 与 FADE 的判断
% - version 2.5 ,5/16/2016
% - 更新：去冗余代码
%        成庆荣参数调节: 加入Sky_Division; 调整tolerence K 为30
% - 参数选取：
%   - kenlRatio = .03，图片尺寸自适应选择最小值滤波窗口大小; 原来是0.01
%   - windowsz = floor(max([3, w*kenlRatio, h*kenlRatio])),最小窗口3*3;
%   - bsz = ，block的大小
%   - minAtomsLight = 240，可行区间［230，255］最小大气光，避免大气光取值过小; 与天空有关；
%   - omega = 0.95，可行区间[0,1]避免除雾过度;
%   - threshold =  ,帧间大气光值A连贯的阈值
%   - s = r/4,可行区间[r/4,r] ，快速引导滤波下采样率;
%   - testamount: 测试图片数量
%   
%   - [R,G,B] =[1.1,1.1,1.1],可行区间 [1,4],调整图像亮度
% - version 1.1 ,1/17/2015
%   - r = windowsz*halo,halo可行区间[12,16],增大halo，解决halo效应，但整体除雾程度降低

%% 0 PREPARATION
% Setting parameters and testing environment

clear
clc
close all

tic;                                                                       %counting time

%parameter setting 

kenlRatio = .03;                                                           %图片尺寸自适应选择最小值滤波窗口大小;
minAtomsLight = 240;                                                       %可行区间［230，255］最小大气光，避免大气光取值过小;
omega = 0.95;                                                              %可行区间[0,1]避免除雾过度;
halo = 10;                                                                 %fast guided filter:halo=[12,16],control halo effect
eps = 10^-6;                                                               %fast guided filter:epsilon
threshold = 0.019;
bsz = 31;

%% VIDEOREADER
VideoObj = VideoReader('cross.avi');                                       %where you put the video file
testamount = floor(VideoObj.Duration*VideoObj.FrameRate);

%% VIDEOWRITER
bszValue = num2str(bsz);
thValue = num2str(threshold);
WriterObj = VideoWriter('A_adaptive temporal avg','Uncompressed AVI');%VideoWriter(['cross_wsz',bszValue,' ','th',thValue],'Uncompressed AVI');
WriterObj.FrameRate = 24;
open(WriterObj)


for testnumber = 1: testamount
    
%{
%file path setting    
inputname = num2str(testnumber);                                           
filetype = 'png';                                                          %输入图片格式
outputtype = 'png';                                                        %输出图片格式
inputpath = 'D:\心韵\复旦\科研\去雾\视频去雾\test\cross\input_frame\';                         %测试输入文件夹路径 $path/
outputpath1 = 'D:\心韵\复旦\科研\去雾\视频去雾\test\cross\A_outputframe\';                    %测试输出文件夹路径 $path/outputfolder 
outputpath2 = 'D:\心韵\复旦\科研\去雾\视频去雾\test\output_frame\CLAHE\'; 
outputpath3 = 'D:\心韵\复旦\科研\去雾\视频去雾\test\output_frame\saturated\'; 
img=imread([inputpath,inputname,'.',filetype]);
%}
img = readFrame(VideoObj); %imread('D:\心韵\复旦\科研\去雾\视频去雾\test\cross\input_frame\628.png');


%% OBTAIN BASIC ATTRIBUTIONS
% 
img_gray = double(rgb2gray(img));
img_d    = double(img); 
sz=size(img);
img_height=sz(1);
img_width=sz(2);

%% DEPLOY DARK CHANNEL PRIOR

dc = zeros(img_height,img_width);

%find minimum value in (R,G,B) pixel-wise

for y=1:img_height

    for x=1:img_width

        dc(y,x) = min(img(y,x,:));

    end

end

%minimum filter window size estimation

windowsz = floor(max([3, img_width*kenlRatio, img_height*kenlRatio]));

%deploy minimum filter

dc_filtered = minfilt2(dc, [windowsz,windowsz]);

dc_filtered(img_height,img_width)=0;

%% ESTIMATE ATMOSPHERIC LIGHT 

%[A0,issky] = Sky_Division(img,minAtomsLight,dc_filtered); %我组A
[A,A_x,A_y] = Airlight_He(img,dc_filtered);  %He的A

Ak(testnumber,:) = [A(1),A(2),A(3)];
S(testnumber) = Block_A(img,A_x,A_y,bsz);

if testnumber~=1
    diff = abs(S(testnumber)- S(testnumber-1)); data{testnumber,1} = diff;
    if diff>threshold
        if testnumber<=30
            if testnumber ==2
                A = mean(Ak);
            else
                A = mean(Ak(1:testnumber-1,:));%A_con(testnumber-1,:);  
            end
        else
            A = mean(Ak(testnumber-30:testnumber-1,:));
        end
    else
        A = A_con(testnumber-1,:);
    end
end
A_con(testnumber,:) = [A(1),A(2),A(3)];
%}
%A = [160,150,146];
issky = 0;

%% OBTAIN FOG/HAZE DENSITY

density_input = FADE(img);
if issky == 1 
    K=50;
elseif density_input<=0.5
%    omega = 0.5; 
    K=50;
elseif (density_input>0.5) &&(density_input<=1)   
%    omega = 0.8; 
    K=40;
elseif (density_input>1) &&(density_input<=2)   
%    omega = 0.9; 
    K=30;
elseif density_input>2 
%    omega = 0.95; 
    K=20;
end
%% OBATAIN TRANSMISSION MAPS 

t = 1 - omega.*(dc_filtered/mean(A));

t_d=double(t);

J = zeros(img_height,img_width,3);


%% REFINE TRANSMISSION 

%use fast guided filter

r = halo*windowsz;                                                         % guided filter: local window radius
s = r/4;                                                                   % subsampling ratio: try r/4 to r

t_d = fastguidedfilter(img_gray/255, t_d, r, eps,s);

%% RECOVER SCENE RADIANCE

% 有了CLAHE 就不用了？


R=1.1;
G=1.1;
B=1.1;



t0=0.2;                                                                    %原来的方法，0.1


for M=1:1:img_height
    for N=1:1:img_width
    

            J(M,N,1) = ((img_d(M,N,1)-A(1))/min(max(K/abs(img_d(M,N,1)-A(1)),1)*max(t_d(M,N),t0),0.95)+A(1));

            J(M,N,2) = ((img_d(M,N,2)-A(2))/min(max(K/abs(img_d(M,N,2)-A(2)),1)*max(t_d(M,N),t0),0.95)+A(2));

            J(M,N,3) = ((img_d(M,N,3)-A(3))/min(max(K/abs(img_d(M,N,3)-A(3)),1)*max(t_d(M,N),t0),0.95)+A(3));
            


    end
end

%% LUMINANCE AND SATURATION CALIBRATION
nbit=8;
J=uint8(J);
%{
[Y1, Cb, Cr] = RGBtoYCbCr(J, nbit);
Y2 = CLAHE(Y1);
J_clahe=YCbCrtoRGB(Y2, Cb, Cr, nbit);
Sampmax=1.5;  % 饱和度增大倍率限制
Srate=1;  % 调整后饱和度的权重 0~1之间
Sfactor=1.1;    % 调整后饱和度再增强倍数
load ('HuevalY.mat');
[Cb2, Cr2] = saturation_adjustment_CbCr(Y1, Y2, Cb, Cr, Xi, Yi, Ki, Sampmax, Srate, Sfactor);   % 饱和度调整并生成调整后的Cb，Cr
J_saturated=YCbCrtoRGB(Y2, Cb2, Cr2, nbit);
density_input  = num2str(density_input);
density_output = num2str(FADE(J));
density_clahe  = num2str(FADE(J_clahe));
density_saturation = num2str(FADE(J_saturated));
%}

%{
imwrite(img,[outputpath,inputname,'_input.',density_input,'.',filetype]);
imwrite(J,[outputpath1,inputname,'_density.',outputtype]);
imwrite(J_clahe,[outputpath2,inputname,'_CLAHE.',outputtype]);
imwrite(J_saturated,[outputpath3,inputname,'_saturated.',outputtype]);
%}

imshow(J)

writeVideo(WriterObj,J);
end
close(WriterObj)
time = toc;


