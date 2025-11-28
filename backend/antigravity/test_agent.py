import asyncio
import sys
import os

# Add backend to sys.path
sys.path.append(os.path.join(os.path.dirname(__file__), "..", ".."))

from backend.antigravity.agent import antigravity_agent

async def main():
    claim = "Chlorine in swimming pools kills the coronavirus."
    prompt = f"Claim: {claim}\nImage Requested: False"
    print(f"Testing claim: {claim}")
    try:
        response = await antigravity_agent.run(prompt)
        print("Response received:")
        # Check if response is the model or has output
        if hasattr(response, 'output'):
            print(response.output)
        else:
            print(response)
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    asyncio.run(main())
