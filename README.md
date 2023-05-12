# Face-morphing-with-affine-transformation-in-Matlab
The goal of this project is to use affine transformation to perform face morphing. In fact, we have the 
important points of both images given to us in text format. We create triangles out of those points and 
try to map every point in source image to its corresponding point in the target image. We must find the 
values of out transformation. Affine transformation has 8 degrees of freedom, and we have to find the 
respective values of our transformation. We do this with p-inv function in Matlab. Specifically, we find 
the p-inv of matrix A and multiply that by matrix B. Once we find our transformation matrix, we apply 
image warping. I iterate over and create 70 values between zero and one for alpha. I set alpha for 8 
values(frames) to show the transformation from Hillary to Ted in the timeframe in the plotting section.
Implementation is done in Matlab and all the functions have been implemented from scratch.
