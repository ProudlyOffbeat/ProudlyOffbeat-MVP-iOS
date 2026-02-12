# Gemini API Key 설정 가이드

## 1. API 키 발급

1. [Google AI Studio](https://aistudio.google.com/apikey)에 접속 (개인 Gmail로 로그인)
2. **Create API Key** 클릭
3. **Create API key in new project** 선택
4. 생성된 키 복사

> 우선 제가 생성한 키로 테스트하고 추후 배포시 어떻게 할지 정해봅시다

## 2. 프로젝트에 키 등록

`LivingStory-iOS/LivingStory-iOS/Core/Consts/Secrets.swift` 파일을 열고 `YOUR_GEMINI_API_KEY`를 발급받은 키로 교체합니다.

```swift
enum Secrets {
    static let geminiAPIKey = "여기에_발급받은_키_붙여넣기"
}
```

> `Secrets.swift`는 `.gitignore`에 포함되어 있어 커밋되지 않습니다.

## 3. 파일이 없는 경우

처음 클론한 경우 `Secrets.swift`가 없을 수 있습니다. 아래 내용으로 직접 파일을 생성하세요.

**경로**: `LivingStory-iOS/LivingStory-iOS/Core/Consts/Secrets.swift`

```swift
import Foundation

enum Secrets {
    static let geminiAPIKey = "여기에_발급받은_키_붙여넣기"
}
```

## 4. 사용 중인 모델

- **모델**: `gemini-3-flash-preview` (Gemini 3 Flash)
- **엔드포인트**: `https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent`
- **응답 형식**: `responseMimeType: "application/json"` (구조화된 JSON 응답)

## 5. 배포 시 API 키 관리

지금 개발 단계에서는 각자 키를 Secrets.swift에 넣어서 쓰면 됩니다.

나중에 앱스토어에 배포할 때는 아래 방식으로 전환해야 합니다.

### 왜?

앱에 키를 직접 넣으면 앱 파일을 분석해서 키를 꺼낼 수 있습니다.
그래서 배포 시에는 **우리 서버를 중간에 두는 방식**을 씁니다.

### 구조

```
[지금 - 개발 단계]
앱 ----(API 키 포함)----> Gemini API

[나중 - 배포 단계]
앱 ----(키 없음)----> 우리 서버 ----(API 키 보관)----> Gemini API
```

### 언제 하면 되나?

- 앱스토어 배포 직전에 백엔드 서버를 하나 만들면 됩니다
- 서버는 Firebase Cloud Functions, Cloudflare Workers 등으로 간단하게 구축 가능
- 개발 중에는 지금 방식(Secrets.swift)으로 충분합니다
