#!/usr/bin/env python3
"""Plot all power traces found in the current directory (trace-N.txt).

Use --diff to plot each trace's deviation from the mean of all traces
instead of the raw values.
"""

import argparse
import glob

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.cm as cm

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument(
    "--diff",
    action="store_true",
    help="Plot each trace minus the mean trace instead of raw values.",
)
args = parser.parse_args()

# Load all trace files, sorted numerically
trace_files = sorted(glob.glob("traces/trace-*"), key=lambda f: int(f.split("-")[1].split(".")[0]))
n = len(trace_files)
print(f"Loading {n} traces…")

raw = [np.load(f) for f in trace_files]
min_len = min(len(t) for t in raw)
traces = np.array([t[:min_len] for t in raw])
mean_trace = traces.mean(axis=0)

colors = cm.viridis(np.linspace(0, 1, n))

fig, ax = plt.subplots(figsize=(14, 6))

if args.diff:
    for i, data in enumerate(traces):
        ax.plot(data - mean_trace, color=colors[i], alpha=0.3, linewidth=0.6)
    ax.axhline(0, color="black", linewidth=1.2, linestyle="--", label="mean (zero)")
    ax.set_title(f"All {n} Power Traces — Difference from Mean")
    ax.set_ylabel("Power Value − Mean")
    output_file = "all_traces_diff.png"
else:
    for i, data in enumerate(traces):
        ax.plot(data, color=colors[i], alpha=0.3, linewidth=0.6)
    ax.plot(mean_trace, color="black", linewidth=1.5, linestyle="--", label="mean")
    ax.set_title(f"All {n} Power Traces")
    ax.set_ylabel("Power Value")
    output_file = "all_traces.png"

# Proxy artist so the legend just shows one entry for all traces
from matplotlib.lines import Line2D
trace_proxy = Line2D([0], [0], color=cm.viridis(0.5), alpha=0.6, linewidth=1,
                     label=f"traces (n={n})")
handles, labels = ax.get_legend_handles_labels()
ax.legend(handles=[trace_proxy] + handles, labels=[trace_proxy.get_label()] + labels)

ax.set_xlabel("Sample Index")
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig(output_file, dpi=150)
print(f"Saved to {output_file}")
plt.show()
