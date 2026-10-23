import SwiftUI
import PDFKit

/// Renders a PDF using PDFKit directly. Unlike QLPreviewController (which
/// must be presented modally via `present(_:animated:)` and depends on the
/// system `quicklookd` service), PDFView is a plain UIView with no special
/// presentation requirements, making it a much more reliable way to show a
/// PDF inline in a SwiftUI screen.
struct PDFKitPreview: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.autoScales = true
        view.displayMode = .singlePageContinuous
        view.displayDirection = .vertical
        view.document = PDFDocument(url: url)
        return view
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        if uiView.document == nil {
            uiView.document = PDFDocument(url: url)
        }
    }
}
