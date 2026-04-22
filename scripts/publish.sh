#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "Regenerating agents/AGENTS.md from skills..."

SKILLS_DIR="$ROOT_DIR/skills"
AGENTS_FILE="$ROOT_DIR/agents/AGENTS.md"

mkdir -p "$(dirname "$AGENTS_FILE")"

{
  echo '<skills>'
  echo ''
  echo 'You have additional SKILLs documented in directories containing a "SKILL.md" file.'
  echo ''
  echo 'These skills are:'

  for skill_dir in "$SKILLS_DIR"/*/; do
    if [[ -f "$skill_dir/SKILL.md" ]]; then
      skill_name="$(basename "$skill_dir")"
      echo " - $skill_name -> \"skills/$skill_name/SKILL.md\""
    fi
  done

  echo ''
  echo 'IMPORTANT: You MUST read the SKILL.md file whenever the description of the skills matches the user intent, or may help accomplish their task. '
  echo ''
  echo '<available_skills>'
  echo ''

  for skill_dir in "$SKILLS_DIR"/*/; do
    if [[ -f "$skill_dir/SKILL.md" ]]; then
      skill_name="$(basename "$skill_dir")"
      description=$(sed -n '/^description:/,/^[a-z]/{ /^description:/{ s/^description: *"//; s/"$//; p; }; }' "$skill_dir/SKILL.md" | head -1)
      if [[ -z "$description" ]]; then
        description=$(awk '/^description:/{flag=1; sub(/^description: *"?/,""); sub(/"$/,""); print; next} flag && /^[a-z]/{exit} flag{sub(/^ */,""); sub(/"$/,""); print}' "$skill_dir/SKILL.md" | tr '\n' ' ')
      fi
      echo "$skill_name: \`\"$description\"\`"
    fi
  done

  echo '</available_skills>'
  echo ''
  echo 'Paths referenced within SKILL folders are relative to that SKILL. For example the chonkie `scripts/rag_pipeline_example.py` would be referenced as `chonkie/scripts/rag_pipeline_example.py`. '
  echo ''
  echo '</skills>'
} > "$AGENTS_FILE"

echo "Generated $AGENTS_FILE"
echo "Publish artifacts generated successfully."
