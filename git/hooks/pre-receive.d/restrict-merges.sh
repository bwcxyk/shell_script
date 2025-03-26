#!/usr/bin/env bash
#
# pre-receive hook to restrict merges into 'main'
#

# 启用调试模式，将日志输出到文件
exec 1> >(tee "/tmp/git_hook_debug.log") 2>&1
echo "=== Hook started at $(date) ==="

target_branch="main"
allowed_branches=("release/*" "hotfix/*")
echo "配置信息: target_branch=$target_branch, allowed_branches=${allowed_branches[*]}"

while read oldrev newrev refname; do
  echo "处理推送: oldrev=$oldrev newrev=$newrev refname=$refname"
  
  if [[ "$refname" != "refs/heads/$target_branch" ]]; then
    echo "跳过非目标分支的推送: $refname"
    continue
  fi

  parent_count=$(git show --no-patch --format="%P" "$newrev" | wc -w)
  echo "提交的父提交数量: $parent_count"

  if [[ $parent_count -eq 1 ]]; then
    echo "检测到非合并提交 (parent_count=$parent_count)"
    echo "GL-HOOK-ERR: 禁止直接推送非合并提交到 $target_branch"
    exit 1
  elif [[ $parent_count -ge 2 ]]; then
    echo "检测到合并提交 (parent_count=$parent_count)"
    merge_msg=$(git log -1 --format=%B "$newrev")
    echo "完整合并信息:"
    echo "$merge_msg"
    
    source_branch=$(echo "$merge_msg" | head -n1 | grep -o "Merge branch '[^']*'\|Revert \"Merge branch '[^']*'" | sed "s/Merge branch '//;s/Revert \"Merge branch '//;s/'.*//")
    echo "提取的源分支: '$source_branch'"

    if [[ -z "$source_branch" ]]; then
      echo "无法解析源分支名"
      echo "GL-HOOK-ERR: 无法解析合并提交中的源分支，请确保使用标准的合并提交信息"
      exit 1
    fi

    echo "开始检查分支权限..."
    allowed=false
    for pattern in "${allowed_branches[@]}"; do
      echo "检查模式: $pattern"
      if [[ "$pattern" == *"/"* ]]; then
        echo "使用通配符匹配: $pattern"
        if [[ "$source_branch" =~ ^${pattern//\*/.*}$ ]]; then
          echo "通配符匹配成功"
          allowed=true
          break
        fi
      elif [[ "$source_branch" == "$pattern" ]]; then
        echo "精确匹配成功"
        allowed=true
        break
      fi
    done

    if ! $allowed; then
      echo "分支权限检查失败"
      echo "GL-HOOK-ERR: Only '${allowed_branches[*]}' can be merged into '$target_branch'."
      exit 1
    fi
    echo "分支权限检查通过"
  fi
done

echo "=== Hook completed successfully at $(date) ==="
exit 0
