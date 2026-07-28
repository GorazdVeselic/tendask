#!/usr/bin/env bash
# Deploys the smart-engine edge function to the self-hosted WSL staging stack.
#
# Hosted Supabase resolves the bare specifiers in smart-engine/deno.json; the
# self-hosted router spawns workers with importMapPath = null (see
# volumes/functions/main/index.ts), so the bare names would not resolve there.
# The copy therefore rewrites them to fully-qualified npm: specifiers — the repo
# source stays as the hosted deploy wants it.
#
# Idempotent: re-run after every change to the function.
#
#   wsl -e bash -lc "/mnt/c/Users/Uporabnik/StudioProjects/tendask/tool/staging_deploy_engine.sh"
set -euo pipefail

REPO="${REPO:-/mnt/c/Users/Uporabnik/StudioProjects/tendask}"
DEST="${DEST:-$HOME/tendask-supabase/volumes/functions}"

src="$REPO/supabase/functions"
[ -d "$src/smart-engine" ] || { echo "no $src/smart-engine — wrong REPO?" >&2; exit 1; }
[ -d "$DEST" ] || { echo "no $DEST — is the staging stack installed?" >&2; exit 1; }

rm -rf "$DEST/smart-engine" "$DEST/_shared"
mkdir -p "$DEST/smart-engine" "$DEST/_shared"

# Tests and the fake db never run in the container; shipping them would only
# widen what a worker can import.
for f in "$src"/smart-engine/*.ts; do
  case "$(basename "$f")" in
    *_test.ts | fake_db.ts) continue ;;
  esac
  cp "$f" "$DEST/smart-engine/"
done
for f in "$src"/_shared/*.ts; do
  case "$(basename "$f")" in *_test.ts) continue ;; esac
  cp "$f" "$DEST/_shared/"
done

# The import map, applied by hand.
sed -i \
  -e "s#from '@supabase/supabase-js'#from 'npm:@supabase/supabase-js@2'#g" \
  -e "s#from 'h3-js'#from 'npm:h3-js@4'#g" \
  -e "s#from 'jose'#from 'npm:jose@5'#g" \
  "$DEST"/smart-engine/*.ts "$DEST"/_shared/*.ts

left=$(grep -rlE "from '(@supabase/supabase-js|h3-js|jose)'" "$DEST/smart-engine" "$DEST/_shared" || true)
[ -z "$left" ] || { echo "unrewritten bare imports in: $left" >&2; exit 1; }

echo "deployed $(ls "$DEST/smart-engine"/*.ts | wc -l) engine + $(ls "$DEST/_shared"/*.ts | wc -l) shared files to $DEST"
