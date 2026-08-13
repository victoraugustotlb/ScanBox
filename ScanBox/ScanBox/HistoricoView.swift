import SwiftUI

struct HistoricoView: View {
    @Binding var currentScreen: String
    @Binding var historico: [EntregaEfetuada]
    
    let amarelo = Color(red: 1.0, green: 0.8, blue: 0.0)
    
    var body: some View {
        VStack(spacing: 0) {
            // Header superior idêntico ao do app
            ZStack {
                Text("Histórico")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(amarelo)
                    .frame(maxWidth: .infinity)
                
                HStack {
                    Button(action: {
                        currentScreen = "main" // Volta para o scanner
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(width: 40, height: 40)
                            .background(amarelo)
                            .cornerRadius(20)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .padding(.top, 20)
            .padding(.bottom, 15)
            .background(Color.white)
            
            // Corpo com a lista de entregas
            if historico.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "shippingbox.and.arrow.slanted.box")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.6))
                    Text("Nenhuma entrega realizada ainda.")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(historico) { entrega in
                            HStack(spacing: 12) {
                                // Se houver imagem de log tirada na hora, renderiza o thumbnail
                                if let foto = entrega.imagemLog {
                                    Image(uiImage: foto)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 70, height: 70)
                                        .cornerRadius(8)
                                        .clipped()
                                } else {
                                    // Fallback caso não tenha foto
                                    ZStack {
                                        Color.gray.opacity(0.2)
                                        Image(systemName: "photo")
                                            .foregroundColor(.gray)
                                    }
                                    .frame(width: 70, height: 70)
                                    .cornerRadius(8)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(entrega.codigo)
                                        .font(.subheadline)
                                        .bold()
                                        .lineLimit(1)
                                        .foregroundColor(.primary)
                                    
                                    HStack(spacing: 4) {
                                        Image(systemName: "mappin.and.ellipse")
                                            .font(.caption)
                                        Text(entrega.endereco)
                                            .font(.caption)
                                            .lineLimit(1)
                                    }
                                    .foregroundColor(.gray)
                                    
                                    HStack(spacing: 4) {
                                        Image(systemName: "calendar.badge.clock")
                                            .font(.caption)
                                        Text(entrega.dataHora)
                                            .font(.caption)
                                    }
                                    .foregroundColor(.blue)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title3)
                            }
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                    }
                    .padding(20)
                }
                .background(Color(.systemGroupedBackground))
            }
        }
        .background(Color.white.ignoresSafeArea())
    }
}

#Preview {
    HistoricoView(
        currentScreen: .constant("historico"),
        historico: .constant([
            EntregaEfetuada(codigo: "PACOTE-HACKATHON-001", endereco: "PUC-SP - Campus Consolação", dataHora: "23/06/2026 às 15:30", imagemLog: nil)
        ])
    )
}
