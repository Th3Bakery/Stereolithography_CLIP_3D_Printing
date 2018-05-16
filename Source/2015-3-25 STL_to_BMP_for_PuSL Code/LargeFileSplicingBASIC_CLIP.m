% STL_to_BMP_for_PuSL
% Written by: Evan Baker 6/10/2013
% The Code was originally developed to convert .stl files generated on
% SolidWorks into .png files required for Micro-CLIP printing in Dr. Cheng Sun's
% lab at Northwestern University.  The code also generates the .txt file
% the Micro-CLIP printer requires.
%
% Make sure the file you want to splice is oriented with Y in the vertical
% direction (the direction of the splicing of layers). If your part is not
% oriented in Y, re-orient it using Solidowrks (Create an assembly, and
% align the base of your part with the X-Z plane) or this program will not
% work - or use the other PuSL_Use_GUI_Windows program. 
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

fname='200um36strandFab2.STL'; %Filename, include .STL
%this is the file we want to test: 200um36strandFab2
if numinputfiles == 2;
fname2='newassem3.STL'; %The second input file name
%NOTE: both structures should have same dimensions
end

%Outputs:
dir_bmap='200um36strandFD';    %Output folder for saving bitmap files
%ofname_prefix='springy';
ofname_prefix='200um36strandFD';   %Prefix of output file for bitmaps
mkdir(ofname_prefix);
Thick=10; %Thickness per layer, i recommend 5um-20um.
nn=round(19.12/(Thick/1000));    %Height of spring structure/layer thickness
%Henry's stent height: 19.12
%round(3.4/0.020) = 170 layers
%nn=180;    %Height of spring structure/20microns for new file

wid=round(3.7/0.0071);   %Width of spring structure/7.1microns
len=round(3.7/0.0071);   %Length of spring structure/7.1microns

% Overall bitmap dimensions - we may want to drop several springs onto this
% bitmap.  For now we will drop one spring at about the middle of the
% bitmap.
b_nn=nn;       %Height of bitmap (number of bitmap layers)
b_wid=1080;    %Vertical monitor Width for bitmap. old PUSL: 1050
b_len=1920;    %Horizontal monitor length for bitmap. old PUSL: 1400

%Offset for placing spring into the final bitmap



if numstruct==1;
o_wid=b_wid/2-wid/2;
o_len=b_len/2-len/2;
end
if numstruct==2;
o_wid1=b_wid/2-wid/2;
o_len1=b_len/2-len-30;

o_wid2=b_wid/2-wid/2;
o_len2=b_len/2+30;
end

if numstruct==4;
o_wid1=b_wid/2-wid-40;
o_len1=b_len/2-len-40;

o_wid2=b_wid/2+40;
o_len2=b_len/2-len-40;

o_wid3=b_wid/2-wid-40;
o_len3=b_len/2+40;

o_wid4=b_wid/2+40;
o_len4=b_len/2+40;
end

if numinputfiles == 2;
o_wid1=b_wid/2-wid/2;
o_len1=b_len/2-len-30;

o_wid2=b_wid/2-wid/2;
o_len2=b_len/2+30;    
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
ofname_base=[dir_bmap '\' ofname_prefix];

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
    ofname=[ofname_base zer sprintf('%i.png',i)];
    imwrite(logical(bz),ofname,'png');
    colormap(gray(256));
    xlabel('X-direction');
    ylabel('Y-direction');
    axis equal tight
    %pause(.05);   %optional pause for viewing small bitmaps
end

Layer = 1; %The starting layer.
Exp=0.01; %Exposure Time 12 seconds

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
    File=[ofname_prefix zer sprintf('%i.png',i)];
    Layer=i;
   % fprintf(fileID,'%1.0f\t %-5s\t %2.0f\t %2.0f\n',Layer,File,Thick,Exp);
    fprintf(fileID,'%1.0f\t',Layer);
    fprintf(fileID,'%s\t',File);
    fprintf(fileID,'%2.0f\t',Thick);
    fprintf(fileID,'%2.0f\n',Exp);
    
end
fclose(fileID);

