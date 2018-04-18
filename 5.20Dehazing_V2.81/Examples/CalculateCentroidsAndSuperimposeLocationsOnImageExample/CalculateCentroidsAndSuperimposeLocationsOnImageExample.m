%% Calculate Centroids and Superimpose Locations on Image
%  
%%
% Read binary image into workspace.

% Copyright 2015 The MathWorks, Inc.

BW = imread('text.png');
%%
% Calculate centroids for connected components in the image using
% |regionprops|.
s = regionprops(BW,'centroid');
%%
% Concatenate structure array containing centroids into a single matrix.
centroids = cat(1, s.Centroid);
%%
% Display binary image with centroid locations superimposed.
imshow(BW)
hold on
plot(centroids(:,1),centroids(:,2), 'b*')
hold off
