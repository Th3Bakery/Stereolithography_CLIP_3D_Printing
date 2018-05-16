function [varargout]=fileread(filein);
%function [varargout]=fileread(filein);
% This function reads the columns from ASCI file named filein
% into vectors specified in the original calling routine. The
% variable varargout allows you to use a variable number of
% output arguments.
% Example: 
%        txfile='wire.rsp';   
%        [freq1,db1,gd1,phase1]=fileread(txfile);
% Opens the file wire.rsp and puts column 1 into freq1, 
% column 2 into db1, etc...
%
nout = max(nargout,1);   %Figure out how many output arguments were asked for.
x=str_filenm(filein);
tx=['load ' filein];
eval(tx);
eval(['y =' x ';']);
[m,n]=size(y);
% Make sure you are not asking for more outputs than you have columns of data
% in the matrix y.
if (n<nout),
   error(['ERROR: You asked for more outputs from fileread than you have columns in ' filein])
end
%varargout(1)=1
%varargout(2)=2
%varargout(3)=3
for i=1:nout
   varargout(i) = {y(:,i)};
end
