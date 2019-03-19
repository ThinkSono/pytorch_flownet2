#!/usr/bin/env bash
PYTHON=${PYTHON:-"python"}
TORCH=$($PYTHON -c "import os; import torch; print(os.path.dirname(torch.__file__))")

cd src

echo "Compiling correlation kernels by nvcc..."

rm correlation_cuda_kernel.o
rm -r ../_ext

nvcc -c -o correlation_cuda_kernel.o correlation_cuda_kernel.cu -x cu -Xcompiler -fPIC -arch=sm_30 -gencode arch=compute_30,code=sm_30 -gencode arch=compute_37,code=sm_37 -gencode arch=compute_50,code=sm_50 -gencode arch=compute_52,code=sm_52 -gencode arch=compute_60,code=sm_60 -gencode arch=compute_61,code=sm_61 -gencode arch=compute_61,code=compute_61

cd ../
$PYTHON build.py
