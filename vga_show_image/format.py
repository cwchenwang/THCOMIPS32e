file = open("rgb.txt") 
tarfile = open("rgb_format.txt", 'w')

while 1:
    flag = 1
    tar_line = ''
    for i in range(4):
        line = file.readline()
        if(i != 3):
            tar_line += line[0 : 4] + " " + line[4 : len(line) - 1] + " "
        else:
            tar_line += line[0 : 4] + " " + line[4 : len(line)]
        if not line:
            flag = 0
            break
    print(tar_line)
    tarfile.write(tar_line)
    if(flag == 0):
        break

file.close()
tarfile.close()