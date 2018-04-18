data=double(zeros(30,2));
for i=1:5
fn=num2str(i);
fn1='_density';
fn2='_output_LS4';
ft='.png';
path1='D:\心韵\复旦\科研\去雾\视频去雾\test\cross\output_frame\density\';
path2='D:\心韵\复旦\科研\去雾\视频去雾\test\cross\output_frame\less saturated\';
output= [path1,fn,fn1,ft];          % read original foggy image
saturated = [path2,fn,fn2,ft];      % read clear image (enhanced image)
 img=imread(output);
 [a,b,c] = saturation1(img);
 imwrite(a,saturated);
data(i,1)=b;
data(i,2)=c;
end