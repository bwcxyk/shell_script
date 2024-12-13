#!/bin/bash
#
# Git pre-receive hook for enforcing conventional commit messages.
# Place this script in the hooks directory of your repository to enforce commit message rules.
#
# Usage: This hook runs automatically on `git push` and checks all incoming commits.

# 定义正则表达式用于匹配约定式提交
msg_regex="^(revert: )?(feat|fix|docs|style|refactor|test|chore|perf|ci|build|revert)(\([^\)]+\))?:\s.{1,50}(\n\n.*)?(\n\n.*)?$"
# ^(revert: )?                                                    # 可选的 revert: 前缀
# (feat|fix|docs|style|refactor|test|chore|perf|ci|build|revert)  # 提交类型
# (\([^\)]+\))?                                                   # 可选的 scope
# :\s                                                             # 冒号和空格分隔符
# .{1,50}                                                         # 描述, 1 到 50 个字符
# (\n\n.*)?                                                       # 可选的 body
# (\n\n.*)?$                                                      # 可选的 footer

check_single_commit() {
  # 跳过合并提交
  if [[ "$COMMIT_MESSAGE" =~ ^Merge.* ]]; then
    echo "Merge commit detected, skipping validation."
    COMMIT_CHECK_STATUS=0
    return
  fi

  # 验证提交消息
  if [[ "$COMMIT_MESSAGE" =~ $msg_regex ]]; then
    COMMIT_CHECK_STATUS=0
    echo "Commit message is conform."
  else
    COMMIT_CHECK_STATUS=1
    echo "Commit message \"$COMMIT_MESSAGE\" is not conform."
    echo "Expected format: <type>(<scope>): <description>"
    echo "Example: feat(auth): 添加登录功能"
    echo "The push has been refused by the server."
    echo "You can change your commit message with: git commit --amend -m \"<NEW MESSAGE>\""
    echo "See https://www.conventionalcommits.org/zh-hans/v1.0.0/ for more information."
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

    [ "$COMMIT_CHECK_STATUS" != "0" ] && exit 1
  done
}

# Get custom commit message format
while read -r OLD_REVISION NEW_REVISION REFNAME ; do
  check_all_commits
done

exit 0
