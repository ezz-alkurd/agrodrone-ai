import sys
import cv2
import json
import time
import threading
import numpy as np
from types import ModuleType
from pathlib import Path
from datetime import datetime
from ultralytics import YOLO

# ── Compatibility patch for models trained with old ultralytics (ultralytics.yolo) ──
def _patch_ultralytics_yolo():
    import ultralytics
    mappings = {
        "ultralytics.yolo":                    "ultralytics",
        "ultralytics.yolo.utils":              "ultralytics.utils",
        "ultralytics.yolo.utils.ops":          "ultralytics.utils.ops",
        "ultralytics.yolo.utils.loss":         "ultralytics.utils.loss",
        "ultralytics.yolo.utils.metrics":      "ultralytics.utils.metrics",
        "ultralytics.yolo.utils.plotting":     "ultralytics.utils.plotting",
        "ultralytics.yolo.engine":             "ultralytics.engine",
        "ultralytics.yolo.engine.results":     "ultralytics.engine.results",
        "ultralytics.yolo.v8":                 "ultralytics.models.yolo",
        "ultralytics.yolo.v8.detect":          "ultralytics.models.yolo.detect",
        "ultralytics.yolo.v8.detect.predict":  "ultralytics.models.yolo.detect",
    }
    for old, new in mappings.items():
        if old not in sys.modules:
            try:
                sys.modules[old] = __import__(new, fromlist=[""])
            except ImportError:
                sys.modules[old] = ModuleType(old)

_patch_ultralytics_yolo()
# ────────────────────────────────────────────────────────────────────────────────

SCRIPT_DIR = Path(__file__).parent
OUTPUT_DIR = SCRIPT_DIR / "detections"
OUTPUT_DIR.mkdir(exist_ok=True)

MODELS = {
    "fire":  SCRIPT_DIR / "best.pt",
    "plant": SCRIPT_DIR / "plant_disease_best2.pt",
}
CONF = 0.3
PLANT_EXCLUDE = {"strawberry"}  # any class containing these words will be ignored (case-insensitive)
FIRE_EXCLUDE  = {"other"}

latest_frame = None
frame_lock = threading.Lock()

annotated_frames = {"fire": None, "plant": None}
annotated_lock = threading.Lock()

stop_event = threading.Event()


def save_detection(model_name: str, result):
    ts = datetime.now().strftime("%Y%m%d_%H%M%S_%f")
    detections = []
    for box in result.boxes:
        cls_id = int(box.cls[0])
        label = result.names[cls_id]
        entry = {
            "class_id": cls_id,
            "class_name": label,
            "confidence": round(float(box.conf[0]), 4),
            "bbox_xyxy": [round(v, 2) for v in box.xyxy[0].tolist()],
        }
        if model_name == "plant":
            entry["disease_name"] = label
        detections.append(entry)

    (OUTPUT_DIR / f"{model_name}_{ts}.json").write_text(
        json.dumps({"model": model_name, "timestamp": datetime.now().isoformat(), "detections": detections}, indent=2)
    )
    cv2.imwrite(str(OUTPUT_DIR / f"{model_name}_{ts}.jpg"), result.plot())
    print(f"[{model_name}] Detection saved  →  {model_name}_{ts}.jpg")


def inference_worker(model_name: str, model_path: Path):
    model = YOLO(str(model_path))
    print(f"Loaded: {model_name} ({model_path.name})")
    print(f"[{model_name}] Classes: {model.names}")

    # Build allowed class ID list (exclude blacklisted classes per model)
    exclude = PLANT_EXCLUDE if model_name == "plant" else FIRE_EXCLUDE if model_name == "fire" else set()
    allowed_ids = [
        cid for cid, cname in model.names.items()
        if not any(excl in cname.lower() for excl in exclude)
    ] if exclude else None
    if exclude:
        print(f"[{model_name}] Excluded classes containing: {exclude}")

    last_saved = 0.0

    while not stop_event.is_set():
        with frame_lock:
            frame = latest_frame.copy() if latest_frame is not None else None

        if frame is None:
            time.sleep(0.01)
            continue

        results = model(frame, conf=CONF, classes=allowed_ids, verbose=False)
        result = results[0]

        with annotated_lock:
            annotated_frames[model_name] = result.plot() if result.boxes is not None else frame

        now = time.time()
        if result.boxes is not None and len(result.boxes):
            if now - last_saved >= 2.0:
                save_detection(model_name, result)
                last_saved = now
            else:
                remaining = round(2.0 - (now - last_saved), 2)
                print(f"[{model_name}] Cooldown: {remaining}s left, skipping save")


def make_combined(fire_frame, plant_frame, raw_frame, win_w=1280):
    """Stack fire and plant frames side by side in one window."""
    h = raw_frame.shape[0]
    half_w = win_w // 2

    left  = fire_frame  if fire_frame  is not None else raw_frame.copy()
    right = plant_frame if plant_frame is not None else raw_frame.copy()

    left  = cv2.resize(left,  (half_w, h))
    right = cv2.resize(right, (half_w, h))

    # Labels
    cv2.putText(left,  "FIRE DETECTION",         (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.9, (0, 60, 255), 2)
    cv2.putText(right, "PLANT DISEASE DETECTION", (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.9, (0, 180, 60), 2)

    return np.hstack([left, right])


def main():
    global latest_frame

    cap = cv2.VideoCapture(0)
    if not cap.isOpened():
        raise RuntimeError("Cannot open camera")

    for name, path in MODELS.items():
        threading.Thread(target=inference_worker, args=(name, path), daemon=True).start()

    print("Running both models. Press 'q' to quit.")
    print(f"Detections saved to: {OUTPUT_DIR}")

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        with frame_lock:
            latest_frame = frame.copy()

        with annotated_lock:
            fire_frame  = annotated_frames["fire"]
            plant_frame = annotated_frames["plant"]

        combined = make_combined(fire_frame, plant_frame, frame)
        cv2.imshow("Fire  |  Plant Disease Detection", combined)

        if cv2.waitKey(1) & 0xFF == ord("q"):
            break

    stop_event.set()
    cap.release()
    cv2.destroyAllWindows()


if __name__ == "__main__":
    main()
