%% Specify Profile for Uncompressed AVI and Write Video
%%
% Create an array containing data from the sample still image,
% |peppers.png|.

% Copyright 2015 The MathWorks, Inc.

A = imread('peppers.png');
%%
% Create a |VideoWriter| object for a new uncompressed AVI file for RGB24 video.
v = VideoWriter('newfile.avi','Uncompressed AVI');
%%
% Open the file for writing.
open(v)
%%
% Write the image in |A| to the video file.
writeVideo(v,A)
%%
% Close the file.
close(v)