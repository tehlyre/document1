from PIL import Image
import sys
walls = sys.argv[1].split("), ")
destination = sys.argv[2]
parsed_walls = []
wall_x = []
wall_y = []
for q in range(0,len(walls)):
    z = ''
    if q == 0:
        z = walls[q][2:]
    elif q == len(walls)-1:
        z = walls[q][1:-2]
    else:
        z = walls[q][1:]
    w = z.split(", ")
    for i in range(0,len(w)):
        w[i] = int(w[i])
    wall_x.append(w[0])
    wall_y.append(w[1])
    parsed_walls.append(w)
img = Image.new("RGBA",(max(wall_x)-min(wall_x)+1, max(wall_y)-min(wall_y)+1))
print(parsed_walls)
print(max(wall_x))
print(min(wall_x))
print(max(wall_y))
print(min(wall_y))
pixelMap = img.load()
for i in range(0,len(parsed_walls)):
    pixelMap[parsed_walls[i][0]-min(wall_x), parsed_walls[i][1]-min(wall_y)] = (255,255,0,255)
img.show()       
img.save("assets/textures/"+destination) 
img.close()


