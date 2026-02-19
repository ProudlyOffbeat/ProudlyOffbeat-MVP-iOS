//
//  GeminiPrompts.swift
//  LivingStory-iOS
//

import Foundation

enum GeminiPrompts {

    static func readingEnvironment(bookTitle: String, bookDescription: String) -> String {
        """
        너는 어린이 독서 환경 설정 전문가야.
        아래 책 정보를 바탕으로 독서에 어울리는 환경을 JSON으로 추천해줘.

        ## 책 정보
        - 제목: \(bookTitle)
        - 줄거리: \(bookDescription)

        ## 응답 형식 (반드시 아래 JSON 구조를 따를 것)
        {
          "musicCategory": "카테고리명",
          "lighting": {
            "hue": 0~360 사이 정수,
            "saturation": 0~100 사이 정수,
            "brightness": 0~100 사이 정수
          },
          "conversations": [
            {
              "question": "아이에게 물어볼 질문",
              "effect": "이 질문의 교육적 효과"
            }
          ]
        }

        ## 규칙
        1. musicCategory는 다음 중 하나: \(MusicCategory.promptList)
        2. lighting은 책 분위기에 맞는 색상/밝기 (hue: 0~360, saturation: 0~100, brightness: 0~100)
        3. conversations는 정확히 3개, 책 내용 기반 대화 주제
        4. 모든 텍스트는 한국어로 작성
        5. JSON만 반환하고 다른 텍스트는 포함하지 마
        """
    }
}
