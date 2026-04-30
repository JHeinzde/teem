#!/usr/bin/env python3
"""
Combines all trace files from the traces/ directory into a single numpy array.
"""

import numpy as np
import os
from pathlib import Path

# Get the traces directory
traces_dir = Path("traces")

# Find all trace files and sort them by number
trace_files = sorted(traces_dir.glob("trace-*"), key=lambda x: int(x.stem.split('-')[1]))

print(f"Found {len(trace_files)} trace files")

# Load the first trace to determine data type
first_trace = np.load(trace_files[0])
print(f"Shape of first trace: {first_trace.shape}")
print(f"Data type of individual trace: {first_trace.dtype}")

# Find the maximum trace length across all traces
print("Scanning all traces to find maximum length...")
max_trace_length = 0
for trace_file in trace_files:
    trace_data = np.load(trace_file)
    max_trace_length = max(max_trace_length, len(trace_data))

print(f"Maximum trace length: {max_trace_length}")

# Create a 2D array to hold all traces (padded to max length)
# Shape will be (num_traces, max_trace_length)
num_traces = len(trace_files)
combined_traces = np.zeros((num_traces, max_trace_length), dtype=first_trace.dtype)

# Load each trace and place it in the correct position, padding with zeros if needed
for idx, trace_file in enumerate(trace_files):
    trace_data = np.load(trace_file)
    # Copy the trace data and pad with zeros if it's shorter than max_trace_length
    combined_traces[idx, :len(trace_data)] = trace_data
    
    if (idx + 1) % 50 == 0:
        print(f"Processed {idx + 1}/{num_traces} traces")

print(f"Combined array shape: {combined_traces.shape}")
print(f"Combined array dtype: {combined_traces.dtype}")
print(f"Value range: {combined_traces.min()} - {combined_traces.max()}")

# Save the combined traces
output_file = "example-traces.npy"
np.save(output_file, combined_traces)
print(f"\nSaved combined traces to {output_file}")
