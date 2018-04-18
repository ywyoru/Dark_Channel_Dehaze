% YUV转换回RGB
% Y, Cb, Cr - 输入 0-255 8bit
% rgbImg - 输出 RGB格式图像 0-255 8bit
function rgbImg = YCbCrtoRGB(Y, Cb, Cr, nbit)
    
    Y=double(Y);
    Cb=double(Cb);
    Cr=double(Cr);
    
%     R=Y+round(round(2^nbit*1.4075)*(Cr-128)/2^nbit);
%     G=Y+round((-round(2^nbit*0.3455)*(Cb-128)-round(2^nbit*0.7169)*(Cr-128))/2^nbit);
%     B=Y+round(round(2^nbit*1.779)*(Cb-128)/2^nbit);
    
    R=Y+round(360*(Cr-128)/2^nbit);
    G=Y+round((-88*(Cb-128)-184*(Cr-128))/2^nbit);
    B=Y+round(455*(Cb-128)/2^nbit);
    
    R=uint8(R);
    G=uint8(G);
    B=uint8(B);
    
    rgbImg(:,:,1)=R;
    rgbImg(:,:,2)=G;
    rgbImg(:,:,3)=B;
    
end


