# Bootpay iOS SwiftUI / Bio SDK

`BootpayUI` (CocoaPods/SPM) — iOS SwiftUI 래퍼 + 생체인증 (`bio`).

## 배포 시 버전 동기화 체크리스트 (CRITICAL)

패키지 버전과 **런타임 VERSION 상수**가 어긋나면 webview/analytics 에 옛 버전이 보고된다. 한 곳만 올리면 안 된다.

| 파일 | 상수 | 비고 |
|------|------|------|
| `BootpayUI.podspec` | `s.version` | CocoaPods/SPM 배포 버전 (소스: tag) |
| `BootpayUI/Classes/bio/config/BootpayBuildConfig.swift` | `VERSION` | webview `setVersion()` 으로 송신되는 런타임 값 |
| `CHANGELOG.md` | — | 새 버전 항목 추가 |

CDN URL 변경 시 추가:
- `BootpayUI/Classes/bio/constants/BioConstants.swift` → `CDN_URL`

## 환경 기본값

런타임 환경은 iOS Swift core (`BootpayConstant.ENVIRONMENT_MODE`) 를 그대로 따른다. 기본값은 `"production"`. `Bootpay.setEnvironmentMode("development" | "stage" | "production")` 으로 토글.
