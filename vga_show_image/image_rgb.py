import cv2
import numpy as np

img_path = 'so_easy.jpg'
img = cv2.imread(img_path)

height = img.shape[0]
width = img.shape[1]

print(height)
print(width)

fw = open('rgb.txt', 'w')

tmp = [0, 0 ,0]

for i in range(height):
	for j in range(width):
		print(np.array(img)[i][j])
		tmp[0] = int(np.array(img)[i][j][0] / 32)
		tmp[1] = int(np.array(img)[i][j][1] / 32)
		tmp[2] = int(np.array(img)[i][j][2] / 64)
		print('{:03b}'.format(tmp[0]) + '{:03b}'.format(tmp[1]) + '{:02b}'.format(tmp[2]))
		print('{:03b}'.format(tmp[0]) + '{:03b}'.format(tmp[1]) + '{:02b}'.format(tmp[2]), file = fw)
		#break

fw.close()