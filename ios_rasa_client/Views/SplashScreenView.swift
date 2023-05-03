//
//  SplashScreenView.swift
//  ios_rasa_client
//
//  Created by ayman moustafa on 03/05/2023.
//

import SwiftUI

struct SplashScreenView: View {
    @State var isActive: Bool = false
    
    var body: some View {
        
        ZStack {
            if self.isActive {
                ContentView()
            } else {
                VStack {
                                Image("aRasa")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 400, height: 400)
//                    Text("aRasa")
//                        .font(.largeTitle)
//                        .fontWeight(.bold)
//                        .foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.blue)
            }
        }.onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    self.isActive = true
                }
            }
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
