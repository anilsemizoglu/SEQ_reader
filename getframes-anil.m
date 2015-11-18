%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1-Extract the data from the SEQ and store in matrices
% 2-Find a 4x4 pixel group to analyze in the center of the spot
% 3-Analyze the Range and Intensity as the gain setting and the 
%   energy per pixel is changing, call every change a config
%   a) look at the graph of RnI for the 200 frames at each config
%   b) create a table that includes all configs, 
%      ie. for each config have two values, average range and intensity
%      this average is the average over 200 frames for that config, 
%      and the 4x4 pixel group, adn create a matrix table
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
pkg load image;

%constants
numpix = 16384;
camserial = 'AAR TC-2003#';
iframe = 1:200; %indices of frames to be used for analysis
fstartri = 512;
framesize = 66960;

%%%%%%%%%%%%%%%
%uncomment next two lines for single file usage
%%%%%%%%%%%%%%%

%fname = 'run2-ND0.4-det20-amp-25';
sdir =  'C:\Users\ASemizoglu\Desktop\pixel-damage\RUN2\run2-SEQ\';

%optional file select window pops up
%[fname,sdir,filtx] = uigetfile('*.SEQ','Select Raw Sequence File', 'MultiSelect', 'on');

cd('C:\Users\ASemizoglu\Desktop\pixel-damage\RUN2\run2-SEQ\');


seqfiles = dir('*.seq');
nfiles = length(seqfiles);


for k=1:nfiles;

  fname = seqfiles(k).name;
  path = strcat(sdir,fname);
  fid1 = fopen(path);
  fid1
  %xpxl = 25:87; %first half of measurements
  %ypxl = 39:90; %first half of measurements

  clf;
  xpxl = 1:128;
  ypxl = 1:128;

  %get image data
  %inten is counts, rvector stores the range in feet
  for frame=iframe(1):iframe(1)+size(iframe,2)-1;
    fseek(fid1, fstartri+(frame-1)*framesize,'bof');   % start of R&I data
    RIvector =  uint32(fread(fid1,numpix,'uint32','l'));
    RIvector = fliplr(flip(reshape(RIvector,128,128)));
    inten(:,:,frame-iframe(1)+1) = bitand(RIvector(ypxl,xpxl),4095);
    rvector(:,:,frame-iframe(1)+1) = double(bitshift(RIvector(ypxl,xpxl),-12))./64;


  end
  fclose(fid1);
  %------------
  %start here, above is all grabbing the data from the SEQ
  %------------

  %create new figure # called by i
  %f=1;
  %figure(f);f++;

  %av is the average of the 200 frames
  av=mean(inten,3);

  %create the color image, 
  %put the colorbar for scale

  imagesc(av);
  colorbar;
  write_path = strcat('C:\Users\ASemizoglu\Desktop\pixel-damage\RUN2\images','av_inten_',fname,'.jpg');

  imwrite(av,write_path);

  

  %to access the pixel values it is [y,x]
  mean_4 = mean(av(51,32:35));

  %intensity 4x4 average
  %take the average of the 4x4 pixels for each frame
  %store the mean intensity value for each frame in inten_4

  inten_4 = zeros(1,200);

   for i=1:200;
    mean_i=mean(mean(inten(51:54,32:35,i)));
    inten_4(1,i) = mean_i;
  end

  %range 4x4 average
  %take the average of the 4x4 pixels for each frame
  %store the mean intensity value for each frame in inten_4
  range_4 = zeros(1,200);

  for i=1:200;
    mean_r=mean(mean(rvector(51:54,32:35,i)));
    range_4(1,i) = mean_r;
  end

  %plot the average R&I on the 4x4 on the y-axis
  %x-axis is the frame number
  
%range_4(range_4>5) = 0;
%figure(f);f++;
%plot(range_4);

%figure(f);f++;
%plot(inten_4);
end










