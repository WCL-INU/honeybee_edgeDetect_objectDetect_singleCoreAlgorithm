clf;clear;clc;
tic
video=VideoReader('output.mp4');

current_time = datetime('now');
time_string = datestr(current_time, 'yyyymmdd_HHMMSS');

rec_video_file=VideoWriter([time_string 'rec_video_focus_noline.mp4'],'MPEG-4');
rec_video_file.FrameRate=60;
open(rec_video_file);

% h=300;
% w=800;
h=70/2;
w=450/2;

count_out=0;
count_in=0;
before_down=0;
before_up=0;
before_obj_count=0;

all_count=0;
frame_count=0;

while hasFrame(video)
    clf;

    axis square;
    axis equal;
    hold on;
    grid on;
    axis equal;
    axis([0 w 0 h]);
%     plot([0,w],[h/2,h/2],'LineWidth',2);

    up=0;
    down=0;

    frame = readFrame(video);
%     frame=frame(53:364,:,3);
%     frame=imresize(frame,800/416);
%     frame=frame(351-h/2:350+h/2,:);
    frame=imresize(frame,1/4);
    frame=frame(111:145,226:450,3);

    blue=255-frame;

    iswhite=blue>180;

    iswhite(1,:)=0;
    iswhite(:,1)=0;
    iswhite(end,:)=0;
    iswhite(:,end)=0;

    line_pixel=logical(zeros(h,w));

    i=2;
    while i<h
        j=2;
        while j<w
            if iswhite(i,j)
