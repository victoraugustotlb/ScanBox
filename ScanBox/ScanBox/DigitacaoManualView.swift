import SwiftUI

struct DigitacaoManualView: View {
    let validCodes: [String]
    let amarelo: Color
    var onSuccess: (String) -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var inputCode = ""
    @State private var showError = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Tag Avariada / Danificada")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.top)
                
                Text("Insira o código manualmente abaixo para validação.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                TextField("Digite o código aqui...", text: $inputCode)
                    .autocapitalization(.allCharacters)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(showError ? Color.red : Color.clear, lineWidth: 2)
                    )
                    .padding(.horizontal)
                
                if showError {
                    Text("❌ Este código não foi encontrado na base offline.")
                        .font(.caption)
                        .foregroundColor(.red)
                        .bold()
                }
                
                Spacer()
                
                Button(action: {
                    if validCodes.contains(inputCode.trimmingCharacters(in: .whitespacesAndNewlines)) {
                        showError = false
                        onSuccess(inputCode)
                    } else {
                        showError = true
                    }
                }) {
                    Text("Validar & Tirar Foto de Log")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(inputCode.isEmpty ? Color.gray.opacity(0.4) : amarelo)
                        .cornerRadius(10)
                }
                .disabled(inputCode.isEmpty)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .navigationTitle("Digitação Manual")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // ALTERADO: Usando o comportamento nativo de cancelamento do iOS
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        dismiss() // Ação lógica fica aqui dentro
                    }) {
                        Text("Cancelar") // O visual do botão fica aqui
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.black)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(amarelo) // Modificador visual no lugar certo!
                            .cornerRadius(8)
                    }

                
                }
            }
        }
    }
}

#Preview {
    DigitacaoManualView(
        validCodes: ["CODIGO1", "PACOTE-HACKATHON-001"],
        amarelo: Color(red: 1.0, green: 0.8, blue: 0.0),
        onSuccess: { code in
            print("Preview: código validado -> \(code)")
        }
    )
}
