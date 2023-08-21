import cv2   #the same cell

img = cv2.imread('../DATA/00-puppy.jpg')
while True:
    cv2.imshow('Puppy',img)
    
    #if we waited at least 1ms and we press the esc
    if cv2.waitKey(1) & 0xFF == 27:
        break

cv2.destroyAllWindows()
#click esc to quit
