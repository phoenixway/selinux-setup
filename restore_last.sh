#!/bin/bash

git rev-list --all | while read commit; do
    if git ls-tree -r $commit | grep -q remove-policy.sh; then
        git show $commit:remove-policy.sh > remove-policy.sh
        break
    fi
done
