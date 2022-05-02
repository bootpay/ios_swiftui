//
//  PG.swift
//  bootpay-bio
//
//  Created by Taesup Yoon on 2022/04/26.
//

import Foundation

class PG {
    public static func getName(_ name: String) -> String {
        switch name {
        case "kcp":
            return "NHN KCP"
        case "danal":
            return "Danal"
        case "inicis":
            return "KG 이니시스"
        case "udpay":
            return "유디페이"
        case "nicepay":
            return "NICEPAY"
        case "lgup":
            return "토스페이먼츠"
        case "toss":
            return "토스페이먼츠"
        case "payapp":
            return "페이앱"
        case "kicc":
            return "EASY PAY"
        case "jtnet":
            return "tPAY"
        case "mobilians":
            return "KG 모빌리언스"
        case "payletter":
            return "payletter"
        case "welcome":
            return "웰컴페이먼츠"
        default:
            return ""
        }
    }
}
