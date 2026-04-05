#!/bin/bash

# print CUDA version
echo "PufferTank 4.0 (CUDA $(nvcc --version | grep "release" | awk '{print $6}'))"

# check if NVIDIA driver is loaded
if ! nvidia-smi > /dev/null 2>&1; then
    echo "WARNING: The NVIDIA Driver was not detected. GPU functionality will not be available."
fi

# keep container running
exec "$@"
