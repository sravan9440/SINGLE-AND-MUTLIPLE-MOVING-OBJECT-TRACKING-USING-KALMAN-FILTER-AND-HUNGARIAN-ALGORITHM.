clc;
close all;
clear all;
video = VideoReader('rhinos.avi'); %in place of aviread
%nframes = length(video);
nframes=video.NumberOfFrames;
for i=1:nframes
mov(i).cdata=read(video,i) 
%creating '.cdata' field to avoid much changes to previous code
end 
temp = zeros(size(mov(1).cdata));
[M,N] = size(temp(:,:,1));
for i = 1:10
temp = double(mov(i).cdata) + temp;
end
imbkg = temp/10;centroidx = zeros(nframes,1);
centroidy = zeros(nframes,1);
predicted = zeros(nframes,4);
actual = zeros(nframes,4);
R=[[0.2845,0.0045]',[0.0045,0.0455]'];
H=[[1,0]',[0,1]',[0,0]',[0,0]'];
Q=0.01*eye(4);
P = 100*eye(4);
dt=1;
A=[[1,0,0,0]',[0,1,0,0]',[dt,0,1,0]',[0,dt,0,1]'];
kfinit = 0;
th = 38;
for i=1:nframes
imshow(mov(i).cdata);
hold on
imcurrent = double(mov(i).cdata);
diffimg = zeros(M,N);
diffimg = (abs(imcurrent(:,:,1)-imbkg(:,:,1))>th) ...
| (abs(imcurrent(:,:,2)-imbkg(:,:,2))>th) ...
| (abs(imcurrent(:,:,3)-imbkg(:,:,3))>th);
labelimg = bwlabel(diffimg,4);
markimg = regionprops(labelimg,['basic']);
[MM,NN] = size(markimg);
for nn = 1:MM
if markimg(nn).Area > markimg(1).Area
tmp = markimg(1);
markimg(1)= markimg(nn);
markimg(nn)= tmp;
end
end
bb = markimg(1).BoundingBox;
xcorner = bb(1);
ycorner = bb(2);
xwidth = bb(3);
ywidth = bb(4);
cc = markimg(1).Centroid;
centroidx(i)= cc(1);
centroidy(i)= cc(2);
hold on
rectangle('Position',[xcorner ycorner xwidth ywidth],'EdgeColor','b');
hold on
plot(centroidx(i),centroidy(i), 'bx');
kalmanx = centroidx(i)- xcorner;
kalmany = centroidy(i)- ycorner;

if kfinit == 0
predicted =[centroidx(i),centroidy(i),0,0]' ;
else
predicted = A*actual(i-1,:)';
end
kfinit = 1;
Ppre = A*P*A' + Q;
K = Ppre*H'/(H*Ppre*H'+R);
actual(i,:) = (predicted + K*([centroidx(i),centroidy(i)]' - H*predicted))';
P = (eye(4)-K*H)*Ppre;
hold on
rectangle('Position',[(actual(i,1)-kalmanx)...
(actual(i,2)-kalmany) xwidth ywidth],'EdgeColor','r','LineWidth',1.5);
hold on
plot(actual(i,1),actual(i,2), 'rx','LineWidth',1.5);
drawnow;
end
