import numpy as np
import os, sys
from PIL import Image

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python convert.py <image address> <flag(i2t: image to text, t2i: text to image)>")
        sys.exit(1)
    if not os.path.exists(sys.argv[1]):
        print("Image file not found.")
        sys.exit(1)
    if sys.argv[2] != "i2t" and sys.argv[2] != "t2i":
        print("Invalid flag.")
        sys.exit(1)
    if sys.argv[2] == "i2t":
        img = Image.open(sys.argv[1])
        img = np.array(img)
        with open(sys.argv[1].replace(sys.argv[1].split(".")[-1], "txt"), "w") as f:
            f.write(str(img.shape[0]) + " " + str(img.shape[1]) + "\n")
            for i in range(img.shape[0]):
                for j in range(img.shape[1]):
                    f.write(str(int(img[i][j][0])) + " " + str(int(img[i][j][1])) + " " + str(int(img[i][j][2])) + " ")
                f.write("\n")        
    else:
        """
            first line of the text file should be the dimensions of the image in the following format
            <rows> <columns> <dim> <gray_scale flag>
        """
        with open(sys.argv[1], "r") as f:
            lines = f.readlines()
            rows, columns, dim, gs_flag = list(map(int, lines[0].split()))
            if gs_flag == 1:
                img = np.zeros((rows, columns))
                for i in range(rows):
                    img[i] = list(map(int, lines[i + 1].split()))
                img = Image.fromarray(img.astype(np.uint8))
                img.save(sys.argv[1].replace("txt", "png"))
            else:
                img = np.zeros((rows, columns, 3))
                for i in range(rows):
                    pixels = list(map(int, lines[i + 1].split()))
                    for j in range(0, len(pixels), dim):
                        for k in range(dim):
                            img[i][j // dim][k] = pixels[j + k]
                img = Image.fromarray(img.astype(np.uint8))
                img.save(sys.argv[1].replace("txt", "png"))
        print("Image saved successfully.")
        os.system("/mnt/c/Windows/explorer.exe " + sys.argv[1].replace("txt", "png").replace("/", "\\\\"))
        
        