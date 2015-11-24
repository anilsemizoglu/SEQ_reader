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

%pixel group to be used in averaging
x1=63; x2=65; y1=76;y2=78;
nframes = 200;

%constants
mkdir 'intensity';
mkdir 'ranges';
mkdir 'pics';

numpix = 16384;
camserial = 'AAR TC-2003#';
iframe = 1:nframes; %indices of frames to be used for analysis
fstartri = 512;
framesize = 66960;
f=1;

% loadfiles, and the number of files
seqfiles = dir('*.seq');
nfiles = length(seqfiles);

rangeId = fopen('ranges.txt','w');
intenId = fopen('intensity.txt','w');

%will store the spatial and time averages
inten_mat = [1:nfiles];
rang_mat = [1:nfiles];
file_names = cell(1,nfiles);

%file loop, loop over seq files
for k=1:nfiles;
  fname = seqfiles(k).name;
  fname_n = strrep(fname,'.seq',' ');
  fid1 = fopen(fname);
  
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
  
  %R&I SPATIAL average
  %take the average of the spot of illuminated pixels for each frame
  %store the mean R&I value for each frame in intensity_spot and range_spot
  intensity_spot = zeros(1,nfiles);
  range_spot = zeros(1,nfiles); 
  
  for i=1:200;
   mean_i=mean(mean(inten(y1:y2,x1:x2,i)));
   intensity_spot(1,i) = mean_i;
   end   

  for i=1:200;
   mean_r=mean(mean(rvector(y1:y2,x1:x2,i)));
   range_spot(1,i) = mean_r;
   end
   
    %fix the obvious errors, only couple times happens
  for i=1:nfiles;
    if (range_spot(1,i) > 10) range_spot(1:i) = 2; 
      end  
    end
  %R&I time average over frames  
  intensity_av     = mean(intensity_spot,2);
  range_av         = mean(range_spot,2); 
  
  
  % fill the inten_mat and rang_mat, 
  % which stores the averages for each 
  % seq file, first column name of the file
  % second column the values
  
  file_names(1,k) = fname_n;
  
  inten_mat(1,k) = intensity_av;
  rang_mat(1,k)  = range_av;

  
  %Save the time evolution fo R&I
  range_path = strcat('ranges\',fname_n,'.jpg');
  ran_fig = figure(f);f++;
  scatter(1:200,range_spot,4);
  saveas(ran_fig,range_path);
  delete(ran_fig);
  
  inten_path = strcat('intensity\',fname_n,'.jpg');
  int_fig = figure(f);f++;
  scatter(1:200,intensity_spot,4);
  saveas(int_fig,inten_path);
  delete(int_fig);
  
  pic_path = strcat('pics\',fname_n,'.jpg');
  inten_pic = figure(f);f++;
  imagesc(mean(inten,3));
  colorbar;
  print(inten_pic,pic_path);
  delete(inten_pic);
  end
  %file loop


   fprintf(intenId, '%s %d %s %d \r\n %s %d %s %d \r\n', ' x1:',x1,'x2:',x2,'y1:',y1,'y2:',y2);
   fprintf(rangeId, '%s %d %s %d \r\n %s %d %s %d \r\n', ' x1:',x1,'x2:',x2,'y1:',y1,'y2:',y2);

 for i=1:nfiles 
  fprintf(intenId,'%s %5.1f \r\n',file_names{1,i}, inten_mat(1,i));
  fprintf(rangeId,'%s %3.2f \r\n',file_names{1,i}, rang_mat(1,i));
  
  end
  
  fclose(intenId);
  fclose(rangeId);
  
  

  
