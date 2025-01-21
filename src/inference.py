import torch
from transformers import AutoModelForCausalLM, AutoTokenizer

def chat():
    model_path = "DeepSeek-R1-Distill-Qwen-7B"
    
    print("Loading tokenizer...")
    tokenizer = AutoTokenizer.from_pretrained(model_path)
    
    print("Loading model...")
    model = AutoModelForCausalLM.from_pretrained(
        model_path,
        device_map="cuda",
        torch_dtype=torch.bfloat16
    )
    
    print("\nModel loaded! You can start chatting. Type 'quit' to exit.\n")
    
    messages = []
    
    while True:
        user_input = input("\nYou: ")
        if user_input.lower() == 'quit':
            break
            
        if user_input.lower() == 'clear':
            messages.clear()
            print("Chat history cleared!")
            continue
        
        # Add user message to history
        messages.append({"role": "user", "content": user_input})
        
        # Use their exact chat template method
        prompt_tokens = tokenizer.apply_chat_template(
            messages,
            add_generation_prompt=True
        )
        
        input_ids = torch.tensor([prompt_tokens], device="cuda")
        attention_mask = torch.ones_like(input_ids, device="cuda")
        
        outputs = model.generate(
            input_ids,
            attention_mask=attention_mask,
            max_new_tokens=2000,
            temperature=0.6,
            do_sample=True,
            pad_token_id=tokenizer.eos_token_id,
            eos_token_id=tokenizer.eos_token_id,
            repetition_penalty=1.1
        )
        
        # Get just the new tokens
        new_tokens = outputs[0][len(prompt_tokens):]
        response = tokenizer.decode(new_tokens, skip_special_tokens=True).strip()
        
        # Clean up the response by removing any think tags
        #if "<think>" in response:
            #response = response.split("</think>")[-1].strip()
        
        print("\nResponse:", response)
        messages.append({"role": "assistant", "content": response})

if __name__ == "__main__":
    chat()