clf;clear;clc;

video=VideoReader('output.mp4');

current_time = datetime('now');
time_string = datestr(current_time, 'yyyymmdd_HHMMSS');

rec_video_file=VideoWriter([time_string 'rec_video.mp4'],'MPEG-4');
rec_video_file.FrameRate=30;
open(rec_video_file);

h=150;
w=400;

count_out=0;
count_in=0;
before_down=0;
before_up=0;
before_obj_count=0;

while hasFrame(video)
    clf;

    %subplot(2,2,1);

    frame = readFrame(video);
    frame=frame(53:364,:,3);
    frame=imresize(frame,400/416);
    frame=frame(176-h/2:175+h/2,:);
    %imshow(frame);

    subplot(3,2,1);

    blue=frame(:,:);
    blue=255-blue;
    imshow(blue);
    title('blue');

    subplot(3,2,2);

    iswhite=blue>180;

    iswhite(1,:)=0;
    iswhite(:,1)=0;
    iswhite(end,:)=0;
    iswhite(:,end)=0;

    i=2;
    while i<h
        j=2;
        while j<w
            if iswhite(i,j)
                check_four = iswhite(i-1,j)+iswhite(i+1,j)+iswhite(i,j-1)+iswhite(i,j+1);
                if check_four<2
                    iswhite(i,j)=0;
                    i=i-1;
                    j=j-1;
                end
            end
            j=j+1;
        end
        i=i+1;
    end

%     for i=2:h-1
%         for j=2:w-1
%             if iswhite(i,j)
%                 check_four = iswhite(i-1,j)+iswhite(i+1,j)+iswhite(i,j-1)+iswhite(i,j+1);
%                 if check_four<2
%                     iswhite(i,j)=0;
%                     i=i-1;
%                     j=j-1;
%                 end
%             end
%         end
%     end

    imshow(iswhite);
    title('iswhite');

    subplot(3,2,3);

%     red_line(:,:,1)=uint8(zeros(h,w)+iswhite*255);
%     red_line(:,:,2)=uint8(zeros(h,w)+iswhite*255);
%     red_line(:,:,3)=uint8(zeros(h,w)+iswhite*255);

    line_pixel=logical(zeros(h,w));

    for i=2:h-1
        for j=2:w-1
            if iswhite(i,j)
                check_four = iswhite(i-1,j)+iswhite(i+1,j)+iswhite(i,j-1)+iswhite(i,j+1);
                if check_four>1 && check_four<4
                    line_pixel(i,j)=1;
                end
            end
%             if iswhite(i-1,j)~=iswhite(i,j) || iswhite(i,j-1)~=iswhite(i,j)
% %                 red_line(i,j,1)=255;
% %                 red_line(i,j,2:3)=0;
%                 
%                 line_pixel(i,j)=1;
%             end
        end
    end
    %imshow(red_line);
    imshow(line_pixel);
    title('line pixel');

    check=logical(zeros(h,w));

    obj_pixel=uint8(ones(h,w)*255);

    obj_count=0;
