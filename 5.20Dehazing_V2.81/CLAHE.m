function output = CLAHE(Y)
newY = adapthisteq(Y,'NumTiles',[8 8],'ClipLimit',0.001,'NBins',256);
output=uint8(newY);

