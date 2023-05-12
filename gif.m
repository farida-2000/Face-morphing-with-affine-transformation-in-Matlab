%create a function to create gif
function f=gif(imgs)
    filename = ('morphed.gif');
    time = 0.06; %delay times between frames
    for i = 1:size(imgs, 4)
        img = uint8(imgs(:, :, :, i));
        [A, index] = rgb2ind(img, 256); %converts the RGB image to an indexed image
        if i == 1
            imwrite(A, index, filename, 'gif', 'LoopCount', Inf, 'DelayTime', time); %INF refers to loop the gif till infinity
        else
            imwrite(A, index, filename, 'gif', 'WriteMode', 'append', 'DelayTime', time);
        end
    end
    %loop again in reverse order 
    for i = size(imgs, 4):-1:1
        img = uint8(imgs(:, :, :, i));
        [A, index] = rgb2ind(img, 256); %Convert RGB to indexed image 
        imwrite(A, index, filename, 'gif', 'WriteMode', 'append', 'DelayTime', time);
    end

end