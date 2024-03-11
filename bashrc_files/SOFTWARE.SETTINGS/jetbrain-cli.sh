#!/usr/bin/env sh

set +x

JETBRAINS_TOOLBOX_SCRIPT_PATH="$HOME/Library/Application Support/JetBrains/Toolbox/scripts/"
for f in "$JETBRAINS_TOOLBOX_SCRIPT_PATH"/*; do
    chmod +x "$f"
done

add_to_path "${JETBRAINS_TOOLBOX_SCRIPT_PATH}"
set +x
