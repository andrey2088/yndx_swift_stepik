import UIKit

extension Note {
    public var json: [String: Any] {
        get{
            var jsonDict: [String: Any] = [
                "uid": self.uid,
                "title": self.title,
                "content": self.content
            ]

            let selfColorArray: [Int] = Note.uicolorToArray(self.color)
            let whiteColorArray: [Int] = Note.uicolorToArray(UIColor(red: 1, green: 1, blue: 1, alpha: 1))
            if !(selfColorArray.elementsEqual(whiteColorArray)) {
                jsonDict["color"] = selfColorArray
            }

            if (self.importance != Note.Importance.normal) {
                jsonDict["importance"] = self.importance.rawValue
            }

            jsonDict["selfDestructDate"] = self.selfDestructDate?.timeIntervalSince1970

            return jsonDict
        }
    }

    public static func parse(json: [String: Any]) -> Note? {
        let importanceRaw: String = (json["importance"] as? String)
            ?? Note.Importance.normal.rawValue

        guard
            let uid = json["uid"] as? String,
            let title = json["title"] as? String,
            let content = json["content"] as? String,
            let importance = Note.Importance(rawValue: importanceRaw)
        else {
            return nil
        }

        let colorArray: [Int] = (json["color"] as? [Int])
            ?? Note.uicolorToArray(UIColor(red: 1, green: 1, blue: 1, alpha: 1))

        var selfDestructDate: Date? = nil
        let jsonSelfDestructDate: TimeInterval? = json["selfDestructDate"] as? TimeInterval
        if (jsonSelfDestructDate != nil) {
            selfDestructDate = Date(timeIntervalSince1970: jsonSelfDestructDate!)
        }

        let note = Note(
            uid: uid,
            title: title,
            content: content,
            color: Note.arrayToUIColor(colorArray),
            importance: importance,
            selfDestructDate: selfDestructDate
        )

        return note
    }

    private static func uicolorToArray(_ uicolor: UIColor) -> [Int] {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        uicolor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return [Int(r * 255), Int(g * 255), Int(b * 255), Int(a * 255)]
    }

    private static func arrayToUIColor(_ array: [Int]) -> UIColor {
        return UIColor(
            red: CGFloat(array[0]) / 255.0,
            green: CGFloat(array[1]) / 255.0,
            blue: CGFloat(array[2]) / 255.0,
            alpha: CGFloat(array[3]) / 255.0
        )
    }
}
