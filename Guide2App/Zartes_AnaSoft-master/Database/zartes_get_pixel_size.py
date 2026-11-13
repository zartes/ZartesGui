"""
zartes_get_pixel_size.py
Query ZarTESDB for TES geometry by design (series + chip_code + pixel),
WITHOUT requiring the specific device/wafer to exist in the database.

Usage:
    python zartes_get_pixel_size.py <device_name> [<device_name2> ...]

Device name format:  {series}{run}_{chip_row}{chip_col}_{pixel_code}
    e.g.  4Z6_62_14   3Z10_44_14   5Z1_37_31

The wafer run number is ignored — only series, chip_code and pixel_code
are used to look up the TES design.

Returns a JSON array to stdout, one object per device:
  [
    {
      "device_name": "4Z6_62_14",
      "series":      "4Z",
      "chip_code":   62,
      "pixel_code":  14,
      "nickname":    "XIFU-8",
      "size":        "40x80",
      "tes_width_um":  40.0,
      "tes_length_um": 80.0,
      "abs_width_um":  240.0,
      "stem_type":     "A10-P15",
      "has_membrane":  1,
      "has_absorber":  1,
      "found": true
    }, ...
  ]

If the design is not found, "found" is false and geometry fields are null.
"""

import sys
import re
import json
import psycopg2

# ── Connection settings ────────────────────────────────────────────────────────
DB_CONFIG = {
    "host":     "155.210.93.184",
    "port":     5432,
    "dbname":   "zartesdb",
    "user":     "invitado",
    "password": "invitado",
}

# ── Device name parser ─────────────────────────────────────────────────────────
# Matches: {series=2-9Z}{run=digits}_{chip_code=2 digits}_{pixel_code=alphanumeric}
DEVICE_RE = re.compile(r'^([2-9]Z)\d+_(\d{2})_(\w+)$')

def parse_name(name):
    """Return (series, chip_code_int, pixel_code_int) or None if unparseable."""
    m = DEVICE_RE.match(name.strip())
    if not m:
        return None
    series     = m.group(1)
    chip_code  = int(m.group(2))
    pixel_str  = m.group(3)
    try:
        pixel_code = int(pixel_str)   # '14' → 14, '02' → 2
    except ValueError:
        pixel_code = None             # e.g. '8X' — non-numeric pixel
    return series, chip_code, pixel_str, pixel_code

# ── SQL query ─────────────────────────────────────────────────────────────────
QUERY_NUMERIC = """
SELECT
    cd.series,
    cd.chip_position_code                                           AS chip_code,
    cd.nickname,
    cd.has_membrane,
    td.design_id,
    td.tes_width_um,
    td.tes_length_um,
    td.abs_width_um,
    td.stem_type,
    CAST(td.tes_width_um  AS INTEGER) || 'x' ||
    CAST(td.tes_length_um AS INTEGER)                               AS size,
    CASE WHEN td.abs_width_um IS NOT NULL THEN 1 ELSE 0 END         AS has_absorber
FROM public.chip_design cd
JOIN public.tes_design td ON td.chip_design_id = cd.chip_design_id
WHERE cd.series              = %s
  AND cd.chip_position_code  = %s
  AND td.chip_position_code  = %s
ORDER BY td.design_id
LIMIT 1;
"""


def query_pixel(cur, name):
    parsed = parse_name(name)
    if parsed is None:
        return {"device_name": name, "found": False,
                "error": f"Cannot parse device name: '{name}'"}

    series, chip_code, pixel_str, pixel_code = parsed

    if pixel_code is None:
        return {"device_name": name, "found": False,
                "series": series, "chip_code": chip_code,
                "pixel_code": pixel_str,
                "error": f"Non-numeric pixel code '{pixel_str}' not supported"}

    cur.execute(QUERY_NUMERIC, (series, chip_code, pixel_code))
    row = cur.fetchone()

    if row is None:
        return {
            "device_name": name, "found": False,
            "series": series, "chip_code": chip_code,
            "pixel_code": pixel_code,
            "error": f"No design found for {series} chip {chip_code} pixel {pixel_code}"
        }

    cols   = [desc[0] for desc in cur.description]
    result = dict(zip(cols, row))
    result["device_name"] = name
    result["found"]       = True
    result["pixel_code"]  = pixel_code
    return result


def main():
    devices = sys.argv[1:]
    if not devices:
        print(json.dumps({"error": "No device names provided"}))
        sys.exit(1)

    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cur  = conn.cursor()
        results = [query_pixel(cur, dev) for dev in devices]
        conn.close()
    except Exception as e:
        print(json.dumps({"error": str(e)}))
        sys.exit(1)

    print(json.dumps(results, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
