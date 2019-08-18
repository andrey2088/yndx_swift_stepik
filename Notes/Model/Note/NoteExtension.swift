import UIKit

extension Note: Codable {

    private static let colorStringSeparator: String.Element = ","

    private enum CodingKeys: String, CodingKey {
        case uid
        case title
        case content
        case color
        case importance
        case selfDestructDate = "self_destruct_date"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        uid = try container.decode(String.self, forKey: .uid)
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)

        importance = container.contains(.importance)
            ? try Importance(rawValue: container.decode(String.self, forKey: .importance)) ?? Importance.normal
            : Importance.normal

        color = container.contains(.color)
            ? try Note.uicolorFromArray(container.decode([Int].self, forKey: .color))
            : UIColor.white

        selfDestructDate = container.contains(.selfDestructDate)
            ? try container.decode(Date.self, forKey: .selfDestructDate)
            : nil
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(uid, forKey: .uid)
        try container.encode(title, forKey: .title)
        try container.encode(content, forKey: .content)

        if (importance != Importance.normal) {
            try container.encode(importance.rawValue, forKey: .importance)
        }

        if (color.extendedSRGB() != UIColor.white.extendedSRGB()) {
            try container.encode(Note.uicolorToArray(color), forKey: .color)
        }

        if let selfDestructDate = selfDestructDate {
            try container.encode(selfDestructDate, forKey: .selfDestructDate)
        }
    }


    private static func uicolorToArray(_ uicolor: UIColor) -> [Int] {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        uicolor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return [Int(r * 255), Int(g * 255), Int(b * 255), Int(a * 255)]
    }

    private static func uicolorFromArray(_ array: [Int]) -> UIColor {
        return UIColor(
            red: CGFloat(array[0]) / 255.0,
            green: CGFloat(array[1]) / 255.0,
            blue: CGFloat(array[2]) / 255.0,
            alpha: CGFloat(array[3]) / 255.0
        )
    }

    static func uicolorToString(_ uicolor: UIColor) -> String {
        let intArray = Note.uicolorToArray(uicolor)
        let stringArray = intArray.map { String($0) }
        let string = stringArray.joined(separator: String(Note.colorStringSeparator))

        return string
    }

    static func uicolorFromString(_ string: String) -> UIColor {
        let stringArray = string.split(separator: Note.colorStringSeparator)
        let intArray = stringArray.map { Int($0)! }
        let uicolor = Note.uicolorFromArray(intArray)

        return uicolor
    }
}
