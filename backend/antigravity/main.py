from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from .agent import antigravity_agent, AntigravityOutput

app = FastAPI(title="Antigravity Agent API")

class VerifyRequest(BaseModel):
    claim: str
    image_requested: bool = False

@app.post("/verify", response_model=AntigravityOutput)
async def verify(request: VerifyRequest):
    try:
        # Construct the input for the agent
        prompt = f"Claim: {request.claim}\nImage Requested: {request.image_requested}"
        
        # Run the agent
        # We use the agent's run method. 
        # Assuming ADK agent run returns a response object with an 'output' attribute 
        # matching the output_schema.
        response = await antigravity_agent.run(prompt)
        
        # If response is just the output model (because of output_schema), return it.
        # If it's a wrapper, access .output or similar.
        # Based on ADK patterns, if output_schema is set, it might return the object directly or in .output
        # I'll assume it returns the object or I can cast it.
        
        if isinstance(response, AntigravityOutput):
            return response
        elif hasattr(response, 'output') and isinstance(response.output, AntigravityOutput):
            return response.output
        else:
             # Fallback if it returns a dict or something else
             return response

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8002)
