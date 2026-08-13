//
//  ContentView.swift
//  ScanBox
//
//  Created by Victor Augusto Toledo Lúcio Borghi on 10/06/26.
//

import SwiftUI
import CoreLocation // Framework para o GPS
import Combine      // Framework para gerenciar as atualizações de estado do GPS

// --- ESTRUTURA DOS PACOTES COM DADOS GEOGRÁFICOS ---
struct Pacote {
    let codigo: String
    let enderecoTexto: String
    let latitude: Double
    let longitude: Double
}

// --- MODELO PARA CADA ITEM DO HISTÓRICO DE ENTREGAS ---
struct EntregaEfetuada: Identifiable {
    let id = UUID()
    let codigo: String
    let endereco: String
    let dataHora: String
    let imagemLog: UIImage? // Armazena a foto tirada pelo entregador na hora
}

// --- GERENCIADOR DE GPS DO APARELHO ---
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var lastLocation: CLLocation?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization() // Pede permissão de GPS ao abrir o app
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
    }
}

struct ContentView: View {
    @State private var currentScreen: String = "main"
    // Banco de dados em memória que guarda o histórico em tempo real
    @State private var historicoDeEntregas: [EntregaEfetuada] = []
    
    let amarelo = Color(red: 1.0, green: 0.8, blue: 0.0)
    
    var body: some View {
        if currentScreen == "main" {
            MainView(currentScreen: $currentScreen, historico: $historicoDeEntregas)
        } else if currentScreen == "codigos" {
            Codigos(currentScreen: $currentScreen)
        } else if currentScreen == "historico" {
            HistoricoView(currentScreen: $currentScreen, historico: $historicoDeEntregas)
        }
    }
}

struct MainView: View {
    @State private var scannedCode: String?
    @Binding var currentScreen: String
    @Binding var historico: [EntregaEfetuada] // Comunicação direta com a ContentView
    
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showInvalidMessage = false
    @State private var showMenu = false
    
    // Controles do fluxo de digitação manual
    @State private var hasAttempted = false
    @State private var showManualInput = false
    
    // Alertas e gatilhos de Localização / Sucesso
    @State private var showLocationError = false
    @State private var locationErrorMessage = ""
    @State private var showSucessoScreen = false
    
    // Instancia o leitor de GPS do iPhone
    @StateObject private var locationManager = LocationManager()
    
    // Todos os códigos configurados com as coordenadas da PUC-SP - Campus Consolação
    let pacotesValidos = [
        Pacote(
            codigo: "https://pt.wikipedia.org",
            enderecoTexto: "PUC-SP - Campus Consolação, São Paulo - SP",
            latitude: -23.550519,
            longitude: -46.651475
        ),
        Pacote(
            codigo: "https://pt.wikipedia.org/wiki/Código_QR",
            enderecoTexto: "PUC-SP - Campus Consolação, São Paulo - SP",
            latitude: -23.550519,
            longitude: -46.651475
        ),
        Pacote(
            codigo: "https://pt.wikipedia.org/wiki/C%C3%B3digo_QR",
            enderecoTexto: "PUC-SP - Campus Consolação, São Paulo - SP",
            latitude: -23.550519,
            longitude: -46.651475
        ),
        Pacote(
            codigo: "PACOTE-HACKATHON-001",
            enderecoTexto: "PUC-SP - Campus Consolação, São Paulo - SP",
            latitude: -23.550519,
            longitude: -46.651475
        ),
        Pacote(
            codigo: "2567719003",
            enderecoTexto: "PUC-SP - Campus Consolação, São Paulo - SP",
            latitude: -23.550519,
            longitude: -46.651475
        ),
        Pacote(
            codigo: "2589893735",
            enderecoTexto: "Aeroporto de Guarulhos - Terminal 3, Guarulhos - SP",
            latitude: -23.425767,
            longitude: -46.482255
        )
    ]
    
    let amarelo = Color(red: 1.0, green: 0.8, blue: 0.0)
    
