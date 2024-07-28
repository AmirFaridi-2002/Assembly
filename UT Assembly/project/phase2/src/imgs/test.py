from PIL import Image

img = Image.open('circle.png')
# resize it to 10 10
img = img.resize((10, 10))
img.save('circle_10_10.png')
img.show()