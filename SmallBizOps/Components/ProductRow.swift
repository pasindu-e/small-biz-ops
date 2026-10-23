import SwiftUI

private let thumbPalette: [(bg: Color, fg: Color)] = [
    (Color(hex: "E8DDD0"), Color(hex: "7D6042")),
    (Color(hex: "EFF0F4"), Color(hex: "798393")),
    (Color(hex: "FFF0D7"), Color(hex: "C88A32")),
    (Color(hex: "DCE8EE"), Color(hex: "52758B")),
]

struct ProductRow: View {
    let product: Product
    let index: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 11) {
                let palette = thumbPalette[index % thumbPalette.count]
                Image(systemName: "shippingbox.fill")
                    .foregroundColor(palette.fg)
                    .frame(width: 48, height: 48)
                    .background(palette.bg)
                    .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(product.name).font(.appRowTitle()).foregroundColor(.primary)
                    Text("\(product.sku) · \(product.category)").font(.appCaption()).foregroundColor(.appMuted)
                    StatusBadge(text: product.status.rawValue, tone: product.status.tone)
                        .padding(.top, 3)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 0) {
                    Text("\(product.stock)").font(.system(size: 17, weight: .bold))
                    Text("units").font(.system(size: 9)).foregroundColor(.appMuted)
                }
            }
            .padding(12)
        }
        .buttonStyle(.press)
    }
}