    var body: some View {
        ZStack {
            // --- FLUXO DE CONFIRMAÇÃO COM CÂMERA ATIVA ---
            if showCamera {
                if capturedImage != nil {
                    ZStack {
                        Color.black
                            .ignoresSafeArea()
                        
                        VStack {
                            HStack {
                                Button(action: {
                                    showCamera = false
                                    scannedCode = nil
                                    capturedImage = nil
                                }) {
                                    HStack {
                                        Image(systemName: "chevron.left")
                                        Text("Voltar")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .padding(12)
                                    .background(amarelo)
                                    .cornerRadius(10)
                                }
                                Spacer()
                            }
                            .padding(20)
                            
                            Spacer()
                            
                            Image(uiImage: capturedImage!)
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(10)
                                .padding(20)
                            
                            Spacer()
                            
                            HStack(spacing: 12) {
                                Button(action: {
                                    capturedImage = nil
                                    showImagePicker = true
                                }) {
                                    Text("Tirar outra")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(amarelo)
                                        .cornerRadius(10)
                                }
                                
                                Button(action: {
                                    validarLocalizacaoEFinalizar()
                                }) {
                                    Text("Confirmar Entrega")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.green)
                                        .cornerRadius(10)
                                }
                            }
                            .padding(20)
                        }
                    }
                } else {
                    ImagePickerView(image: $capturedImage, isPresented: $showImagePicker)
                        .ignoresSafeArea()
                }
            } else {
                // --- TELA DO SCANNER EM TEMPO REAL ---
                ScannerView(scannedCode: $scannedCode)
                    .ignoresSafeArea()
                    .onChange(of: scannedCode) { newValue in
                        if let value = newValue {
                            let isValid = isCodeValid(value)
                            showInvalidMessage = !isValid
                            if !isValid {
                                hasAttempted = true
                            }
                        }
                    }
                
                VStack(spacing: 0) {
                    ZStack {
                        Text("ScanBox")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(amarelo)
                            .frame(maxWidth: .infinity)
                        
                        HStack {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showMenu.toggle()
                                }
                            }) {
                                Image(systemName: "line.3.horizontal")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.black)
                                    .frame(width: 50, height: 50)
                                    .background(amarelo)
                                    .cornerRadius(25)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    Text("Validar entrega")
                        .font(.headline)
                        .foregroundColor(.yellow)
                        .padding()
                    
                    // Mira do Scanner
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            scannedCode == nil ? amarelo : isCodeValid(scannedCode ?? "") ? Color.green : Color.red,
                            lineWidth: 4
                        )
                        .frame(width: 250, height: 250)
                        .background(Color.black.opacity(0.1))
                    
                    if showInvalidMessage {
                        VStack(spacing: 12) {
                            Text("❌ Código Inválido")
                                .font(.headline)
                                .foregroundColor(.red)
                            
                            Button(action: {
                                showManualInput = true
                            }) {
                                lightManualButton
                            }
                        }
                        .padding()
                    } else if hasAttempted && scannedCode == nil {
                        Button(action: { showManualInput = true }) {
                            Text("Digitar Manualmente")
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(.blue)
                                .padding(.top, 10)
                        }
                    }
                    
                    Spacer()
                    
                    // Botões Inferiores (Confirmar / Limpar)
                    HStack(spacing: 12) {
                        Button(action: {
                            if let code = scannedCode {
                                if isCodeValid(code) {
                                    capturedImage = nil
                                    showImagePicker = true
                                    showCamera = true
                                    showInvalidMessage = false
                                } else {
                                    showInvalidMessage = true
                                    hasAttempted = true
                                }
                            }
                        }) {
                            Text(scannedCode == nil ? "Aguardando..." : "Confirmar")
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(scannedCode == nil ? Color.gray : isCodeValid(scannedCode ?? "") ? amarelo : Color.gray)
                                .cornerRadius(10)
                        }
                        .disabled(scannedCode == nil || !isCodeValid(scannedCode ?? ""))
                        
                        Button(action: {
                            scannedCode = nil
                            showInvalidMessage = false
                        }) {
                            Text("Limpar")
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(amarelo)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
                .ignoresSafeArea(edges: .bottom)
            }
            
            // Sombra do menu lateral
            if showMenu {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showMenu = false
                        }
                    }
            }
            
            // --- MENU LATERAL ---
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 20) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) { showMenu = false }
                    }) {
                        HStack {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .semibold))
                                .padding(.horizontal, 18)
                            Text("Fechar")
                                .padding(.horizontal, -15)
                        }
                        .foregroundColor(.black)
                        .padding(.top, 90)
                    }
                    
                    Divider()
                    
                    // Redireciona para a tela de histórico
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentScreen = "historico"
                            showMenu = false
                        }
                    }) {
                        HStack { Image(systemName: "clock.fill"); Text("Histórico") }.foregroundColor(.black).frame(maxWidth: .infinity, alignment: .leading).padding()
                    }
                    
                    Button(action: { withAnimation { showMenu = false } }) {
                        HStack { Image(systemName: "gear"); Text("Configurações") }.foregroundColor(.black).frame(maxWidth: .infinity, alignment: .leading).padding()
                    }
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentScreen = "codigos"
                            showMenu = false
                        }
                    }) {
                        HStack { Image(systemName: "cloud"); Text("Importar códigos") }.foregroundColor(.black).frame(maxWidth: .infinity, alignment: .leading).padding()
                    }
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showMenu = false
                        }
                    }) {
                        HStack { Image(systemName: "cloud.fill"); Text("Lote de códigos") }.foregroundColor(.black).frame(maxWidth: .infinity, alignment: .leading).padding()
                    }
                    
                    Button(action: { withAnimation { showMenu = false } }) {
                        HStack { Image(systemName: "info.circle"); Text("Sobre") }.foregroundColor(.black).frame(maxWidth: .infinity, alignment: .leading).padding()
                    }
                    Spacer()
                }
                .frame(maxWidth: 280)
                .background(amarelo)
                .ignoresSafeArea()
                
                Spacer()
            }
            .offset(x: showMenu ? 0 : -320)
            .zIndex(1)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(image: $capturedImage, isPresented: $showImagePicker)
        }
        // CHAMADA DA TELA DE DIGITAÇÃO MANUAL
        .sheet(isPresented: $showManualInput) {
            DigitacaoManualView(
                validCodes: pacotesValidos.map { $0.codigo },
                amarelo: amarelo,
                onSuccess: { codeString in
                    showManualInput = false
                    self.scannedCode = codeString
                    self.capturedImage = nil
                    self.showImagePicker = true
                    self.showCamera = true
                }
            )
        }
        // CHAMADA DA TELA DE SUCESSO COBRINDO 100% DA TELA DO IPHONE
        .fullScreenCover(isPresented: $showSucessoScreen) {
            Confirmacao(currentScreen: $currentScreen)
        }
        // POP-UP DE ALERTA DE FRAUDE DE LOCALIZAÇÃO
        .alert(isPresented: $showLocationError) {
            Alert(
                title: Text("Entrega Bloqueada"),
                message: Text(locationErrorMessage),
                dismissButton: .default(Text("Entendido"))
            )
        }
    }
    
    var lightManualButton: some View {
        HStack {
            Image(systemName: "keyboard")
            Text("Digitar Manualmente")
        }
        .font(.subheadline)
        .bold()
        .foregroundColor(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.blue)
        .cornerRadius(8)
    }
    
    // --- FUNÇÃO DE VALIDAÇÃO DE GPS ---
    func validarLocalizacaoEFinalizar() {
        guard let codigoAtual = scannedCode else { return }
        
        guard let pacote = pacotesValidos.first(where: { entry in
            let normalizedEntry = entry.codigo.removingPercentEncoding ?? entry.codigo
            let normalizedCode = codigoAtual.removingPercentEncoding ?? codigoAtual
            return normalizedEntry == normalizedCode
        }) else { return }
        
        guard let localizacaoAtual = locationManager.lastLocation else {
            locationErrorMessage = "Não foi possível obter o seu GPS atual. Verifique se a localização do iPhone está ativa."
            showLocationError = true
            return
        }
        
        let localizacaoDestino = CLLocation(latitude: pacote.latitude, longitude: pacote.longitude)
        let distanciaEmMetros = localizacaoAtual.distance(from: localizacaoDestino)
        
        let raioMaximoPermitido: Double = 550.0 // Raio de tolerância (150 metros)
        
        if distanciaEmMetros <= raioMaximoPermitido {
            print("Entrega realizada a \(Int(distanciaEmMetros))m do destino.")
            
            // --- GERA REGISTRO DO HISTÓRICO COM DATA E HORA ---
            let formatador = DateFormatter()
            formatador.dateFormat = "dd/MM/yyyy 'às' HH:mm"
            let dataFormatada = formatador.string(from: Date())
            
            let novaEntrega = EntregaEfetuada(
                codigo: codigoAtual,
                endereco: pacote.enderecoTexto,
                dataHora: dataFormatada,
                imagemLog: capturedImage
            )
            historico.append(novaEntrega) // Joga na lista compartilhada
            // --------------------------------------------------
            
            showCamera = false
            scannedCode = nil
            capturedImage = nil
            hasAttempted = false
            
            showSucessoScreen = true // Abre a tela verde animada
        } else {
            // BLOQUEIO ANTIFRAUDE: Fora do raio da PUC-SP
            let distFormatada = distanciaEmMetros > 1000 ? String(format: "%.1f km", distanciaEmMetros / 1000) : "\(Int(distanciaEmMetros)) metros"
            locationErrorMessage = "Você está a \(distFormatada) de distância do local correto de entrega (\(pacote.enderecoTexto)). Vá até lá para concluir."
            showLocationError = true
        }
    }
    
    func isCodeValid(_ code: String) -> Bool {
        let normalizedCode = code.removingPercentEncoding ?? code
        return pacotesValidos.contains { entry in
            let normalizedEntry = entry.codigo.removingPercentEncoding ?? entry.codigo
            return normalizedEntry == normalizedCode
        }
    }
}

// --- CLASSE DE INTERFACE COM A CÂMERA DO IOS ---
struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePickerView
        init(_ parent: ImagePickerView) { self.parent = parent }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage { parent.image = image }
            parent.isPresented = false
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { parent.isPresented = false }
    }
}

#Preview {
    ContentView()
}
