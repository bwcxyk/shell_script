#!/bin/bash
#
# pre-receive hook for Commit Check
#

VALID_MESSAGE_PREFIXES="^(refacto|feat|test|fix|style|docs|chore|perf)"

check_single_commit()
{
  #
  # Put here any logic you want for your commit
  #
  # Skip merge commit
  if [[ "$COMMIT_MESSAGE" =~ "Merge branch" ]]; then
    echo "Merge commit detected, skipping validation."
    COMMIT_CHECK_STATUS=0
    return
  fi
  
  # Set COMMIT_CHECK_STATUS to non zero to indicate an error
  if [[ "$COMMIT_MESSAGE" =~ $VALID_MESSAGE_PREFIXES:[[:space:]].*$  ]]; then
    COMMIT_CHECK_STATUS=0
    echo "Commit message is conform."
  else
    COMMIT_CHECK_STATUS=1
    echo "Commit message \"$COMMIT_MESSAGE\" is not conform."
    echo "The push has been refused by the server."
    echo "You can change your commit message with the command: git commit --amend -m \"<NEW MESSAGE>\""
  fi
}

check_all_commits() {
  if [ "$OLD_REVISION" = "0000000000000000000000000000000000000000" ]; then
    OLD_REVISION=$NEW_REVISION
  fi

  REVISIONS=$(git rev-list "$OLD_REVISION".."$NEW_REVISION")
  IFS=$'\n' read -ra LIST_OF_REVISIONS <<< "$REVISIONS"

  for REVISION in "${LIST_OF_REVISIONS[@]}"; do
    COMMIT_HASH=$REVISION
    COMMIT_MESSAGE=$(git cat-file commit "$COMMIT_HASH" | sed '1,/^$/d')

    check_single_commit

    if [ "$COMMIT_CHECK_STATUS" != "0" ]; then
      echo "Commit validation failed for commit $REVISION ($COMMIT_AUTHOR)" >&2
      exit 1
    fi
  done
}

# Get custom commit message format
while read -r OLD_REVISION NEW_REVISION REFNAME ; do
  check_all_commits
done

exit 0
