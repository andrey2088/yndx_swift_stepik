/*import UIKit

class ViewController: UIViewController {

    private let scrollView = ScrollView(frame: CGRect.zero)
    private let colorPickerView = ColorPickerView(frame: CGRect.zero)

    private var keyboardHeight: CGFloat = 0

    override internal func viewDidLoad() {
        super.viewDidLoad()
        /*#if DARKMODE
            self.view.backgroundColor = UIColor(red: 28.0/255.0, green: 28.0/255.0, blue: 28.0/255.0, alpha: 1)
        #else
            self.view.backgroundColor = UIColor(red: 242.0/255.0, green: 242.0/255.0, blue: 247.0/255.0, alpha: 1)
        #endif*/

        setupViews()
        detectKeyboardEvents()

        self.view.addSubview(scrollView)
        self.view.addSubview(colorPickerView)
    }

    override internal func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        modifyScrollViewFrame()
        colorPickerView.frame = view.safeAreaLayoutGuide.layoutFrame
    }

    private func setupViews() {
        colorPickerView.isHidden = true
        scrollView.setColorPickerView(colorPickerView)
        scrollView.setViewController(self)

        colorPickerView.onDoneButtonTapped = { [weak self] color in DispatchQueue.main.async {
            self?.colorPickerColorSelected(color)
        }}
    }

    private func colorPickerColorSelected(_ color: UIColor) {
        self.scrollView.setCustomColor(color)
        self.colorPickerView.isHidden = true
        self.scrollView.isHidden = false
        if (!self.isEditing) {
            keyboardHeight = 0
            modifyScrollViewFrame()
        }
    }


    private func modifyScrollViewFrame() {
        scrollView.frame = view.safeAreaLayoutGuide.layoutFrame
        scrollView.frame.size.height -= keyboardHeight
    }


    private func detectKeyboardEvents() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidShow(notification:)),
            name: UIResponder.keyboardDidShowNotification,
            object:nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidHide(notification:)),
            name: UIResponder.keyboardDidHideNotification,
            object:nil
        )

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector (dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    @objc func keyboardDidShow(notification: NSNotification) {
        let detectedKeyboardHeight =
            (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        keyboardHeight = detectedKeyboardHeight
        modifyScrollViewFrame()
    }

    @objc func keyboardDidHide(notification: NSNotification) {
        keyboardHeight = 0
        modifyScrollViewFrame()
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
        keyboardHeight = 0
        modifyScrollViewFrame()
    }
}
*/
