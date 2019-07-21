import UIKit

public struct Note {
    public let uid: String
    public let title: String
    public let content: String
    public let color: UIColor
    public let importance: Importance
    public let selfDestructDate: Date?

    public enum Importance: String {
        case unimportant = "unimportant"
        case normal = "normal"
        case important = "important"
    }

    public init(
        uid: String,
        title: String,
        content: String,
        color: UIColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1),
        importance: Importance = Importance.normal,
        selfDestructDate: Date? = nil
    ) {
        self.uid = (uid == "") ? UUID().uuidString : uid
        self.title = (title == "") ? "Empty title" : title
        self.content = content
        self.color = color
        self.importance = importance
        self.selfDestructDate = selfDestructDate
    }
}
