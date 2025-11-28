# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Deployment script for LLM Auditor."""

import os
from pathlib import Path

from absl import app
from absl import flags
from dotenv import load_dotenv
from llm_auditor.agent import root_agent
import vertexai
from vertexai import agent_engines
from vertexai.preview.reasoning_engines import AdkApp

FLAGS = flags.FLAGS
flags.DEFINE_string("project_id", None, "GCP project ID.")
flags.DEFINE_string("location", None, "GCP location.")
flags.DEFINE_string("bucket", None, "GCP bucket.")
flags.DEFINE_string("resource_id", None, "ReasoningEngine resource ID.")

flags.DEFINE_bool("list", False, "List all agents.")
flags.DEFINE_bool("create", False, "Creates a new agent.")
flags.DEFINE_bool("delete", False, "Deletes an existing agent.")
flags.DEFINE_bool("force", False, "Force deletion without confirmation prompt.")
flags.mark_bool_flags_as_mutual_exclusive(["create", "delete"])


def create() -> None:
    """Creates an agent engine for LLM Auditor."""
    display_name = root_agent.name
    requirements = [
        "google-adk (>=0.0.2,<2.0.0)",
        "google-cloud-aiplatform[agent_engines] (>=1.88.0,<2.0.0)",
        "google-genai (>=1.5.0,<2.0.0)",
        "pydantic (>=2.10.6,<3.0.0)",
        "absl-py (>=2.2.1,<3.0.0)",
    ]
    
    # Compute absolute path to llm_auditor package
    # deploy.py is in backend/llm-auditor/deployment/
    # llm_auditor package is in backend/llm-auditor/llm_auditor/
    deploy_dir = Path(__file__).resolve().parent
    package_path = str(deploy_dir.parent / "llm_auditor")
    
    try:
        print(f"Creating agent '{display_name}'...")
        print(f"Requirements: {requirements}")
        print(f"Package path: {package_path}")
        
        adk_app = AdkApp(agent=root_agent, enable_tracing=True)
        
        remote_agent = agent_engines.create(
            adk_app,
            display_name=display_name,
            requirements=requirements,
            extra_packages=[package_path],
        )
        
        print(f"Successfully created remote agent: {remote_agent.resource_name}")
        
    except Exception as e:
        print(f"\nError creating agent '{display_name}':")
        print(f"  Exception: {type(e).__name__}: {e}")
        print(f"  Display name: {display_name}")
        print(f"  Requirements: {requirements}")
        print("\nPossible causes:")
        print("  - Network connectivity issues")
        print("  - Authentication/permission errors (check gcloud auth)")
        print("  - Invalid project/location configuration")
        print("  - Resource quota exceeded")
        print("  - Missing or invalid dependencies")
        raise SystemExit(1) from e


def delete(resource_id: str, force: bool = False) -> None:
    """Deletes an agent engine.
    
    Args:
        resource_id: The resource ID of the agent to delete.
        force: If True, skip confirmation prompt and force deletion.
    """
    try:
        # Check if agent exists
        remote_agent = agent_engines.get(resource_id)
        
        if remote_agent is None:
            print(f"Error: Agent with resource_id '{resource_id}' not found.")
            return
        
        # Prompt for confirmation unless force is True or running in non-interactive mode
        if not force:
            # Check if running in non-interactive mode (CI/CD)
            import sys
            if not sys.stdin.isatty():
                print("Running in non-interactive mode. Skipping confirmation.")
            else:
                confirmation = input(
                    f"Are you sure you want to delete agent '{remote_agent.display_name}' "
                    f"(resource_id: {resource_id})? [y/N]: "
                )
                if confirmation.lower() not in ['y', 'yes']:
                    print("Deletion cancelled.")
                    return
        
        # Delete the agent
        remote_agent.delete(force=True)
        print(f"Successfully deleted remote agent: {resource_id}")
        
    except Exception as e:
        print(f"Error deleting agent '{resource_id}': {e}")
        raise


def list_agents() -> None:
    remote_agents = agent_engines.list()
    TEMPLATE = '''
{agent.name} ("{agent.display_name}")
- Create time: {agent.create_time}
- Update time: {agent.update_time}
'''
    remote_agents_string = '\n'.join(TEMPLATE.format(agent=agent) for agent in remote_agents)
    print(f"All remote agents:\n{remote_agents_string}")

def main(argv: list[str]) -> None:
    del argv  # unused
    load_dotenv()

    project_id = (
        FLAGS.project_id
        if FLAGS.project_id
        else os.getenv("GOOGLE_CLOUD_PROJECT")
    )
    location = (
        FLAGS.location if FLAGS.location else os.getenv("GOOGLE_CLOUD_LOCATION")
    )
    bucket = (
        FLAGS.bucket if FLAGS.bucket
        else os.getenv("GOOGLE_CLOUD_STORAGE_BUCKET")
    )

    print(f"PROJECT: {project_id}")
    print(f"LOCATION: {location}")
    print(f"BUCKET: {bucket}")

    if not project_id:
        print("Missing required environment variable: GOOGLE_CLOUD_PROJECT")
        return
    elif not location:
        print("Missing required environment variable: GOOGLE_CLOUD_LOCATION")
        return
    elif not bucket:
        print(
            "Missing required environment variable: GOOGLE_CLOUD_STORAGE_BUCKET"
        )
        return


    try:
        print("\nInitializing Vertex AI...")
        vertexai.init(
            project=project_id,
            location=location,
            staging_bucket=f"gs://{bucket}",
        )
        print("Vertex AI initialized successfully.\n")
    except Exception as e:
        print(f"\nError initializing Vertex AI:")
        print(f"  Exception: {type(e).__name__}: {e}")
        print(f"  Project ID: {project_id}")
        print(f"  Location: {location}")
        print(f"  Staging bucket: gs://{bucket}")
        print("\nPossible causes:")
        print("  - Invalid project ID or location")
        print("  - Authentication error (run 'gcloud auth application-default login')")
        print("  - Missing permissions (check IAM roles)")
        print("  - Vertex AI API not enabled (enable at console.cloud.google.com)")
        print("  - Invalid or inaccessible storage bucket")
        print("  - Network connectivity issues")
        raise SystemExit(1) from e


    if FLAGS.list:
        list_agents()
    elif FLAGS.create:
        create()
    elif FLAGS.delete:
        if not FLAGS.resource_id:
            print("resource_id is required for delete")
            return
        delete(FLAGS.resource_id, force=FLAGS.force)
    else:
        print("Unknown command")


if __name__ == "__main__":
    app.run(main)
