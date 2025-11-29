from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from .agent import antigravity_agent, antigravity_chat_agent, AntigravityOutput
from google.adk.runners import InMemoryRunner
from google.genai.types import Part, UserContent
import json
from typing import Optional

from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Antigravity Agent API")


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"message": "Antigravity Agent API is running"}

class VerifyRequest(BaseModel):
    claim: str
    image_requested: bool = False
    language: str = "English"

@app.post("/verify", response_model=AntigravityOutput)
async def verify(request: VerifyRequest):
    try:
        # Construct the input for the agent
        prompt = f"Claim: {request.claim}\nImage Requested: {request.image_requested}\nLanguage: {request.language}"
        
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
            output = AntigravityOutput(**data)

            # Image Generation (Nano Banana / Gemini 2.5 Flash Image)
            if output.image_generation and output.image_generation.image_prompt:
                try:
                    from google.genai import Client
                    import base64
                    import os
                    
                    client = Client(api_key=os.environ.get("GOOGLE_API_KEY"))
                    # Using gemini-2.5-flash-image (Nano Banana)
                    response = client.models.generate_images(
                        model='gemini-2.5-flash-image',
                        prompt=output.image_generation.image_prompt,
                        config={'number_of_images': 1}
                    )
                    if response.generated_images:
                        image_bytes = response.generated_images[0].image.image_bytes
                        b64_img = base64.b64encode(image_bytes).decode('utf-8')
                        output.image_generation.generated_image_base64 = b64_img
                        print("Image generated successfully with Nano Banana.")
                except Exception as img_err:
                    print(f"Image generation failed: {img_err}")
                    # Fallback or just ignore, the prompt is still there
            
            return output
        except json.JSONDecodeError:
             # Fallback: try to find JSON object if there's extra text
            start = cleaned_text.find('{')
            end = cleaned_text.rfind('}')
            if start != -1 and end != -1:
                json_str = cleaned_text[start:end+1]
                data = json.loads(json_str)
                output = AntigravityOutput(**data)
                
                # Image Generation (Nano Banana / Gemini 2.5 Flash Image) - Copy of logic
                if output.image_generation and output.image_generation.image_prompt:
                    try:
                        from google.genai import Client
                        import base64
                        import os
                        
                        client = Client(api_key=os.environ.get("GOOGLE_API_KEY"))
                        response = client.models.generate_images(
                            model='gemini-2.5-flash-image',
                            prompt=output.image_generation.image_prompt,
                            config={'number_of_images': 1}
                        )
                        if response.generated_images:
                            image_bytes = response.generated_images[0].image.image_bytes
                            b64_img = base64.b64encode(image_bytes).decode('utf-8')
                            output.image_generation.generated_image_base64 = b64_img
                            print("Image generated successfully with Nano Banana.")
                    except Exception as img_err:
                        print(f"Image generation failed: {img_err}")

                return output
            else:
                raise ValueError(f"Could not parse JSON from response: {cleaned_text}")

    except Exception as e:
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))

class ChatRequest(BaseModel):
    message: str
    session_id: str = "default_session"
    language: str = "English"

class ChatResponse(BaseModel):
    response: str
    assessment: str
    image_prompt: Optional[str] = None

@app.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    try:
        runner = InMemoryRunner(agent=antigravity_chat_agent)
        session = await runner.session_service.create_session(
            app_name=runner.app_name, user_id="api_user", session_id=request.session_id
        )
        content = UserContent(parts=[Part(text=f"{request.message}\n(Respond in {request.language})")])
        
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
            return ChatResponse(**data)
        except json.JSONDecodeError:
             # Fallback: try to find JSON object if there's extra text
            start = cleaned_text.find('{')
            end = cleaned_text.rfind('}')
            if start != -1 and end != -1:
                json_str = cleaned_text[start:end+1]
                data = json.loads(json_str)
                return ChatResponse(**data)
            else:
                # Fallback for plain text response (if agent fails to output JSON)
                return ChatResponse(
                    response=final_text,
                    assessment="UNCERTAIN",
                    image_prompt=None
                )


    except Exception as e:
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8002)
