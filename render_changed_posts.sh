#!/bin/bash

# 스크립트 설명 출력
echo "=========================================="
echo "변경된 포스트 파일 렌더링 스크립트"
echo "=========================================="
echo ""

# Git으로 변경된 파일 목록 가져오기
echo "1. Git에서 변경된 파일 검색 중..."
changed_files=$(git diff --name-only HEAD)

# staged 파일도 포함
staged_files=$(git diff --name-only --cached)

# 모든 변경된 파일 합치기
all_changed_files=$(echo -e "${changed_files}\n${staged_files}" | sort -u)

echo "   전체 변경된 파일:"
echo "$all_changed_files" | sed 's/^/   - /'
echo ""

# posts 폴더 내의 index.md 파일만 필터링
echo "2. posts/ 폴더 내 index.md 파일 필터링 중..."
post_files=$(echo "$all_changed_files" | grep '^posts/.*index\.md$')

if [ -z "$post_files" ]; then
    echo "   ⚠️  변경된 index.md 파일이 없습니다."
    echo ""
    exit 0
fi

echo "   필터링된 파일:"
echo "$post_files" | sed 's/^/   - /'
echo ""

# 각 파일에 대해 quarto render 실행
echo "3. Quarto 렌더링 시작..."
echo ""

file_count=0
success_count=0
fail_count=0

while IFS= read -r file; do
    if [ -n "$file" ]; then
        file_count=$((file_count + 1))
        echo "-------------------------------------------"
        echo "[$file_count] 렌더링 중: $file"
        echo "-------------------------------------------"
        
        if quarto render "$file"; then
            echo "✅ 성공: $file"
            success_count=$((success_count + 1))
        else
            echo "❌ 실패: $file"
            fail_count=$((fail_count + 1))
        fi
        echo ""
    fi
done <<< "$post_files"

# 결과 요약
echo "=========================================="
echo "렌더링 완료"
echo "=========================================="
echo "총 파일 수: $file_count"
echo "성공: $success_count"
echo "실패: $fail_count"
echo "=========================================="

