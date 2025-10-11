---
toc: true
toc-depth: 3
toc-expand: true
number-sections: true
title: Unity - matchWidthOrHeight - 해상도 변경 시 UI 스케일링 기준을 조정
date: 2025-02-02
categories: [Unity]
author: limyj0708
comments:
  giscus:
    repo: limyj0708/blog
format:
    html:
        page-layout: full
---


# CanvasScaler의 matchWidthOrHeight

Unity UI의 **CanvasScaler** 컴포넌트의 **matchWidthOrHeight** 속성은, 화면 해상도가 다양한 기기에서 UI 요소들이 어떻게 스케일링될지를 결정함.

## matchWidthOrHeight 값의 의미
- 아래 코드에서는 `Awake()` 함수에서 match 변수를 scaler.matchWidthOrHeight에 적용함.
```csharp
[Tooltip("Match width or height")]
[Range(0, 1)]
public float match = 0.5f; // 0 = width, 1 = height, 0.5 = balanced
void Awake() {
    ApplyScreenSettings();
    var scaler = GetComponent<CanvasScaler>();
    if (scaler != null) {
            scaler.referenceResolution = referenceResolution;
            scaler.matchWidthOrHeight = match;
        }
}
```

### matchWidthOrHeight = 0 (너비 기준)
- UI가 **화면 너비**에 맞춰 스케일링됨
- 모든 기기에서 UI 요소의 **가로 크기**가 일정하게 유지됨
- 세로가 긴 기기에서는 UI 요소가 위아래로 늘어날 수 있음
- **가로 방향 게임**에 적합

### matchWidthOrHeight = 1 (높이 기준)
- UI가 **화면 높이**에 맞춰 스케일링됨
- 모든 기기에서 UI 요소의 **세로 크기**가 일정하게 유지됨
- 가로가 넓은 기기에서는 UI 요소가 좌우로 늘어날 수 있음
- **세로 방향 게임**에 적합

### matchWidthOrHeight = 0.5 (균형)
- 너비와 높이의 **중간값**으로 스케일링됨
- 다양한 화면 비율에서 UI 요소의 크기가 **적절히 조정**됨
- **여러 해상도를 지원**해야 할 때 권장되는 값

## 실제 동작

예를 들어 `referenceResolution = (1080, 1920)`인 경우:

1. **iPhone SE (750x1334)** 에서:
   - match = 0: 너비 750에 맞추므로 UI가 전체적으로 작아짐
   - match = 1: 높이 1334에 맞추므로 UI 요소가 약간 작아지지만 세로 비율은 유지됨
   - match = 0.5: 양쪽을 모두 고려해 균형있게 조정됨

2. **iPad (1024x768)** 에서:
   - match = 0: 너비 1024에 맞추므로 UI 요소가 가로로 약간 늘어나고 세로로는 매우 압축됨
   - match = 1: 높이 768에 맞추므로 UI 요소가 세로로 압축되지만 가로로는 많이 늘어남
   - match = 0.5: 양쪽에서 각각 절충된 형태로 UI가 표시됨

세로 모드 게임은 1에 가깝게, 가로 모드 게임은 0에 가깝게 설정하는 것이 일반적임