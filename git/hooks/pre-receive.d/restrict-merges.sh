#!/usr/bin/env bash
#
# pre-receive hook to restrict merges into 'main'
#
set -e

zero_commit='0000000000000000000000000000000000000000'
source_branch='develop'
target_branch='main'
hotfix_pattern='^hotfix/.*'

while read -r oldrev newrev refname; do
    # 如果目标分支不是 main，直接略过
    [ "${refname#refs/heads/}" != "$target_branch" ] && continue

    # 如果是新建或删除分支，直接略过
    [ "$oldrev" = "$zero_commit" ] || [ "$newrev" = "$zero_commit" ] && continue

    # 获取最新的提交信息
    msg=$(git rev-list --pretty "$oldrev..$newrev" -n 1 --format=%B)

    # 如果不是 merge 请求，直接略过
    [[ ! $msg =~ "Merge branch" ]] && continue

    # 提取合并的源分支名称
    merged_branch=$(echo "$msg" | grep -o "Merge branch '[^']\+'" | sed "s/Merge branch '\(.*\)'/\1/")

    # 检查是否是 develop 分支或 hotfix/* 分支
    if [[ "$merged_branch" != "$source_branch" && ! "$merged_branch" =~ $hotfix_pattern ]]; then
        echo "GL-HOOK-ERR: Only '$source_branch' or branches matching '$hotfix_pattern' can be merged into '$target_branch'."
        echo "GL-HOOK-ERR: Attempted to merge from '$merged_branch' into '$target_branch'."
        exit 1
    fi

done

exit 0
