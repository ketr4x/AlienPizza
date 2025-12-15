import json
from fastapi import FastAPI, HTTPException, APIRouter
from pydantic import BaseModel
from openai import OpenAI
import os
from dotenv import load_dotenv
import uvicorn
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse

app = FastAPI()
load_dotenv()
api_router = APIRouter(prefix="/api")


class EvaluateRequest(BaseModel):
    toppings: list[str]


@app.post("/api/evaluate")
async def evaluate(request: EvaluateRequest):
    toppings = request.toppings

    if not toppings:
        raise HTTPException(status_code=400, detail="No toppings provided")

    client = OpenAI(
        api_key=os.environ.get("API_KEY", ""),
        base_url=os.environ.get("API_URL", "")
    )

    response = client.chat.completions.create(
        model=os.environ.get("AI_MODEL"),
        messages=[
            {"role": "system", "content": "A cross-species pizza generator that brings giant raccoons and friendly aliens together"},
            {
                "role": "user",
                "content":
                    f'''    
                    Provide a compatibility rating in a scale of 0/100 for a pizza with these toppings: {toppings}. If the pizza is compatible with the species, it should receive a high score.
                    Provide the name for said pizza.
                    Provide a little backstory about why it suits Humans, Giant Raccoons and Friendly Aliens.   
                    Reply with a JSON object only, no extra text. Example reply:
                    {{"rating": "98", "name": "The Cosmic Dumpster Deluxe", "backstory": "Raccoons love leftovers and texture, Aliens prefer balance and glow-energy, Humans just want it cheesy"}}
                    Return the JSON object exactly as shown.
                    Do not use tags like ```json.
                    '''
            }
        ]
    )

    return json.loads(response.choices[0].message.content)


@app.get("/api/toppings")
async def toppings(count: int = 12):
    client = OpenAI(
        api_key=os.environ.get("API_KEY", ""),
        base_url=os.environ.get("API_URL", "")
    )

    response = client.chat.completions.create(
        model=os.environ.get("AI_MODEL"),
        messages=[
            {"role": "system", "content": "A cross-species pizza generator that brings giant raccoons and friendly aliens together"},
            {
                "role": "user",
                "content":
                    f'''
                    Provide a topping list for a cross-species pizza generator. They should be pretty crazy and random.
                    Example format: {{"toppings":["topping1","topping2"]}}
                    You should return {count} toppings.
                    Return the JSON object exactly as shown.
                    Do not use tags like ```json.
                    '''
            }
        ]
    )

    return json.loads(response.choices[0].message.content)

app.include_router(api_router)
flutter_build_path = "../flutter/build/web"
app.mount("/assets", StaticFiles(directory=f"{flutter_build_path}/assets"), name="assets")

@app.get("/{full_path:path}")
async def serve_flutter(full_path: str):
    file_path = os.path.join(flutter_build_path, full_path)
    if os.path.isfile(file_path):
        return FileResponse(file_path)
    return FileResponse(f"{flutter_build_path}/index.html")

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run("main:app", host="0.0.0.0", port=port)