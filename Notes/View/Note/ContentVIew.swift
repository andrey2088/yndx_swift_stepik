import UIKit

class ContentView: UIView, UITextViewDelegate {

    private let portraitWidth: CGFloat = UIScreen.main.nativeBounds.width / UIScreen.main.nativeScale
    private let sideMargin: CGFloat = 15

    private let noteTitleView = UITextField()
    private let noteTextView = UITextView()
    private let switchLabelView = UILabel()
    private let switchView = UISwitch()
    private let dateView = UIDatePicker()
    private let colorsView = UIView()
    private let whiteColorSquare = UIView()
    private let redColorSquare = UIView()
    private let greenColorSquare = UIView()
    private let customColorSquare = UIView()
    private let paletteSquare = UIImageView()
    private var selectedColorSquare: UIView?
    private let markView = MarkView(frame: CGRect.zero)

    private let noteTitleViewMarginTop: CGFloat = 20
    private let noteTextViewMarginTop: CGFloat = 5
    private let switchLabelViewMarginTop: CGFloat = 0
    private let switchViewMarginTop: CGFloat = 0
    private let dateViewMarginTop: CGFloat = 0
    private let colorsViewMarginTop: CGFloat = 10
    private var colorsViewMarginLeft: CGFloat = 0

    private var parentView: UIScrollView = UIScrollView()
    private var viewController: UIViewController = UIViewController()
    private var colorPickerView = ColorPickerView(frame: CGRect.zero)
    private var customColorSelected: Bool = false
    private var customColor: UIColor = UIColor.clear {
        didSet {
            customColorSelected = true
            customColorSquare.backgroundColor = customColor
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }

    public func setParentView(_ parentView: UIScrollView) {
        self.parentView = parentView
    }

    public func setViewController(_ viewController: UIViewController) {
        self.viewController = viewController
    }

    public func setColorPickerView(_ colorPickerView: ColorPickerView) {
        self.colorPickerView = colorPickerView
    }

    public func setCustomColor(_ customColor: UIColor) {
        self.customColor = customColor
    }

    override internal func layoutSubviews() {
        super.layoutSubviews()

        updateUI()
    }

    private func setupViews() {
        setupNoteTitleView()
        setupNoteTextView()
        setupSwitchLabelView()
        setupSwitchView()
        setupDateView()
        setupColorsViews()
        setupMarkView()

        self.addSubview(noteTitleView)
        self.addSubview(noteTextView)
        self.addSubview(switchLabelView)
        self.addSubview(switchView)
        self.addSubview(dateView)
        self.addSubview(colorsView)
    }

    private func updateUI() {
        adjustNoteTitleViewLayout()
        adjustNoteTextViewLayout()
        adjustSwitchLabelViewLayout()
        adjustSwitchViewLayout()
        adjustDateViewLayout()
        adjustColorsViewsLayout()
        adjustMarkViewLayout()

        setContentAndParentViewsHeight()
    }


    // ---------- Note title view ----------

    private func adjustNoteTitleViewLayout() {
        noteTitleView.frame = CGRect(
            x: self.bounds.minX + sideMargin,
            y: self.bounds.minY + noteTitleViewMarginTop,
            width: self.bounds.size.width - sideMargin * 2,
            height: 30
        )
    }

    private func setupNoteTitleView() {
        noteTitleView.layer.cornerRadius = 3
        noteTitleView.layer.borderWidth = 1
        noteTitleView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0.1, alpha: 0.22).cgColor

        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 30))
        noteTitleView.leftView = paddingView
        noteTitleView.leftViewMode = .always

        //noteTitleView.font = .systemFont(ofSize: 14)
        noteTitleView.placeholder = "Enter title for your note"
    }


    // ---------- Note text view ----------

    private func adjustNoteTextViewLayout() {
        noteTextView.frame.origin = CGPoint(
            x: self.bounds.minX + sideMargin,
            y: noteTitleView.frame.maxY + noteTextViewMarginTop
        )
        adjustNoteTextViewSize()
    }

    private func adjustNoteTextViewSize() {
        //noteTextView.translatesAutoresizingMaskIntoConstraints = true
        let noteTextViewWidth = self.bounds.size.width - sideMargin * 2
        let noteTextViewFitsSize = noteTextView.sizeThatFits(CGSize(
            width: noteTextViewWidth,
            height: CGFloat.greatestFiniteMagnitude
        ))
        noteTextView.frame.size = CGSize(
            width: noteTextViewWidth,
            height: noteTextViewFitsSize.height
        )
    }

    private func setupNoteTextView() {
        noteTextView.delegate = self
        /*noteTextView.layer.borderWidth = 1
         noteTextView.layer.borderColor = UIColor.black.cgColor*/
        //noteTextView.font = .systemFont(ofSize: 14)
        noteTextView.text = "Lorem Ipsum is simply dummy text of the printing and typesetting industry.Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book."
        noteTextView.isScrollEnabled = false
    }

    private func noteTextViewChanged() {
        adjustNoteTextViewSize()
    }


    // ---------- Switch label view ----------

    private func adjustSwitchLabelViewLayout() {
        switchLabelView.frame.origin = CGPoint(
            x: self.bounds.minX + sideMargin,
            y: noteTextView.frame.maxY + switchLabelViewMarginTop
        )

        let switchLabelViewHeight: CGFloat = 30
        let switchLabelViewFitsSize = switchLabelView.sizeThatFits(CGSize(
            width: CGFloat.greatestFiniteMagnitude,
            height: switchLabelViewHeight
        ))
        switchLabelView.frame.size = CGSize(
            width: switchLabelViewFitsSize.width,
            height: switchLabelViewHeight
        )
    }

    private func setupSwitchLabelView() {
        //switchLabelView.font = .systemFont(ofSize: 16)
        switchLabelView.text = "Use Destroy Date:"
    }


    // ---------- Switch view ----------

    private func adjustSwitchViewLayout() {
        switchView.frame.origin = CGPoint(
            x: switchLabelView.frame.maxX + 8,
            y: noteTextView.frame.maxY + switchViewMarginTop
        )
    }

    private func setupSwitchView() {
        switchView.addTarget(self, action: #selector(switchViewChanged), for: UIControl.Event.valueChanged)
        switchViewChanged()
    }

    @objc private func switchViewChanged() {
        if (switchView.isOn) {
            dateView.isHidden = false
        } else {
            dateView.isHidden = true
        }
        updateUI()
    }


    // ---------- Date view ----------

    private func adjustDateViewLayout() {
        dateView.frame.origin = CGPoint(
            x: self.bounds.minX + sideMargin,
            y: switchView.frame.maxY + dateViewMarginTop
        )
        dateView.frame.size.width = self.bounds.maxX - self.bounds.minX - sideMargin * 2
        dateView.frame.size.height = 150
    }

    private func setupDateView() {}


    // ---------- Colors views ----------

    private func adjustColorsViewsLayout() {
        let colorsViewWidth = min(portraitWidth, self.bounds.size.width) - sideMargin * 2
        let colorViewSide = colorsViewWidth * 0.22
        let colorViewMargin = colorsViewWidth * 0.04

        colorsViewMarginLeft = self.bounds.size.width > portraitWidth
            ? (self.bounds.size.width - colorsViewWidth - sideMargin) / 2
            : 0

        colorsView.frame = CGRect(
            x: colorsViewMarginLeft + self.bounds.minX + sideMargin,
            y: dateView.isHidden
                ? (switchView.frame.maxY + colorsViewMarginTop)
                : (dateView.frame.maxY + colorsViewMarginTop),
            width: colorsViewWidth,
            height: colorViewSide
        )

        whiteColorSquare.frame = CGRect(
            x: colorsView.bounds.minX,
            y: colorsView.bounds.minY,
            width: colorViewSide,
            height: colorViewSide
        )

        redColorSquare.frame = CGRect(
            x: whiteColorSquare.frame.maxX + colorViewMargin,
            y: colorsView.bounds.minY,
            width: colorViewSide,
            height: colorViewSide
        )

        greenColorSquare.frame = CGRect(
            x: redColorSquare.frame.maxX + colorViewMargin,
            y: colorsView.bounds.minY,
            width: colorViewSide,
            height: colorViewSide
        )

        customColorSquare.frame = CGRect(
            x: greenColorSquare.frame.maxX + colorViewMargin,
            y: colorsView.bounds.minY,
            width: colorViewSide,
            height: colorViewSide
        )

        paletteSquare.frame = CGRect(
            x: customColorSquare.bounds.minX,
            y: customColorSquare.bounds.minY,
            width: customColorSquare.bounds.size.width,
            height: customColorSquare.bounds.size.height
        )

        if (selectedColorSquare != nil) {
            markView.frame.origin.x = selectedColorSquare!.frame.maxX - markView.frame.height - 5
            markView.drawMark()
        }
    }

    private func setupColorsViews() {
        whiteColorSquare.layer.borderWidth = 1
        whiteColorSquare.layer.borderColor = UIColor.black.cgColor
        redColorSquare.layer.borderWidth = 1
        redColorSquare.layer.borderColor = UIColor.black.cgColor
        redColorSquare.layer.backgroundColor = UIColor.red.cgColor
        greenColorSquare.layer.borderWidth = 1
        greenColorSquare.layer.borderColor = UIColor.black.cgColor
        greenColorSquare.layer.backgroundColor = UIColor.green.cgColor
        customColorSquare.layer.borderWidth = 1
        customColorSquare.layer.borderColor = UIColor.black.cgColor

        paletteSquare.image = UIImage(named: "palette_icon")
        paletteSquare.isUserInteractionEnabled = false

        colorsView.addSubview(whiteColorSquare)
        colorsView.addSubview(redColorSquare)
        colorsView.addSubview(greenColorSquare)
        colorsView.addSubview(customColorSquare)
        colorsView.addSubview(markView)
        customColorSquare.addSubview(paletteSquare)

        let whiteColor = UITapGestureRecognizer(target: self, action: #selector (colorSquareTapped(sender:)))
        let redColor = UITapGestureRecognizer(target: self, action: #selector (colorSquareTapped(sender:)))
        let greenColor = UITapGestureRecognizer(target: self, action: #selector (colorSquareTapped(sender:)))
        let customColor = UITapGestureRecognizer(target: self, action: #selector (colorSquareTapped(sender:)))
        whiteColorSquare.addGestureRecognizer(whiteColor)
        redColorSquare.addGestureRecognizer(redColor)
        greenColorSquare.addGestureRecognizer(greenColor)
        customColorSquare.addGestureRecognizer(customColor)

        let customColorLong = UILongPressGestureRecognizer(
            target: self,
            action: #selector (customSquarePressed(sender:))
        )
        customColorLong.minimumPressDuration = 0.5
        customColorSquare.addGestureRecognizer(customColorLong)
    }

    @objc private func colorSquareTapped(sender: UIGestureRecognizer) {
        let colorSquare: UIView? = sender.view

        if (colorSquare != nil) {
            selectedColorSquare = colorSquare
            updateUI()
        }

        if (colorSquare == customColorSquare && !customColorSelected) {
            showColorPicker()
        }
    }

    @objc private func customSquarePressed(sender: UIGestureRecognizer) {
        if (sender.state == UIGestureRecognizer.State.began) {
            selectedColorSquare = customColorSquare
            updateUI()
            showColorPicker()
        }
    }

    private func showColorPicker() {
        parentView.isHidden = true
        paletteSquare.isHidden = true
        colorPickerView.isHidden = false
        viewController.view.endEditing(true)
    }


    // ---------- Mark view ----------

    private func adjustMarkViewLayout() {
        markView.frame.origin.y = 5
    }

    private func setupMarkView() {
        markView.isHidden = true
        markView.isUserInteractionEnabled = false
        markView.setState(state: MarkView.states.colorFlag)
    }


    // ----------

    internal func textViewDidChange(_ textView: UITextView) {
        if (textView == noteTextView) {
            noteTextViewChanged()
        }
    }

    private func setContentAndParentViewsHeight() {
        var contentViewHeight: CGFloat =
            noteTitleViewMarginTop + noteTitleView.frame.size.height
                + noteTextViewMarginTop + noteTextView.frame.size.height
                + switchViewMarginTop + switchView.frame.size.height
                + colorsViewMarginTop + colorsView.frame.size.height

        if (!dateView.isHidden) {
            contentViewHeight += dateViewMarginTop + dateView.frame.size.height
        }

        self.frame.size.height = contentViewHeight
        parentView.contentSize.height = contentViewHeight
    }
}
