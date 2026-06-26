"""
Debug script: logs ALL raw keyboard events to runtime/beacon_debug.log.
Hold the Nav key (x3y4) for 5 seconds, then check the log.
"""
import keyboard
import time
from pathlib import Path

LOG = Path(__file__).resolve().parent.parent / "runtime" / "beacon_debug.log"
LOG.parent.mkdir(exist_ok=True)

start = time.monotonic()

with open(LOG, "w", encoding="utf-8") as f:
    f.write(f"Debug started. Hold Nav (x3y4) for 5 seconds.\n")
    f.write(f"{'elapsed':>10}  {'type':>4}  {'name':<20} scan={'':<6} \n")
    f.write("-" * 60 + "\n")

    def on_event(event):
        elapsed = f"{time.monotonic() - start:.4f}"
        line = f"{elapsed:>10}  {event.event_type:>4}  {str(event.name):<20} scan={event.scan_code:<6}\n"
        f.write(line)
        f.flush()

    keyboard.hook(on_event)
    print(f"Logging to {LOG}")
    print("Press Ctrl+C to stop.")
    keyboard.wait()
