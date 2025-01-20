import torch
import time

def test_cuda_operations():
    print(f"PyTorch version: {torch.__version__}")
    print(f"CUDA available: {torch.cuda.is_available()}")
    if torch.cuda.is_available():
        print(f"CUDA device: {torch.cuda.get_device_name()}")
        print(f"CUDA version: {torch.version.cuda}")
    
    # Create tensors
    print("\nTesting tensor operations...")
    x = torch.randn(1000, 1000)
    print(f"Created tensor on: {x.device}")
    
    # Time GPU transfer and operations
    start = time.time()
    if torch.cuda.is_available():
        x_gpu = x.cuda()
        print(f"Moved tensor to: {x_gpu.device}")
        
        # Do some operations on GPU
        y_gpu = x_gpu @ x_gpu.T  # Matrix multiplication
        z_gpu = torch.relu(y_gpu)
        
        # Move back to CPU
        z_cpu = z_gpu.cpu()
        print(f"Moved result back to: {z_cpu.device}")
    
    end = time.time()
    print(f"Operations took: {end - start:.4f} seconds")

if __name__ == "__main__":
    test_cuda_operations()