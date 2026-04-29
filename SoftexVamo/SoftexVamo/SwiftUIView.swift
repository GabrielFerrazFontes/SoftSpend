//
//  SwiftUIView.swift
//  SoftexVamo
//
//  Created by Joao Victor on 24/04/26.
//

import SwiftUI
internal import System

struct SwiftUIView: View {
    var body: some View {
        AsyncImage(url: URL("https://s2-techtudo.glbimg.com/RXKwphwEN6dNXRX0z5kpmFEXc_I=/0x0:1284x720/888x0/smart/filters:strip_icc()/i.s3.glbimg.com/v1/AUTH_08fbf48bc0524877943fe86e43087e7a/internal_photos/bs/2023/T/b/ROz6eEQq6nGnHDnEYRNw/invincible-melhor-serie-2021-q4vz.jpg")) { imagem in
            imagem
                .resizable()
            
        } placeholder: {
            ProgressView()
        }
        }
    }


#Preview {
    SwiftUIView()
}
