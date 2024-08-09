log=f"./expected/verilator/{name}.log"
log_dir=os.path.dirname(log)
os.makedirs(log_dir, exist_ok=True)
with open(log, encoding="UTF-8") as f:
    f.write(f"{out2}")
