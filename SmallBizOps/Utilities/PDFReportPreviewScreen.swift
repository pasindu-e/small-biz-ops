import SwiftUI

/// Full-screen PDF report preview with standard iOS share/save actions.
struct PDFReportPreviewScreen: View {
    let url: URL
    var onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            PDFKitPreview(url: url)
                .ignoresSafeArea(edges: .bottom)
                .background(Color(uiColor: .systemGray6))
                .navigationTitle("Report Preview")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done", action: onDismiss)
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        ShareLink(item: url) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
        }
    }
}
