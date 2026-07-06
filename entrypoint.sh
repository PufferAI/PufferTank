#!/bin/bash

# print CUDA version
echo "PufferTank 4.0 (CUDA $(nvcc --version | grep "release" | awk '{print $6}'))"

# check if NVIDIA driver is loaded
if ! nvidia-smi > /dev/null 2>&1; then
    echo "WARNING: The NVIDIA Driver was not detected. GPU functionality will not be available."
fi

# Conditionally force Mesa for software rendering.
# Commit dd662d8 added __GLX_VENDOR_LIBRARY_NAME=mesa to fix window creation on
# setups without NVIDIA GLX passthrough (e.g. CPU-only or WSL2 without graphics
# bindings). However, forcing Mesa breaks native NVIDIA GLX passthrough because
# Mesa tries to load the nvidia-drm DRI driver, which is not present in the
# container, leading to Zink/Vulkan swapchain errors.
# Only set it when NVIDIA GLX libraries are absent and the user hasn't
# explicitly configured it.
if [ -z "${__GLX_VENDOR_LIBRARY_NAME+x}" ]; then
    if ! ldconfig -p 2>/dev/null | grep -q "libGLX_nvidia.so.0"; then
        export __GLX_VENDOR_LIBRARY_NAME=mesa
        echo "INFO: NVIDIA GLX libraries not found. Forcing Mesa for software rendering."
    fi
fi

# keep container running
exec "$@"
