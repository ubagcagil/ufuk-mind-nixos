#!/usr/bin/env python3
import csv
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]  # /etc/nixos/erpnext
config_dir = ROOT / "config"
items_csv = config_dir / "items.csv"
component_csv = config_dir / "price" / "pena-component-costs.csv"

# 1) Component cost dictionary: (type, code) -> cost
component_cost = {}
with open(component_csv, newline="") as f:
    reader = csv.DictReader(f)
    for row in reader:
        key = (row["component_type"].strip(), row["code"].strip())
        component_cost[key] = float(row["unit_cost_try"])

def seg_cost(component_type, code):
    if not code:
        return 0.0
    return component_cost.get((component_type, code), 0.0)

# 2) Item code parser: BV_HC_LAT_1X_CAR_AL vs BV_HC_ESP_1X vs BV_HC_ESP
def parse_code(code: str):
    parts = code.split("_")
    dept = parts[0] if len(parts) > 0 else ""
    group = parts[1] if len(parts) > 1 else ""
    base = parts[2] if len(parts) > 2 else ""

    shot = syrup = milk = ""
    if len(parts) == 3:
        # BV_HC_ESP (no shot info)
        pass
    elif len(parts) == 4:
        # BV_HC_ESP_1X, BV_HC_LNG_2X
        shot = parts[3]
    else:
        # BV_HC_LAT_1X_CAR_AL style
        shot  = parts[3]
        syrup = parts[4] if len(parts) > 4 else ""
        milk  = parts[5] if len(parts) > 5 else ""

    return dept, group, base, shot, syrup, milk

def compute_recipe_cost(code: str) -> float:
    dept, group, base, shot, syrup, milk = parse_code(code)
    cost = 0.0
    cost += seg_cost("BASE", base)
    cost += seg_cost("SHOT", shot)
    cost += seg_cost("SYRUP", syrup)
    cost += seg_cost("MILK", milk)
    return cost

# 3) Oku ve tablo üret
with open(items_csv, newline="") as f:
    reader = csv.DictReader(f)
    items = list(reader)

print("item_code,item_name,base,shot,syrup,milk,recipe_cost,recommended_price")
for row in items:
    code = row["item_code"]
    dept, group, base, shot, syrup, milk = parse_code(code)
    recipe_cost = compute_recipe_cost(code)
    recommended_price = round(recipe_cost * 3)  # v0: 3x markup

    print(
        f"{code},{row['item_name']},"
        f"{base},{shot},{syrup},{milk},"
        f"{recipe_cost:.2f},{recommended_price:.2f}"
    )
