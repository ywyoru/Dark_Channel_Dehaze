% FADE example

clear all; close all; clc; 

tic

inputpath = 'D:\心韵\复旦\科研\气象视觉\Fog Image Gallery\';
density_data = [];
testnumber = 10;
%for testnumber = 1: 1
    inputname = num2str(testnumber);  
    image = imread([inputpath,inputname,'_input.png']); 
    density = FADE(image);
    density_data(testnumber,:) = [testnumber,density];
%end
time = toc;

%% For density and density map, please use below:
% [density, density_map] = FADE(image);

%% For other test images, please use below:
% image2 = imread('test_image2.jpg'); 
% density2 = FADE(image2)

% image3 = imread('test_image3.jpg'); 
% density3 = FADE(image3)

