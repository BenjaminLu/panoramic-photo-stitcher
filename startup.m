clear variables
close all
clc

image1 = imread('images/1.jpg')
image2 = imread('images/2.jpg')

%compute transform matrix%
junction1 = [831 733
             73  579]
junction2 = [849 421
             89  247]
junction3 = [883 597
             133  437]

x1 = junction1(1, 1)
y1 = junction1(1, 2)

x2 = junction2(1, 1)
y2 = junction2(1, 2)

x3 = junction3(1, 1)
y3 = junction3(1, 2)

x1Dot = junction1(2, 1)
y1Dot = junction1(2, 2)

x2Dot = junction2(2, 1)
y2Dot = junction2(2, 2)

x3Dot = junction3(2, 1)
y3Dot = junction3(2, 2)

matrix1 = [x1 y1 1
           x2 y2 1
           x3 y3 1]
vectorXDot = [x1Dot
              x2Dot
              x3Dot]
          
vectorYDot = [y1Dot
              y2Dot
              y3Dot]
       
A = inv(matrix1) * vectorXDot
B = inv(matrix1) * vectorYDot


C = [A'
     B']

%compute max height and max width of the whole picture%
[height1, width1, color1Size] = size(image1)
[height2, width2, color2Size] = size(image2)

%convert 4 cordinates of corner points of image2 to cordinates of image1%
syms C1 C2 C3 C4 C5 C6 xDot yDot x y
C1 = C(1,1)
C2 = C(1, 2)
C3 = C(1, 3)
C4 = C(2, 1)
C5 = C(2, 2)
C6 = C(2, 3)
xDot = 0
yDot = 0
eq1 =  C1 * x + C2 * y + C3 == xDot
eq2 =  C4 * x + C5 * y + C6 == yDot
S = solve(eq1, eq2)

leftTopOfimage1X = S.x
leftTopOfimage1Y = S.y

syms C1 C2 C3 C4 C5 C6 xDot yDot x y
C1 = C(1,1)
C2 = C(1, 2)
C3 = C(1, 3)
C4 = C(2, 1)
C5 = C(2, 2)
C6 = C(2, 3)
xDot = width2
yDot = 0
eq1 =  C1 * x + C2 * y + C3 == xDot
eq2 =  C4 * x + C5 * y + C6 == yDot
S = solve(eq1, eq2)

rightTopOfimage1X = S.x
rightTopOfimage1Y = S.y

syms C1 C2 C3 C4 C5 C6 xDot yDot x y
C1 = C(1,1)
C2 = C(1, 2)
C3 = C(1, 3)
C4 = C(2, 1)
C5 = C(2, 2)
C6 = C(2, 3)
xDot = 0
yDot = height2
eq1 =  C1 * x + C2 * y + C3 == xDot
eq2 =  C4 * x + C5 * y + C6 == yDot
S = solve(eq1, eq2)

leftBottomOfimage1X = S.x
leftBottomOfimage1Y = S.y

syms C1 C2 C3 C4 C5 C6 xDot yDot x y
C1 = C(1,1)
C2 = C(1, 2)
C3 = C(1, 3)
C4 = C(2, 1)
C5 = C(2, 2)
C6 = C(2, 3)
xDot = width2
yDot = height2
eq1 =  C1 * x + C2 * y + C3 == xDot
eq2 =  C4 * x + C5 * y + C6 == yDot
S = solve(eq1, eq2)

rightBottomOfimage1X = S.x
rightBottomOfimage1Y = S.y

xArray = [leftTopOfimage1X, rightTopOfimage1X, leftBottomOfimage1X, rightBottomOfimage1X]
maxWidth = max(xArray)

yArray = [leftTopOfimage1Y, rightTopOfimage1Y, leftBottomOfimage1Y, rightBottomOfimage1Y];
candidateMaxHeight = max(yArray)

minY = min(yArray)
minY = int64(minY)
if minY < 0
    maxHeight = candidateMaxHeight + abs(minY)
else
    maxHeight = candidateMaxHeight
end

maxWidth = int64(maxWidth)
maxHeight = int64(maxHeight)


%set background color%

%background%
image = zeros(maxHeight, maxWidth, 3, 'uint8');

%set color at (a, b) of panoramic image from image1%
if minY < 0
    offset = abs(minY)
    image((1 + offset) : (height1 + offset), 1:width1, :) = image1(1:height1, 1:width1, :)
else
    image(1:height1, 1:width1, :) = image1(1:height1, 1:width1, :);
end


%set color at (a, b) of panoramic image from image2%
for b = 1:maxHeight
    for a = 1:maxWidth
        x = a - 1;
        y = b - 1;
        if minY < 0
            x = a;
            %matlab coordinate start from 1, so we need to sub one%
            y = b - abs(minY);
        end
        
        coordinateVectorOfImage1 = [double(x)
                                    double(y)
                                    1];
        coordinateVectorOfImage2 = C * coordinateVectorOfImage1;
        coordinateXOfImage2 = coordinateVectorOfImage2(1, 1);
        coordinateYOfImage2 = coordinateVectorOfImage2(2, 1);
        
        if (coordinateXOfImage2 >= 1) && (coordinateXOfImage2 <= width2) && (coordinateYOfImage2 >= 1) && (coordinateYOfImage2 <= height2)
            %change these 3 lines to Bilinear Interpolation%
            coordinateXOfImage2 = int64(coordinateXOfImage2);
            coordinateYOfImage2 = int64(coordinateYOfImage2);
            image(b, a, :) = image2(coordinateYOfImage2, coordinateXOfImage2, :);
        end
    end
end

figure, imshow(image)
imwrite(image, 'images/panoramic.jpg')
