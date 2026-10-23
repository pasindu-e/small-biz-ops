import SwiftUI

struct AddProductView: View {
    @EnvironmentObject var store: MockDataStore
    @Environment(\.dismiss) private var dismiss

    /// Pass an existing product to edit it; leave nil to create a new one.
    let productToEdit: Product?

    @State private var name: String
    @State private var sku: String
    @State private var category: String
    @State private var supplier: String
    @State private var stock: String
    @State private var minimum: String
    @State private var unitCost: String
    @State private var averageDailyUsage: String
    @State private var errorMessage: String?
    @State private var isSaving = false
    @State private var showSavedConfirmation = false

    init(productToEdit: Product? = nil) {
        self.productToEdit = productToEdit
        _name = State(initialValue: productToEdit?.name ?? "")
        _sku = State(initialValue: productToEdit?.sku ?? "")
        _category = State(initialValue: productToEdit?.category ?? "")
        _supplier = State(initialValue: productToEdit?.supplier ?? "")
        _stock = State(initialValue: productToEdit.map { String($0.stock) } ?? "")
        _minimum = State(initialValue: productToEdit.map { String($0.minimum) } ?? "")
        _unitCost = State(initialValue: productToEdit.map { String($0.unitCost) } ?? "")
        _averageDailyUsage = State(initialValue: productToEdit.map { String($0.averageDailyUsage) } ?? "")
    }

    private var isEditing: Bool { productToEdit != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Product") {
                    TextField("Name", text: $name)
                    TextField("SKU", text: $sku)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .disabled(isEditing)
                    TextField("Category", text: $category)
                    TextField("Supplier", text: $supplier)
                }
                Section("Stock") {
                    TextField("Current stock", text: $stock)
                        .keyboardType(.numberPad)
                    TextField("Minimum stock", text: $minimum)
                        .keyboardType(.numberPad)
                    TextField("Average daily usage", text: $averageDailyUsage)
                        .keyboardType(.decimalPad)
                }
                Section("Cost") {
                    TextField("Unit cost", text: $unitCost)
                        .keyboardType(.decimalPad)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 12))
                        .foregroundColor(.appDanger)
                }
            }
            .navigationTitle(isEditing ? "Edit Product" : "Add Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Save") { save() }
                    }
                }
            }
            .disabled(isSaving)
            .alert("Product Added", isPresented: $showSavedConfirmation) {
                Button("OK") { dismiss() }
            } message: {
                Text("\(name) has been added to your inventory.")
            }
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSKU = sku.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        guard !trimmedName.isEmpty, !trimmedSKU.isEmpty else {
            errorMessage = "Enter a product name and SKU."
            return
        }
        if !isEditing {
            guard store.product(sku: trimmedSKU) == nil else {
                errorMessage = "A product with this SKU already exists."
                return
            }
        }
        guard let stockValue = Int(stock), let minimumValue = Int(minimum), let unitCostValue = Double(unitCost) else {
            errorMessage = "Enter valid numbers for stock, minimum, and unit cost."
            return
        }

        let product = Product(
            name: trimmedName,
            sku: trimmedSKU,
            stock: stockValue,
            minimum: minimumValue,
            status: stockValue <= minimumValue ? .lowStock : .inStock,
            category: category.trimmingCharacters(in: .whitespacesAndNewlines),
            supplier: supplier.trimmingCharacters(in: .whitespacesAndNewlines),
            unitCost: unitCostValue,
            averageDailyUsage: Double(averageDailyUsage) ?? 0
        )

        isSaving = true
        if isEditing {
            store.updateProduct(product) { result in
                isSaving = false
                switch result {
                case .success:
                    dismiss()
                case .failure(let error):
                    errorMessage = "Couldn't save: \(error.localizedDescription)"
                }
            }
        } else {
            store.addProduct(product) { result in
                isSaving = false
                switch result {
                case .success:
                    showSavedConfirmation = true
                case .failure(let error):
                    errorMessage = "Couldn't save: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    AddProductView().environmentObject(MockDataStore())
}
