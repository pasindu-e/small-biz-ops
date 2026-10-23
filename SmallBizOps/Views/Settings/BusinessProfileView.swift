import SwiftUI

struct BusinessProfileView: View {
    @EnvironmentObject var store: MockDataStore
    @Environment(\.dismiss) private var dismiss

    @State private var ownerName: String
    @State private var businessName: String
    @State private var role: String
    @State private var errorMessage: String?
    @State private var isSaving = false

    init() {
        _ownerName = State(initialValue: "")
        _businessName = State(initialValue: "")
        _role = State(initialValue: "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    TextField("Owner name", text: $ownerName)
                    TextField("Role", text: $role)
                    TextField("Business name", text: $businessName)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 12))
                        .foregroundColor(.appDanger)
                }
            }
            .navigationTitle("Business Profile")
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
            .onAppear {
                ownerName = store.business.ownerName
                businessName = store.business.businessName
                role = store.business.role
            }
        }
    }

    private func save() {
        let trimmedOwner = ownerName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBusiness = businessName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedOwner.isEmpty, !trimmedBusiness.isEmpty else {
            errorMessage = "Enter your name and business name."
            return
        }

        let business = Business(
            ownerName: trimmedOwner,
            businessName: trimmedBusiness,
            role: role.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        isSaving = true
        store.updateBusiness(business) { result in
            isSaving = false
            switch result {
            case .success:
                dismiss()
            case .failure(let error):
                errorMessage = "Couldn't save: \(error.localizedDescription)"
            }
        }
    }
}

#Preview {
    BusinessProfileView().environmentObject(MockDataStore())
}
