from torch import float16
from json import load as json_load
from transformers import pipeline
from time import time as current_time
from huggingface_hub import login
from os import environ

def main():
    login(token=json_load(open("projects/localllama/token.env"))["huggingface_token"])
    environ["PYTORCH_CUDA_ALLOC_CONF"] = "expandable_segments:True"
    
    # model_id = "TinyLlama/TinyLlama-1.1B-Chat-v1.0"
    model_id = "meta-llama/Meta-Llama-3-8B"
    # model_id = "meta-llama/Meta-Llama-3-8B-Instruct"
    print(f"Using model: {model_id}")

    chatbot = pipeline(
        "text-generation",
        model=model_id,
        torch_dtype=float16,
        device_map="auto",
        # offload_buffers=True
    )

    messages = [
        {
            "role": "system",
            "content": "You are a friendly chatbot who answers questions with concise, short answers. You can also ask questions to the user."
        }
    ]

    print("Hello! I am your chatbot. You can start chatting with me now. Type 'quit' to exit.")
    while True:
        user_input = input("You: ")
        messages.append({"role": "user", "content": f"{user_input}"})
        if user_input.lower() == 'quit':
            exit(0)
        
        start_time = current_time()
        prompt = chatbot.tokenizer.apply_chat_template(messages, tokenize=False, add_generation_prompt=True)
        outputs = chatbot(prompt, max_new_tokens=256, do_sample=True, temperature=0.7, top_k=50, top_p=0.95)
        stop_time = current_time()

        print(outputs[0]["generated_text"])
        print(f"Response time: {stop_time - start_time:.2f}s")

if __name__ == "__main__":
    main()
