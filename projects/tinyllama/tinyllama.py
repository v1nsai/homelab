import transformers
import torch
from huggingface_hub import login
import json
import time

def main():
    login(token=json.load(open("projects/tinyllama/token.env"))["huggingface_token"])
    model_id = "TinyLlama/TinyLlama-1.1B-Chat-v1.0"

    chatbot = transformers.pipeline(
        "text-generation",
        model=model_id,
        torch_dtype=torch.float16,
        device_map="auto",
    )

    messages = [
        {
            "role": "system",
            "content": "You are a friendly chatbot who answers questions with concise, short answers. You can also ask questions to the user."
        }
    ]
    # Start chatting
    print("Hello! I am your chatbot. You can start chatting with me now. Type 'quit' to exit.")
    while True:
        user_input = input("You: ")
        messages.append({"role": "user", "content": f"{user_input}"})
        if user_input.lower() == 'quit':
            exit(0)
        
        start_time = time.time()
        prompt = chatbot.tokenizer.apply_chat_template(messages, tokenize=False, add_generation_prompt=True)
        outputs = chatbot(prompt, max_new_tokens=256, do_sample=True, temperature=0.7, top_k=50, top_p=0.95)
        stop_time = time.time()

        print(outputs[0]["generated_text"])
        print(f"Response time: {stop_time - start_time:.2f}s")

if __name__ == "__main__":
    main()
