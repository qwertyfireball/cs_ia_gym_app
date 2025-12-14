from fastapi import FastAPI, UploadFile, File #api -> web framework
from fastapi.responses import JSONResponse #returns raw bytes -> like jpeg
import uvicorn #runs the fastapi server
import io # turns raw bytes into PIL
from PIL import Image # turns raw bytes into PIL
from ultralytics import YOLO
import asyncio

server = FastAPI()
model = YOLO("best.pt")
print("model loaded")
model.eval() #sets it to inference mode

@server.post("/detect") # Whenever someone sends a POST request to /detect, FastAPI will run detect() function.
async def detect(file: UploadFile = File(...)): # file: python expects a file to be uploaded in the "file" field, UploadFile: fastapi's file handling class, File(...): the input parameter should be from a file upload
    img_bytes = await file.read()
    print(f"{img_bytes}")
    img_PIL = Image.open(io.BytesIO(img_bytes)).convert("RGB") #rgb so YOLO can process

    result = model(img_PIL)
    first_result = result[0]

    labels = model.names #python dict {0: salmon, 1: beef etc.}
 
    classes = first_result.boxes.cls # returns ([0, 0, 1]) detection 1: class[0], detection 3: class[1]
    confidence = first_result.boxes.conf

    obj_count = 0

    for cls_idx, conf in zip(classes, confidence): # zip pairs to list into one ie zip([0, 0, 1], [0.92, 0.88, 0.66]) -> (0, 0.92)/(0, 0.88)/(1, 0.66)
        classname = labels[int(cls_idx.item())]
        if classname == "salmon" and conf.item() > 0.5:
            obj_count += 1
    print('response should have been sent')
    return JSONResponse({"salmon_count": obj_count})

if __name__ == "__main__":
    print("server is now working")
    uvicorn.run(server, host="0.0.0.0", port=9001)