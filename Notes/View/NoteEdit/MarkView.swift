import UIKit

class MarkView: UIView {

    enum states: String {
        case colorFlag = "color_flag"
    }

    private let portraitWidth: CGFloat = UIScreen.main.nativeBounds.width / UIScreen.main.nativeScale
    private var state: states = states.colorFlag
    private let shapeLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setState(state: states) {
        self.state = state
    }

    func drawMark() {
        setNeedsDisplay()
        self.isHidden = false
    }


    override func draw(_ rect: CGRect) {
        super.draw(rect)

        switch state {
        case states.colorFlag:
            drawColorFlag(in: self.bounds)
        }
    }

    private func setup() {
        let markSide: CGFloat = (portraitWidth * 0.07).rounded()
        self.frame.size = CGSize(
            width: markSide,
            height: markSide
        )
        self.backgroundColor = UIColor.clear

        self.layer.addSublayer(shapeLayer)
    }

    private func drawColorFlag(in rect: CGRect) {
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: rect.midX, y: rect.midY),
            radius: rect.size.width / 2,
            startAngle: CGFloat(0),
            endAngle:CGFloat(Double.pi * 2),
            clockwise: true
        )
        shapeLayer.path = circlePath.cgPath
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 2

        let linePath = UIBezierPath()
        linePath.lineWidth = 2
        linePath.move(to: CGPoint(x: rect.maxX * 0.2, y: rect.midY))
        linePath.addLine(to: CGPoint(x: rect.midX, y: rect.maxY * 0.8))
        linePath.addLine(to: CGPoint(x: rect.maxX * 0.7, y: rect.maxY * 0.2))
        linePath.stroke()
    }
}
