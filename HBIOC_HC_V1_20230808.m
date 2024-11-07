clf;clear;clc;

video=VideoReader('output.mp4');

current_time = datetime('now');
time_string = datestr(current_time, 'yyyymmdd_HHMMSS');

rec_video_file=VideoWriter(['rec_video' time_string '.mp4'],'MPEG-4');
rec_video_file.FrameRate=30;
open(rec_video_file);

h=300;%300행
w=800;%800열

count_out=0;    %누적 나간 벌 수
count_in=0;     %누적 들어온 벌 수
before_down=0;  %이전 픽셀에서 기준선 아래에 있던 벌 수
before_up=0;    %이전 픽셀에서 기준선 위에 있던 벌 수
before_obj_count=0; %이전 픽셀에서 카운트 된 전체 벌 수 / before_down+before+up과 같음 귀찮아서 코드 추가함

while hasFrame(video)   %다음 픽셀이 있을때까지 / 카메라 모듈 사용할 경우 무한대로 반복문 시작할때마다 프레임 촬영
    clf;

    frame = readFrame(video);   %영상에서 한 프레임 불러옴
    frame=frame(53:364,:,3);    %1대1영상에서 원래 이미지 사이즈만 추출 / 매트박스 부분 삭제
                                %지금 사용하는 영상에서 원본 해상도 416:416,RGB에서 blue값만 추출함
    frame=imresize(frame,800/416);  %잘라낸 이미지에서 800:800으로 비율 조정
                                    %알고리즘 완성 후 해상도를 더 낮아도 연산이 가능한지 확인 해볼 예정
    frame=frame(351-h/2:350+h/2,:,:);   %원본영상에서 필요한 부분만 추출 / 8대3 비율로 추출함

    subplot(3,2,1);

    blue=frame(:,:);    %기존에 blue데이터만 추출하고 이미지를 자르지 않아서 여기서 잘랐었음 / 의미없음
    blue=255-blue;      %색 반전, 배경이 0에 가깝고 벌이 255에 가깝게 처리됨
    imshow(blue);       %반전된 blue이미지
    title('blue');

    subplot(3,2,2);

    iswhite=blue>180;   %blue에서 180이상인 부분만 추출, 대부분이 벌인 영역임

    iswhite(1,:)=0;
    iswhite(:,1)=0;
    iswhite(end,:)=0;
    iswhite(:,end)=0;   %테두리 값은 전부 배경과 같은 색으로 처리 / 아래 코드에서 외곽선 잡기 쉽게 하기 위함

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
    %위 이중 while loop은 벌 영역 픽셀을 다듬기 위함, 픽셀의 상하좌우 중 벌인 영역이 2개 이상이 아니라면 튀어나온
    %픽셀로 연산하기 어려움, 그냥 배경으로 취급함

    imshow(iswhite);
    title('iswhite');

    subplot(3,2,3);

    line_pixel=logical(zeros(h,w)); %외곽선을 표시하기 위한 matrix, 연산 후 외곽선은 0으로 표시됨

    for i=2:h-1
        for j=2:w-1
            if iswhite(i,j)
                check_four = iswhite(i-1,j)+iswhite(i+1,j)+iswhite(i,j-1)+iswhite(i,j+1);
                if check_four>1 && check_four<4
                    line_pixel(i,j)=1;
                end
            end
        end
    end
    %자신이 벌에 위치한 픽셀이면서,
    %자신의 상하좌우에 벌인 픽셀이 2개이거나 3개이면 외곽선인 픽셀로 취급하고 ㅣine_pixel을 1로 표시함

    imshow(line_pixel);
    title('line pixel');

    check=logical(zeros(h,w));  %모든 픽셀을 확인하면서 확인한 픽셀인지 표시하는 matrix, 연산량을 줄이기 위함

    obj_pixel=uint8(ones(h,w)*255); %각 벌을 구성하는 픽셀을 저장하는 matrix
                                    %배경의 값은 255, 첫번째로 검출되는 벌의 위치의 값은 1,
                                    %두번째 벌은 2, 세번째 벌은 3...

    obj_count=0;    %검출된 벌의 수, obj_pixel에 값을 넣을 때 사용됨
    for i=2:h-1
        for j=2:w-1 %테두리는 보두 배경으로 취급하기 때문에 해당 영역은 제외하고 확인함
            if check(i,j)
                continue;
            end     %check한 픽셀이라면 추가로 확인할 필요 없으므로 다음 픽셀로 넘어감

            check(i,j)=1;   %앞에서 continue되지 않았다면 이제 해당 픽셀을 검사할거기 때문에 1로 표시함

            if line_pixel(i,j)  %해당 픽셀이 외곽선에 해당한다면

                bee_size=1;     %벌 하나의 개체를 이루는 사이즈를 카운트 함
                                %1로 시작해서 값이 늘어남

                first_coor_h=i;
                first_coor_w=j; %벌의 외곽선의 첫번째 좌표
                
                obj_count=obj_count+1;  %검출된 벌의 수 증가
                obj_pixel(first_coor_h,first_coor_w)=obj_count; %해당 픽셀에 해당 번호 개체의 값 대입

                %line_case라는 변수는 1~8로 구성됨
                %우상단에서 좌하단으로 다음 픽셀을 검출하면 case1, 반시계 방향으로 45도씩
                %case2,case3...

                %if문 안의 last_coor_h와 last_coor_w는 마지막으로 검출한 외곽선픽셀의 좌표를 나타냄

                %외곽선은 중심을 기준으로 반시계반향으로 돌면서 감지함
                
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
                %한 열씩 좌->우로 check하기 때문에 첫번째로 검출되는 외곽선 픽셀의 다음 픽셀은 좌하단이나 하단에
                %위치해야함 case1,case2인지만 확인함

                %앞에서 보정을 했기 때문에(line63주석 확인) 첫번째 좌표에서 갈 수 있는 케이스는 1,2밖에 없음

                bee_size=2; %다음 픽셀을 찾았기 때문에 벌을 구성하는 픽셀수 1 증가한 2
                check(last_coor_h,last_coor_w)=1;   %마지막으로 검출한 좌표를 check함
                obj_pixel(last_coor_h,last_coor_w)=obj_count;   %검출된 좌표에 몇번째 벌의 좌표인지 대입

                while 1
                    %while loop를 돌면서 한 개체의 외곽선을 검출함
                    %보정을 했기 때문에 진행방향 오른쪽 90도에서 왼쪽 90도 사이에서 검출되어야 함
                    %검출되지 않으면 외곽선이 끊겼다는 뜻으로 해석하고 break;
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
                        break;  %새로 외곽선으로 검출된 좌표가 예전에 check한적이 있다면 break;
                                %대체로 해당 개체의 첫번째 좌표일 가능성이 높음
                    end
                    check(last_coor_h,last_coor_w)=1;   %새로 검출된 외곽선 좌표를 지나왔으므로 1로 check함
                    bee_size=bee_size+1;    %해당 개체를 구성하는 벌의 픽셀수 증가
                    obj_pixel(last_coor_h,last_coor_w)=obj_count;   %해당 개체를 구성하는 벌임을 표시
                end
                if bee_size<50  %현재까지는 외곽선을 구성하는 픽셀만 구함, 해당 픽셀 수가 50개를 넘지 않는다면
                                %벌의 사이즈가 아니라고 판단(물론 50이 기준일 필요는 없음, 임의로 잡음)
                    for check_h=first_coor_h:h-1
                        for check_w=2:w-1
                            if obj_pixel(check_h,check_w)==obj_count
                                obj_pixel(check_h,check_w)=255;
                                iswhite(check_h,check_w)=0;
                            end
                        end
                    end %matrix 전체를 확인하면서 해당 개체 삭제
                    obj_count=obj_count-1;  %해당 개체를 삭제함으로서 감지한 벌의 수도 감ㅅ
                    continue;   %아래 코드를 수행할 이유가 없으므로 다음 픽셀을 감지하기 위한 continue
                end

                outline_pixel=bee_size; %현재까지 외곽선을 구성하는 픽셀만 카운트 해놨으므로 값 저장
                for check_h=first_coor_h:h-2    %내부 픽셀은 무조건 외곽선으로 검출된 첫번째 픽셀보다 아래에 위치함
                                                %first_coor_h+1부터 검사해도 됨
                    for check_w=3:w-2   %외곽선이 아닌 내부를 구성하는 픽셀을 검출하기 위한 loop이므로
                                        %이미지에서 제일 바깥쪽 픽셀은 무조건 배경, 바깥쪽에서 두번째
                                        %픽셀부터 배경일 수 있으므로 개체의 내부를 구성하는 픽셀은 무조건
                                        %이미지 바깥에서 세번째 픽셀부터 가능성이 있음
                        if iswhite(check_h,check_w)==1 && obj_pixel(check_h,check_w)==255
                                    %자신이 벌 개체를 구성하는 픽셀이면서, 외곽선으로 취급받지 않은
                                    %픽셀(사실 obj_pixel 검사 안해도 되지만 혹시 몰라서 넣어놓음)
                                    %현재 외곽선만 해당 개체 번호이며 다른 픽셀은 전부 배경과 같은
                                    %255임
                            if  obj_pixel(check_h,check_w-1)==obj_count
                                obj_pixel(check_h,check_w) = obj_count;
                                check(check_h,check_w)=1;
                                bee_size=bee_size+1;
                            elseif obj_pixel(check_h-1,check_w)==obj_count
                                obj_pixel(check_h,check_w) = obj_count;
                                check(check_h,check_w)=1;
                                bee_size=bee_size+1;
                            end %위나 아래가 해당 개체의 벌 숫자라면 자신도 해당 벌 개체 픽셀임
                                %해당 픽셀의 개체확인도 했으니 check도 표시
                        end
                    end
                end
                if outline_pixel==bee_size
                                %외곽선만 존재하고 해당 벌을 구성하는 내부 픽셀이 없다는 뜻
                                %문제가 있으므로 해당 벌 개체 삭제
                                %위에서 삭제한 방식과 동일
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
            %각 개체들의 중심 좌표를 평균을 사용하여 구하고 plot으로 표시함
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

    plot([0 800],[150 150],'LineWidth',2);
    for i=1:obj_count
        obj_pixel_idx = (obj_pixel==i);
        avg_w=sum(default_w_idx.*obj_pixel_idx,'all')/sum(obj_pixel_idx,'all');
        avg_h=sum(default_h_idx.*obj_pixel_idx,'all')/sum(obj_pixel_idx,'all');
        plot(avg_w,avg_h,'ro');

        %obj_pixel 위에 중심점도 같이 표시함

        if avg_h<150
            down=down+1;
        else
            up=up+1;
        end
    end %중심선을 기준으로 위에 있는지 아래에 있는지 판단함

    text(700,200,num2str(up));
    text(700,100,num2str(down));

    %임시로 만든 출입 계수 카운터
    %정확도가 매우 낮으며 loss율이 높음
    if obj_count==before_obj_count  %이전 프레임과 전체 벌의 수가 같은 것을 전제로 함
        minus=down-before_down;
        if minus<0
            count_in=count_in-minus;
        else
            count_out=count_out+minus;
        end
    end

    text(25,200,[' in count : ' num2str(count_in)]);
    text(25,100,['out count : ' num2str(count_out)]);

    before_down=down;
    before_up=up;
    before_obj_count=obj_count;

    rec_video_frame=getframe(gcf);
    writeVideo(rec_video_file,rec_video_frame);

    pause(0.00001);
end

close(rec_video_file);