import UIKit

class PointerView: UIView {

    public enum states: String {
        case circlePointer = "circle_pointer"
    }

    private let portraitWidth: CGFloat = UIScreen.main.nativeBounds.width / UIScreen.main.nativeScale
    private var state: states = states.circlePointer
    private var fillColor: UIColor = .clear
    private let shapeLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    public func setState(state: states) {
        self.state = state
    }

    public func setFillColor(color: UIColor) {
        self.fillColor = color
    }

    public func drawPointer() {
        setNeedsDisplay()
        self.isHidden = false
    }


    override internal func draw(_ rect: CGRect) {
        super.draw(rect)

        switch state {
            case states.circlePointer:
                drawPickerPointer(in: self.bounds)
        }
    }

    private func setup() {
        let pointerSide: CGFloat = (portraitWidth * 0.07).rounded()
        self.frame.size = CGSize(
            width: pointerSide,
            height: pointerSide
        )
        self.backgroundColor = UIColor.clear

        self.layer.addSublayer(shapeLayer)
    }

    private func drawPickerPointer(in rect: CGRect) {
        UIColor.gray.setStroke()

        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: rect.midX, y: rect.midY),
            radius: rect.size.width / 3,
            startAngle: CGFloat(0),
            endAngle:CGFloat(Double.pi * 2),
            clockwise: true
        )
        shapeLayer.path = circlePath.cgPath
        shapeLayer.strokeColor = UIColor.gray.cgColor
        shapeLayer.fillColor = fillColor.cgColor
        shapeLayer.lineWidth = 1

        let linePath = UIBezierPath()
        linePath.lineWidth = 2
        linePath.move(to: CGPoint(x: rect.midX, y: rect.minY))
        linePath.addLine(to: CGPoint(x: rect.midX, y: rect.maxY * 0.2))
        linePath.move(to: CGPoint(x: rect.maxX, y: rect.midY))
        linePath.addLine(to: CGPoint(x: rect.maxX * 0.8, y: rect.midY))
        linePath.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        linePath.addLine(to: CGPoint(x: rect.midX, y: rect.maxY * 0.8))
        linePath.move(to: CGPoint(x: rect.minX, y: rect.midY))
        linePath.addLine(to: CGPoint(x: rect.maxX * 0.2, y: rect.midY))
        linePath.stroke()
    }
}
