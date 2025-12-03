from fastapi import FastAPI, status
from pydantic import BaseModel
from typing import List


class FeatureFlag(BaseModel):
    name: str
    enabled: bool
    description: str | None = None


app = FastAPI(
    title="Trunk-Based Demo",
    description=(
        "Reference FastAPI service demonstrating trunk-based development "
        "concepts with feature flags and progressive rollout."
    ),
    version="0.1.0",
)


FEATURE_FLAGS: List[FeatureFlag] = [
    FeatureFlag(name="new_checkout_flow", enabled=False, description="Gradual rollout via LaunchDarkly"),
    FeatureFlag(name="holiday_banner", enabled=True, description="Short-lived marketing flag"),
]


@app.get("/healthz", status_code=status.HTTP_200_OK)
def healthcheck() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/flags", response_model=List[FeatureFlag])
def list_flags() -> List[FeatureFlag]:
    return FEATURE_FLAGS


@app.get("/rollout")
def progressive_rollout(stage: int = 1) -> dict[str, str]:
    match stage:
        case 1:
            message = "Stage 1 - internal dogfood"
        case 2:
            message = "Stage 2 - 10% production traffic"
        case 3:
            message = "Stage 3 - 50% production traffic"
        case 4:
            message = "Stage 4 - 100% production traffic"
        case _:
            message = "Unknown stage"
    return {"stage": stage, "message": message}