%                 check_four = iswhite(i-1,j)+iswhite(i+1,j)+iswhite(i,j-1)+iswhite(i,j+1);
                check_ud = iswhite(i-1,j)+iswhite(i+1,j);
                check_lr = iswhite(i,j-1)+iswhite(i,j+1);
                check_four = check_ud+check_lr;
                if check_four<2
                    iswhite(i,j)=0;
                    i=i-1;
                    j=j-1;
                elseif check_ud==2 && check_lr==0
                    iswhite(i,j)=0;
                    i=i-1;
                    j=j-1;
                elseif check_ud==0 && check_lr==2
                    iswhite(i,j)=0;
                    i=i-1;
                    j=j-1;
                elseif ~iswhite(i+1,j)
                    if iswhite(i+1,j-1) && ~iswhite(i,j-1)
                        iswhite(i,j)=0;
                        i=i-1;
                        j=j-1;
                    elseif iswhite(i+1,j+1) && ~iswhite(i,j+1)
                        iswhite(i,j)=0;
                        i=i-1;
                        j=j-1;
                    end
                end
            end
            j=j+1;
        end
        i=i+1;
    end

    for i=2:h-1
        for j=2:w-1
            if iswhite(i,j)
                check_four = iswhite(i-1,j)+iswhite(i+1,j)+iswhite(i,j-1)+iswhite(i,j+1);
                if check_four<4
                    line_pixel(i,j)=1;
                end
            end
        end
    end

    check=logical(zeros(h,w));

    obj_pixel=uint8(ones(h,w)*255);

    obj_count=0;
    for i=2:h-1
        for j=2:w-1
            if check(i,j)
                continue;
            end

            check(i,j)=1;

            if line_pixel(i,j)

                bee_size=1;

                first_coor_h=i;
                first_coor_w=j;
                
                obj_count=obj_count+1;
                obj_pixel(first_coor_h,first_coor_w)=obj_count;
                
                if line_pixel(first_coor_h+1,first_coor_w-1)
                    last_coor_h=first_coor_h+1;
                    last_coor_w=first_coor_w-1;
                    line_case=1;
                elseif line_pixel(first_coor_h+1,first_coor_w)
                    last_coor_h=first_coor_h+1;
                    last_coor_w=first_coor_w;
                    line_case=2;
                else
                    continue;
                end

                sum_coor_h=first_coor_h+last_coor_h;
                sum_coor_w=first_coor_w+last_coor_w;

                bee_size=2;
                check(last_coor_h,last_coor_w)=1;
                obj_pixel(last_coor_h,last_coor_w)=obj_count;

                while 1
                    if line_case==1
                        if line_pixel(last_coor_h-1,last_coor_w-1)
                            last_coor_h=last_coor_h-1;
                            last_coor_w=last_coor_w-1;
                            line_case=7;
                        elseif line_pixel(last_coor_h,last_coor_w-1)
                            last_coor_w=last_coor_w-1;
                            line_case=8;
                        elseif line_pixel(last_coor_h+1,last_coor_w-1)
                            last_coor_h=last_coor_h+1;
                            last_coor_w=last_coor_w-1;
                            line_case=1;
                        elseif line_pixel(last_coor_h+1,last_coor_w)
                            last_coor_h=last_coor_h+1;
                            line_case=2;
                        elseif line_pixel(last_coor_h+1,last_coor_w+1)
                            last_coor_h=last_coor_h+1;
                            last_coor_w=last_coor_w+1;
                            line_case=3;
                        else
                            break;
                        end
                    elseif line_case==2
                        if line_pixel(last_coor_h,last_coor_w-1)
                            last_coor_w=last_coor_w-1;
                            line_case=8;
                        elseif line_pixel(last_coor_h+1,last_coor_w-1)
                            last_coor_h=last_coor_h+1;
                            last_coor_w=last_coor_w-1;
                            line_case=1;
                        elseif line_pixel(last_coor_h+1,last_coor_w)
                            last_coor_h=last_coor_h+1;
                            line_case=2;
                        elseif line_pixel(last_coor_h+1,last_coor_w+1)
                            last_coor_h=last_coor_h+1;
                            last_coor_w=last_coor_w+1;
                            line_case=3;
                        elseif line_pixel(last_coor_h,last_coor_w+1)
                            last_coor_w=last_coor_w+1;
                            line_case=4;
                        else
                            break;
                        end
                    elseif line_case==3
                        if line_pixel(last_coor_h+1,last_coor_w-1)
                            last_coor_h=last_coor_h+1;
                            last_coor_w=last_coor_w-1;
                            line_case=1;
                        elseif line_pixel(last_coor_h+1,last_coor_w)
                            last_coor_h=last_coor_h+1;
                            line_case=2;
                        elseif line_pixel(last_coor_h+1,last_coor_w+1)
                            last_coor_h=last_coor_h+1;
                            last_coor_w=last_coor_w+1;
                            line_case=3;
                        elseif line_pixel(last_coor_h,last_coor_w+1)
                            last_coor_w=last_coor_w+1;
                            line_case=4;
                        elseif line_pixel(last_coor_h-1,last_coor_w+1)
                            last_coor_h=last_coor_h-1;
                            last_coor_w=last_coor_w+1;
                            line_case=5;
                        else
                            break;
                        end
                    elseif line_case==4
                        if line_pixel(last_coor_h+1,last_coor_w)
                            last_coor_h=last_coor_h+1;
                            line_case=2;
                        elseif line_pixel(last_coor_h+1,last_coor_w+1)
                            last_coor_h=last_coor_h+1;
                            last_coor_w=last_coor_w+1;
                            line_case=3;
                        elseif line_pixel(last_coor_h,last_coor_w+1)
                            last_coor_w=last_coor_w+1;
                            line_case=4;
                        elseif line_pixel(last_coor_h-1,last_coor_w+1)
                            last_coor_h=last_coor_h-1;
                            last_coor_w=last_coor_w+1;
                            line_case=5;
                        elseif line_pixel(last_coor_h-1,last_coor_w)
                            last_coor_h=last_coor_h-1;
                            line_case=6;
                        else
                            break;
                        end
                    elseif line_case==5
                        if line_pixel(last_coor_h+1,last_coor_w+1)
                            last_coor_h=last_coor_h+1;
                            last_coor_w=last_coor_w+1;
                            line_case=3;
                        elseif line_pixel(last_coor_h,last_coor_w+1)
                            last_coor_w=last_coor_w+1;
                            line_case=4;
                        elseif line_pixel(last_coor_h-1,last_coor_w+1)
                            last_coor_h=last_coor_h-1;
                            last_coor_w=last_coor_w+1;
                            line_case=5;
                        elseif line_pixel(last_coor_h-1,last_coor_w)
                            last_coor_h=last_coor_h-1;
                            line_case=6;
                        elseif line_pixel(last_coor_h-1,last_coor_w-1)
                            last_coor_h=last_coor_h-1;
                            last_coor_w=last_coor_w-1;
                            line_case=7;
                        else
                            break;
                        end
                    elseif line_case==6
                        if line_pixel(last_coor_h,last_coor_w+1)
                            last_coor_w=last_coor_w+1;
                            line_case=4;
                        elseif line_pixel(last_coor_h-1,last_coor_w+1)
                            last_coor_h=last_coor_h-1;
                            last_coor_w=last_coor_w+1;
                            line_case=5;
                        elseif line_pixel(last_coor_h-1,last_coor_w)
                            last_coor_h=last_coor_h-1;
                            line_case=6;
                        elseif line_pixel(last_coor_h-1,last_coor_w-1)
                            last_coor_h=last_coor_h-1;
                            last_coor_w=last_coor_w-1;
                            line_case=7;
                        elseif line_pixel(last_coor_h,last_coor_w-1)
                            last_coor_w=last_coor_w-1;
                            line_case=8;
                        else
                            break;
                        end
                    elseif line_case==7
                        if line_pixel(last_coor_h-1,last_coor_w+1)
                            last_coor_h=last_coor_h-1;
                            last_coor_w=last_coor_w+1;
                            line_case=5;
                        elseif line_pixel(last_coor_h-1,last_coor_w)
                            last_coor_h=last_coor_h-1;
                            line_case=6;
                        elseif line_pixel(last_coor_h-1,last_coor_w-1)
                            last_coor_h=last_coor_h-1;
                            last_coor_w=last_coor_w-1;
                            line_case=7;
                        elseif line_pixel(last_coor_h,last_coor_w-1)
                            last_coor_w=last_coor_w-1;
                            line_case=8;
                        elseif line_pixel(last_coor_h+1,last_coor_w-1)
                            last_coor_h=last_coor_h+1;
                            last_coor_w=last_coor_w-1;
                            line_case=1;
                        else
                            break;
                        end
                    elseif line_case==8
                        if line_pixel(last_coor_h-1,last_coor_w)
                            last_coor_h=last_coor_h-1;
                            line_case=6;
                        elseif line_pixel(last_coor_h-1,last_coor_w-1)
                            last_coor_h=last_coor_h-1;
                            last_coor_w=last_coor_w-1;
                            line_case=7;
                        elseif line_pixel(last_coor_h,last_coor_w-1)
                            last_coor_w=last_coor_w-1;
                            line_case=8;
                        elseif line_pixel(last_coor_h+1,last_coor_w-1)
                            last_coor_h=last_coor_h+1;
                            last_coor_w=last_coor_w-1;
                            line_case=1;
                        elseif line_pixel(last_coor_h+1,last_coor_w)
                            last_coor_h=last_coor_h+1;
                            line_case=2;
                        else
                            break;
                        end
                    end
                    if check(last_coor_h,last_coor_w)
                        break;
                    end
                    check(last_coor_h,last_coor_w)=1;
                    bee_size=bee_size+1;
                    obj_pixel(last_coor_h,last_coor_w)=obj_count;

                    sum_coor_h=sum_coor_h+last_coor_h;
                    sum_coor_w=sum_coor_w+last_coor_w;

                end
                if bee_size<20
                    for check_h=first_coor_h:h-1
                        for check_w=2:w-1
                            if obj_pixel(check_h,check_w)==obj_count
                                obj_pixel(check_h,check_w)=255;
                                iswhite(check_h,check_w)=0;
                            end
                        end
                    end
                    obj_count=obj_count-1;
                    continue;
                end

                outline_pixel=bee_size;
                for check_h=first_coor_h:h-2
                    for check_w=3:w-2
                        if iswhite(check_h,check_w)==1 && obj_pixel(check_h,check_w)==255
                            if  obj_pixel(check_h,check_w-1)==obj_count
                                obj_pixel(check_h,check_w) = obj_count;
                                check(check_h,check_w)=1;
                                bee_size=bee_size+1;
