#include<stdio.h>
#include<opencv2/opencv.hpp>
#include<opencv2/highgui/highgui.hpp>

#define h 1080
#define w 1920

int main(int, char**){

    unsigned int count_out=0;
    unsigned int count_in=0;
    unsigned char before_down=0;
    unsigned char before_up=0;
    unsigned char before_obj_count=0;

    cv::VideoCapture cap(0);
    if(!cap.isOpened())return -1;
    cv::Mat frame;

    for(int _=0;_<100;_++){
        unsigned char up=0;
        unsigned char down=0;
        
        cap >> frame;

        if (frame.empty())return -1;

        if(frame.channels!=3)return -1;

        // h=frame.cols;
        // w=frame.rows;

        //pixel_data 0~ : iswhite/line_pixel/check

        unsigned char* RGB_pixel=frame.data;
        unsigned char pixel_data[w][h];
        for(int i=0;i<h;i++){
            for(int j=0;j<w;j++){
                if(RGB_pixel[(i*w+h)*3+2]<75)pixel_data[i][j]=1;
                else                         pixel_data[i][j]=0;
            }
        }
        //free(RGB_pixel);
        unsigned char check_four=0;
        for(int i=1;i<h-1;i++){
            for(int j-1;j<w-1;j++){
                check_four=pixel_data[i-1][j]&0x01+pixel_data[i+1][j]&0x01
                          +pixel_data[i][j-1]&0x01+pixel_data[i][j+1]&0x01;
                if(pixel_data[i][j]&0x01 && check_four&0x02){
                    pixel_data[i][j]+=2;
                }
            }
        }
        unsigned char obj_pixel[w][h]={0,};
        unsigned char obj_count=0;
        for(int i=1;i<h-1;i++){
            for(int j=1;j<w-1;j++){
                if(pixel_data[i][j]&0x04)continue;
                pixel_data[i][j]+=4;
                if(pixel_data[i][j]&0x02){
                    unsigned int bee_size=1;
                    unsigned int first_coor_h=i;
                    unsigned int first_coor_w=j;
                    unsigned int last_coor_h=first_coor_h;
                    unsigned int last_coor_w=first_coor_w;
                    unsigned char line_case=0;
                    unsigned int sum_coor_h;
                    unsigned int sum_coor_w;
                    obj_count++;
                    obj_pixel[first_coor_h,first_coor_w]=obj_count;

                    if(pixel_data[first_coor_h+1][first_coor_w-1]&0x02){
                        last_coor_h=first_coor_h++;
                        last_coor_w=first_coor_w--;
                        line_case=1;
                    }else if(pixel_data[first_coor_h+1][first_coor_w]&0x02){
                        last_coor_h++;
                        line_case=2;
                    }else continue;

                    sum_coor_h=first_coor_h+last_coor_h;
                    sum_coor_w=first_coor_w+last_coor_w;
                    bee_size++;
                    pixel_data[last_coor_h][last_coor_w]+=4;
                    obj_pixel[last_coor_h][last_coor_w]=obj_count;

                    while(1){
                        if(line_case==1){
                            if(pixel_data[last_coor_h-1][last_coor_w-1]&0x02){
                                last_coor_h--;
                                last_coor_w--;
                                line_case=7;
                            }else if(pixel_data[last_coor_h][last_coor_w-1]&0x02){
                                last_coor_w--;
                                line_case=8;
                            }else if(pixel_data[last_coor_h+1][last_coor_w-1]&0x02){
                                last_coor_h++;
                                last_coor_w--;
                                line_case=1;
                            }else if(pixel_data[last_coor_h+1][last_coor_w]&0x02){
                                last_coor_h++;
                                line_case=2;
                            }else if(pixel_data[last_coor_h+1][last_coor_w+1]&0x02){
                                last_coor_h++;
                                last_coor_w++;
                                line_case=3;
                            }else break;
                        }else if(line_case==2){
                            if(pixel_data[last_coor_h][last_coor_w-1]&0x02){
                                last_coor_w--;
                                line_case=8;
                            }else if(pixel_data[last_coor_h+1][last_coor_w-1]&0x02){
                                last_coor_h++;
                                last_coor_w--;
                                line_case=1;
                            }else if(pixel_data[last_coor_h+1][last_coor_w]&0x02){
                                last_coor_h++;
                                line_case=2;
                            }else if(pixel_data[last_coor_h+1][last_coor_w+1]&0x02){
                                last_coor_h++;
                                last_coor_w++;
                                line_case=3;
                            }else if(pixel_data[last_coor_h][last_coor_w+1]&0x02){
                                last_coor_w++;
                                line_case=4;
                            }else break;
                        }else if(line_case==3){
                            if(pixel_data[last_coor_h+1][last_coor_w-1]&0x02){
                                last_coor_h++;
                                last_coor_w--;
                                line_case=1;
                            }else if(pixel_data[last_coor_h+1][last_coor_w]&0x02){
                                last_coor_h++;
                                line_case=2;
                            }else if(pixel_data[last_coor_h+1][last_coor_w+1]&0x02){
                                last_coor_h++;
                                last_coor_w++;
                                line_case=3;
                            }else if(pixel_data[last_coor_h][last_coor_w+1]&0x02){
                                last_coor_w++;
                                line_case=4;
                            }else if(pixel_data[last_coor_h-1][last_coor_w+1]&0x02){
                                last_coor_h--;
                                last_coor_w++;
                                line_case=5;
                            }else break;
                        }else if(line_case==4){
                            if(pixel_data[last_coor_h+1][last_coor_w]&0x02){
                                last_coor_h++;
                                line_case=2;
                            }else if(pixel_data[last_coor_h+1][last_coor_w+1]&0x02){
                                last_coor_h++;
                                last_coor_w++;
                                line_case=3;
                            }else if(pixel_data[last_coor_h][last_coor_w+1]&0x02){
                                last_coor_w++;
                                line_case=4;
                            }else if(pixel_data[last_coor_h-1][last_coor_w+1]&0x02){
                                last_coor_h--;
                                last_coor_w++;
                                line_case=5;
                            }else if(pixel_data[last_coor_h-1][last_coor_w]&0x02){
                                last_coor_h--;
                                line_case=6;
                            }else break;
                        }else if(line_case==5){
                            if(pixel_data[last_coor_h+1][last_coor_w+1]&0x02){
                                last_coor_h++;
                                last_coor_w++;
                                line_case=3;
                            }else if(pixel_data[last_coor_h][last_coor_w+1]&0x02){
                                last_coor_w++;
                                line_case=4;
                            }else if(pixel_data[last_coor_h-1][last_coor_w+1]&0x02){
                                last_coor_h--;
                                last_coor_w++;
                                line_case=5;
                            }else if(pixel_data[last_coor_h-1][last_coor_w]&0x02){
                                last_coor_h--;
                                line_case=6;
                            }else if(pixel_data[last_coor_h-1][last_coor_w-1]&0x02){
                                last_coor_h--;
                                last_coor_w--;
                                line_case=7;
                            }else break;
                        }else if(line_case==6){
                            if(pixel_data[last_coor_h][last_coor_w+1]&0x02){
                                last_coor_w++;
                                line_case=4;
                            }else if(pixel_data[last_coor_h-1][last_coor_w+1]&0x02){
                                last_coor_h--;
                                last_coor_w++;
                                line_case=5;
                            }else if(pixel_data[last_coor_h-1][last_coor_w]&0x02){
                                last_coor_h--;
                                line_case=6;
                            }else if(pixel_data[last_coor_h-1][last_coor_w-1]&0x02){
                                last_coor_h--;
                                last_coor_w--;
                                line_case=7;
                            }else if(pixel_data[last_coor_h][last_coor_w-1]&0x02){
                                last_coor_w--;
                                line_case=8;
                            }else break;
                        }else if(line_case==7){
                            if(pixel_data[last_coor_h-1][last_coor_w+1]&0x02){
                                last_coor_h--;
                                last_coor_w++;
                                line_case=5;
                            }else if(pixel_data[last_coor_h-1][last_coor_w]&0x02){
                                last_coor_h--;
                                line_case=6;
                            }else if(pixel_data[last_coor_h-1][last_coor_w-1]&0x02){
                                last_coor_h--;
                                last_coor_w--;
                                line_case=7;
                            }else if(pixel_data[last_coor_h][last_coor_w-1]&0x02){
                                last_coor_w--;
                                line_case=8;
                            }else if(pixel_data[last_coor_h+1][last_coor_w-1]&0x02){
                                last_coor_h++;
                                last_coor_w--;
                                line_case=1;
                            }else break;
                        }else if(line_case==8){
                            if(pixel_data[last_coor_h-1][last_coor_w]&0x02){
                                last_coor_h--;
                                line_case=6;
                            }else if(pixel_data[last_coor_h-1][last_coor_w-1]&0x02){
                                last_coor_h--;
                                last_coor_w--;
                                line_case=7;
                            }else if(pixel_data[last_coor_h][last_coor_w-1]&0x02){
                                last_coor_w--;
                                line_case=8;
                            }else if(pixel_data[last_coor_h+1][last_coor_w-1]&0x02){
                                last_coor_h++;
                                last_coor_w--;
                                line_case=1;
                            }else if(pixel_data[last_coor_h+1][last_coor_w]&0x02){
                                last_coor_h++;
                                line_case=2;
                            }else break;
                        }
                        if(pixel_data[last_coor_h][last_coor_w]&0x04)break;
                        pixel_data[last_coor_h][last_coor_w]+=4;
                        bee_size++;
                        obj_pixel[last_coor_h,last_coor_w]=obj_count;

                        sum_coor_h+=last_coor_h;
                        sum_coor_w+=last_coor_w;
                    }
                    if(bee_size<50){
                        for(int check_h=first_coor_h;check_h<h-1;check_h++){
                            for(int check_w=1;check_w<w-1;check_w++){
                                if(obj_pixel[check_h][check_w]==obj_count){
                                    obj_pixel[check_h][check_w]=0;
                                    pixel_data&=0xfe;                                    
                                }
                            }
                        }
                        obj_count--;
                        continue;
                    }
                    unsigned int outline_pixel=bee_xize;
                    for(int check_h=first_coor_h+1;check_h<h-2;check_h++){
                        for(int check_w=2;check_w<w-2;check_w++){
                            if(pixel_data[check_h,check_w]&0x01 
                                && obj_pixel[check_h][check_w]==0){
                                if(obj_pixel[check_h][check_w-1]==obj_count){
                                    obj_pixel[check_h][check_w]=obj_count;
                                    pixel_data[check_h][check_w]+=4;
                                    bee_size++;
                                }else if(obj_pixel[check_h-1][check_w]==obj_count){
                                    obj_pixel[check_h][check_w]=obj_count;
                                    pixel_data[check_h][check_w]+=4;
                                    bee_size++;
                                }
                            }
                        }
                    }
                    if(outline_pixel==bee_size){
                        for(int check_h=first_coor_h;check_h<h-1;check_h++){
                            for(int check_w=1;check_w<w-1;check_w++){
                                if(obj_pixel[check_h][check_w]==obj_count){
                                    obj_pixel[check_h][check_w]=0;
                                    pixel_data&=0xfe;                                    
                                }
                            }
                        }
                        obj_count--;
                        continue;
                    }
                    avg_coor_w=sum_coor_w/outline_pixel;
                    avg_coor_h=sum_coor_h/outline_pixel;

                    if(avg_coor_h<150)down++;
                    else up++;
                }
            }
        }
        char minus=0;
        if(obj_count==before_obj_count){
            minus=down-before_down;
            if(minus<0)count_in-=minus;
            else count_count+=minus;
            before_down=down;
            before_up=up;
            before_obj_count=obj_count;
        }
    }
    printf('in : %d / out : %d',count_in,count_out);

    return 0;
}