%     obj_coordinate={};

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
%                     if first_coor_h==last_coor_h && first_coor_w==last_coor_w
%                         break;
%                     end
%                     if last_coor_h~=h && last_coor_w~=1 && line_case~=4
%                         if line_pixel(last_coor_h+1,last_coor_w-1)==1 && check(last_coor_h+1,last_coor_w-1)==0
%                             %좌하단
%                             flag=1;
%                             line_case=1;
%                             check(last_coor_h+1,last_coor_w-1)=1;
% %                             obj_coordinate{obj_count}=[obj_coordinate{obj_count} [last_coor_h+1;
% %                                                                                   last_coor_w-1]];
%                             last_coor_h=last_coor_h+1;
%                             last_coor_w=last_coor_w-1;
%                         end
%                     end
%                     if last_coor_h~=h && flag==0 && line_case~=5
%                         if line_pixel(last_coor_h+1,last_coor_w)==1 && check(last_coor_h+1,last_coor_w)==0
%                             %하단
%                             flag=1;
%                             line_case=2;
%                             check(last_coor_h+1,last_coor_w)=1;
% %                             obj_coordinate{obj_count}=[obj_coordinate{obj_count} [last_coor_h+1;
% %                                                                                   last_coor_w]];
%                             last_coor_h=last_coor_h+1;
%                             %last_coor_w=last_coor_w;
%                         end
%                     end
%                     if last_coor_w~=w && flag==0 && line_case~=6
%                         if line_pixel(last_coor_h,last_coor_w+1)==1 && check(last_coor_h,last_coor_w+1)==0
%                             %우측
%                             flag=1;
%                             line_case=3;
%                             check(last_coor_h,last_coor_w+1)=1;
% %                             obj_coordinate{obj_count}=[obj_coordinate{obj_count} [last_coor_h;
% %                                                                                   last_coor_w+1]];
%                             %last_coor_h=last_coor_h;
%                             last_coor_w=last_coor_w+1;
%                         end
%                     end
%                     if last_coor_h~=1 && last_coor_w~=w && flag==0 && line_case~=1
%                         if line_pixel(last_coor_h-1,last_coor_w+1)==1 && check(last_coor_h-1,last_coor_w+1)==0
%                             %우상단
%                             flag=1;
%                             line_case=4;
%                             check(last_coor_h-1,last_coor_w+1);
% %                             obj_coordinate{obj_count}=[obj_coordinate{obj_count} [last_coor_h-1;
% %                                                                                   last_coor_w+1]];
%                             last_coor_h=last_coor_h-1;
%                             last_coor_w=last_coor_w+1;
%                         end
%                     end
%                     if last_coor_h~=1 && flag==0 && line_case~=2
%                         if line_pixel(last_coor_h-1,last_coor_w)==1 && check(last_coor_h-1,last_coor_w)==0
%                             %상단
%                             flag=1;
%                             line_case=5; 
%                             check(last_coor_h-1,last_coor_w)=1;
% %                             obj_coordinate{obj_count}=[obj_coordinate{obj_count} [last_coor_h-1;
% %                                                                                   last_coor_w]];
%                             last_coor_h=last_coor_h-1;
%                             %last_coor_w=last_coor_w;
%                         end
%                     end
%                     if last_coor_w~=1 && flag==0 && line_case~=3
%                         if line_pixel(last_coor_h,last_coor_w-1)==1 && check(last_coor_h,last_coor_w-1)==0
%                             %좌측
%                             flag=1;
%                             line_case=6;
%                             check(last_coor_h,last_coor_w-1)=1;
% %                             obj_coordinate{obj_count}=[obj_coordinate{obj_count} [last_coor_h;
% %                                                                                   last_coor_w-1]];
%                             %last_coor_h=last_coor_h;
%                             last_coor_w=last_coor_w-1;
%                         end
%                     end
%                     if flag==0
%                         break;
%                     end
                    bee_size=bee_size+1;
%                     check(obj_coordinate{obj_count}(1,end),obj_coordinate{obj_count}(2,end))=1;
%                     obj_pixel(obj_coordinate{obj_count}(1,end),obj_coordinate{obj_count}(2,end))=255-obj_count;
                    obj_pixel(last_coor_h,last_coor_w)=obj_count;
                end
                if bee_size<25
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
                for check_h=3:h-2
                    for check_w=3:w-2
%                         if obj_pixel(check_h,check_w-1)==obj_count && iswhite(check_h,check_w)==1 && obj_pixel(check_h,check_w)==255
%                             obj_pixel(check_h,check_w) = obj_count;
%                             check(check_h,check_w)=1;
%                             check_point=check_point+1;
%                         end
                        if iswhite(check_h,check_w)==1 && obj_pixel(check_h,check_w)==255
                            if  obj_pixel(check_h,check_w-1)==obj_count
                                obj_pixel(check_h,check_w) = obj_count;
                                check(check_h,check_w)=1;
                                bee_size=bee_size+1;
                            elseif obj_pixel(check_h-1,check_w)==obj_count
                                obj_pixel(check_h,check_w) = obj_count;
                                check(check_h,check_w)=1;
                                bee_size=bee_size+1;
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

            end
        end
    end
    
