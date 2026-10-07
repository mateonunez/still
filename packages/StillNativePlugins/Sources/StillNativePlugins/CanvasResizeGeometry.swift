import CoreGraphics

/// Shared by measured layout and the committed placement at the end of a resize.
public enum CanvasResizeGeometry {
    public static func frame(original: CGRect, size: CGSize) -> CGRect {
        CGRect(origin: original.origin, size: size)
    }
}
