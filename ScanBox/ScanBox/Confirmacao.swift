import SwiftUI

struct Confirmacao: View {
    @Binding var currentScreen: String
    @Environment(\.dismiss) var dismiss
    
    // Estados para controlar o início das animações
    @State private var scaleCheck: CGFloat = 0.5
    @State private var opacityCheck: Double = 0.0
    @State private var textOffset: CGFloat = 20
    
    var body: some View {
        ZStack {
            // Fundo Verde Vibrante de Sucesso
            Color(red: 0.18, green: 0.67, blue: 0.38)
                .ignoresSafeArea()
            
            VStack(spacing: 25) {
                Spacer()
                
                // Ícone de Check Animado
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 100, height: 100)
                        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 45, weight: .bold))
                        .foregroundColor(Color(red: 0.18, green: 0.67, blue: 0.38))
                }
                .scaleEffect(scaleCheck)
                .opacity(opacityCheck)
                
                // Textos com efeito de subida suave
                VStack(spacing: 8) {
                    Text("Entrega Concluída!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("O código e a foto de log foram salvos localmente com sucesso.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
                .offset(y: textOffset)
                .opacity(opacityCheck)
                
                Spacer()
                
                // Botão para voltar para a tela inicial do scanner
                Button(action: {
                    // Fecha o fluxo e reseta a MainView
                    dismiss()
                }) {
                    Text("Voltar para o Início")
                        .font(.headline)
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            // Dispara as animações assim que a tela abre
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0).delay(0.1)) {
                scaleCheck = 1.0
                opacityCheck = 1.0
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.2)) {
                textOffset = 0
            }
        }
    }
}

#Preview {
    Confirmacao(currentScreen: .constant("main"))
}