%     subplot(3,2,4);
%     axis square;
%     axis equal;
%     axis([0 1600 -600 00]);
%     grid on;
%     hold on;
%     for i=1:obj_count
%         if length(obj_coordinate{i})<100
%             continue;
%         end
%         plot([obj_coordinate{i}(2,:) obj_coordinate{i}(2,1)],-[obj_coordinate{i}(1,:) obj_coordinate{i}(1,1)]);
%     end
%     title('plot');
%     hold off;

%     for i=2:h-1
%         for j=2:w-1
%             if obj_pixel(i,j-1)~=255 && iswhite(i,j)==1 %|| (obj_pixel(i-1,j)~=0 && iswhite(i,j)==1)
%                 obj_pixel(i,j)=obj_pixel(i,j-1);
%             end
% %             if obj_pixel(i-1,j)~=0 && iswhite(i,j)==1
% %                 obj_pixel(i,j)=obj_pixel(i-1,j);
% %             end
%         end
%     end

%     for check_obj_all_pixel=1:obj_count
%         obj_pixel_length=sum(obj_pixel==check_obj_all_pixel,'all');
%         if obj_pixel_length<500
%             obj_pixel(obj_pixel==check_obj_all_pixel)=255;
%         end
%     end

    subplot(3,2,4);
    imshow(obj_pixel);
    title('obj pixel');

    subplot(3,2,5);
    [default_w_idx,default_h_idx]=meshgrid(1:w,1:h);
    axis square;
    axis equal;
    axis([0 w -h 00]);
    hold on;
    grid on;
    for i=1:obj_count
        obj_pixel_idx = (obj_pixel==i);
        avg_w=sum(default_w_idx.*obj_pixel_idx,'all')/sum(obj_pixel_idx,'all');
        avg_h=sum(default_h_idx.*obj_pixel_idx,'all')/sum(obj_pixel_idx,'all');
        plot(avg_w,-avg_h,'o');
    end
    title('center of object');

    subplot(3,2,6);
    axis square;
    axis equal;
    hold on;
    grid on;
    image(obj_pixel);
    axis([0 w 0 h]);

    up=0;
    down=0;

    plot([0 400],[75 75],'LineWidth',2);
    for i=1:obj_count
        obj_pixel_idx = (obj_pixel==i);
        avg_w=sum(default_w_idx.*obj_pixel_idx,'all')/sum(obj_pixel_idx,'all');
        avg_h=sum(default_h_idx.*obj_pixel_idx,'all')/sum(obj_pixel_idx,'all');
        plot(avg_w,avg_h,'ro');
        if avg_h<75
            down=down+1;
        else
            up=up+1;
        end
    end
%     text(25,250,num2str(obj_count));
    text(350,100,num2str(up));
    text(350, 50,num2str(down));
    if obj_count==before_obj_count
        minus=down-before_down;
        if minus<0
            count_in=count_in-minus;
        else
            count_out=count_out+minus;
        end
    end

    text(12,100,[' in count : ' num2str(count_in)]);
    text(12, 50,['out count : ' num2str(count_out)]);

    before_down=down;
    before_up=up;
    before_obj_count=obj_count;

    rec_video_frame=getframe(gcf);
    writeVideo(rec_video_file,rec_video_frame);

    pause(0.00001);
end

close(rec_video_file);

% url = 'http://kjh1131.dothome.co.kr/beeCounter/beeCounter_image_1/bee.jpg';
% download_image=webread(url);
% imshow(download_image);
