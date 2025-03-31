## 4.4.6
* xcode 16.0 예외처리 추가 

## 4.4.2
* auto layout 코드 개선 

## 4.4.0
* 중요 
* 간편결제는 생체인증, 통합결제 2가지를 사용중 
* 간편결제시 서버 분리 승인 로직을 추가하면서 사이드 이펙트가 생긴것을 확인하여 아래와 같이 수정함
  * 발견된 사이드 이펙트는 서버 승인 로직이 추가되면서 클라이언트에서 간편결제 승인이 진행되지 않는 것임 (separatelyConfirmed 옵션 기본값이 true)
  * 수정사항) extra -> bio_extra 모델로 대체 
    * bio_extra.separatelyConfirmed 옵션은 통합결제에만 적용되도록 수정 
    * bio_extra.separatelyConfirmedBio 옵션은 간편결제에만 적용되도록 수정 
      - 단 이 옵션이 true일 경우 특성상 서버승인으로만 진행을 해야함 

## 4.3.5
* bootpay 4.3.5 적용 
* 등록된 결제수단 편집 기능 제공 

## 4.3.2
* 커스텀 테마 적용할 수 있도록 수정 

## 4.3.1
* bootpay 4.3.1 적용 
* bootpay js 4.2.0 적용 

## 4.3.0
* bootpay webview transactionConfirm 작동되지 않는 버그 수정 

## 4.2.9
* 비밀번호 간편결제 적용 

## 4.2.6
* bootpay 4.2.6 적용
* swift version 명시 
* debounceClose event 적용시점 변경 viewWilldisappear -> viewDidappear

## 4.2.5
* debounce event 적용 
* bootpay 4.2.5 적용 

## 4.2.0
* metadata data type changed dic -> string 

## 4.1.9
* onReady -> onIsseud renamed 

## 4.1.8
* bootpay 4.1.7 적용 

## 4.1.7

* 비밀번호 간편결제 지원  

## 4.1.6

* bootpay 4.1.6 적용 

## 4.0.21

* swift compiler version 에 따른 코드 분기 

## 4.0.2

* Bootpay.confirm(data) -> Bootpay.transacionConfirm() 으로 수정 

* confirm에서 return false 일 때 결제창 닫히는 버그 수정   

## 4.0.1

* bootpay bio 호환을 위한 필드 scope 변경  

## 4.0.0

* bootpay js major update 
