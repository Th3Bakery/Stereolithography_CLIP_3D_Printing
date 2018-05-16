% STL_to_BMP_for_PuSL
% Written by: Evan Baker 6/10/2013
% The Code was originally developed to convert .stl files generated on
% SolidWorks into .bmp files required for PuSL printing in Dr. Cheng Sun's
% lab at Northwestern University.  The code also generates the .txt file
% the PuSL printer requires.
%
% Future recommended improvements:
% After generating the 1st bitmap, check the previous bitmap and make sure
% it is not exactly the same.  If it is exactly the same, do not generate a
% new bitmap and repeat the 1st one a second time. 
%
% TO RUN THIS CODE ON MAC: skip to line 160 and fix.
% 
% This STL file used in this example was created on solidworks.  Other tools may orient the
% file differently.  You may need to modify the inputs to VOXELISE function
% below.
%

% When printing 2 different input files, fname will be on the left
% side of the bitmap, fname2 will be on the right side

%********************************************************************
%Inputs:
%fname='sw_2x2_160umSpring.STL';  %Filename of STL file 
clear all
close all
fclose all;

numinputfiles = 1;  %This is the number of input files
%How many structures?
numstruct=1;
%NOTE: if you have 2 input files, numstruct=1 will make 1 of each.

fname='LSM_Weighting Dynamic 0.75 4mm base stl.STL'; %Filename of Dec 27 file

if numinputfiles == 2;
fname2='Simp Weighting Dynamic 0.0 4mm base stl.STL'; %The second input file name
%NOTE: both structures should have same dimensions
end

%Outputs:
dir_bmap='LSM Part';    %Output folder for saving bitmap files
%ofname_prefix='springy';
mkdir(dir_bmap);
ofname_prefix=dir_bmap;   %Prefix of output file for bitmaps

nn=round(5.5/0.020);    %Height of spring structure/20microns for old file
%round(3.4/0.020) = 170 layers
%nn=180;    %Height of spring structure/20microns for new file

%Topology Optimized Designs are 4mmx4mm
wid=round(3.3/0.0071);   %Width of spring structure/7.1microns
len=round(3.3/0.0071);   %Length of spring structure/7.1microns
%For spring use 3.3 for both


% Overall bitmap dimensions - we may want to drop several springs onto this
% bitmap.  For now we will drop one spring at about the middle of the
% bitmap.  
b_nn=nn;       %Height of bitmap (number of bitmap layers)
b_wid=1050;    %Vertical monitor Width for bitmap: 7.455mm
b_len=1400;    %Horizontal monitor length for bitmap: 9.940mm

%Offset for placing spring into the final bitmap

%Spacer represents the pixel separation between designs. Previously set to
%40 pixels.  Even at 50 pixels the single spring's tops clung together.
%Testing 60 now. (I also shrunk the top)
spacer = 60;
Exp=12; %Exposure Time was 12 seconds

if numstruct==1;
o_wid=b_wid/2-wid/2;
o_len=b_len/2-len/2;
end
if numstruct==2;
o_wid1=b_wid/2-wid/2;
o_len1=b_len/2-len-spacer;

o_wid2=b_wid/2-wid/2;
o_len2=b_len/2+spacer;
end

if numstruct==4;
o_wid1=b_wid/2-wid-spacer;
o_len1=b_len/2-len-spacer;

o_wid2=b_wid/2+spacer;
o_len2=b_len/2-len-spacer;

o_wid3=b_wid/2-wid-spacer;
o_len3=b_len/2+spacer;

o_wid4=b_wid/2+spacer;
o_len4=b_len/2+spacer;
end

if numinputfiles == 2;
o_wid1=b_wid/2-wid/2;
o_len1=b_len/2-len-spacer;

o_wid2=b_wid/2-wid/2;
o_len2=b_len/2+spacer;    
end

if numinputfiles == 2 && numstruct==2;
o_wid1=b_wid/2-wid-spacer;
o_len1=b_len/2-len-spacer;

o_wid2=b_wid/2+40;
o_len2=b_len/2-len-spacer;

o_wid3=b_wid/2-wid-spacer;
o_len3=b_len/2+spacer;

o_wid4=b_wid/2+spacer;
o_len4=b_len/2+spacer;
end


%*********************************************************************
%oset=[o_wid,o_len];

figure
[stlcoords] = READ_stl(fname);

xco = squeeze( stlcoords(:,1,:) )';
yco = squeeze( stlcoords(:,2,:) )';
zco = squeeze( stlcoords(:,3,:) )';
[hpat] = patch(xco,yco,zco,'b');
axis equal

%Voxelise the STL:
[OUTPUTgrid] = VOXELISE(wid,nn,len,fname,'xyz');
%The final structure will drop these springs onto a volume of dimension:
% x:1400, y:1050, z=height of structure/20microns = 3.4mm/20microns=170

