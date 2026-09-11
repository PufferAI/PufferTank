#!/bin/bash

echo "PufferTank 5.0 (CUDA $(nvcc --version | grep "release" | awk '{print $6}'))"

if ! nvidia-smi > /dev/null 2>&1; then
    echo "WARNING: The NVIDIA Driver was not detected. GPU functionality will not be available."
fi

exec "$@"
