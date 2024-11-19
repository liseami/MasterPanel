//
//  Date+.swift
//  SMON
//
//  Created by 赵翔宇 on 2024/3/5.
//

import Foundation

extension Date {
    
    var dateStr : String {
        let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today)
            let beforeYesterday = calendar.date(byAdding: .day, value: -2, to: today)
            
            if calendar.isDateInToday(self) {
                return "今天"
            } else if calendar.isDate(self, inSameDayAs: yesterday!) {
                return "昨天"
            } else if calendar.isDate(self, inSameDayAs: beforeYesterday!) {
                return "前天"
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .long
                dateFormatter.timeStyle = .none
                return dateFormatter.string(from: self)
            }
    }
    var timeStampStr : String
    {
        String(Int(self.timeIntervalSince1970 * 1000))
    }
    var zodiacString: String {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: self)
        let day = calendar.component(.day, from: self)

        switch (month, day) {
        case (3, 21...31), (4, 1...19):
            return "白羊座"
        case (4, 20...30), (5, 1...20):
            return "金牛座"
        case (5, 21...31), (6, 1...21):
            return "双子座"
        case (6, 22...30), (7, 1...22):
            return "巨蟹座"
        case (7, 23...31), (8, 1...22):
            return "狮子座"
        case (8, 23...31), (9, 1...22):
            return "处女座"
        case (9, 23...30), (10, 1...23):
            return "天秤座"
        case (10, 24...31), (11, 1...22):
            return "天蝎座"
        case (11, 23...30), (12, 1...21):
            return "射手座"
        case (12, 22...31), (1, 1...19):
            return "摩羯座"
        case (1, 20...31), (2, 1...18):
            return "水瓶座"
        case (2, 19...29), (3, 1...20):
            return "双鱼座"
        default:
            return "无效日期"
        }
    }

    var zodiacEmojiString: String {
        let zodiacString = self.zodiacString

        switch zodiacString {
        case "白羊座":
            return "♈️"
        case "金牛座":
            return "♉️"
        case "双子座":
            return "♊️"
        case "巨蟹座":
            return "♋️"
        case "狮子座":
            return "♌️"
        case "处女座":
            return "♍️"
        case "天秤座":
            return "♎️"
        case "天蝎座":
            return "♏️"
        case "射手座":
            return "♐️"
        case "摩羯座":
            return "♑️"
        case "水瓶座":
            return "♒️"
        case "双鱼座":
            return "♓️"
        default:
            return "无效日期"
        }
    }
}
