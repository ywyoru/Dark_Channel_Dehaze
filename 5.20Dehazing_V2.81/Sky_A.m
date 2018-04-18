function G = Sky_A(I,dark_ori)%原图像和暗通道图像
G=rgb2gray(I);
s=0;d=0;
s=double(s);
d=double(d);
[h,w]=size(dark_ori);
for i=1:1:h
    for j=1:1:w
        s=s+dark_ori(i,j);
        d=d+G(i,j);
    end
end
average=s/(h*w);%求取暗通道的均值
ad=max(max(G));
ans=max(max(dark_ori));
Gma = imgradient(G,'Prewitt'); 
B2=medfilt2(Gma,[5,5]); 
for a=1:1:h
    for b=1:1:w
        if B2(a,b)<0.01&&(dark_ori(a,b)>1.3*average)%利用梯度信息和暗通道亮度图像进行判断
            Q(a,b)=1;
        else
            Q(a,b)=0;
        end
            
    end
end
for i=1:1:h
    for j=1:1:w
        if Q(i,j)==1;
        else
            G(i,j)=0;
        end
    end
end


%[x y]=find(I=max(max(I)));
