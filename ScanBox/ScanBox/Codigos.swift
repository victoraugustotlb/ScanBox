//
//  Codigos.swift
//  ScanBox
//
//  Created by Victor Augusto Toledo Lúcio Borghi on 19/06/26.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers // Garante o suporte aos formatos de arquivos

struct Codigos: View {
    @Binding var currentScreen: String
    
    // Estados para controlar o seletor de arquivos
    @State private var showFileImporter = false
    @State private var importedText = ""
    
    // Mantendo o padrão de cor amarela do seu app
    let amarelo = Color(red: 1.0, green: 0.8, blue: 0.0)
    
    var body: some View {
        VStack(spacing: 0) {
            
            // --- HEADER (Botão de Voltar) ---
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentScreen = "main"
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Voltar")
                            .font(.headline)
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(amarelo)
                    .cornerRadius(20)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            Spacer()
            
            // --- CONTEÚDO CENTRAL ---
            VStack(spacing: 25) {
                Image(systemName: "square.and.arrow.down.on.square.fill")
                    .font(.system(size: 70))
                    .foregroundColor(amarelo)
                
                VStack(spacing: 8) {
                    Text("Importar Códigos")
                        .font(.title)
                        .bold()
                    
                    Text("Selecione um arquivo de texto (.txt) contendo a lista de códigos.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                    
                    if !importedText.isEmpty {
                        Text("Arquivo lido com sucesso!")
                            .foregroundColor(.green)
                            .bold()
                            .padding(.top, 10)
                    }
                }
            }
            
            Spacer()
            
            // --- BOTÃO DE AÇÃO PRINCIPAL ---
            Button(action: {
                showFileImporter = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "doc.badge.plus")
                        .font(.headline)
                    Text("Selecionar Arquivo")
                        .font(.headline)
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(amarelo)
                .cornerRadius(14)
                .shadow(color: amarelo.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        // --- SELETOR DE ARQUIVOS DO IOS ---
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.plainText],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let fileURLs):
                            // Pega a primeira URL da lista, já que só permitimos selecionar um arquivo
                            guard let fileURL = fileURLs.first else { return }
                            
                            guard fileURL.startAccessingSecurityScopedResource() else { return }
                            
                            defer {
                                fileURL.stopAccessingSecurityScopedResource()
                            }
                            
                            do {
                                let conteudo = try String(contentsOf: fileURL, encoding: .utf8) 
                    self.importedText = conteudo
                    print("Conteúdo do arquivo:\n\(conteudo)")
                    
                    // O próximo passo será pegar essa String 'conteudo' e salvar
                    // na lista do seu aplicativo!
                    
                } catch {
                    print("Erro ao ler o arquivo: \(error.localizedDescription)")
                }
                
            case .failure(let error):
                print("Erro ao selecionar arquivo: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    Codigos(currentScreen: .constant("codigos"))
}
