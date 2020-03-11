import AppKit

extension NSButton {

    func set(textColor color: NSColor) {
        let newAttributedTitle = NSMutableAttributedString(attributedString: attributedTitle)
        let range = NSRange(location: 0, length: attributedTitle.length)

        newAttributedTitle.addAttributes([
            .foregroundColor: color,
        ], range: range)

        attributedTitle = newAttributedTitle
    }
}
