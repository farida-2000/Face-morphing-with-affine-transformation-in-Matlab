%how to run 
% load points and correspponding matrixes;
% imgs = morph(first_image, second_image, points_matrix1,point_matrix2);
function imgs = morph(first_image, second_image, points_matrix1,point_matrix2)
%load images
im1 = double(imread(first_image));
im2 = double(imread(second_image));
%adding four additional points to each matrix, corresponding to the corners of the two images (i.e., (0.5, 0.5), (0.5, size(im1, 2)-0.5), (size(im1, 1)-0.5, 0.5), and (size(im1, 1)-0.5, size(im1, 2)-0.5) for input_cords, and corresponding points for target_cords).
input_cords = points_matrix1(:, 1:2); %exract first two col of locations of first txt file
target_cords = point_matrix2(:, 1:2); %extract second two col of locations of second txt file
input_cords = [input_cords; [0.5, 0.5]; [0.5, size(im1, 2)-0.5]; [size(im1, 1)-0.5, 0.5]; [size(im1, 1)-0.5, size(im1, 2)-0.5]]; %find four corners of points in matrix
target_cords = [target_cords; [0.5, 0.5]; [0.5, size(im2, 2)-0.5]; [size(im2, 1)-0.5, 0.5]; [size(im2, 1)-0.5, size(im2, 2)-0.5]];
ap = (input_cords+target_cords)/2; 
triangle_poly = delaunayTriangulation(ap); %create triangle from the matrix ap
%triplot(triangle_poly)
frames =70; %set number of frames to 70
count = 1; %create the count to print number of frames 
imgs = []; 
%create a vector with linspace to generate different alphas
for alpha = linspace(0, 1, frames)
    if(alpha==0), img = im1;
    elseif(alpha==1), img = im2;
    else
        output_cords = (1-alpha)*input_cords + alpha*target_cords; 
        im1t = transform(triangle_poly, im1, input_cords, output_cords);
        im2t = transform(triangle_poly, im2, target_cords, output_cords);
        img = (1-alpha)*im1t + alpha*im2t;%morphed image is the combination of transormed src/ref images
    end
    %fprintf("Frame %d/%d.\n", count, frames);
    imgs(:, :, :, count) = img; %storing images
    count = count + 1; 
end
%gif func
gif(imgs)
unit = frames/8;
subplot(3,3,1); 
imshow(uint8(imgs(:, :, :, 1))); title('a=0')
subplot(3,3,2); 
imshow(uint8(imgs(:, :, :, round(1*unit)))); title('a=1/8');
subplot(3,3,3); 
imshow(uint8(imgs(:, :, :, round(2*unit)))); title('a=2/8');
subplot(3,3,4); 
imshow(uint8(imgs(:, :, :, round(3*unit)))); title('a=3/8');
subplot(3,3,5); 
imshow(uint8(imgs(:, :, :, round(4*unit)))); title('a=4/8');
subplot(3,3,6); 
imshow(uint8(imgs(:, :, :, round(5*unit)))); title('a=5/8');
subplot(3,3,7); 
imshow(uint8(imgs(:, :, :, round(6*unit)))); title('a=6/8');
subplot(3,3,8); 
imshow(uint8(imgs(:, :, :, round(7*unit)))); title('a=7/8');
subplot(3,3,9); 
imshow(uint8(imgs(:, :, :, size(imgs, 4)))); title('a=8/8');
end
function imt = transform(triangle_poly, input_image, input_cords, output_cords)
%triangle_poly is a matrix includes indices that correspond to the three vertices of each triangle. each row is a different triangle.

%loops on each pixel, checks which triangle it belongs to, and assigns it to the proper index in the t matrix.
%Then, for each triangle,we calculate the affine transformation matrix affine_trans by taking the pseudo-inverse of the transpose of a 3x3 matrix composed of the three corresponding points from input_cords with a column of ones appended to the end. It then constructs a 3x3 matrix B by taking the transpose of a 3x3 matrix composed of the three corresponding points from output_cords with a column of ones appended to the end. The affine transformation matrix is then obtained by multiplying the pseudo-inverse of the transpose of the 3x3 matrix from input_cords with the transpose of the 3x3 matrix from output_cords.

t = zeros([size(input_image, 2), size(input_image, 1)]);
x = output_cords(:, 1); y = output_cords(:, 2);
for j = 1:size(triangle_poly,1)   %index j that belogs to triangle
    x1 = x(triangle_poly(j, 1)); x2 = x(triangle_poly(j, 2)); x3 = x(triangle_poly(j, 3)); y1 = y(triangle_poly(j, 1)); y2 = y(triangle_poly(j, 2)); y3 = y(triangle_poly(j, 3));
    for p = 1:size(input_image, 2)
        for q = 1:size(input_image, 1)
            %check if the chosen pixel is inside the triangle
            if ((x2-x1)*(q-y1) - (y2-y1)*(p-x1)) * ((x2-x1)*(y3-y1) - (y2-y1)*(x3-x1)) < 0, continue; end
            if ((x3-x2)*(q-y2) - (y3-y2)*(p-x2)) * ((x3-x2)*(y1-y2) - (y3-y2)*(x1-x2)) < 0, continue; end
            if ((x1-x3)*(q-y3) - (y1-y3)*(p-x3)) * ((x1-x3)*(y2-y3) - (y1-y3)*(x2-x3)) < 0, continue; end
            %assign matrix t in location of pixels p,q to index j coming
            %from the poly_triangle
            t(p, q) = j;
        end
    end
end
% affine_trans constructs a 3x3 matrix A by taking the transpose of a 3x3 matrix composed of the three corresponding points from input_cords with a column of ones appended to the end. It then calculates the pseudo-inverse of this matrix 
%Next, it constructs a 3x3 matrix B by taking the transpose of a 3x3 matrix composed of the three corresponding points from output_cords with a column of ones appended to the end.
affine_trans = zeros(3, 3, size(triangle_poly, 1));
for i = 1:size(triangle_poly, 1)
    Ainv = pinv(transpose([input_cords(triangle_poly(i, :), :) ones(3,1)])); %using p inverse 
    B = transpose([output_cords(triangle_poly(i, :), :) ones(3,1)]); %transpose
    affine_trans(:, :, i) = B*Ainv; %multiply inverse of A to B (transpose) to generate affine transformation matrix for triangle
end
% we apply image warping
%check if index t(j, i) is zero or not. Skip if zero. if not, it
%apply transformation to the pixel (pt) and
%do the rounding. If transformed pixel is not in range
%of boundry we set it to the boundary. Copy RGB values of the transformed
%pixel in original image to pixel in the transformed image.
imt = input_image;

for i = 1:size(input_image, 1)
    for j = 1:size(input_image, 2)
        if(t(j, i) == 0), continue; end
        pinv_affine = pinv(affine_trans(:, :, t(j, i)));
        pt = [j; i; 1]; % pt: applying transformation on pixels
        p = round(pinv_affine*pt);
        %round and check if it's not out of range of boundry
        if(p(1) < 1) p(1) = 1; end
        if(p(2) < 1) p(2) = 1; end
        if(p(1) > size(input_image, 2)) p(1) = size(input_image, 2); end
        if(p(2) > size(input_image, 1)) p(2) = size(input_image, 1); end
        imt(i, j, :) = input_image(p(2), p(1), :); %RGB values of pixels in original image are copied to the transformed image(imt)
    end
end
end