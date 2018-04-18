function RGB2 = saturation1(RGB)

% Saturation Calibration
% - updated: 03/28/2016
% - credit to : Jin Xi Xiaoyi
% problems:
%  1. O(?) unknown
%  2. 怎么调参？
%可以设置参数t1,t2。t1为饱和度调整倍数（目前为3），t2为饱和度调整的中间点，取值范围为0到1（目前为0.5）.

HSV=rgb2hsv(RGB);
H=HSV(:,:,1);              
S=HSV(:,:,2);             
V=HSV(:,:,3);    

Dverylow=(S<=0.25);
Dlow=(S>0.25)&(S<=0.5);
Dhigh=(S>0.5)&(S<=0.75);
Dveryhigh=(S>0.75);

Nverylow=sum(sum(double(Dverylow)));
Nlow=sum(sum(double(Dlow)));
Nhigh=sum(sum(double(Dhigh)));
Nveryhigh=sum(sum(double(Dveryhigh)));
[m,n]=size(S);
N=m*n;
Uverylow=Nverylow/N;
Ulow=Nlow/N;
Uhigh=Nhigh/N;
Uveryhigh=Nveryhigh/N;
%参数可调
%t=[t1,t2];
b=-0.4*Uveryhigh-0.12*Uhigh+0.19*Ulow+0.83*Uverylow;
t1=3;
t2=0.5;
VS=1+t1*(b-0.125);
sc=t2/VS;
SS=S.*VS.*(S<=sc)+((S-1)*(1-t2)./((1-sc))+1).*(S>sc);
newimg = cat(3,H,SS,V);  
RGB2=hsv2rgb(newimg);
end
