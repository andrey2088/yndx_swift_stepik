import UIKit

class PaletteView: UIView {

    var onColorDidChange: ((_ color: UIColor) -> ())?

    private var elementSize: CGFloat = 1
    private var brightness: CGFloat = 1
    var pickedColor: UIColor = UIColor.white

    private let pointerView = PointerView(frame: CGRect.zero)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if let point = getPointOfColor(pickedColor) {
            putPointer(point: point)
        }
    }

    private func setup() {
        self.clipsToBounds = true

        let touchGesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(self.touchedColor(gestureRecognizer:))
        )
        touchGesture.minimumPressDuration = 0
        touchGesture.allowableMovement = CGFloat.greatestFiniteMagnitude
        self.addGestureRecognizer(touchGesture)

        pointerView.isHidden = true
        pointerView.setState(state: PointerView.states.circlePointer)
        pointerView.isUserInteractionEnabled = false
        self.addSubview(pointerView)
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let context = UIGraphicsGetCurrentContext()

        for y in stride(from: CGFloat(0), to: self.bounds.size.height, by: elementSize) {

            let saturation: CGFloat = (self.bounds.size.height - y) / self.bounds.size.height

            for x in stride(from: (0 as CGFloat), to: self.bounds.size.width, by: elementSize) {
                let hue = x / self.bounds.size.width

                let color = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)

                context!.setFillColor(color.cgColor)
                context!.fill(CGRect(
                    x:x,
                    y: y + self.bounds.origin.y,
                    width: elementSize,
                    height: elementSize
                ))
            }
        }
    }

    private func getColorAtPoint(point: CGPoint) -> UIColor {
        var roundedPoint = CGPoint(
            x:elementSize * CGFloat(Int(point.x / elementSize)),
            y:elementSize * CGFloat(Int(point.y / elementSize))
        )

        let hue = roundedPoint.x / self.bounds.width

        if self.bounds.contains(point) {
            roundedPoint.y -= self.bounds.origin.y

            let saturation: CGFloat = (self.bounds.size.height - roundedPoint.y) / self.bounds.size.height

            return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
        } else {
            return UIColor(white: hue, alpha: 1.0)
        }
    }

    private func getPointOfColor(_ color: UIColor) -> CGPoint? {
        if
            let hue = color.getHueValue(),
            let saturation = color.getSaturationValue()
        {
            let point = CGPoint (
                x: self.bounds.size.width * hue,
                y: self.bounds.size.height - (self.bounds.size.height * saturation)
            )

            return point
        } else {
            return nil
        }
    }

    private func putPointer(point: CGPoint) {
        pickedColor = getColorAtPoint(point: point)

        pointerView.frame.origin = CGPoint(
            x: point.x - pointerView.frame.size.width / 2,
            y: point.y - pointerView.frame.size.height / 2
        )
        pointerView.setFillColor(color: pickedColor)
        pointerView.drawPointer()

        self.onColorDidChange?(pickedColor)
    }

    @objc private func touchedColor(gestureRecognizer: UILongPressGestureRecognizer) {
        let point = gestureRecognizer.location(in: self)
        putPointer(point: point)
    }
}
