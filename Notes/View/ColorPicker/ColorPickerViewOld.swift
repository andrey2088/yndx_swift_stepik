/*import UIKit

class ColorPickerView: UIView {
    
    private let portraitWidth: CGFloat = UIScreen.main.nativeBounds.width / UIScreen.main.nativeScale
    private let sideMargin: CGFloat = 15
    private let cornerRadius: CGFloat = 7

    private let selectedView = UIView()
    private let selectedColorView = UIView()
    private let selectedHexView = UILabel()
    private let brightnessView = UISlider()
    private let brightnessLabelView = UILabel()
    private let paletteView = PaletteView(frame: CGRect.zero)
    private let doneButton = UIButton()

    private let selectedViewMarginTop: CGFloat = 10
    private let selectedViewMarginRight: CGFloat = 20
    private let brightnessViewMarginTop: CGFloat = 5
    private let brightnessLabelViewHeight: CGFloat = 30
    private let paletteViewMarginTop: CGFloat = 10
    private let doneButtonMarginTop: CGFloat = 20
    private let doneButtonWidth: CGFloat = 100
    private let doneButtonHeight: CGFloat = 30
    private let doneButtonMarginBottom: CGFloat = 20

    private var pickedColor: UIColor = UIColor.white {
        didSet {
            updateSelectedColor()
        }
    }

    var onDoneButtonTapped: ((_ color: UIColor) -> ())?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }

    public func getPickedColor() ->UIColor {
        return pickedColor
    }

    override internal func layoutSubviews() {
        super.layoutSubviews()

        adjustSelectedViewsLayout()
        adjustBrightnessViewsLayout()
        adjustPaletteViewLayout()
        adjustDoneButtonLayout()
    }

    private func setupViews() {
        setupSelectedViews()
        setupBrightnessViews()
        setupPaletteView()
        setupDoneButton()

        self.addSubview(selectedView)
        selectedView.addSubview(selectedColorView)
        selectedView.addSubview(selectedHexView)
        self.addSubview(brightnessView)
        self.addSubview(brightnessLabelView)
        self.addSubview(paletteView)
        self.addSubview(doneButton)

        updateSelectedColor()
    }


    // ---------- Selected views ----------

    private func adjustSelectedViewsLayout() {
        let selectedColorSide = ((portraitWidth - sideMargin) * 0.24).rounded()
        let selectedHeight = (selectedColorSide * 1.18).rounded()

        selectedView.frame = CGRect(
            x: self.bounds.minX + sideMargin,
            y: self.bounds.minY + selectedViewMarginTop,
            width: selectedColorSide,
            height: selectedHeight
        )

        selectedColorView.frame = CGRect(
            x: selectedView.bounds.minX,
            y: selectedView.bounds.minY,
            width: selectedColorSide,
            height: (selectedColorSide * 0.93).rounded()
        )

        selectedHexView.frame = CGRect(
            x: selectedView.bounds.minX,
            y: selectedColorView.bounds.maxY,
            width: selectedColorSide,
            height: selectedHeight - selectedColorSide
        )
    }

    private func setupSelectedViews() {
        selectedView.layer.borderWidth = 1
        selectedView.layer.borderColor = UIColor.black.cgColor
        selectedView.layer.cornerRadius = cornerRadius

        selectedColorView.layer.borderWidth = 1
        selectedColorView.layer.borderColor = UIColor.black.cgColor
        selectedColorView.layer.cornerRadius = cornerRadius
        selectedColorView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        selectedHexView.textAlignment = .center

        /*selectedHexView.layer.borderWidth = 1
        selectedHexView.layer.borderColor = UIColor.red.cgColor*/
    }

    private func updateSelectedColor() {
        let selectedColor: UIColor = pickedColor.getThisColorWithBrightness(CGFloat(brightnessView.value))
        let selectedHex: String = selectedColor.toHexString()
        selectedColorView.backgroundColor = selectedColor
        selectedHexView.text = selectedHex
    }


    // ---------- Brightness views ----------

    private func adjustBrightnessViewsLayout() {
        brightnessView.frame.origin = CGPoint(
            x: selectedView.frame.maxX + selectedViewMarginRight,
            y: selectedView.frame.maxY - brightnessView.frame.size.height
        )
        brightnessView.frame.size.width =
            self.bounds.size.width - selectedView.frame.maxX - selectedViewMarginRight - sideMargin * 2

        brightnessLabelView.frame = CGRect(
            x: selectedView.frame.maxX + selectedViewMarginRight,
            y: selectedView.frame.maxY - brightnessView.frame.size.height - brightnessViewMarginTop
                - brightnessLabelViewHeight,
            width: self.bounds.size.width - selectedView.frame.maxX - selectedViewMarginRight - sideMargin * 2,
            height: brightnessLabelViewHeight
        )
    }

    private func setupBrightnessViews() {
        brightnessLabelView.text = "Brightness"

        brightnessView.maximumValue = 1
        brightnessView.value = 1

        brightnessView.addTarget(self, action: #selector(brightnessViewChanged), for: UIControl.Event.valueChanged)
    }

    @objc private func brightnessViewChanged() {
        updateSelectedColor()
    }


    // ---------- Palette view ----------

    private func adjustPaletteViewLayout() {
        paletteView.frame = CGRect(
            x: self.bounds.minX + sideMargin,
            y: selectedView.frame.maxY + paletteViewMarginTop,
            width: self.bounds.size.width - sideMargin * 2,
            height: self.bounds.size.height - selectedView.frame.maxY - paletteViewMarginTop
                - doneButtonMarginTop - doneButtonHeight - doneButtonMarginBottom
        )
    }

    private func setupPaletteView() {
        paletteView.layer.borderWidth = 1
        paletteView.layer.borderColor = UIColor.black.cgColor

        paletteView.onColorDidChange = { [weak self] color in DispatchQueue.main.async {
            self?.pickedColor = color
        }}
    }

    // ---------- Done button ----------

    private func adjustDoneButtonLayout() {
        doneButton.frame = CGRect(
            x: self.bounds.minX + (self.bounds.size.width - doneButtonWidth) / 2,
            y: paletteView.frame.maxY + doneButtonMarginTop,
            width: doneButtonWidth,
            height: doneButtonHeight
        )
    }

    private func setupDoneButton() {
        doneButton.setTitle("Done", for: .normal)
        //doneButton.setTitleColor(UIColor(red: 255.0 / 10.0, green: 255.0 / 132.0, blue: 1, alpha: 1), for: .normal)
        doneButton.setTitleColor(doneButton.tintColor, for: .normal)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (doneButtonTapped))
        doneButton.addGestureRecognizer(tapGesture)
    }

    @objc private func doneButtonTapped() {
        let color: UIColor = pickedColor.getThisColorWithBrightness(CGFloat(brightnessView.value))
        self.onDoneButtonTapped?(color)
    }
}
*/
