PYTHON ?= "python"
NVCC ?= "nvcc"
TORCH = $(shell $(PYTHON) -c "import os; import torch; print(os.path.dirname(torch.__file__))")
OPS_PATH ?= FlowNet2_src/models/components/ops
.PHONY: all clean check-nvcc

#
# Build Targets
#

all: channelnorm correlation resample2d

channelnorm: $(OPS_PATH)/channelnorm/_ext
$(OPS_PATH)/channelnorm/_ext: $(OPS_PATH)/channelnorm/src/ChannelNorm_kernel.o
	$(call build_extension,$@)

correlation: $(OPS_PATH)/correlation/_ext
$(OPS_PATH)/correlation/_ext: $(OPS_PATH)/correlation/src/correlation_cuda_kernel.o
	$(call build_extension,$@)

resample2d: $(OPS_PATH)/resample2d/_ext
$(OPS_PATH)/resample2d/_ext: $(OPS_PATH)/resample2d/src/Resample2d_kernel.o
	$(call build_extension,$@)

#
# Helper
#

clean:
	find $(OPS_PATH) -type f -name "*.o" -exec rm {} \+
	find $(OPS_PATH) -type d -name "_ext" -exec rm -r {} \+

check-nvcc:
	if [ ! $$(which $(NVCC)) ]; then \
		echo "nvcc is not installed."; \
		echo "Install the nvidia cuda toolkit >= 8.0.0."; \
		echo "Aborting compilation of pytorch_flownet2"; \
		exit 1; \
	fi

define build_extension
	cd "$$(dirname $(1))" && $(PYTHON) build.py
endef

#
# Compile Cuda Code
#

%.o: %.cu | check-nvcc
	$(NVCC) -c -o $@ $< \
		-x cu \
		-Xcompiler \
		-fPIC \
		-arch=sm_30 \
			-gencode arch=compute_30,code=sm_30 \
			-gencode arch=compute_37,code=sm_37 \
			-gencode arch=compute_50,code=sm_50 \
			-gencode arch=compute_52,code=sm_52 \
			-gencode arch=compute_60,code=sm_60 \
			-gencode arch=compute_61,code=sm_61 \
			-gencode arch=compute_61,code=compute_61 \
		-I $(TORCH)/lib/include/TH \
		-I $(TORCH)/lib/include/THC

