import cv2

from ultralytics import YOLO
import supervision as sv
import socket
import sys
import json

def main():
    cap = cv2.VideoCapture(0)

    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
    model = YOLO("train8/weights/best.pt", verbose=False)

    boxAnnotater = sv.BoundingBoxAnnotator(
        thickness=2
    )
    labelAnnotater = sv.LabelAnnotator(
        text_position=sv.Position.BOTTOM_CENTER,
        text_thickness=2,
        text_scale=2
    )

    # Create a TCP/IP socket
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    # Connect the socket to the server's address and port
    server_address = ('localhost', 4040)  # Adjust as necessary
    client_socket.connect(server_address)

    try:
        while True:
            ret, frame = cap.read()
            result = model(frame)[0]
            detections = sv.Detections.from_ultralytics(result)

            for i in range(detections.__len__()):
                d = detections.__getitem__(i)
                line = {
                    "xyxy": d.xyxy[0].tolist(),
                    "conf": float(d.confidence[0]),
                    "cls_id": int(d.class_id[0]),
                    "cls_n": d['class_name'][0]
                }
                client_socket.sendall(json.dumps(line).encode('utf-8') + b'\n')

            boxedFrame = boxAnnotater.annotate(scene=frame,detections=detections)
            labeledFrame = labelAnnotater.annotate(scene=boxedFrame,detections=detections)
            cv2.imshow('CardDetector', labeledFrame)

            if cv2.waitKey(30) == 27:
                client_socket.close()
                cv2.destroyAllWindows()
                print("Exiting...")
                break
    finally:
        client_socket.close()
        cv2.destroyAllWindows()
        sys.exit(1)

    sys.exit(0)

if __name__ == "__main__":
    main()
#%%

#%%
