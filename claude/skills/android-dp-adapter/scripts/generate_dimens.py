"""
Android multi-screen dimens.xml generator.

Two modes:
  1. Init base     — write `<output>/values/dimens.xml` with 1:1 values.
  2. Sync sw桶     — read `<output>/values/dimens.xml` as source of truth,
                     delete all existing `values-sw*dp/` dirs under <output>,
                     regenerate sw buckets with values scaled from base.

CLI examples:
  # Phase 1: init base (defaults: -20..-1 and 1..200)
  python3 generate_dimens.py --base 375 --output app/src/main/res --default-only

  # Phase 1: add ad-hoc values (rewrites values/dimens.xml, include all historic extras)
  python3 generate_dimens.py --base 375 --output app/src/main/res --default-only \
      --extra 332,500,0.5

  # Phase 2: sync sw buckets from base (auto-deletes old sw dirs)
  python3 generate_dimens.py --base 375 --output app/src/main/res \
      --targets 320,360,392,411,420,480,600

Note: use `python3` on macOS/recent Linux distros — bare `python` is usually absent.
"""

from __future__ import annotations

import argparse
import re
import shutil
from pathlib import Path

DIMEN_LINE = re.compile(
    r'<dimen\s+name="[^"]+">\s*(-?\d+(?:\.\d+)?)dp\s*</dimen>'
)


def format_dimen_name(prefix: str, value: float) -> str:
    """dp_16 / dp_0_5 (positive) · dp__16 / dp__0_5 (negative, double underscore)."""
    if value < 0:
        abs_value = abs(value)
        if abs_value == int(abs_value):
            return f"{prefix}__{int(abs_value)}"
        return f"{prefix}__{str(abs_value).replace('.', '_')}"
    if value == int(value):
        return f"{prefix}_{int(value)}"
    return f"{prefix}_{str(value).replace('.', '_')}"


def _write_xml(
    file_path: Path,
    values: list[float],
    target_dp: int,
    base_dp_width: int,
    decimal_places: int,
    name_prefix: str,
) -> None:
    file_path.parent.mkdir(parents=True, exist_ok=True)
    with file_path.open("w", encoding="utf-8") as f:
        f.write('<?xml version="1.0" encoding="utf-8"?>\n')
        f.write("<resources>\n")
        for v in values:
            calc = (v * target_dp) / float(base_dp_width)
            formatted = (
                f"{round(calc)}dp"
                if decimal_places == 0
                else f"{calc:.{decimal_places}f}dp"
            )
            name = format_dimen_name(name_prefix, v)
            f.write(f'    <dimen name="{name}">{formatted}</dimen>\n')
        f.write("</resources>\n")
    print(f"Generated {file_path}")


def _default_base_values(start_dp: int, end_dp: int, extras: list[float] | None) -> list[float]:
    vals: set[float] = {float(i) for i in range(start_dp, end_dp + 1)}
    if extras:
        vals.update(extras)
    return sorted(vals)


def parse_base_dimens(base_file: Path) -> list[float]:
    """Parse each <dimen>...dp</dimen> in values/dimens.xml.

    The base file has target==base, so value == original dp, and we can round-trip
    through the numeric value instead of decoding the name.
    """
    if not base_file.is_file():
        raise FileNotFoundError(
            f"Base file not found: {base_file}\n"
            f"Run with --default-only first to create it."
        )
    text = base_file.read_text(encoding="utf-8")
    values: list[float] = []
    for m in DIMEN_LINE.finditer(text):
        num = float(m.group(1))
        values.append(int(num) if num == int(num) else num)
    if not values:
        raise ValueError(f"No <dimen> entries found in {base_file}")
    return sorted(set(values))


def init_base(
    base_dp_width: int,
    output_root: Path,
    start_dp: int,
    end_dp: int,
    extras: list[float] | None,
    decimal_places: int,
    name_prefix: str,
) -> None:
    values = _default_base_values(start_dp, end_dp, extras)
    _write_xml(
        output_root / "values" / "dimens.xml",
        values,
        target_dp=base_dp_width,
        base_dp_width=base_dp_width,
        decimal_places=decimal_places,
        name_prefix=name_prefix,
    )


def sync_sw_buckets(
    base_dp_width: int,
    target_dp_widths: list[int],
    output_root: Path,
    decimal_places: int,
    name_prefix: str,
) -> None:
    base_file = output_root / "values" / "dimens.xml"
    values = parse_base_dimens(base_file)

    removed = 0
    for entry in sorted(output_root.glob("values-sw*dp")):
        if entry.is_dir():
            shutil.rmtree(entry)
            print(f"Removed {entry}")
            removed += 1
    if removed:
        print(f"(cleared {removed} old sw bucket dir(s))")

    for target_dp in target_dp_widths:
        _write_xml(
            output_root / f"values-sw{target_dp}dp" / "dimens.xml",
            values,
            target_dp=target_dp,
            base_dp_width=base_dp_width,
            decimal_places=decimal_places,
            name_prefix=name_prefix,
        )


def _parse_number_list(text: str) -> list[float]:
    return [float(x) if "." in x else int(x) for x in text.split(",") if x.strip()]


def main() -> None:
    p = argparse.ArgumentParser(
        description="Generate Android dimens.xml: init base, or sync sw buckets from base.",
    )
    p.add_argument("--base", type=int, required=True, help="base design width in dp (e.g. 375)")
    p.add_argument(
        "--output", type=str, required=True,
        help="res root, e.g. app/src/main/res",
    )
    p.add_argument(
        "--default-only", action="store_true",
        help="init/rewrite values/dimens.xml; uses --start/--end/--extra",
    )
    p.add_argument(
        "--targets", type=str, default="",
        help="sw buckets to generate (sync mode), comma-separated, e.g. 320,360,411,480,600",
    )
    p.add_argument("--start", type=int, default=-20, help="[init] start dp (inclusive, default -20)")
    p.add_argument("--end", type=int, default=200, help="[init] end dp (inclusive, default 200)")
    p.add_argument("--extra", type=str, default="",
                   help="[init] extra dp values, comma-separated (floats/negatives OK)")
    p.add_argument("--decimals", type=int, default=1, help="decimal places (default 1)")
    p.add_argument("--prefix", type=str, default="dp", help="dimen name prefix (default 'dp')")
    args = p.parse_args()

    output_root = Path(args.output)
    output_root.mkdir(parents=True, exist_ok=True)

    targets = [int(x) for x in args.targets.split(",") if x.strip()] if args.targets else []
    extras = _parse_number_list(args.extra) if args.extra else None

    if args.default_only and targets:
        p.error("--default-only and --targets are mutually exclusive (two separate phases)")
    if not args.default_only and not targets:
        p.error("pass either --default-only (init base) or --targets (sync sw buckets)")

    if args.default_only:
        init_base(
            base_dp_width=args.base,
            output_root=output_root,
            start_dp=args.start,
            end_dp=args.end,
            extras=extras,
            decimal_places=args.decimals,
            name_prefix=args.prefix,
        )
    else:
        sync_sw_buckets(
            base_dp_width=args.base,
            target_dp_widths=targets,
            output_root=output_root,
            decimal_places=args.decimals,
            name_prefix=args.prefix,
        )


if __name__ == "__main__":
    main()