%                                 sum_coor_h=sum_coor_h+check_h;
%                                 sum_coor_w=sum_coor_w+check_w;
                            elseif obj_pixel(check_h-1,check_w)==obj_count
                                obj_pixel(check_h,check_w) = obj_count;
                                check(check_h,check_w)=1;
                                bee_size=bee_size+1;
%                                 sum_coor_h=sum_coor_h+check_h;
%                                 sum_coor_w=sum_coor_w+check_w;
                            end
                        end
                    end
                end

                if outline_pixel==bee_size
                    for check_h=first_coor_h:h-1
                        for check_w=2:w-1
                            if obj_pixel(check_h,check_w)==obj_count
                                obj_pixel(check_h,check_w)=255;
                            end
                        end
                    end
                    obj_count=obj_count-1;
                    continue;
                end

                avg_coor_w=sum_coor_w/outline_pixel;
                avg_coor_h=sum_coor_h/outline_pixel;

%                 disp(['w ' num2str(sum_coor_w)]);
%                 disp(['h ' num2str(sum_coor_h)]);

                count1obj=1;
                if bee_size>100
                    count1obj=round(bee_size/110);
                end
%                 disp(['c ' num2str(count1obj)]);
% 
                plot(avg_coor_w,avg_coor_h,'o');
                text(avg_coor_w,avg_coor_h,[num2str(count1obj) '/' num2str(bee_size)]);
                
                if avg_coor_h<h/2
                    down=down+count1obj;
                else
                    up=up+count1obj;
                end
                
            end
        end
    end

    image(obj_pixel,'AlphaData',0.3);


%     text(w*3/4,h*3/4,num2str(up));
%     text(w*3/4,h/4  ,num2str(down));

    if obj_count==before_obj_count
        minus=down-before_down;
        if minus<0
            count_in=count_in-minus;
        else
            count_out=count_out+minus;
        end
    end

%     text(w/10,h*3/4,[' in count : ' num2str(count_in)]);
%     text(w/10,h/4  ,['out count : ' num2str(count_out)]);

    before_down=down;
    before_up=up;
    before_obj_count=obj_count;

%     disp(['in : ' num2str(count_in) ' / out : ' num2str(count_out)]);

    all_count = all_count + obj_count;
    frame_count=frame_count+1;
    disp([num2str(frame_count) ' / ' num2str(all_count)]);

    rec_video_frame=getframe(gcf);
    writeVideo(rec_video_file,rec_video_frame);

    pause(0.00001);
end
toc
close(rec_video_file);