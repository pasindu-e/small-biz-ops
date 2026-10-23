import SwiftUI

private struct DraftLineItem: Identifiable {
    let id = UUID()
    var title = ""
    var amount = ""
}

struct AddOrderView: View {
    @EnvironmentObject var store: MockDataStore
    @Environment(\.dismiss) private var dismiss

    @State private var customer = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var status: OrderStatus = .pending
    @State private var shipping = ""
    @State private var lineItems: [DraftLineItem] = [DraftLineItem()]
    @State private var errorMessage: String?
    @State private var isSaving = false

    private var itemsTotal: Double {
        lineItems.reduce(0) { $0 + (Double($1.amount) ?? 0) }
    }

    private var shippingValue: Double { Double(shipping) ?? 0 }
    private var grandTotal: Double { itemsTotal + shippingValue }

    var body: some View {
        NavigationStack {
            Form {
                Section("Customer") {
                    TextField("Name", text: $customer)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                }

                Section("Items") {
                    ForEach($lineItems) { $item in
                        HStack {
                            TextField("Item", text: $item.title)
                            TextField("Amount", text: $item.amount)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 90)
                        }
                    }
                    .onDelete { lineItems.remove(atOffsets: $0) }

                    Button {
                        lineItems.append(DraftLineItem())
                    } label: {
                        Label("Add Item", systemImage: "plus.circle")
                    }
                }

                Section("Shipping & Status") {
                    TextField("Shipping cost", text: $shipping)
                        .keyboardType(.decimalPad)
                    Picker("Status", selection: $status) {
                        ForEach(OrderStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                }

                Section {
                    HStack {
                        Text("Total").font(.system(size: 14))
                        Spacer()
                        Text(grandTotal.asUSD()).font(.system(size: 14, weight: .bold))
                    }
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 12))
                        .foregroundColor(.appDanger)
                }
            }
            .navigationTitle("New Order")
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
        }
    }

    private func save() {
        let trimmedCustomer = customer.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedCustomer.isEmpty else {
            errorMessage = "Enter a customer name."
            return
        }

        let validItems = lineItems.compactMap { item -> OrderLineItem? in
            let title = item.title.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !title.isEmpty, let amount = Double(item.amount) else { return nil }
            return OrderLineItem(title: title, amount: amount)
        }
        guard !validItems.isEmpty else {
            errorMessage = "Add at least one item with a valid amount."
            return
        }

        let placedAt = Self.dateFormatter.string(from: Date())
        let order = Order(
            id: generateOrderID(),
            customer: trimmedCustomer,
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            phone: phone.trimmingCharacters(in: .whitespacesAndNewlines),
            total: validItems.reduce(0) { $0 + $1.amount } + shippingValue,
            status: status,
            time: timeLabel(for: status),
            itemsLabel: validItems.count == 1 ? "1 item" : "\(validItems.count) items",
            lineItems: validItems,
            shipping: shippingValue,
            timeline: timeline(for: status, placedAt: placedAt)
        )

        isSaving = true
        store.addOrder(order) { result in
            isSaving = false
            switch result {
            case .success:
                dismiss()
            case .failure(let error):
                errorMessage = "Couldn't save: \(error.localizedDescription)"
            }
        }
    }

    private func generateOrderID() -> String {
        var candidate: String
        repeat {
            candidate = "#ORD-\(Int.random(in: 1000...9999))"
        } while store.order(id: candidate) != nil
        return candidate
    }

    private func timeLabel(for status: OrderStatus) -> String {
        switch status {
        case .pending: return "Just placed"
        case .processing: return "Processing"
        case .delayed: return "Delayed"
        }
    }

    private func timeline(for status: OrderStatus, placedAt: String) -> [OrderStatusStep] {
        switch status {
        case .pending:
            return [
                OrderStatusStep(title: "Order placed", subtitle: placedAt, complete: true),
                OrderStatusStep(title: "Processing", subtitle: "Pending", complete: false),
                OrderStatusStep(title: "Shipped", subtitle: "Pending", complete: false),
                OrderStatusStep(title: "Delivered", subtitle: "Pending", complete: false),
            ]
        case .processing:
            return [
                OrderStatusStep(title: "Order placed", subtitle: placedAt, complete: true),
                OrderStatusStep(title: "Processing", subtitle: placedAt, complete: true),
                OrderStatusStep(title: "Shipped", subtitle: "Pending", complete: false),
                OrderStatusStep(title: "Delivered", subtitle: "Pending", complete: false),
            ]
        case .delayed:
            return [
                OrderStatusStep(title: "Order placed", subtitle: placedAt, complete: true),
                OrderStatusStep(title: "Processing", subtitle: placedAt, complete: true),
                OrderStatusStep(title: "Shipped", subtitle: placedAt, complete: true),
                OrderStatusStep(title: "Delivery update", subtitle: "Overdue", complete: false),
            ]
        }
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d · h:mm a"
        return formatter
    }()
}

#Preview {
    AddOrderView().environmentObject(MockDataStore())
}
