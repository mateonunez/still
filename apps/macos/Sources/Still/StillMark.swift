import AppKit
import SwiftUI

/// Original quiet-aperture mark; designed to stay readable at menu-bar size.
enum StillMark {
    @MainActor static func menuImage(covered: Bool) -> NSImage {
        let image = NSImage(size: NSSize(width: 18, height: 18), flipped: false) { _ in
            NSColor.black.setStroke()
            NSColor.black.setFill()
            let ring = NSBezierPath()
            ring.appendArc(withCenter: NSPoint(x: 9, y: 8.5), radius: 5.7,
                           startAngle: 125, endAngle: 55, clockwise: false)
            ring.lineWidth = 1.65
            ring.lineCapStyle = .round
            ring.stroke()
            NSBezierPath(ovalIn: NSRect(x: 7.5, y: 13.7, width: 3, height: 3)).fill()
            if covered {
                NSBezierPath(ovalIn: NSRect(x: 7.8, y: 7.3, width: 2.4, height: 2.4)).fill()
            }
            return true
        }
        image.isTemplate = true
        image.accessibilityDescription = "Still"
        return image
    }
}

struct StillMarkView: View {
    var body: some View {
        Canvas { context, size in
            let scale = min(size.width, size.height) / 18
            context.scaleBy(x: scale, y: scale)
            var ring = Path()
            ring.addArc(center: CGPoint(x: 9, y: 9.5), radius: 5.7,
                        startAngle: .degrees(-55), endAngle: .degrees(-125), clockwise: false)
            context.stroke(ring, with: .foreground, style: StrokeStyle(lineWidth: 1.65, lineCap: .round))
            context.fill(Path(ellipseIn: CGRect(x: 7.5, y: 1.3, width: 3, height: 3)), with: .foreground)
        }
        .accessibilityHidden(true)
    }
}
