import SwiftUI

struct InventoryView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var store: MockDataStore
    @State private var filter = "All"
    @State private var searchText = ""
    @State private var showingAddProduct = false

    private let filters = ["All", "Low stock", "Beverages", "Supplies"]

    private var filteredProducts: [Product] {
        let base = store.products.filter { product in
            searchText.isEmpty ||
            product.name.localizedCaseInsensitiveContains(searchText) ||
            product.sku.localizedCaseInsensitiveContains(searchText)
        }
        switch filter {
        case "All": return base
        case "Low stock": return base.filter { $0.status == .lowStock }
        default: return base.filter { $0.category == filter }
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                searchField
                    .padding(.top, 10)
                chips
                    .padding(.top, 12)
                summary
                    .padding(.top, 5)

                HStack {
                    Text(filter == "All" ? "All products" : filter).font(.appSectionTitle())
                    Spacer()
                    Text("\(filteredProducts.count) items").font(.appCaption()).foregroundColor(.appMuted)
                }
                .padding(.top, 22)
                .padding(.bottom, 10)

                VStack(spacing: 0) {
                    ForEach(Array(filteredProducts.enumerated()), id: \.element.id) { index, product in
                        ProductRow(product: product, index: index) {
                            router.go(.product(sku: product.sku))
                        }
                        if product.id != filteredProducts.last?.id {
                            Divider().background(Color.appLine)
                        }
                    }
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous).stroke(Color.appLine, lineWidth: 1))
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 24)
        }
        .background(Color.appOffWhite)
        .sheet(isPresented: $showingAddProduct) {
            AddProductView().environmentObject(store)
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Inventory").font(.appHeroTitle())
                Text("\(store.products.count) products · Updated just now").font(.appCaption()).foregroundColor(.appMuted)
            }
            Spacer()
            Button {
                showingAddProduct = true
            } label: {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.appNavy)
                    .clipShape(Circle())
            }
            .buttonStyle(.press)
        }
        .padding(.bottom, 4)
    }

    private var searchField: some View {
        HStack(spacing: 9) {
            Image(systemName: "magnifyingglass")
            TextField("Search products or SKU", text: $searchText)
        }
        .font(.system(size: 12))
        .foregroundColor(Color(hex: "8B96A6"))
        .padding(.horizontal, 13)
        .frame(height: 43)
        .background(Color(hex: "EDF1F5"))
        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
    }

    private var chips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 7) {
                ForEach(filters, id: \.self) { item in
                    Button {
                        filter = item
                    } label: {
                        Text(item)
                            .font(.system(size: 10, weight: .semibold))
                            .padding(.horizontal, 12)
                            .frame(height: 31)
                            .foregroundColor(filter == item ? .white : .appMuted)
                            .background(filter == item ? Color.appNavy : Color.white)
                            .overlay(Capsule().stroke(filter == item ? Color.appNavy : Color(hex: "DCE2EA"), lineWidth: 1))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.press)
                }
            }
        }
    }

    private var summary: some View {
        HStack(spacing: 0) {
            summaryItem(value: "\(store.products.count)", label: "Tracked", color: .white)
            Divider().overlay(Color.white.opacity(0.12))
            summaryItem(value: "\(store.lowStockCount)", label: "Low stock", color: Color(hex: "FFC66D"))
            Divider().overlay(Color.white.opacity(0.12))
            summaryItem(value: "\(store.products.filter { $0.stock == 0 }.count)", label: "Out of stock", color: .white)
        }
        .padding(.vertical, 15)
        .background(Color.appNavy)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
    }

    private func summaryItem(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Text(value).font(.system(size: 18, weight: .bold)).foregroundColor(color)
            Text(label).font(.system(size: 9)).foregroundColor(Color(hex: "A8B3C5"))
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    InventoryView().environmentObject(AppRouter()).environmentObject(MockDataStore())
}
