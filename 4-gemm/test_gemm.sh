#!/usr/bin/env bash

set -u

mkdir -p test-logs
total=0
passed=0
failed=0

for n in $(seq 1 32); do
    for batch in 1 7 100 1000; do
        total=$((total + 1))
        log="test-logs/n${n}_batch${batch}.log"

        if ./gemm "$n" "$batch" >"$log" 2>&1; then
            if grep -q "TEST PASS" "$log"; then
                passed=$((passed + 1))
                printf "PASS  n=%2d  batch=%4d\n" "$n" "$batch"
            else
                failed=$((failed + 1))
                printf "FAIL  n=%2d  batch=%4d (no TEST PASS)\n" "$n" "$batch"
                tail -n 8 "$log"
            fi
        else
            failed=$((failed + 1))
            printf "FAIL  n=%2d  batch=%4d (program error)\n" "$n" "$batch"
            tail -n 8 "$log"
        fi
    done
done

echo
echo "========== SUMMARY =========="
echo "Total:  $total"
echo "Passed: $passed"
echo "Failed: $failed"
echo "Logs:   test-logs/"

if [ "$failed" -ne 0 ]; then
    exit 1
fi
