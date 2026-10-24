#!/usr/bin/env bash
# cobol-lint/check.sh - read-only checks for this repo's COBOL rules.
#
#   bash .claude/skills/cobol-lint/check.sh            # whole repo
#   bash .claude/skills/cobol-lint/check.sh FILE...    # just these
#
# Checks (.cob/.cpy): line longer than 72 columns, TAB characters,
# CR characters, bad column-7 indicator.  Checks (.dat): CR
# characters, unequal record lengths, missing final newline.
# Repo-wide: duplicate program basenames (all land in build/bin/)
# and lib/src PROGRAM-ID not matching the file name.
# Exit 0 = clean, 1 = problems found.  Needs only bash + awk + grep.

cd "$(dirname "$0")/../../.." || exit 2

if [ $# -gt 0 ]; then
    files=("$@")
    whole_repo=0
else
    mapfile -t files < <(ls tutorials/*/*.cob examples/*/*.cob \
        lib/src/*.cob lib/tests/*.cob lib/copybooks/*.cpy \
        tutorials/*/*.dat examples/*/*.dat 2>/dev/null)
    whole_repo=1
fi

CR=$(printf '\r')
problems=0
report() { echo "$1"; problems=$((problems + 1)); }

for f in "${files[@]}"; do
    [ -f "$f" ] || { report "$f: file not found"; continue; }

    # grep -U, not awk: Git Bash tools strip CR in text mode.
    crs=$(grep -cU "$CR" "$f")
    if [ "$crs" -gt 0 ]; then
        first=$(grep -nU "$CR" "$f" | head -1 | cut -d: -f1)
        report "$f:$first: $crs line(s) end in CR (use LF)"
    fi

    case "$f" in
    *.cob | *.cbl | *.cpy)
        while IFS= read -r line; do report "$line"; done < <(
            awk -v F="$f" '
            {
                raw = $0
                sub(/\r$/, "", raw)
                if (index(raw, "\t")) {
                    print F ":" NR ": TAB character (use spaces)"
                    next
                }
                if (length(raw) > 72) {
                    print F ":" NR ": " length(raw) " columns; text past column 72 is ignored by cobc"
                }
                c7 = substr(raw, 7, 1)
                if (length(raw) >= 7 && c7 !~ /^[ *\/Dd-]$/) {
                    print F ":" NR ": column 7 is \"" c7 "\"; code must start in column 8"
                }
            }' "$f")
        ;;
    *.dat)
        while IFS= read -r line; do report "$line"; done < <(
            awk -v F="$f" '
            {
                r = $0; sub(/\r$/, "", r)
                n = length(r); len[NR] = n
                count[n]++
                if (count[n] > count[best]) best = n
            }
            END {
                for (i = 1; i <= NR; i++)
                    if (len[i] != best)
                        print F ":" i ": record is " len[i] " chars, most records are " best
            }' "$f")
        if [ -s "$f" ] && [ -n "$(tail -c 1 "$f")" ]; then
            report "$f: no newline at end of file"
        fi
        ;;
    esac
done

if [ "$whole_repo" -eq 1 ]; then
    # Every main program and test becomes build/bin/<basename>.
    dups=$(ls tutorials/*/*.cob examples/*/*.cob lib/tests/*.cob 2>/dev/null |
        awk -F/ '{ b = $NF; sub(/\.cob$/, "", b); k = toupper(b)
                   seen[k] = seen[k] " " $0; n[k]++ }
                 END { for (k in n) if (n[k] > 1) print k ":" seen[k] }')
    while IFS= read -r d; do
        [ -n "$d" ] && report "duplicate program basename ${d%%:*} (all build to build/bin/):${d#*:}"
    done <<< "$dups"

    # CALL "FOO" loads build/lib/FOO.so, so PROGRAM-ID must equal FOO.
    for f in lib/src/*.cob; do
        [ -f "$f" ] || continue
        want=$(basename "$f" .cob)
        got=$(awk 'toupper($0) ~ /PROGRAM-ID\./ {
                   s = toupper($0); sub(/.*PROGRAM-ID\.[ ]*/, "", s)
                   sub(/[ .\r].*/, "", s); print s; exit }' "$f")
        [ "$got" = "${want^^}" ] ||
            report "$f: PROGRAM-ID is \"$got\" but the file name needs \"${want^^}\""
    done
fi

if [ "$problems" -eq 0 ]; then
    echo "cobol-lint: clean (${#files[@]} files checked)"
    exit 0
fi
echo "cobol-lint: $problems problem(s)"
exit 1
