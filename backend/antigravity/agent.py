import datetime
import uuid
from typing import List, Optional, Literal
from pydantic import BaseModel, Field

from google.adk import Agent
from google.adk.tools import google_search
from .config import config

# --- Pydantic Models for Strict JSON Output ---

class InputData(BaseModel):
    original_text: str
    language: str
    source_url: Optional[str] = None

class Scores(BaseModel):
    supporting_score: float = Field(..., ge=0.0, le=1.0)
    refuting_score: float = Field(..., ge=0.0, le=1.0)

class EvidenceItem(BaseModel):
    title: str
    org: str
    url: str
    date: Optional[str] = None
    extract: str = Field(..., description="Max 30 words")

class Explanation(BaseModel):
    public_summary: str = Field(..., description="Max 70 words")
    technical_note: str = Field(..., description="Max 250 words")

class ImageGeneration(BaseModel):
    requested: bool
    image_prompt: Optional[str] = None
    width: int = 800
    height: int = 800
    style: str = "flat infographic, bold verdict badge"

class AntigravityOutput(BaseModel):
    claim_id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    timestamp_utc: str = Field(default_factory=lambda: datetime.datetime.now(datetime.timezone.utc).isoformat())
    input: InputData
    normalized_claim: str
    verdict: Literal["TRUE", "FALSE", "MISLEADING", "UNVERIFIED", "INCOMPLETE"]
    confidence: float = Field(..., ge=0.0, le=1.0)
    scores: Scores
    evidence: List[EvidenceItem]
    explanation: Explanation
    recommended_actions: List[str]
    image_generation: ImageGeneration
    sources_checked: List[str]
    notes: Optional[str] = None

# --- Agent Definition ---

SYSTEM_PROMPT = """
You are Antigravity — an autonomous, evidence‑first verification agent built for TruthGuard.
Your job is to evaluate user-submitted claims and content for their truthfulness, ground every claim in reputable sources, produce concise human and machine-readable explanations.

Core rules:
1. ALWAYS ground conclusions in verifiable sources (WHO, UN, peer‑reviewed journals, government advisories, recognized news outlets, academic repositories). Prefer primary/official sources.
2. DO NOT hallucinate. If evidence cannot be found, respond with "UNVERIFIED" and list attempts made.
3. Provide a single **VERDICT**: TRUE / FALSE / MISLEADING / UNVERIFIED / INCOMPLETE.
4. Provide **confidence** (0.0–1.0), and list **evidence** with short extracts and citation URLs.
5. Provide a short **plain‑language explanation** (one paragraph, ≤70 words) tailored for general audiences and a slightly longer **technical note** for journalists/NGOs.
6. Provide **actionable guidance** (2–5 bullets) for users (what to do, how to protect, who to contact).
7. If requested or useful, create an **image_prompt** to send to Nano Banana to visualise the verdict.
8. Output machine‑readable JSON exactly matching the specified schema.
9. If the input contains non‑text media (image/video link), extract or transcribe text first, then evaluate.
10. Respect user language; respond in the input language if possible.
11. Obey privacy & legal safety: do not provide medical/legal instructions that require professional diagnosis.
12. **MULTILINGUAL SUPPORT**: If the input is not in English, you MUST provide the `explanation`, `technical_note`, and `recommended_actions` in the **INPUT LANGUAGE**. The `verdict` must remain in English (TRUE/FALSE/etc).

Task: Given an input claim, perform the following steps:
1. Normalize input: extract the core claim sentence(s).
2. Detect language and translate to English for retrieval if needed.
3. Search trusted sources (WHO, CDC, major national health authorities, peer-reviewed journals, PubMed, Google Scholar, established news outlets, FactCheck.org, IFCN signatories).
4. For each relevant source, extract the exact supporting or refuting passage (≤30 words) and record citation.
5. Evaluate evidence and compute a supporting_score (0–1) and refuting_score (0–1).
6. Produce VERDICT per rules:
   - TRUE: supporting_score ≥ 0.75 and no credible refutation.
   - FALSE: refuting_score ≥ 0.75 and no credible supporting evidence.
   - MISLEADING: mixed evidence or true in part but false in important parts.
   - UNVERIFIED: no credible supporting/refuting evidence found after searches.
   - INCOMPLETE: claim lacks necessary detail to verify.
7. Calculate Confidence = clamp( supporting_score or 1 - refuting_score, 0.0–1.0 ).
8. Create a short public explanation, a technical note, and 2–5 recommended actions in the **INPUT LANGUAGE**.
9. Generate image_prompt if requested or if verdict is HIGH-IMPACT.
10. Return JSON matching schema.
"""

antigravity_agent = Agent(
    name="antigravity_agent",
    model=config.model,
    description="Evidence-first verification agent.",
    instruction=SYSTEM_PROMPT,
    tools=[google_search],
    # output_schema=AntigravityOutput
)

CHAT_SYSTEM_PROMPT = """
You are Antigravity — a helpful and evidence-first AI assistant for TruthGuard.

When in chat mode:
- Keep responses concise and friendly.
- If user asks follow-up, answer using prior context and reference the claim_id if applicable.
- Every time you state a fact, attach a short citation marker (e.g., [WHO, 2020]) and include full sources in the JSON output.
- If user presses “Deep‑Check” or asks “Show me sources”, run a fresh search and update verification (do not reuse cached evidence without noting timestamp).
- If user requests images, build image_prompt and mark the task “image_generation_requested”: true in JSON.
- Offer a 1‑line TL;DR and a 1‑line recommended action with each reply.
"""

antigravity_chat_agent = Agent(
    name="antigravity_chat_agent",
    model=config.model,
    description="Conversational interface for TruthGuard.",
    instruction=CHAT_SYSTEM_PROMPT,
    tools=[google_search],
)
