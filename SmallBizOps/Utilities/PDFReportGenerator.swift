import UIKit

enum PDFReportGenerator {
    /// Renders an agent run into a simple PDF report, written to a temporary
    /// file so it can be handed to QuickLook / the share sheet.
    static func makeRunReport(for run: AgentRun) -> URL {
        let pageWidth: CGFloat = 612 // US Letter at 72dpi
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 48
        let contentWidth = pageWidth - margin * 2

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))
        let fileName = "SmallBizOps-Report-\(run.dateLabel)-\(Int(Date().timeIntervalSince1970)).pdf"
        let url = URL.temporaryDirectory.appending(path: fileName)

        try? renderer.writePDF(to: url) { context in
            context.beginPage()
            var y = margin

            func draw(_ text: String, font: UIFont, color: UIColor = .black, spacingAfter: CGFloat = 8) {
                let attributed = NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: color])
                let boundingRect = attributed.boundingRect(
                    with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin],
                    context: nil
                )
                attributed.draw(with: CGRect(x: margin, y: y, width: contentWidth, height: boundingRect.height), options: [.usesLineFragmentOrigin], context: nil)
                y += boundingRect.height + spacingAfter
            }

            func divider() {
                let path = UIBezierPath()
                path.move(to: CGPoint(x: margin, y: y))
                path.addLine(to: CGPoint(x: pageWidth - margin, y: y))
                UIColor(white: 0.85, alpha: 1).setStroke()
                path.lineWidth = 0.75
                path.stroke()
                y += 16
            }

            draw("SmallBizOps", font: .boldSystemFont(ofSize: 22), spacingAfter: 4)
            draw("Daily Operations Report", font: .systemFont(ofSize: 14), color: .darkGray, spacingAfter: 6)
            draw("\(run.dateLabel) at \(run.timeLabel) · Completed in \(run.duration)", font: .systemFont(ofSize: 11), color: .gray, spacingAfter: 18)

            divider()

            draw("Summary", font: .boldSystemFont(ofSize: 15), spacingAfter: 6)
            draw(
                "\(run.findingsCount) issues identified · \(run.tasksCount) tasks created · \(run.toolCallsCount) tool calls",
                font: .systemFont(ofSize: 12),
                color: .darkGray,
                spacingAfter: 18
            )

            draw("Execution Trace", font: .boldSystemFont(ofSize: 15), spacingAfter: 10)
            for (index, step) in run.executionTrace.enumerated() {
                draw("\(index + 1). [\(step.kind)] \(step.title)", font: .boldSystemFont(ofSize: 12), spacingAfter: 3)
                draw(step.copy, font: .systemFont(ofSize: 11), color: .darkGray, spacingAfter: 14)
            }

            divider()
            draw(
                "Processed entirely on-device. No business data left this iPhone during this run.",
                font: .italicSystemFont(ofSize: 10),
                color: .gray
            )
        }

        return url
    }
}
