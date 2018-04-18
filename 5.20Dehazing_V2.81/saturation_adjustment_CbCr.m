% 根据亮度变化计算饱和度调整系数 （HSY格式图像模型） 
% Y1 输入 原始亮度图Y通道
% Y2 输入 直方图均衡后的亮度图Y通道
% Xi, Yi, Ki, 输入 Hue0-359度三角形对应的valY分段拟合曲线顶点坐标及斜率
% Sampmax  %饱和度增大倍率限制
% Srate  %调整后饱和度的权重 0~1之间
% Sfactor   %调整后饱和度再增强倍数
% Cb2 输出 根据亮度变化调整饱和度后的Cb2
% Cr2 输出 根据亮度变化调整饱和度后的Cr2
function [Cb2, Cr2] = saturation_adjustment_CbCr(Y1, Y2, Cb1, Cr1, Xi, Yi, Ki, Sampmax, Srate, Sfactor)
    
    [row, column]=size(Y1);
    Y1=double(Y1);
    Y2=double(Y2);
    Cb1=double(Cb1);
    Cr1=double(Cr1);
    Cb2=zeros(row,column);
    Cr2=zeros(row,column);
    Ksat=zeros(row,column);
    
    Hue=zeros(256,256);
    for i=1:row
        for j=1:column
            % 曲线拟合 arctan（y/x）=y/(y+x)*90
            if Cb1(i,j)==128 && Cr1(i,j)==128
                Hue(i,j)=0;
            elseif Cb1(i,j)>=128 && Cr1(i,j)>=128
                    Hue(i,j)=floor((Cr1(i,j)-128)/(Cr1(i,j)+Cb1(i,j)-256)*90);
            elseif Cb1(i,j)>=128 && Cr1(i,j)<128
                Hue(i,j)=-floor((128-Cr1(i,j))/(-Cr1(i,j)+Cb1(i,j))*90)+360;
            elseif Cb1(i,j)<128 && Cr1(i,j)>=128
                Hue(i,j)=-floor((Cr1(i,j)-128)/(Cr1(i,j)-Cb1(i,j))*90)+180;
            else %Cb1(i,j)<128 && Cr1(i,j)<128
                Hue(i,j)=floor((128-Cr1(i,j))/(256-Cr1(i,j)-Cb1(i,j))*90)+180;
            end
            if Hue(i,j)==360
                Hue(i,j)=0;
            end
            
            % Hue0-359度三角形对应的valY分线段拟合
            for m=1:length(Ki)
                if Hue(i,j)<Xi(m+1) && Hue(i,j)>=Xi(m)
                    y=round(Ki(m)*(Hue(i,j)-Xi(m)))+Yi(m);
                end
            end
            
            if Y1(i,j)==0||Y1(i,j)==255
                Ksat(i,j)=1;     % 原来亮度是0或者255，则饱和度保持不变，
                                     % 否则根据Y1 Y2与对应三角形顶点坐标y的大小关系 分段计算 具体计算公式如下（参考文档说明）
            elseif Y1(i,j)<=y && Y2(i,j)<=y
                Ksat(i,j)=Y2(i,j)/Y1(i,j);
            elseif Y1(i,j)<=y && Y2(i,j)>y
                Ksat(i,j)=((255-Y2(i,j))*y)/((255-y)*Y1(i,j));
            elseif Y1(i,j)>y && Y2(i,j)<=y
                Ksat(i,j)=((255-y)*Y2(i,j))/((255-Y1(i,j))*y);
            else 
                Ksat(i,j)=(255-Y2(i,j))/(255-Y1(i,j));
            end
            
%             S2(i,j)=min([S1(i,j)*Sampmax,S2(i,j)]);     % 限制饱和度变化不能超过原来饱和度数值的两倍
            if Ksat(i,j)>Sampmax
                Ksat(i,j)=Sampmax;
            end
%             S2(i,j)=S1(i,j)*(1-Srate)+S2(i,j)*Srate;    % 设置权重值Srate 0-1之间 变化后的饱和度可在原饱和度S1和上面计算的S2之间权衡 
            Ksat(i,j)=1-Srate+Ksat(i,j)*Srate;
%             S2(i,j)=Sfactor*S2(i,j);    % 适当的增强调整后的饱和度S2，增强倍数为Sfactor， 一般取1-1.5之间
            Ksat(i,j)=Sfactor*Ksat(i,j); 
%             S2(i,j)=max(S1(i,j),S2(i,j));   % 如果某像素点处调整后的饱和度降低了，即S2<S1,则沿用原先的饱和度
            if Ksat(i,j)<1
                Ksat(i,j)=1;
            end
        end
    end
    
    Cb2=uint8(Ksat.*(Cb1-128)+128);
    Cr2=uint8(Ksat.*(Cr1-128)+128);

end
