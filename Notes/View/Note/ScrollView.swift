import UIKit

class ScrollView: UIScrollView {
    
    private let contentView = ContentView(frame: CGRect.zero)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }

    public func setViewController(_ viewController: UIViewController) {
        contentView.setViewController(viewController)
    }

    public func setColorPickerView(_ colorPickerView: ColorPickerView) {
        contentView.setColorPickerView(colorPickerView)
    }

    public func setCustomColor(_ customColor: UIColor) {
        contentView.setCustomColor(customColor)
    }

    override internal func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame.size.width = self.bounds.maxX - self.bounds.minX
        self.contentSize.width = contentView.frame.size.width
    }

    private func setupViews() {
        /*self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.red.cgColor*/

        contentView.setParentView(self)
        contentView.frame.origin = CGPoint(
            x: self.bounds.minX,
            y: self.bounds.minY
        )
        self.autoresizingMask = UIView.AutoresizingMask.flexibleHeight

        self.addSubview(contentView)
    }
}
