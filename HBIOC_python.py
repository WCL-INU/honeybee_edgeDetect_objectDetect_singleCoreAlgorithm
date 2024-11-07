from datetime import datetime

import cv2
import os

from PIL import Image
import picamera
import numpy as np
import io

current_time = datetime.now()
time_string = current_time.strftime('%Y%m%d_%H%M%S')



h=360
w=640

count_out=0
count_in=0
before_down=0
before_up=0
before_obj_count=0

for _ in range(100):
	up=0
	down=0

	with picamera.PiCamera() as camera:
		camera.resolution=(w,h)
		image_stream = io.BytesIO()
		camera.capture(image_stream, format='jpeg')
		image_stream.seek(0)
		image = Image.open(image_stream)
		pixel_array = np.array(image)
		
	blue=pixel_array[:,:,2]
	iswhite=(blue<75).astype(int)
	iswhite[0,:]=0
	iswhite[-1,:]=0
	iswhite[:,0]=0
	iswhite[:,-1]=0
	
	for i in range(1,h-1):
		for j in range(1,w-1):
			if iswhite[i,j]:
				check_four=iswhite[i-1,j]+iswhite[i+1,j]+iswhite[i,j-1]+iswhite[i,j+1]
				if check_four<2:
					iswhite[i,j]=0
					i=i-1
					j=j-1
			
	
	line_pixel=np.zeros((h,w),dtype=int)

	for i in range(1,h-1):
		for j in range(1,w-1):
			if iswhite[i,j]:
				check_four=iswhite[i-1,j]+iswhite[i+1,j]+iswhite[i,j-1]+iswhite[i,j+1]
				if check_four>1 and check_four<4:
					line_pixel[i,j]=1
					
	check=np.zeros((h,w),dtype=int)
	obj_pixel=np.zeros((h, w), dtype=np.uint8)
	
	obj_count=0
	for i in range(1,h-1):
		for j in range(1,w-1):
			if check[i,j]:
				continue
			check[i,j]=1
			if line_pixel[i,j]:
				bee_size=1
				first_coor_h=i
				first_coor_w=j
				
				obj_count=obj_count+1
				obj_pixel[first_coor_h,first_coor_w]=obj_count
				
				if line_pixel[first_coor_h+1,first_coor_w-1]:
					last_coor_h=first_coor_h+1
					last_coor_w=first_coor_w-1
					line_case=1
				elif line_pixel[first_coor_h+1,first_coor_w]:
					last_coor_h=first_coor_h+1
					last_coor_w=first_coor_w
					line_case=2
				else:
					continue
				
				sum_coor_h=first_coor_h+last_coor_h
				sum_coor_w=first_coor_w+last_coor_w
				
				bee_size=2
				check[last_coor_h,last_coor_w]=1
				obj_pixel[last_coor_h,last_coor_w]=obj_count
				
				while 1:
					if line_case==1:
						if line_pixel[last_coor_h-1,last_coor_w-1]:
							last_coor_h-=1
							last_coor_w-=1
							line_case=7
						elif line_pixel[last_coor_h,last_coor_w-1]:
							last_coor_w-=1
							line_case=8
						elif line_pixel[last_coor_h+1,last_coor_w-1]:
							last_coor_h+=1
							last_coor_w-=1
							line_case=1
						elif line_pixel[last_coor_h+1,last_coor_w+1]:
							last_coor_h+=1
							line_case=2
						elif line_pixel[last_coor_h+1,last_coor_w+1]:
							last_coor_h+=1
							last_coor_w+=1
							line_case=3
						else:
							break
					elif line_case==2:
						if line_pixel[last_coor_h,last_coor_w-1]:
							last_coor_w-=1
							line_case=8
						elif line_pixel[last_coor_h+1,last_coor_w-1]:
							last_coor_h+=1
							last_coor_w-=1
							line_case=1
						elif line_pixel[last_coor_h+1,last_coor_w+1]:
							last_coor_h+=1
							line_case=2
						elif line_pixel[last_coor_h+1,last_coor_w+1]:
							last_coor_h+=1
							last_coor_w+=1
							line_case=3
						elif line_pixel[last_coor_h,last_coor_w+1]:
							last_coor_w+=1
							line_case=4
						else:
							break
					elif line_case==3:
						if line_pixel[last_coor_h+1,last_coor_w-1]:
							last_coor_h+=1
							last_coor_w-=1
							line_case=1
						elif line_pixel[last_coor_h+1,last_coor_w+1]:
							last_coor_h+=1
							line_case=2
						elif line_pixel[last_coor_h+1,last_coor_w+1]:
							last_coor_h+=1
							last_coor_w+=1
							line_case=3
						elif line_pixel[last_coor_h,last_coor_w+1]:
							last_coor_w+=1
							line_case=4
						elif line_pixel[last_coor_h-1,last_coor_w+1]:
							last_coor_h-=1
							last_coor_w+=1
							line_case=5
						else:
							break
					elif line_case==4:
						if line_pixel[last_coor_h+1,last_coor_w+1]:
							last_coor_h+=1
							line_case=2
						elif line_pixel[last_coor_h+1,last_coor_w+1]:
							last_coor_h+=1
							last_coor_w+=1
							line_case=3
						elif line_pixel[last_coor_h,last_coor_w+1]:
							last_coor_w+=1
							line_case=4
						elif line_pixel[last_coor_h-1,last_coor_w+1]:
							last_coor_h-=1
							last_coor_w+=1
							line_case=5
						elif line_pixel[last_coor_h-1,last_coor_w]:
							last_coor_h-=1
							line_case=6
						else:
							break
					elif line_case==5:
						if line_pixel[last_coor_h+1,last_coor_w+1]:
							last_coor_h+=1
							last_coor_w+=1
							line_case=3
						elif line_pixel[last_coor_h,last_coor_w+1]:
							last_coor_w+=1
							line_case=4
						elif line_pixel[last_coor_h-1,last_coor_w+1]:
							last_coor_h-=1
							last_coor_w+=1
							line_case=5
						elif line_pixel[last_coor_h-1,last_coor_w]:
							last_coor_h-=1
							line_case=6
						elif line_pixel[last_coor_h-1,last_coor_w-1]:
							last_coor_h-=1
							last_coor_w-=1
							line_case=7
						else:
							break
					elif line_case==6:
						if line_pixel[last_coor_h,last_coor_w+1]:
							last_coor_w+=1
							line_case=4
						elif line_pixel[last_coor_h-1,last_coor_w+1]:
							last_coor_h-=1
							last_coor_w+=1
							line_case=5
						elif line_pixel[last_coor_h-1,last_coor_w]:
							last_coor_h-=1
							line_case=6
						elif line_pixel[last_coor_h-1,last_coor_w-1]:
							last_coor_h-=1
							last_coor_w-=1
							line_case=7
						elif line_pixel[last_coor_h,last_coor_w-1]:
							last_coor_w-=1
							line_case=8
						else:
							break
					elif line_case==7:
						if line_pixel[last_coor_h-1,last_coor_w+1]:
							last_coor_h-=1
							last_coor_w+=1
							line_case=5
						elif line_pixel[last_coor_h-1,last_coor_w]:
							last_coor_h-=1
							line_case=6
						elif line_pixel[last_coor_h-1,last_coor_w-1]:
							last_coor_h-=1
							last_coor_w-=1
							line_case=7
						elif line_pixel[last_coor_h,last_coor_w-1]:
							last_coor_w-=1
							line_case=8
						elif line_pixel[last_coor_h+1,last_coor_w-1]:
							last_coor_h+=1
							last_coor_w-=1
							line_case=1
						else:
							break
					elif line_case==8:
						if line_pixel[last_coor_h-1,last_coor_w]:
							last_coor_h-=1
							line_case=6
						elif line_pixel[last_coor_h-1,last_coor_w-1]:
							last_coor_h-=1
							last_coor_w-=1
							line_case=7
						elif line_pixel[last_coor_h,last_coor_w-1]:
							last_coor_w-=1
							line_case=8
						elif line_pixel[last_coor_h+1,last_coor_w-1]:
							last_coor_h+=1
							last_coor_w-=1
							line_case=1
						elif line_pixel[last_coor_h+1,last_coor_w+1]:
							last_coor_h+=1
							line_case=2
						else:
							break
						
					if check[last_coor_h,last_coor_w]:
						break
					check[last_coor_h,last_coor_w]=1
					bee_size+=1
					obj_pixel[last_coor_h,last_coor_w]=obj_count
					
					sum_coor_h+=last_coor_h
					sum_coor_w+=last_coor_h
					
				if bee_size<50:
					for check_h in range(first_coor_h,h-1):
						for check_w in range(1,w-1):
							if obj_pixel[check_h,check_w]==obj_count:
								obj_pixel[check_h,check_w]=0
								iswhite[check_h,check_w]=0
					obj_count-=1
					continue
				
				outline_pixel=bee_size
				for check_h in range(first_coor_h+1,h-2):
					for check_w in range(2,w-2):
						if iswhite[check_h,check_w]==1 and obj_pixel[check_h,check_w]==0:
							if obj_pixel[check_h,check_w-1]==obj_count:
								obj_pixel[check_h,check_w]=obj_count
								check[check_h,check_w]=1
								bee_size+=1
							elif obj_pixel[check_h-1,check_w]==obj_count:
								obj_pixel[check_h,check_w]=obj_count
								check[check_h,check_w]=1
								bee_size+=1
								
				if outline_pixel==bee_size:
					for check_h in range(first_coor_h,h-1):
						for check_w in range(1,w-1):
							if obj_pixel[check_h,check_w]==obj_count:
								obj_pixel[check_h,check_w]=0
					obj_count-=1
					continue
				
				avg_coor_w=sum_coor_w/outline_pixel
				avg_coor_h=sum_coor_h/outline_pixel
				
				if avg_coor_h<150:
					down+=1
				else:
					up+=1
	if obj_count==before_obj_count:
		minus=down-before_down
		if minus<0:
			count_in-=minus
		else:
			count_out+=minus
			
		before_down=down
		before_up=up
		before_obj_count=obj_count
		
print('in : '+str(count_in)+' / out : '+str(count_out))