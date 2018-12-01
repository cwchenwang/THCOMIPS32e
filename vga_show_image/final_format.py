file = open("rgb_format.txt") 
tarfile = open("final.txt", 'w')
line_num = 1

while 1:
    tar_line = ''
    flag = 1
    for i in range(4):
        line = file.readline()
        if not line:
            flag = 0
            break
        if(i != 3):
            tar_line += hex(int(line[0 : 4], 2))[2] + hex(int(line[5 : 9], 2))[2] + hex(int(line[10 : 14], 2))[2] + hex(int(line[15 : 19], 2))[2] + ' '
            tar_line += hex(int(line[20 : 24], 2))[2] + hex(int(line[25 : 29], 2))[2] + hex(int(line[30 : 34], 2))[2] + hex(int(line[35 : 39], 2))[2] + ' '
            #print(hex(int(line[0 : 4], 2))[2] + hex(int(line[5 : 9], 2))[2] + hex(int(line[10 : 14], 2))[2] + hex(int(line[15 : 19], 2))[2], end = ' ')
        else:
            tar_line += hex(int(line[0 : 4], 2))[2] + hex(int(line[5 : 9], 2))[2] + hex(int(line[10 : 14], 2))[2] + hex(int(line[15 : 19], 2))[2] + ' '
            tar_line += hex(int(line[20 : 24], 2))[2] + hex(int(line[25 : 29], 2))[2] + hex(int(line[30 : 34], 2))[2] + hex(int(line[35 : 39], 2))[2] + '\n'
            #print(hex(int(line[0 : 4], 2))[2] + hex(int(line[5 : 9], 2))[2] + hex(int(line[10 : 14], 2))[2] + hex(int(line[15 : 19], 2))[2])
    print(tar_line, end = '')
    tarfile.write(tar_line)
    print(line_num)
    if(flag == 0):
        break
    line_num += 1

file.close()
tarfile.close()