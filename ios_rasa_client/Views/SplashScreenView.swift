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
                    //            Image("logo")
                    //                .resizable()
                    //                .aspectRatio(contentMode: .fit)
                    //                .frame(width: 200, height: 200)
                    Text("aRasa")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
            }
        }.onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
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
