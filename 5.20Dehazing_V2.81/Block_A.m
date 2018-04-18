function S = Block_A( img, row, col, wsz)
%[row,col]大气光值A坐标，wsz是A附近block的大小
[h,w,c] = size(img);
hsv = rgb2hsv(img);
grayimg = hsv(:, :, 3);
B = zeros(wsz,wsz);
for i =1 : wsz
    for j =1: wsz
        if (row-floor(wsz/2)-1+i)>0 && (row-floor(wsz/2)-1+i)<=h && (col-floor(wsz/2)-1+j)>0 && (col-floor(wsz/2)-1+j)<=w
            B(i,j) = grayimg(row-floor(wsz/2)-1+i, col-floor(wsz/2)-1+j); %v值存入B(i,j)
        end
    end
end
B(find(B==0))=[];
S = abs(mean(B)-std(B));        
end

