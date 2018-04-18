clear all,close all,clc;

tic;%计算程序执行时间
%读入图像并显示
I_ori=imread('D:\心韵\复旦\科研\去雾\视频去雾\test\cross\input_frame\1.png');
I=double(I_ori)/255;%double 复杂度极高
I_hsv = rgb2hsv(I_ori);
v = I_hsv(:,:,3);
figure;
imshow(I_ori);
title('有雾图像');
kenlRatio = .01;
 %获取图像尺寸
[h,w,c]=size(I);

%计算图像的暗原色
dark_or=ones(h,w);
dark_ori=ones(h,w);
t=ones(h,w);
dehaze=zeros(h,w,c);
dark_extend=ones(h+14,w+14);
window=7;%扫描步长
%求出三个颜色通道的最小值
for i=1:h
    for j=1:w
        dark_extend(i+window,j+window)=min(I(i,j,:));
    end
end
%在方形区域内求出暗原色
for i=1+window:h+window
    for j=1+window:w+window
        A=dark_extend(i-window:i+window,j-window:j+window);
        dark_ori(i-window,j-window)=min(min(A));
    end
end
figure;
imshow(dark_ori);
title('暗原色图像');
G=rgb2gray(I);
s=0;
s=double(s);
for i=1:1:h
    for j=1:1:w
        s=s+G(i,j);
    end
end
average=s/(h*w);
[Gmag, Gdir] = imgradient(G,'prewitt');
B2=medfilt2(Gmag,[5,5]);  
subplot(2,4,8),imshow(B2);
%for a=1:1:h
%    for b=1:1:w
%        if B2(a,b)<0.01&&G(a,b)>1.5*average;
%            Q(a,b)=1;
%        else
%            Q(a,b)=0;
%        end
            
%    end
%end
%imshow(Q);
figure; imshowpair(Gmag, Gdir, 'montage');
[height,width] = size(Gmag);%获得图像的高度和宽度
%for s=1:1:height
%   for d=1:1:width
%        if Gmag(s,d)>0.05
%            H(s,d)=1;
            
%        else
%           H(s,d)=0;
%        end
%    end
%end

% imshow(H);
%imwrite(H,'d.bmp','bmp') ;
% for s=1:1:height
%    for d=1:1:width
%        if H(s,d)==0
%            dark_or(s,d)=0;
%        else
%            dark_or(s,d)=dark_ori(s,d);
%        end
%    end
% end
%imshow(dark_or);




 

%m=0; n=0 ;x=0;v=0;
%for j=1:1:h
%    for k=1:1:w
%        if dark_or(j,k)>0.75
            
%            m=m+1;
%        end
%        if dark_or(j,k)<0.75&&dark_or(j,k)>0.5
            
%            n=n+1;
%        end
%        if dark_or(j,k)<0.5&&dark_or(j,k)>0.25
            
%            x=x+1;
%        end
%        if dark_or(j,k)<0.25
            
%            v=v+1;
%        end
%    end
%end
%m=m/(w*h);n=n/(w*h);x=x/(w*h);v=v/(w*h);
%if (m+n)<0.002
%    disp(' 雾等级为 无雾');
%end
%if (m+n)<0.04&&(m+n)>0.002
%    disp(' 雾等级为 薄雾');
%end
%if (m+n)>0.04&&(m+n)<0.1
%    disp(' 雾等级为 较浓')
%end
%if (m+n)>0.1&&(m+n)<0.3
%    disp('雾等级为 浓雾');
%end
%if (m+n)>0.3
%     disp('雾等级为 特浓雾');
%end
%I1 = double(I_ori)/255;
p =double(G)/2;

r = floor(max([3, w*kenlRatio, h*kenlRatio]));
eps = 10^-6;

q = guidedfilter_color(I, p, r, eps);%建议不要用 color filter

figure();
imshow([I, repmat(p, [1, 1, 3]), repmat(q, [1, 1, 3])], [0, 1]);
[Gma, Gdi] = imgradient(q,'prewitt');     
imshow(Gma);
B2=medfilt2(Gma,[5,5]); %使用中值滤波
for a=1:1:h
    for b=1:1:w
        if B2(a,b)<0.01&&G(a,b)>1.3*average;
            Q(a,b)=1;
        else
            Q(a,b)=0;
        end
            
    end
end
%Q=medfilt2(Q,[6,6]);
imshow(Q);
%估测大气光
for t=1:h
    for y=1:w
        if Q(t,y)==0
            dark_or(t,y)=dark_ori(t,y);
        end
        if Q(t,y)==1
            dark_or(t,y)=0;
        end
            
    end
end
[dark_sort,index]=sort(dark_or(:),'ascend');
 dark_chose=dark_sort(1:round(0.001*w*h));
 for i=1:round(0.001*w*h)
     [x,y] = ind2sub([480,640],index(i)); %索引转换为下标
     I_chose(i)= v(x,y); %暗通道里最亮的那些pixel的intensity
     %I_chose(i)=I(index(i));
 end
 A_v = max(I_chose);
 [x0,y0] = find(v==A_v);
 A = A_v;
%A = max(I_chose);
%A=220/255;
w_1=0.9;
%t=ones(w,h);
t=1-w_1*q/A;
%t=max(min(t,1),0);
figure;
imshow(t);
title('原始透射率图');
%复原物体光线，得到无雾图像
t0=0.1;%透射因子下限t0
%t1=1;

for i=1:c
    for j=1:h
        for l=1:w
            if Q(j,l)==0;
            dehaze(j,l,i)=(I(j,l,i)-A*0.95)/max(t(j,l),t0)+A;
            else
                dehaze(j,l,i)=(I(j,l,i)-A)/0.8+A;
            end
        end
    end
end
figure;
imshow(dehaze);

title('去雾后图像');
toc%显示程序执行时间