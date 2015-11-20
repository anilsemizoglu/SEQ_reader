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
  y1=52; y2=54; x1=33;x2=35;
  
  %%%%%%%%%%%%%%%%%%%%%%%%



  sdir =  'C:\Users\ASemizoglu\Desktop\pixel-damage\RUN2\run2-SEQ\';
  run2dir = 'C:\Users\ASemizoglu\Desktop\pixel-damage\RUN2\';
  cd('C:\Users\ASemizoglu\Desktop\pixel-damage\RUN2\run2-SEQ\');

  %optional file select window pops up
  %[fname,sdir,filtx] = uigetfile('*.SEQ','Select Raw Sequence File', 'MultiSelect', 'on');

  %open all .seq files
  seqfiles = dir('*.seq');
   cd('C:\Users\ASemizoglu\Desktop\pixel-damage\src\');
  nfiles = length(seqfiles);
  
  %text files to store the spatial 
  %and time average data
  rangeId = fopen('C:\Users\ASemizoglu\Desktop\pixel-damage\RUN2\ranges.txt','w');
  intenId = fopen('C:\Users\ASemizoglu\Desktop\pixel-damage\RUN2\intensity.txt','w');
  
  %will store the spatial and time averages
  inten_mat = cell(16,2);
  rang_mat = cell(16,2);
  
  f=1;
  
  %file loop, loop over all .seq files in the folder
  for k=1:nfiles;
  
  fname = seqfiles(k).name;
  fname_n = strrep(fname,'.seq',' ');
  path = strcat(sdir,fname);
  fid1 = fopen(path);
  
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
  
  %int_av ran_av are the average of the 200 frames for all pixels
  
  int_av=mean(inten,3);
  ran_av=mean(rvector,3);
   
  %to access the pixel values it is [y,x]
  
  %R&I SPATIAL average
  %take the average of the spot of illuminated pixels for each frame
  %store the mean R&I value for each frame in intensity_spot and range_spot
  intensity_spot = zeros(1,200);
  
  for i=1:200;
   mean_i=mean(mean(inten(y1:y2,x1:x2,i)));
   intensity_spot(1,i) = mean_i;
   end 
   
  range_spot = zeros(1,200);
  
  for i=1:200;
   mean_r=mean(mean(rvector(y1:y2,x1:x2,i)));
   range_spot(1,i) = mean_r;
   end
   
  % fix the obvious errors, only couple times happens
  for i=1:length(range_spot);
    if (range_spot(1:i) > 10) range_spot(1:i) = 2;
    end
    
  %R&I time average over frames
  
  intensity_av     = mean(intensity_spot,2);
  range_av         = mean(range_spot,2);

  % fill the inten_mat and rang_mat, 
  % which stores the averages for each 
  % seq file, first column name of the file
  % second column the values
  
  inten_mat(k,1) = fname_n;
  rang_mat(k,1)  = fname_n;
  
  inten_mat(k,2) = num2str(intensity_av);
  rang_mat(k,2)  = num2str(range_av);
  

  % Save the time evolution fo R&I
  range_path = strcat(run2dir,'plots\range\',fname_n,'.jpg');
  ran_fig = figure(f);f++;
  plot(range_spot);
  saveas(ran_fig,range_path);
  delete(ran_fig);
  
  inten_path = strcat(run2dir,'plots\intensity\',fname_n,'.jpg');
  int_fig = figure(f);f++;
  plot(intensity_spot);
  saveas(int_fig,inten_path);
  delete(int_fig);
  y = waitforbuttonpress;
  end %end of file loop

  figure(55);
  plot(intensity_spot);
  
  %save the matrices to text files
  
  [nrow,ncol]=size(inten_mat);
  
  for row = 1:nrow
    fprintf(intenId,'%s %s \r\n',inten_mat{row,:});
    end
    
  for row = 1:nrow
    fprintf(rangeId,'%s %s \r\n',rang_mat{row,:});
    end
  
  fclose(intenId);
  fclose(rangeId);