import cv2

from ultralytics import YOLO
import supervision as sv
import socket
import sys
import json

def main():
    server_address = ('localhost', 4040)  # Adjust as necessary
    print("creating socket")
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    print(f"connecting {server_address}")
    client_socket.connect(server_address)

    print("creating video capture")
    cap = cv2.VideoCapture(0)

    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)

    print("loading model")
    model = YOLO("best_yolov8_weights.pt", verbose=False)

    boxAnnotater = sv.BoundingBoxAnnotator(
        thickness=2
    )
    labelAnnotater = sv.LabelAnnotator(
        text_position=sv.Position.BOTTOM_CENTER,
        text_thickness=2,
        text_scale=2
    )

    try:
        print("starting loop")
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
                d_json = json.dumps(line).encode('utf-8')
                print(d_json)
                client_socket.sendall(d_json + b'\n')

            boxedFrame = boxAnnotater.annotate(scene=frame,detections=detections)
            labeledFrame = labelAnnotater.annotate(scene=boxedFrame,detections=detections)
            cv2.line(frame, (0, 240), (640, 240), (0, 0, 255), 2)
            cv2.imshow('CardDetector', labeledFrame)

            if cv2.waitKey(30) == 27:
                client_socket.close()
                cv2.destroyAllWindows()
                print("Exiting...")
                break
    except Exception as e:
        print(f"Error: {e}")
    finally:
        client_socket.close()
        cv2.destroyAllWindows()
        sys.exit(1)

    sys.exit(0)

if __name__ == "__main__":
    main()