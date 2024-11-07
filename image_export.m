clf;clear;clc;

% w=800;
% h=300;

h=35;
w=115;

video=VideoReader('output.mp4');

    frame = readFrame(video);
%     frame=frame(53:364,:,3);
%     frame=imresize(frame,800/416);
%     frame=frame(:,201:600,:);
%     frame=frame(351-h/2:350+h/2,201:600);
    frame=imresize(frame,1/4);
    frame=frame(111:145,286:400,3);
frame2=frame<75;

frame2(1,:)=0;
frame2(end,:)=0;
frame2(:,1)=0;
frame2(:,end)=0;

frame3=frame2;

i=2;
while i<h
    j=2;
    while j<w
        if frame3(i,j)
            check_ud = frame3(i-1,j)+frame3(i+1,j);
            check_lr = frame3(i,j-1)+frame3(i,j+1);
            check_four = check_ud+check_lr;
            if check_four<2
                frame3(i,j)=0;
                i=i-1;
                j=j-1;
            elseif check_ud==2 && check_lr==0
                frame3(i,j)=0;
                i=i-1;
                j=j-1;
            elseif check_ud==0 && check_lr==2
                frame3(i,j)=0;
                i=i-1;
                j=j-1;
            elseif ~frame3(i+1,j)
                if frame3(i+1,j-1) && ~frame3(i,j-1)
                    frame3(i,j)=0;
                    i=i-1;
                    j=j-1;
                elseif frame3(i+1,j+1) && ~frame3(i,j+1)
                    frame3(i,j)=0;
                    i=i-1;
                    j=j-1;
                end
            end
        end
        j=j+1;
    end
    i=i+1;
end


edge=logical(zeros(35,115));

for i=2:h-1
    for j=2:w-1
        if frame3(i,j)==1
            check_ud = frame3(i-1,j)+frame3(i+1,j);
            check_lr = frame3(i,j-1)+frame3(i,j+1);
            check_four = check_ud+check_lr;
            if check_four==2 || check_four==3
                edge(i,j)=1;
            end
        end
    end
end

% frame3=frame2(251:300,121:270);
% 
% frame4=frame3;
% frame4(:,1:5)=0;
% frame4(:,end-4:end)=0;
% frame4(1:5,:)=0;
% frame4(end-4:end,:)=0;
% 
% frame5=[frame3 ones(50,5) frame4];
% 
% frame5=kron(frame5,ones(4));

% arr=[0 1 1;
%      0 1 1;
%      1 0 0];
% frame=kron(arr,ones(100));
% frame=[zeros(10) zeros(10,300) zeros(10);
%        zeros(300,10) frame zeros(300,10);
%        zeros(10) zeros(10,300) zeros(10)];
% % frame3=insertText(frame,100,100,'1');,
% arr2=[0 1 1;
%       0 0 1;
%       1 0 0];
% frame2=kron(arr2,ones(100));
% frame2=[zeros(10) zeros(10,300) zeros(10);
%        zeros(300,10) frame2 zeros(300,10);
%        zeros(10) zeros(10,300) zeros(10)];
% 
% subplot(1,2,1);
% imshow(frame);
% subplot(1,2,2);
% imshow(frame2);

% frame4=[frame2 ones(35,1) frame3];
frame4=[frame3 ones(35,1),edge];

frame4=kron(frame4,ones(10));

imshow(frame4);
