% RGB转换为YUV，同时查表计算色相Hue，饱和度Sat
% rgbImg - 输入 RGB格式图像 0-255 8bit
% HueLUT - 输入 色度查找表 0-359度 9bit
% SatLUT - 输入 饱和度查找表 0-180 8bit
% Y, Cb, Cr - 输出 0-255 8bit
% Hue - 色度输出 0-359度 9bit
% Sat - 饱和度输出 0-180 8bit
function [Y, Cb, Cr] = RGBtoYCbCr(rgbImg, nbit)
    
    R=rgbImg(:,:,1);
    G=rgbImg(:,:,2);
    B=rgbImg(:,:,3);
    [row, column, dim]=size(rgbImg);    % row-图像行数 column-列数 dim-维度|比如RGB图像dim=3
    
    R=double(R);
    G=double(G);
    B=double(B);
    
%     Y=round((round(2^nbit*0.299)*R+round(2^nbit*0.587)*G+round(2^nbit*0.114)*B)/2^nbit);    % round-四舍五入取整
%     Cb=round((-round(2^nbit*0.1687)*R-round(2^nbit*0.3313)*G+round(2^nbit*0.5)*B)/2^nbit)+128;
%     Cr=round((round(2^nbit*0.5)*R-round(2^nbit*0.4187)*G-round(2^nbit*0.0813)*B)/2^nbit)+128;
    
    Y=round((77*R+150*G+29*B)/2^nbit);    % round-四舍五入取整
    Cb=round((-43*R-85*G+128*B)/2^nbit)+128;
    Cr=round((128*R-107*G-21*B)/2^nbit)+128;
    
    Y=uint8(Y);     % 上述四舍五入取整做加法可能会使Y/Cb/Cr大于255，uint8改变数据格式相当于将大于255的数取255，小于0的数取0
    Cb=uint8(Cb);
    Cr=uint8(Cr);
    
end
