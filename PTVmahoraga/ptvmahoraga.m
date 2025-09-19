% Set up the video reader
inputVideo = VideoReader('pingpong3.mov'); % change number from 1-3 for each video in the experiment.

% Create a figure for displaying the frames
hFig = figure;

% Initialize storage for the ball's centroid positions
centroidPositions = [];

while hasFrame(inputVideo)
    frame = readFrame(inputVideo); % Read each frame
    
    % Apply Gaussian blur to the frame
    blurredFrame = imgaussfilt(frame, 2); % The standard deviation of the Gaussian blur

    % Convert the blurred frame to grayscale
    grayFrame = rgb2gray(blurredFrame); 

    % Thresholding to detect the ball
    thresholdValue = 138; % Adjust the threshold based on your video the threshold for video 1 and 2 must be 125 and for video 3 138
    ballMask = grayFrame > thresholdValue;

    % Use regionprops to find the centroid of the ball in the binary image
    props = regionprops(ballMask, 'Centroid');
    if ~isempty(props)
        % Assuming the largest blob is the ball
        centroid = props(1).Centroid; % Get the centroid of the first (largest) blob
        centroidPositions = [centroidPositions; centroid]; % Store the centroid

        % Display the frame with the ball in white and the background in black
        imshow(uint8(ballMask) * 255);
        hold on;
        
        % Draw a colored circle around the detected ball for tracking visualization
        viscircles(centroid, 80, 'Color', 'red', 'LineWidth', 2); % Adjust the radius and line width radius should be 50 for video 1 and 2 and 80 for video 3
        
        hold off;
    else
        % If no ball is detected, just show the binary frame
        imshow(uint8(ballMask) * 255);
    end
    
    drawnow; % Update the figure window
    pause(1/inputVideo.FrameRate); % Optional: control the playback speed
end

% After processing all frames, plot the graph of the ball's movement

% Find the highest Y-coordinate (lowest point in the image coordinate system)
maxY = max(centroidPositions(:,2));

% Invert and shift Y-coordinates so the lowest point becomes the highest in the graph
adjustedY = maxY - centroidPositions(:,2);

figure;
plot(centroidPositions(:,1), adjustedY, 'r-');
title('Movement of the Ball');
xlabel('X Position');
ylabel('Y Position');
ylim([0 max(adjustedY)+10]); % Ensure the Y-axis starts at 0 and has a small buffer above the highest point
axis('equal'); % Set equal scaling by unit length along each axis
