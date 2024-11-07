% h=300;
% w=800;
h=70/2;
w=450/2;

count_out=0;
count_in=0;
before_down=0;
before_up=0;
before_obj_count=0;

while hasFrame(video)

    frame = readFrame(video);

    frame=imresize(frame,1/4);
    frame=frame(111:145,226:450,3);

    subplot(6,1,1);

    blue=frame(:,:);
    blue=255-blue;

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
                        else
                            break;
                        end
                    elseif line_case==2
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
                        else
                            break;
                        end
                    elseif line_case==4
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
                        else
                            break;
                        end
                    elseif line_case==6
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
                        else
                            break;
                        end
                    elseif line_case==8
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
                for check_h=3:h-2
                    for check_w=3:w-2
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
    
    [default_w_idx,default_h_idx]=meshgrid(1:w,1:h);

    for i=1:obj_count
        obj_pixel_idx = (obj_pixel==i);
        avg_w=sum(default_w_idx.*obj_pixel_idx,'all')/sum(obj_pixel_idx,'all');
        avg_h=sum(default_h_idx.*obj_pixel_idx,'all')/sum(obj_pixel_idx,'all');
    end
    
    up=0;
    down=0;

    for i=1:obj_count
        obj_pixel_idx = (obj_pixel==i);
        avg_w=sum(default_w_idx.*obj_pixel_idx,'all')/sum(obj_pixel_idx,'all');
        avg_h=sum(default_h_idx.*obj_pixel_idx,'all')/sum(obj_pixel_idx,'all');
        if avg_h<h/2
            down=down+1;
        else
            up=up+1;
        end
    end

    if obj_count==before_obj_count
        minus=down-before_down;
        if minus<0
            count_in=count_in-minus;
        else
            count_out=count_out+minus;
        end
    end

    before_down=down;
    before_up=up;
    before_obj_count=obj_count;
end
