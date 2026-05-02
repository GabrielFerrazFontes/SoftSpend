//
//  RegisterView.swift
//  SoftexVamo
//
//  Created by Joao Victor on 30/04/26.
//

import SwiftUI

struct RegisterView: View {
    
    @ObservedObject var authService = AuthService.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var nome: String = ""
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var senha: String = ""
    @State private var confirmarSenha: String = ""
    
    private var isFormValid: Bool {
        !nome.isEmpty &&
        !username.isEmpty &&
        !email.isEmpty &&
        !senha.isEmpty &&
        senha == confirmarSenha &&
        senha.count >= 6
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                // Header
                VStack(spacing: 8) {
                    Text("Criar Conta")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color("textPrimary"))
                    
                    Text("Preencha seus dados para comecar")
                        .font(.system(size: 16))
                        .foregroundStyle(Color("textSecondary"))
                }
                .padding(.top, 20)
                
                // Form
                VStack(spacing: 16) {
                    TextField("Nome completo", text: $nome)
                        .textContentType(.name)
                        .padding()
                        .background(Color("cinza"))
                        .cornerRadius(12)
                    
                    TextField("Nome de usuario", text: $username)
                        .textContentType(.username)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color("cinza"))
                        .cornerRadius(12)
                    
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color("cinza"))
                        .cornerRadius(12)
                    
                    SecureField("Senha (min 6 caracteres)", text: $senha)
                        .textContentType(.newPassword)
                        .padding()
                        .background(Color("cinza"))
                        .cornerRadius(12)
                    
                    SecureField("Confirmar senha", text: $confirmarSenha)
                        .textContentType(.newPassword)
                        .padding()
                        .background(Color("cinza"))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 25)
                
                if !confirmarSenha.isEmpty && senha != confirmarSenha {
                    Text("Senhas nao conferem")
                        .font(.system(size: 14))
                        .foregroundStyle(.red)
                }
                
                if let error = authService.errorMessage {
                    Text(error)
                        .font(.system(size: 14))
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 25)
                }
                
                Spacer()
                
                // Register Button
                Button(action: {
                    Task {
                        await authService.register(nome: nome, username: username, email: email, senha: senha)
                        if authService.isAuthenticated {
                            dismiss()
                        }
                    }
                }) {
                    if authService.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Cadastrar")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [Color("roxoInicial"), Color("roxoFinal")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .padding(.horizontal, 25)
                .disabled(authService.isLoading || !isFormValid)
                .opacity(authService.isLoading || !isFormValid ? 0.6 : 1)
                
                // Cancel Button
                Button(action: {
                    dismiss()
                }) {
                    Text("Cancelar")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color("textSecondary"))
                }
                .padding(.bottom, 20)
            }
            .background(Color("surfaceBackground").ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    RegisterView()
}