disp('finished voxelise');


%Initialize the final bitmap array to all zeros (or all ones)
bz=zeros(b_wid,b_len);

if numinputfiles==2;
figure
[stlcoords] = READ_stl(fname2);

xco = squeeze( stlcoords(:,1,:) )';
yco = squeeze( stlcoords(:,2,:) )';
zco = squeeze( stlcoords(:,3,:) )';
[hpat] = patch(xco,yco,zco,'b');
axis equal

%Voxelise the STL:
[OUTPUTgrid2] = VOXELISE(wid,nn,len,fname2,'xyz');
%The final structure will drop these springs onto a volume of dimension:
% x:1400, y:1050, z=height of structure/20microns = 3.4mm/20microns=170

disp('finished voxelise');
    
end

% For each of the 20micron slices, we want to create a bitmap file
%ofname_base=[dir_bmap '\' ofname_prefix]; %comment this to run on mac
ofname_base = ofname_prefix; % un-comment this to run on mac...

figure
for i=1:nn
    %For STL files from Solidworks, the height is imported into matlab
    %(using the READ_stl function as the middle variable.  We are assuming
    %the width is the first variable and the length is the third variable.
    %If we build non-symmetrical shapes in the future, then may need to
    %switch first and third variables.
    xx=OUTPUTgrid(:,i,:);
    z=squeeze(xx);
    if numinputfiles==2;
       xx2=OUTPUTgrid2(:,i,:);
       z2=squeeze(xx2);
    end
    if numinputfiles==1;
    if numstruct==1;
    bz(o_wid:o_wid+wid-1,o_len:o_len+len-1)=z;
    end
    if numstruct==2;
    bz(o_wid1:o_wid1+wid-1,o_len1:o_len1+len-1)=z;    
    bz(o_wid2:o_wid2+wid-1,o_len2:o_len2+len-1)=z;
    end
    if numstruct==4;
    bz(o_wid1:o_wid1+wid-1,o_len1:o_len1+len-1)=z;    
    bz(o_wid2:o_wid2+wid-1,o_len2:o_len2+len-1)=z;
    bz(o_wid3:o_wid3+wid-1,o_len3:o_len3+len-1)=z;
    bz(o_wid4:o_wid4+wid-1,o_len4:o_len4+len-1)=z;
    end
    end
    if numinputfiles==2;
    if numstruct==1;
    bz(o_wid1:o_wid1+wid-1,o_len1:o_len1+len-1)=z;    
    bz(o_wid2:o_wid2+wid-1,o_len2:o_len2+len-1)=z2;
    end
    if numstruct==2;
    bz(o_wid1:o_wid1+wid-1,o_len1:o_len1+len-1)=z;    
    bz(o_wid2:o_wid2+wid-1,o_len2:o_len2+len-1)=z;
    bz(o_wid3:o_wid3+wid-1,o_len3:o_len3+len-1)=z;
    bz(o_wid4:o_wid4+wid-1,o_len4:o_len4+len-1)=z;
    end
    end
    imagesc(bz);
    if i<1000
        zer='';
    end
    if i<100
        zer='0';
    end
    if i<10
        zer='00';
    end  
    ofname=[ofname_base zer sprintf('%i.bmp',i)];
    imwrite(bz,ofname,'bmp');
    colormap(gray(256));
    xlabel('X-direction');
    ylabel('Y-direction');
    axis equal tight
    %pause(.05);   %optional pause for viewing small bitmaps
end

Layer = 1; %The starting layer.
Thick=20; %Thickness 20um per layer.
%Exp=12; %Exposure Time 12 seconds (moved to top)

fileID = fopen([ofname_base '.txt'],'w');
fprintf(fileID,'%s\t','Layer');
%fprintf(fileID,'%5s\t %4s\t %5s\t %3s\n','Layer','File','Thick','Exp');
fprintf(fileID,'%s\t','File');
fprintf(fileID,'%s\t','Thick');
fprintf(fileID,'%s\n','Exp');
for i=1:nn
    
    if i<1000
        zer='';
    end
    if i<100
        zer='0';
    end
    if i<10
        zer='00';
    end  
    File=[ofname_prefix zer sprintf('%i.bmp',i)];
    Layer=i;
   % fprintf(fileID,'%1.0f\t %-5s\t %2.0f\t %2.0f\n',Layer,File,Thick,Exp);
    fprintf(fileID,'%1.0f\t',Layer);
    fprintf(fileID,'%s\t',File);
    fprintf(fileID,'%2.0f\t',Thick);
    fprintf(fileID,'%2.0f\n',Exp);
    
end
fclose(fileID);

