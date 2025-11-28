from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from .agent import antigravity_agent, AntigravityOutput
from google.adk.runners import InMemoryRunner
from google.genai.types import Part, UserContent
import json

app = FastAPI(title="Antigravity Agent API")

class VerifyRequest(BaseModel):
    claim: str
    image_requested: bool = False

@app.post("/verify", response_model=AntigravityOutput)
async def verify(request: VerifyRequest):
    try:
        # Construct the input for the agent
        prompt = f"Claim: {request.claim}\nImage Requested: {request.image_requested}"
        
        runner = InMemoryRunner(agent=antigravity_agent)
        session = await runner.session_service.create_session(
            app_name=runner.app_name, user_id="api_user"
        )
        content = UserContent(parts=[Part(text=prompt)])
        
        final_text = ""
        async for event in runner.run_async(
            user_id=session.user_id,
            session_id=session.id,
            new_message=content,
        ):
            if event.content and event.content.parts:
                for part in event.content.parts:
                    if part.text:
                        final_text += part.text
        
        # Parse the JSON output
        # The agent is instructed to output JSON.
        # We might need to clean it if it contains markdown code blocks.
        cleaned_text = final_text.strip()
        if cleaned_text.startswith("```json"):
            cleaned_text = cleaned_text[7:]
        elif cleaned_text.startswith("```"):
            cleaned_text = cleaned_text[3:]
        
        if cleaned_text.endswith("```"):
            cleaned_text = cleaned_text[:-3]
            
        cleaned_text = cleaned_text.strip()
        
        try:
            data = json.loads(cleaned_text)
            return AntigravityOutput(**data)
        except json.JSONDecodeError:
             # Fallback: try to find JSON object if there's extra text
            start = cleaned_text.find('{')
            end = cleaned_text.rfind('}')
            if start != -1 and end != -1:
                json_str = cleaned_text[start:end+1]
                data = json.loads(json_str)
                return AntigravityOutput(**data)
            else:
                raise ValueError(f"Could not parse JSON from response: {cleaned_text}")

    except Exception as e:
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8002)
