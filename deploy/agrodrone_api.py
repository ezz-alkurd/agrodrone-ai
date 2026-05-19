from __future__ import annotations

import base64
import cgi
import json
import mimetypes
import os
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from types import ModuleType
from urllib.parse import parse_qs, urlparse

import cv2
import numpy as np
from ultralytics import YOLO


ROOT = Path(__file__).resolve().parents[1]
DEPLOY_DIR = Path(__file__).resolve().parent
MODEL_DIR = ROOT / "grad project fire base and flutter" / "grad prop" / "yolo" / "models"
MODELS = {
    "fire": MODEL_DIR / "best.pt",
    "disease": MODEL_DIR / "plant_disease_best2.pt",
}

CONF = 0.15
EXCLUDED = {
    "fire": {"other"},
    "disease": {"strawberry"},
}

_loaded_models: dict[str, YOLO] = {}


def patch_legacy_ultralytics_imports() -> None:
    import ultralytics

    mappings = {
        "ultralytics.yolo": "ultralytics",
        "ultralytics.yolo.utils": "ultralytics.utils",
        "ultralytics.yolo.utils.ops": "ultralytics.utils.ops",
        "ultralytics.yolo.utils.loss": "ultralytics.utils.loss",
        "ultralytics.yolo.utils.metrics": "ultralytics.utils.metrics",
        "ultralytics.yolo.utils.plotting": "ultralytics.utils.plotting",
        "ultralytics.yolo.engine": "ultralytics.engine",
        "ultralytics.yolo.engine.results": "ultralytics.engine.results",
        "ultralytics.yolo.v8": "ultralytics.models.yolo",
        "ultralytics.yolo.v8.detect": "ultralytics.models.yolo.detect",
        "ultralytics.yolo.v8.detect.predict": "ultralytics.models.yolo.detect",
    }
    for old, new in mappings.items():
        if old in sys.modules:
            continue
        try:
            sys.modules[old] = __import__(new, fromlist=[""])
        except ImportError:
            sys.modules[old] = ModuleType(old)


def get_model(model_key: str) -> YOLO:
    if model_key not in MODELS:
        raise ValueError(f"Unknown model '{model_key}'")
    if model_key not in _loaded_models:
        model_path = MODELS[model_key]
        if not model_path.exists():
            raise FileNotFoundError(f"Model file not found: {model_path}")
        patch_legacy_ultralytics_imports()
        _loaded_models[model_key] = YOLO(str(model_path))
    return _loaded_models[model_key]


def allowed_class_ids(model_key: str, model: YOLO) -> list[int] | None:
    excluded = EXCLUDED.get(model_key, set())
    if not excluded:
        return None
    return [
        class_id
        for class_id, class_name in model.names.items()
        if not any(word in class_name.lower() for word in excluded)
    ]


def infer(model_key: str, image_bytes: bytes) -> dict:
    model = get_model(model_key)
    image_array = np.frombuffer(image_bytes, np.uint8)
    image = cv2.imdecode(image_array, cv2.IMREAD_COLOR)
    if image is None:
        raise ValueError("Could not decode uploaded image")

    results = model(
        image,
        conf=CONF,
        imgsz=640,
        classes=allowed_class_ids(model_key, model),
        verbose=False,
    )
    result = results[0]
    detections = []

    if result.boxes is not None:
        for box in result.boxes:
            class_id = int(box.cls[0])
            label = result.names[class_id]
            confidence = float(box.conf[0])
            x1, y1, x2, y2 = [int(v) for v in box.xyxy[0].tolist()]
            anomaly_type = "disease" if model_key == "disease" else label.lower()
            detections.append(
                {
                    "class_id": class_id,
                    "label": label,
                    "anomaly_type": anomaly_type,
                    "confidence": round(confidence, 4),
                    "confidence_percent": round(confidence * 100, 1),
                    "bbox": [x1, y1, x2, y2],
                }
            )

    annotated = result.plot()
    ok, encoded = cv2.imencode(".jpg", annotated)
    annotated_url = ""
    if ok:
      annotated_url = "data:image/jpeg;base64," + base64.b64encode(encoded).decode("ascii")

    best = max(detections, key=lambda item: item["confidence"], default=None)
    return {
        "model": model_key,
        "model_label": "YOLOv8 Fire & Smoke" if model_key == "fire" else "YOLOv8 Plant Disease",
        "threshold": CONF,
        "detections": detections,
        "best_detection": best,
        "annotated_image": annotated_url,
        "status": "detected" if best else "clear",
    }


class Handler(BaseHTTPRequestHandler):
    server_version = "AgroDroneAPI/1.0"

    def end_headers(self) -> None:
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.send_header("Access-Control-Allow-Private-Network", "true")
        self.send_header("Access-Control-Max-Age", "86400")
        super().end_headers()

    def do_OPTIONS(self) -> None:
        self.send_response(204)
        self.end_headers()

    def do_GET(self) -> None:
        path = urlparse(self.path).path
        if path == "/api/health":
            self.write_json(
                {
                    "ok": True,
                    "models": {key: path.exists() for key, path in MODELS.items()},
                    "loaded": sorted(_loaded_models.keys()),
                }
            )
            return
        self.serve_static(path)

    def serve_static(self, request_path: str) -> None:
        if request_path in {"", "/"}:
            request_path = "/agrodrone_ai_complete.html"

        relative = request_path.lstrip("/").replace("/", "\\")
        target = (DEPLOY_DIR / relative).resolve()

        try:
            target.relative_to(DEPLOY_DIR.resolve())
        except ValueError:
            self.write_json({"error": "Forbidden"}, status=403)
            return

        if not target.exists() or not target.is_file():
            self.write_json({"error": "Not found"}, status=404)
            return

        content_type = mimetypes.guess_type(str(target))[0] or "application/octet-stream"
        body = target.read_bytes()
        self.send_response(200)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_POST(self) -> None:
        path = urlparse(self.path).path
        if path != "/api/detect":
            self.write_json({"error": "Not found"}, status=404)
            return

        try:
            query = parse_qs(urlparse(self.path).query)
            model_key = query.get("model", ["fire"])[0]
            form = cgi.FieldStorage(
                fp=self.rfile,
                headers=self.headers,
                environ={
                    "REQUEST_METHOD": "POST",
                    "CONTENT_TYPE": self.headers.get("Content-Type", ""),
                    "CONTENT_LENGTH": self.headers.get("Content-Length", "0"),
                },
            )
            file_item = form["image"] if "image" in form else None
            if file_item is None or not getattr(file_item, "file", None):
                raise ValueError("Upload field 'image' is required")
            payload = file_item.file.read()
            self.write_json(infer(model_key, payload))
        except Exception as exc:
            self.write_json({"error": str(exc)}, status=500)

    def write_json(self, payload: dict, status: int = 200) -> None:
        body = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)


def main() -> None:
    # Render.com injects PORT; fall back to AGRODRONE_API_PORT for local use,
    # then 8767 as the last resort.
    host = os.environ.get("AGRODRONE_API_HOST", "0.0.0.0")
    port = int(os.environ.get("PORT") or os.environ.get("AGRODRONE_API_PORT", "8767"))
    print(f"AgroDrone AI API running at http://{host}:{port}/api/health")
    print("Website endpoint: POST /api/detect?model=fire or model=disease")
    ThreadingHTTPServer((host, port), Handler).serve_forever()


if __name__ == "__main__":
    main()
