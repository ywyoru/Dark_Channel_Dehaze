video = VideoReader('cross.avi');                                          %where you put the video file
testamount = floor(video.Duration*video.FrameRate);
for i = 1: testamount
    image_name=strcat('D:\心韵\复旦\科研\去雾\视频去雾\test\riverside\input_frame\',num2str(i),'.png');
    frame = readFrame(video);
    imwrite(frame,image_name,'png');
    frame=[];
end
