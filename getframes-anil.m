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
run2dir = 'C:\Users\ASemizoglu\Desktop\pixel-damage\RUN2\';

%optional file select window pops up
%[fname,sdir,filtx] = uigetfile('*.SEQ','Select Raw Sequence File', 'MultiSelect', 'on');

cd('C:\Users\ASemizoglu\Desktop\pixel-damage\RUN2\run2-SEQ\');


seqfiles = dir('*.seq');
nfiles = length(seqfiles);

rangeId = fopen('ranges.txt','w');
intenId = fopen('intensity.txt','w');
    inten_mat = cell(16,2);
    rang_mat = cell(16,2);
    
    

  
  for k=1:nfiles;

  f=1;
  
  fname = seqfiles(k).name;
  path = strcat(sdir,fname);
  fid1 = fopen(path);
  
  %xpxl = 25:87; %first half of measurements
  %ypxl = 39:90; %first half of measurements
 
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

  fname_n = strrep(fname,'.seq',' ');
  clf;
  
  img_path = strcat(run2dir,'images\','av_inten_',fname_n);
 
  h = figure(f); 
  set(h, 'Visible', 'on');
  
  %img = imagesc(av);
  %colorbar;
  
  %saveas(uint8(img),'figure.jpg');
  %f++;
   
  %to access the pixel values it is [y,x]
  mean_4 = mean(av(51,32:35));

  %intensity 4x4 average
  %take the average of the 4x4 pixels for each frame
  %store the mean intensity value for each frame in inten_4
  intensity_4 = zeros(1,200);

  for i=1:200;
    mean_i=mean(mean(inten(51:54,32:35,i)));
    intensity_4(1,i) = mean_i;
    end

  %range 4x4 average
  %take the average of the 4x4 pixels for each frame
  %store the mean range value for each frame in range_4
  
  range_4 = zeros(1,200);

  for i=1:200;
    mean_r=mean(mean(rvector(51:54,32:35,i)));
    range_4(1,i) = mean_r;
    end


    %average over 200 frames

    intensity_av     = mean(intensity_4,2);
    range_av         = mean(range_4,2);
    
    inten_mat(k,1) = fname_n;
    rang_mat(k,1)  = fname_n;

    inten_mat(k,2) = num2str(intensity_av);
    rang_mat(k,2)  = num2str(range_av);
    
  
    
  %plot the average R&I on the 4x4 on the y-axis
  %x-axis is the frame number
    %{
  range_4(range_4 > 10) = 0;
  clf;
  ran_fig=figure(f);
  range_path = strcat(run2dir,'plots\range\',fname_n,'.jpg');
  plot(range_4);
  print(ran_fig,range_path,'-djpeg');
  f++;
 
  clf;
  int_fig=figure(f);
  int_path = strcat(run2dir,'plots\intensity\',fname_n,'.jpg');
  plot(intensity_4);
  print(int_fig,int_path,'-djpeg');
  f++;
    %}
 
  end
  
    figure(100);

    imagesc(av);
    colorbar;
   
  
  [nrow,ncol]=size(inten_mat);
  
  for row = 1:nrow
    fprintf(intenId,'%s %s \r\n',inten_mat{row,:});
    end
    
   for row = 1:nrow
    fprintf(rangeId,'%s %s \r\n',rang_mat{row,:});
    end
  
  fclose(intenId);
  fclose(rangeId);
  


