import json
import matplotlib.pyplot as plt
import numpy as np
from pathlib import Path
import sys

def plot_comparison(results, metric, title, ylabel, lower_is_better=True):
    """Generates a bar chart comparing a metric for exact vs approx designs."""
    labels = list(results.keys())
    values = [results[label].get(metric) for label in labels]

    # Check if data exists for the metric
    if any(v is None for v in values):
        print(f"Skipping plot '{title}': Metric '{metric}' not found for all designs.")
        return

    # Handle potential list values if multiple power/area metrics exist (take total)
    numeric_values = []
    for v in values:
        if isinstance(v, list): # Example if parsing returned multiple values
             numeric_values.append(sum(v)) # Or appropriate aggregation
        else:
             numeric_values.append(v)

    if not numeric_values:
        print(f"Skipping plot '{title}': No numeric values found for metric '{metric}'.")
        return

    fig, ax = plt.subplots()
    x = np.arange(len(labels))
    bar_width = 0.35

    bars = ax.bar(x, numeric_values, bar_width, label=metric)

    ax.set_ylabel(ylabel)
    ax.set_title(title)
    ax.set_xticks(x)
    ax.set_xticklabels(labels)
    ax.legend()

    # Add value labels on bars
    ax.bar_label(bars, fmt='%.2f', padding=3)

    fig.tight_layout()
    return fig


def plot_scatter(results, x_metric, y_metric, title, xlabel, ylabel):
    """Generates a scatter plot for two metrics."""
    labels = list(results.keys())
    x_values = [results[label].get(x_metric) for label in labels]
    y_values = [results[label].get(y_metric) for label in labels]

    # Check if data exists
    if any(v is None for v in x_values) or any(v is None for v in y_values):
        print(f"Skipping plot '{title}': Metrics '{x_metric}' or '{y_metric}' not found for all designs.")
        return

    fig, ax = plt.subplots()
    ax.scatter(x_values, y_values)

    # Add labels to points
    for i, label in enumerate(labels):
        ax.annotate(label, (x_values[i], y_values[i]), textcoords="offset points", xytext=(0,10), ha='center')

    ax.set_xlabel(xlabel)
    ax.set_ylabel(ylabel)
    ax.set_title(title)
    ax.grid(True)
    fig.tight_layout()
    return fig

def calculate_savings(exact_val, approx_val):
    """Calculates percentage saving."""
    if exact_val is None or approx_val is None or exact_val == 0:
        return None
    return ((exact_val - approx_val) / exact_val) * 100

def main():
    base_dir = Path(__file__).parent.parent
    results_file = base_dir / "scripts" / "results" / "synthesis_results.json"
    plots_dir = base_dir / "scripts" / "plots"
    plots_dir.mkdir(exist_ok=True)

    print(f"Loading results from: {results_file}")
    try:
        with open(results_file, 'r') as f:
            results = json.load(f)
    except FileNotFoundError:
        print(f"Error: Results file not found at {results_file}")
        print("Please run 'parse_synth_reports.py' first.")
        sys.exit(1)
    except json.JSONDecodeError:
        print(f"Error: Could not decode JSON from {results_file}. Check the file format.")
        sys.exit(1)

    print("Generating plots...")

    # --- Generate Comparison Plots ---
    plot_config = [
        {'metric': 'area_total', 'title': 'Area Comparison', 'ylabel': 'Total Area (units from report)', 'lower_is_better': True},
        {'metric': 'power_total', 'title': 'Power Comparison (Estimated)', 'ylabel': 'Total Power (units from report)', 'lower_is_better': True},
        {'metric': 'timing_wns', 'title': 'Timing Comparison (WNS)', 'ylabel': 'Worst Negative Slack (ns)', 'lower_is_better': False}, # Higher (less negative) slack is better
    ]

    figs = {}
    for config in plot_config:
        fig = plot_comparison(results, config['metric'], config['title'], config['ylabel'], config['lower_is_better'])
        if fig:
            plot_filename = plots_dir / f"{config['metric']}_comparison.png"
            fig.savefig(plot_filename)
            print(f" Saved plot: {plot_filename}")
            plt.close(fig) # Close figure to free memory

    # --- Generate Scatter/Trade-off Plots ---
    # Need at least one approx design and the exact design with necessary metrics
    if "exact" in results and "approx_v1" in results:
        exact_res = results["exact"]
        approx_res = results["approx_v1"]

        # Calculate Savings
        area_saving = calculate_savings(exact_res.get('area_total'), approx_res.get('area_total'))
        power_saving = calculate_savings(exact_res.get('power_total'), approx_res.get('power_total'))
        error_rate = approx_res.get('error_rate_percent')
        med = approx_res.get('mean_error_distance')

        # Plot Error vs Savings (if data available)
        tradeoff_data = []
        if error_rate is not None:
            if area_saving is not None:
                tradeoff_data.append({'x': error_rate, 'y': area_saving, 'label': 'approx_v1', 'x_label': 'Error Rate (%)', 'y_label': 'Area Saving (%)', 'title': 'Area Saving vs Error Rate'})
            if power_saving is not None:
                tradeoff_data.append({'x': error_rate, 'y': power_saving, 'label': 'approx_v1', 'x_label': 'Error Rate (%)', 'y_label': 'Power Saving (%)', 'title': 'Power Saving vs Error Rate'})

        for item in tradeoff_data:
             fig, ax = plt.subplots()
             ax.scatter(item['x'], item['y'], label=item['label'])
             ax.annotate(item['label'], (item['x'], item['y']), textcoords="offset points", xytext=(0,10), ha='center')
             ax.set_xlabel(item['x_label'])
             ax.set_ylabel(item['y_label'])
             ax.set_title(item['title'])
             ax.grid(True)
             fig.tight_layout()
             plot_filename = plots_dir / f"{item['title'].lower().replace(' ', '_')}.png"
             fig.savefig(plot_filename)
             print(f" Saved plot: {plot_filename}")
             plt.close(fig)

        # Plot Power vs Delay (using WNS as proxy for delay - higher WNS is better/faster)
        power_vals = [r.get('power_total') for r in results.values()]
        wns_vals = [r.get('timing_wns') for r in results.values()]

        if not any(v is None for v in power_vals) and not any(v is None for v in wns_vals):
            fig = plot_scatter(results, 'power_total', 'timing_wns', 'Power vs Timing (WNS)', 'Total Power', 'Worst Negative Slack (ns)')
            if fig:
                 plot_filename = plots_dir / "power_vs_timing_scatter.png"
                 fig.savefig(plot_filename)
                 print(f" Saved plot: {plot_filename}")
                 plt.close(fig)

    print("\nPlot generation complete.")
    print(f"Plots saved in: {plots_dir}")

if __name__ == "__main__":
    main()
