import re
import os
import json
from pathlib import Path

def parse_report(report_path, metrics):
    """Parses a single Synopsys report file for specific metrics."""
    try:
        with open(report_path, 'r') as f:
            content = f.read()

        # Area Parsing (Example - adjust regex based on your report format)
        area_match = re.search(r"Total cell area:\s+([\d\.]+)", content)
        if area_match:
            metrics['area_cell'] = float(area_match.group(1))
        area_match_total = re.search(r"Total area:\s+([\d\.]+)", content) # Look for total if available
        if area_match_total:
             metrics['area_total'] = float(area_match_total.group(1))
        elif 'area_cell' in metrics: # Fallback if only cell area found
             metrics['area_total'] = metrics['area_cell'] # Approximation

        # Power Parsing (Example)
        power_match = re.search(r"Total Dynamic Power\s+=\s+([\d\.]+)e([-+]\d+)\s+W", content) # Example format mW or uW
        # Needs refinement based on actual report (Internal, Switching, Leakage)
        # A simpler proxy often used is total cell count or area as power indicator if power report unreliable/complex
        # Let's extract different power components if possible
        int_power = re.search(r"Cell Internal Power\s+=\s+([\d\.]+)\s+\(.*\)", content)
        switch_power = re.search(r"Net Switching Power\s+=\s+([\d\.]+)\s+\(.*\)", content)
        leak_power = re.search(r"Cell Leakage Power\s+=\s+([\d\.]+)\s+\(.*\)", content)

        total_power = 0
        if int_power:
            metrics['power_internal'] = float(int_power.group(1))
            total_power += metrics['power_internal']
        if switch_power:
            metrics['power_switching'] = float(switch_power.group(1))
            total_power += metrics['power_switching']
        if leak_power:
            metrics['power_leakage'] = float(leak_power.group(1))
            total_power += metrics['power_leakage']
        if total_power > 0:
             metrics['power_total'] = total_power

        # Timing Parsing (Example: Worst Negative Slack - WNS)
        # Look for the endpoint summary, often near the end
        wns_match = re.search(r"slack \(VIOLATED\)\s+(-?[\d\.]+)", content) # VIOLATED paths
        if not wns_match:
             wns_match = re.search(r"slack \(MET\)\s+(-?[\d\.]+)", content) # MET paths (use the smallest MET slack)

        if wns_match:
            metrics['timing_wns'] = float(wns_match.group(1))
            # Calculate delay: Period - Slack (assuming a single clock)
            # Needs clock period info, which isn't typically in the timing report itself easily
            # Often better to report slack directly, or max frequency (1 / (Period - WNS)) if period is known

    except FileNotFoundError:
        print(f"Warning: Report file not found: {report_path}")
    except Exception as e:
        print(f"Error parsing {report_path}: {e}")


def main():
    base_dir = Path(__file__).parent.parent # Project root
    report_base_dir = base_dir / "syn" / "reports"
    results_dir = base_dir / "scripts" / "results"
    results_dir.mkdir(exist_ok=True)
    results_file = results_dir / "synthesis_results.json"

    designs = {
        "exact": report_base_dir / "exact",
        "approx_v1": report_base_dir / "approximate_v1"
    }

    all_results = {}

    print("Parsing synthesis reports...")

    for name, report_dir in designs.items():
        print(f" Processing: {name}")
        metrics = {'design': name}
        area_report = report_dir / f"{'exact' if name == 'exact' else 'approx_compressor_8_2_v1'}_area.rpt"
        power_report = report_dir / f"{'exact' if name == 'exact' else 'approx_compressor_8_2_v1'}_power.rpt"
        timing_report = report_dir / f"{'exact' if name == 'exact' else 'approx_compressor_8_2_v1'}_timing.rpt"

        parse_report(area_report, metrics)
        parse_report(power_report, metrics)
        parse_report(timing_report, metrics)

        all_results[name] = metrics
        print(f"  Metrics found: {metrics}")


    # --- Add Error Metrics Manually (or parse from sim log) ---
    # These values should come from your simulation log output
    print("\nFetching Error Metrics (update manually if needed)...")
    # Example values - REPLACE with actual results from tb_compressor_8_2.v execution log
    error_metrics = {
        "approx_v1": {"ER": 10.156, "MED": 0.117} # Example: ~10% error rate, low MED
    }

    if "approx_v1" in all_results and "approx_v1" in error_metrics:
        all_results["approx_v1"]["error_rate_percent"] = error_metrics["approx_v1"]["ER"]
        all_results["approx_v1"]["mean_error_distance"] = error_metrics["approx_v1"]["MED"]
        print(f"  Added error metrics for approx_v1: {error_metrics['approx_v1']}")
    else:
         print("  Warning: Could not add error metrics for approx_v1.")

    # --- Save results ---
    print(f"\nSaving parsed results to {results_file}")
    try:
        with open(results_file, 'w') as f:
            json.dump(all_results, f, indent=4)
        print("Results saved successfully.")
    except Exception as e:
        print(f"Error saving results: {e}")

if __name__ == "__main__":
    main()
